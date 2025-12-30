<?php

// AFFICHER LA PAGE DE RÉSERVATION
Flight::route('GET /trajet/reserver/@id', function($id){
    if(!isset($_SESSION['user'])) {
        $_SESSION['flash_error'] = "Veuillez vous connecter pour réserver un trajet.";
        Flight::redirect('/connexion');
        return;
    }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // Récupérer le trajet
    $sql = "SELECT t.*, u.prenom, u.nom, u.photo_profil, v.marque, v.modele, v.nb_places_totales
            FROM TRAJETS t
            JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
            JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
            WHERE t.id_trajet = :id";
    
    $stmt = $db->prepare($sql);
    $stmt->execute([':id' => $id]);
    $trajet = $stmt->fetch(PDO::FETCH_ASSOC);

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

    // Calcul places prises
    $sqlPlaces = "SELECT COALESCE(SUM(nb_places_reservees), 0) as places_prises
                  FROM RESERVATIONS
                  WHERE id_trajet = :id AND statut_code = 'V'";
    
    $stmtPlaces = $db->prepare($sqlPlaces);
    $stmtPlaces->execute([':id' => $id]);
    $placesData = $stmtPlaces->fetch(PDO::FETCH_ASSOC);
    
    $trajet['places_prises'] = $placesData['places_prises'];
    $trajet['places_disponibles'] = $trajet['places_proposees'] - $trajet['places_prises'];

    // Vérif si déjà réservé
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

    $dateObj = new DateTime($trajet['date_heure_depart']);
    $trajet['date_fmt'] = $dateObj->format('d/m/Y');
    $trajet['heure_fmt'] = $dateObj->format('H:i');

    Flight::render('reservation.tpl', [
        'titre' => 'Réserver un trajet',
        'trajet' => $trajet
    ]);
});

// TRAITEMENT DE LA RÉSERVATION
Flight::route('POST /trajet/reserver/@id', function($id){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');

    $data = Flight::request()->data;
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    try {
        $db->beginTransaction();

        $stmt = $db->prepare("SELECT * FROM TRAJETS WHERE id_trajet = :id");
        $stmt->execute([':id' => $id]);
        $trajet = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$trajet) throw new Exception("Trajet introuvable.");

        // Vérification places
        $sqlPlaces = "SELECT COALESCE(SUM(nb_places_reservees), 0) as places_prises
                      FROM RESERVATIONS
                      WHERE id_trajet = :id AND statut_code = 'V'";
        
        $stmtPlaces = $db->prepare($sqlPlaces);
        $stmtPlaces->execute([':id' => $id]);
        $placesData = $stmtPlaces->fetch(PDO::FETCH_ASSOC);
        
        $placesDisponibles = $trajet['places_proposees'] - $placesData['places_prises'];
        $nbPlacesVoulues = (int)$data->nb_places;

        if ($nbPlacesVoulues > $placesDisponibles) {
            throw new Exception("Pas assez de places disponibles !");
        }

        // Insertion Réservation
        $sqlReserve = "INSERT INTO RESERVATIONS 
                       (id_trajet, id_passager, nb_places_reservees, statut_code, date_reservation)
                       VALUES (:trajet, :passager, :places, 'V', NOW())";
        
        $stmtReserve = $db->prepare($sqlReserve);
        $stmtReserve->execute([
            ':trajet' => $id,
            ':passager' => $userId,
            ':places' => $nbPlacesVoulues
        ]);

        if ($placesDisponibles - $nbPlacesVoulues == 0) {
            $sqlUpdate = "UPDATE TRAJETS SET statut_flag = 'C' WHERE id_trajet = :id";
            $stmtUpdate = $db->prepare($sqlUpdate);
            $stmtUpdate->execute([':id' => $id]);
        }

        // --- AJOUT SYSTEM : Message automatique "A rejoint" ---
        $msgContent = "::sys_join::";
        $sqlMsg = "INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (:tid, :uid, :content, NOW())";
        $stmtMsg = $db->prepare($sqlMsg);
        $stmtMsg->execute([':tid' => $id, ':uid' => $userId, ':content' => $msgContent]);
        // -----------------------------------------------------

        $db->commit();
        $_SESSION['flash_success'] = "Réservation confirmée, bon voyage !";
        Flight::redirect('/mes_reservations');

    } catch (Exception $e) {
        $db->rollBack();
        $_SESSION['flash_error'] = $e->getMessage();
        Flight::redirect('/trajet/reserver/' . $id);
    }
});

// LISTE DES RÉSERVATIONS
Flight::route('GET /mes_reservations', function(){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');
    
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    $sql = "SELECT r.*, t.*, 
            u.prenom as conducteur_prenom, u.nom as conducteur_nom, u.photo_profil as conducteur_photo,
            v.marque, v.modele, v.nb_places_totales
            FROM RESERVATIONS r
            JOIN TRAJETS t ON r.id_trajet = t.id_trajet
            JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
            JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
            WHERE r.id_passager = :user
            AND r.statut_code = 'V'
            ORDER BY t.date_heure_depart ASC";
    
    $stmt = $db->prepare($sql);
    $stmt->execute([':user' => $userId]);
    $reservations = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $participants = [];

    foreach ($reservations as &$r) {
        $participants[$r['id_trajet']] = [];
        $d = new DateTime($r['date_heure_depart']);
        $r['date_fmt'] = $d->format('d/m/Y');
        $r['heure_fmt'] = $d->format('H\hi');

        $participants[$r['id_trajet']][] = [
            'id'=>$r['id_conducteur'],
            'nom'=>$r['conducteur_prenom'].' '.$r['conducteur_nom'],
            'role'=>'Conducteur'
        ];

        $ps = $db->prepare("
            SELECT u.id_utilisateur, u.prenom, u.nom 
            FROM RESERVATIONS r
            JOIN UTILISATEURS u ON r.id_passager = u.id_utilisateur
            WHERE r.id_trajet = :t AND r.statut_code='V' AND u.id_utilisateur != :me
        ");
        $ps->execute([':t'=>$r['id_trajet'], ':me'=>$userId]);

        foreach($ps->fetchAll(PDO::FETCH_ASSOC) as $p){
            $participants[$r['id_trajet']][] = [
                'id'=>$p['id_utilisateur'],
                'nom'=>$p['prenom'].' '.$p['nom'],
                'role'=>'Passager'
            ];
        }
    }

    Flight::render('mes_reservations.tpl', [
        'titre'=>'Mes réservations',
        'reservations'=>$reservations,
        'participants'=>$participants
    ]);
});

// SIGNALEMENT
Flight::route('POST /api/signalement/nouveau', function() {
    if(!isset($_SESSION['user'])) Flight::json(['success'=>false, 'msg'=>'Non connecté']);

    $db = Flight::get('db');
    $me = $_SESSION['user']['id_utilisateur'];

    $data = json_decode(file_get_contents("php://input"), true);

    if(empty($data['id_trajet']) || empty($data['id_signale']) || empty($data['motif'])){
        Flight::json(['success'=>false,'msg'=>'Champs manquants']);
    }

    $check = $db->prepare("
        SELECT 1 FROM TRAJETS WHERE id_trajet = :t AND id_conducteur = :u
        UNION
        SELECT 1 FROM RESERVATIONS WHERE id_trajet = :t AND id_passager = :u AND statut_code='V'
    ");
    $check->execute([':t'=>$data['id_trajet'], ':u'=>$data['id_signale']]);

    if(!$check->fetch()){
        Flight::json(['success'=>false,'msg'=>'Utilisateur non lié au trajet']);
    }

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

// ANNULER UNE RÉSERVATION
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

        // Mettre le statut à A pour annulé
        $sqlUpdate = "UPDATE RESERVATIONS SET statut_code = 'A' WHERE id_reservation = :id";
        $stmtUpdate = $db->prepare($sqlUpdate);
        $stmtUpdate->execute([':id' => $id]);

        // Si le trajet était complet, le réouvrir
        $sqlTrajet = "UPDATE TRAJETS SET statut_flag = 'A' WHERE id_trajet = :trajet AND statut_flag = 'C'";
        $stmtTrajet = $db->prepare($sqlTrajet);
        $stmtTrajet->execute([':trajet' => $reservation['id_trajet']]);

        // Message système "A quitté"
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