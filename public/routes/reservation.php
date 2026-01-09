<?php

// ============================================================
// PARTIE 1 : PAGE DE RÉSERVATION (FORMULAIRE)
// ============================================================
Flight::route('GET /trajet/reserver/@id', function($id){
    // Vérification de connexion
    if(!isset($_SESSION['user'])) {
        $_SESSION['flash_error'] = "Veuillez vous connecter pour réserver un trajet.";
        Flight::redirect('/connexion');
        return;
    }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // 1. Récupération des détails du trajet, conducteur et véhicule
    $sql = "SELECT t.*, u.prenom, u.nom, u.photo_profil, v.marque, v.modele, v.nb_places_totales
            FROM TRAJETS t
            JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
            JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
            WHERE t.id_trajet = :id";
    
    $stmt = $db->prepare($sql);
    $stmt->execute([':id' => $id]);
    $trajet = $stmt->fetch(PDO::FETCH_ASSOC);

    // Sécurités
    if (!$trajet) {
        $_SESSION['flash_error'] = "Ce trajet n'existe pas.";
        Flight::redirect('/recherche');
        return;
    }

    if ($trajet['id_conducteur'] == $userId) {
        $_SESSION['flash_error'] = "Vous ne pouvez pas réserver votre propre trajet !";
        Flight::redirect('/recherche');
        return;
    }

    // 2. Calcul des places déjà prises
    $sqlPlaces = "SELECT COALESCE(SUM(nb_places_reservees), 0) as places_prises
                  FROM RESERVATIONS
                  WHERE id_trajet = :id AND statut_code = 'V'";
    
    $stmtPlaces = $db->prepare($sqlPlaces);
    $stmtPlaces->execute([':id' => $id]);
    $placesData = $stmtPlaces->fetch(PDO::FETCH_ASSOC);
    
    $trajet['places_prises'] = $placesData['places_prises'];
    $trajet['places_disponibles'] = $trajet['places_proposees'] - $trajet['places_prises'];

    // 3. Vérification si l'utilisateur a déjà réservé ce trajet
    $sqlCheck = "SELECT * FROM RESERVATIONS 
                 WHERE id_trajet = :id 
                 AND id_passager = :user 
                 AND statut_code = 'V'";
                 
    $stmtCheck = $db->prepare($sqlCheck);
    $stmtCheck->execute([':id' => $id, ':user' => $userId]);
    $dejaReserve = $stmtCheck->fetch(PDO::FETCH_ASSOC);

    if ($dejaReserve) {
        $_SESSION['flash_error'] = "Vous avez déjà réservé ce trajet !";
        Flight::redirect('/mes_reservations');
        return;
    }

    // Formatage des dates pour l'affichage
    $dateObj = new DateTime($trajet['date_heure_depart']);
    $trajet['date_fmt'] = $dateObj->format('d/m/Y');
    $trajet['heure_fmt'] = $dateObj->format('H:i');

    Flight::render('reservation/reservation.tpl', [
        'titre' => 'Réserver un trajet',
        'trajet' => $trajet
    ]);
});

// ============================================================
// PARTIE 2 : TRAITEMENT DE LA RÉSERVATION (POST)
// ============================================================
Flight::route('POST /trajet/reserver/@id', function($id){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];
    
    // Récupération du nombre de places souhaitées
    $nbPlacesDemandees = isset(Flight::request()->data->nb_places) ? (int)Flight::request()->data->nb_places : 1;
    if ($nbPlacesDemandees < 1) $nbPlacesDemandees = 1;

    try {
        $db->beginTransaction(); // Début de transaction (pour éviter les conflits de places)

        // A. Vérification de l'existence du trajet
        $stmt = $db->prepare("SELECT * FROM TRAJETS WHERE id_trajet = :id");
        $stmt->execute([':id' => $id]);
        $trajet = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$trajet) throw new Exception("Trajet introuvable.");

        // B. Recalcul temps réel des places disponibles (Crucial pour éviter le surbooking)
        $stmtPlaces = $db->prepare("
            SELECT COALESCE(SUM(nb_places_reservees), 0) as places_prises
            FROM RESERVATIONS
            WHERE id_trajet = :id AND statut_code = 'V'
        ");
        $stmtPlaces->execute([':id' => $id]);
        $placesData = $stmtPlaces->fetch(PDO::FETCH_ASSOC);

        $placesDisponibles = $trajet['places_proposees'] - $placesData['places_prises'];

        if ($placesDisponibles < $nbPlacesDemandees) {
            throw new Exception("Pas assez de places disponibles !");
        }

        // C. Insertion de la réservation
        $stmtReserve = $db->prepare("
            INSERT INTO RESERVATIONS 
            (id_trajet, id_passager, nb_places_reservees, statut_code, date_reservation)
            VALUES (:trajet, :passager, :nb, 'V', NOW())
        ");
        $stmtReserve->execute([
            ':trajet' => $id,
            ':passager' => $userId,
            ':nb' => $nbPlacesDemandees
        ]);

        // D. Mise à jour du statut du trajet si COMPLET
        if (($placesDisponibles - $nbPlacesDemandees) == 0) {
            $stmtUpdate = $db->prepare("UPDATE TRAJETS SET statut_flag = 'C' WHERE id_trajet = :id");
            $stmtUpdate->execute([':id' => $id]);
        }

        // E. Envoi d'un message système dans le chat ("X a rejoint le trajet")
        $contenuMsg = "::sys_join::" . $nbPlacesDemandees;
        $stmtMsg = $db->prepare("
            INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi)
            VALUES (:tid, :uid, :contenu, NOW())
        ");
        $stmtMsg->execute([
            ':tid' => $id, 
            ':uid' => $userId, 
            ':contenu' => $contenuMsg
        ]);

        $db->commit(); // Validation
        $_SESSION['flash_success'] = "Réservation confirmée pour " . $nbPlacesDemandees . " place(s) !";
        Flight::redirect('/mes_reservations');

    } catch (Exception $e) {
        $db->rollBack();
        $_SESSION['flash_error'] = $e->getMessage();
        Flight::redirect('/trajet/reserver/' . $id);
    }
});

// ============================================================
// PARTIE 3 : LISTE "MES RÉSERVATIONS" (TRIÉE)
// ============================================================
Flight::route('GET /mes_reservations', function(){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');
    
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // 1. Récupération des réservations (Uniquement les validées 'V')
    // On ne fait pas de ORDER BY SQL ici car le tri est complexe et sera fait en PHP
    $sql = "SELECT r.*, t.*, 
            u.prenom as conducteur_prenom, u.nom as conducteur_nom, u.photo_profil as conducteur_photo,
            v.marque, v.modele, v.nb_places_totales
            FROM RESERVATIONS r
            JOIN TRAJETS t ON r.id_trajet = t.id_trajet
            JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
            JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
            WHERE r.id_passager = :user
            AND r.statut_code = 'V'";
    
    $stmt = $db->prepare($sql);
    $stmt->execute([':user' => $userId]);
    $reservations = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $participants = [];
    $now = new DateTime();

    // 2. Traitement des données (Calcul des statuts visuels)
    foreach ($reservations as &$r) {
        $participants[$r['id_trajet']] = [];

        $dateObj = new DateTime($r['date_heure_depart']);
        $r['date_fmt'] = $dateObj->format('d/m/Y');
        $r['heure_fmt'] = $dateObj->format('H\hi');

        // --- Détermination du statut (À venir / En cours / Terminé) ---
        // Calcul de la date de fin en utilisant duree_estimee de la base de données (format TIME: HH:MM:SS)
        $dateDebut = clone $dateObj; // Copie pour ne pas modifier l'original
        $dateFin = clone $dateObj; // Copie pour calculer la date de fin
        
        // Parse de duree_estimee (format TIME: HH:MM:SS)
        if (isset($r['duree_estimee']) && !empty($r['duree_estimee'])) {
            $dureeParts = explode(':', $r['duree_estimee']);
            $heures = isset($dureeParts[0]) ? (int)$dureeParts[0] : 0;
            $minutes = isset($dureeParts[1]) ? (int)$dureeParts[1] : 0;
            $dateFin->add(new DateInterval('PT' . $heures . 'H' . $minutes . 'M'));
        } else {
            // Fallback : Si pas de durée, on considère que le trajet dure 1h par défaut
            $dateFin->modify('+1 hour');
        }

        // Détermination du statut basé sur la date actuelle, date de départ et date de fin
        if ($dateDebut > $now) {
            // Le trajet n'a pas encore commencé
            $r['statut_visuel'] = 'avenir';
            $r['statut_libelle'] = 'À venir';
            $r['statut_couleur'] = 'primary';
        } elseif ($now >= $dateDebut && $now <= $dateFin) {
            // Le trajet est en cours (entre le début et la fin calculée avec duree_estimee)
            $r['statut_visuel'] = 'encours';
            $r['statut_libelle'] = 'En cours';
            $r['statut_couleur'] = 'success';
            $interval = $now->diff($dateFin);
            $r['temps_restant'] = $interval->format('%Hh %Im');
        } else {
            // Le trajet est terminé (après la date de fin calculée avec duree_estimee)
            $r['statut_visuel'] = 'termine';
            $r['statut_libelle'] = 'Terminé';
            $r['statut_couleur'] = 'secondary';
        }

        // --- Récupération de la liste des participants pour l'affichage ---
        $participants[$r['id_trajet']][] = [
            'id'=>$r['id_conducteur'],
            'nom'=>$r['conducteur_prenom'].' '.$r['conducteur_nom'],
            'role'=>'Conducteur'
        ];

        // On récupère les autres passagers du même trajet
        $ps = $db->prepare("SELECT u.id_utilisateur, u.prenom, u.nom FROM RESERVATIONS r JOIN UTILISATEURS u ON r.id_passager = u.id_utilisateur WHERE r.id_trajet = :t AND r.statut_code='V' AND u.id_utilisateur != :me");
        $ps->execute([':t'=>$r['id_trajet'], ':me'=>$userId]);

        foreach($ps->fetchAll(PDO::FETCH_ASSOC) as $p){
            $participants[$r['id_trajet']][] = [
                'id'=>$p['id_utilisateur'],
                'nom'=>$p['prenom'].' '.$p['nom'],
                'role'=>'Passager'
            ];
        }
    }

    // 3. LOGIQUE DE TRI INTELLIGENT
    usort($reservations, function($a, $b) {
        // A. Priorité par catégorie (En cours > À venir > Terminé)
        $order = ['encours' => 1, 'avenir' => 2, 'termine' => 3, 'annule' => 4];
        
        $weightA = $order[$a['statut_visuel']] ?? 99;
        $weightB = $order[$b['statut_visuel']] ?? 99;

        if ($weightA !== $weightB) {
            return $weightA - $weightB;
        }

        // B. Tri par date selon la catégorie
        $timeA = strtotime($a['date_heure_depart']);
        $timeB = strtotime($b['date_heure_depart']);

        if ($a['statut_visuel'] === 'avenir' || $a['statut_visuel'] === 'encours') {
            // Pour le futur : Ordre chronologique (Le plus proche d'abord)
            return $timeA - $timeB;
        } else {
            // Pour le passé : Ordre anté-chronologique (Le plus récent d'abord)
            return $timeB - $timeA;
        }
    });

    Flight::render('reservation/mes_reservations.tpl', [
        'titre'=>'Mes réservations',
        'reservations'=>$reservations,
        'participants'=>$participants
    ]);
});


// ============================================================
// PARTIE 4 : SIGNALEMENT (API)
// ============================================================
Flight::route('POST /api/signalement/nouveau', function() {
    if(!isset($_SESSION['user'])) Flight::json(['success'=>false, 'msg'=>'Non connecté']);

    $db = Flight::get('db');
    $me = $_SESSION['user']['id_utilisateur'];

    $data = json_decode(file_get_contents("php://input"), true);

    if(empty($data['id_trajet']) || empty($data['id_signale']) || empty($data['motif'])){
        Flight::json(['success'=>false,'msg'=>'Champs manquants']);
    }

    // Vérification que les deux utilisateurs sont bien liés au trajet
    $check = $db->prepare("
        SELECT 1 FROM TRAJETS WHERE id_trajet = :t AND id_conducteur = :u
        UNION
        SELECT 1 FROM RESERVATIONS WHERE id_trajet = :t AND id_passager = :u AND statut_code='V'
    ");
    $check->execute([':t'=>$data['id_trajet'], ':u'=>$data['id_signale']]);

    if(!$check->fetch()){
        Flight::json(['success'=>false,'msg'=>'Utilisateur non lié au trajet']);
    }

    // Enregistrement du signalement
    $stmt = $db->prepare("
        INSERT INTO SIGNALEMENTS (id_signaleur, id_signale, id_trajet, motif, description)
        VALUES (:me,:sig,:t,:motif,:desc)
    ");
    $stmt->execute([
        ':me'=>$me,
        ':sig'=>$data['id_signale'],
        ':t'=>$data['id_trajet'],
        ':motif'=>$data['motif'],
        ':desc'=>$data['description'] ?? null
    ]);

    Flight::json(['success'=>true]);
});

// ============================================================
// PARTIE 5 : ANNULATION D'UNE RÉSERVATION
// ============================================================
Flight::route('POST /reservation/annuler/@id', function($id){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    try {
        $db->beginTransaction();

        $stmt = $db->prepare("SELECT * FROM RESERVATIONS WHERE id_reservation = :id AND id_passager = :user");
        $stmt->execute([':id' => $id, ':user' => $userId]);
        $reservation = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$reservation) throw new Exception("Réservation introuvable.");

        // 1. Passage du statut à 'A' (Annulé)
        $sqlUpdate = "UPDATE RESERVATIONS SET statut_code = 'A' WHERE id_reservation = :id";
        $stmtUpdate = $db->prepare($sqlUpdate);
        $stmtUpdate->execute([':id' => $id]);

        // 2. Si le trajet était Complet ('C'), on le repasse en Actif ('A') car une place se libère
        $sqlTrajet = "UPDATE TRAJETS SET statut_flag = 'A' WHERE id_trajet = :trajet AND statut_flag = 'C'";
        $stmtTrajet = $db->prepare($sqlTrajet);
        $stmtTrajet->execute([':trajet' => $reservation['id_trajet']]);

        // 3. Notification système dans le chat ("A quitté")
        $msgContent = "::sys_leave::";
        $sqlMsg = "INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (:tid, :uid, :content, NOW())";
        $stmtMsg = $db->prepare($sqlMsg);
        $stmtMsg->execute([':tid' => $reservation['id_trajet'], ':uid' => $userId, ':content' => $msgContent]);

        $db->commit();
        $_SESSION['flash_success'] = "Réservation annulée avec succès.";

    } catch (Exception $e) {
        $db->rollBack();
        $_SESSION['flash_error'] = $e->getMessage();
    }

    Flight::redirect('/mes_reservations');
});
?>