<?php

// AFFICHER LE FORMULAIRE DE CRÉATION
Flight::route('GET /trajet/nouveau', function(){
    if(!isset($_SESSION['user'])) {
        $_SESSION['flash_error'] = "Veuillez vous connecter pour proposer un trajet.";
        Flight::redirect('/connexion');
        return;
    }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];
    
    // Vérif voiture
    $stmt = $db->prepare("SELECT COUNT(*) FROM POSSESSIONS WHERE id_utilisateur = :id");
    $stmt->execute([':id' => $userId]);
    if ($stmt->fetchColumn() == 0) {
        $_SESSION['flash_error'] = "Erreur : Vous devez ajouter un véhicule à votre profil !";
        Flight::redirect('/'); 
        return;
    }

    $stmtLieux = $db->query("SELECT * FROM LIEUX_FREQUENTS");
    $lieux = $stmtLieux->fetchAll(PDO::FETCH_ASSOC);

    Flight::render('proposer_trajet.tpl', [
        'titre' => 'Proposer un trajet',
        'lieux_frequents' => $lieux
    ]);
});

// TRAITEMENT CRÉATION (POST)
Flight::route('POST /trajet/nouveau', function(){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');

    $data = Flight::request()->data;
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // Récupérer le véhicule
    $stmtVehicule = $db->prepare("SELECT id_vehicule FROM POSSESSIONS WHERE id_utilisateur = :id LIMIT 1");
    $stmtVehicule->execute([':id' => $userId]);
    $vehicule = $stmtVehicule->fetch(PDO::FETCH_ASSOC);

    if(!$vehicule) {
        Flight::render('proposer_trajet.tpl', ['error' => 'Erreur : Aucun véhicule associé.']);
        return;
    }

    try {
        $db->beginTransaction();

        $dateDebut = new DateTime($data->date . ' ' . $data->heure);
        
        if ($data->regulier === 'Y' && !empty($data->date_fin)) {
            $dateFin = new DateTime($data->date_fin . ' 23:59:59');
        } else {
            $dateFin = clone $dateDebut;
        }

        $compteur = 0;
        
        while ($dateDebut <= $dateFin) {
            $sql = "INSERT INTO TRAJETS (
                        id_conducteur, id_vehicule, 
                        ville_depart, code_postal_depart, rue_depart,
                        ville_arrivee, code_postal_arrivee, rue_arrivee,
                        date_heure_depart, duree_estimee, 
                        places_proposees, commentaires, statut_flag
                    ) VALUES (
                        :conducteur, :vehicule, 
                        :depart, '00000', '', 
                        :arrivee, '00000', '', 
                        :dateheure, :duree,
                        :places, :desc, 'A'
                    )";
            
            $stmt = $db->prepare($sql);
            $stmt->execute([
                ':conducteur' => $userId,
                ':vehicule'   => $vehicule['id_vehicule'],
                ':depart'     => $data->depart,
                ':arrivee'    => $data->arrivee,
                ':dateheure'  => $dateDebut->format('Y-m-d H:i:s'),
                ':duree'      => $data->duree_calc,
                ':places'     => (int)$data->places,
                ':desc'       => $data->description
            ]);

            $compteur++;

            if ($data->regulier === 'Y') {
                $dateDebut->modify('+1 week');
            } else {
                break;
            }
        }

        $db->commit();

        if ($compteur > 1) {
            $_SESSION['flash_success'] = "$compteur trajets créés jusqu'au " . $dateFin->format('d/m/Y') . " !";
        } else {
            $_SESSION['flash_success'] = "Trajet publié avec succès !";
        }
        
        Flight::redirect('/');

    } catch (Exception $e) {
        $db->rollBack();
        Flight::render('proposer_trajet.tpl', [
            'error' => "Erreur : " . $e->getMessage(),
            'titre' => 'Proposer un trajet'
        ]);
    }
});

// SUPPRIMER / ANNULER UN TRAJET
Flight::route('POST /trajet/supprimer', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];
    $idTrajet = Flight::request()->data->id_trajet;

    // 1. Vérification : Est-ce bien mon trajet ?
    $stmtVerif = $db->prepare("SELECT id_conducteur FROM TRAJETS WHERE id_trajet = :id");
    $stmtVerif->execute([':id' => $idTrajet]);
    $trajet = $stmtVerif->fetch(PDO::FETCH_ASSOC);

    if (!$trajet || $trajet['id_conducteur'] != $idUser) {
        $_SESSION['flash_error'] = "Action non autorisée.";
        Flight::redirect('/mes_trajets');
        return;
    }

    try {
        $db->beginTransaction();

        // 2. Vérifier s'il y a des réservations actives
        $stmtCheck = $db->prepare("SELECT COUNT(*) FROM RESERVATIONS WHERE id_trajet = :id AND statut_code IN ('V', 'A')");
        $stmtCheck->execute([':id' => $idTrajet]);
        $nbReservations = $stmtCheck->fetchColumn();

        if ($nbReservations > 0) {
            // --- CAS A : PASSAGERS PRÉSENTS -> ANNULATION (Soft Delete) ---

            // Envoyer le message système
            $msgSysteme = "::sys_cancel::";
            $stmtMsg = $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (:tid, :uid, :msg, NOW())");
            $stmtMsg->execute([
                ':tid' => $idTrajet, 
                ':uid' => $idUser,
                ':msg' => $msgSysteme
            ]);
            
            // Passer le trajet en 'C' (Annulé)
            $updTrajet = $db->prepare("UPDATE TRAJETS SET statut_flag = 'C' WHERE id_trajet = :id");
            $updTrajet->execute([':id' => $idTrajet]);

            // Passer les réservations en 'R' (Rejeté)
            $updRes = $db->prepare("UPDATE RESERVATIONS SET statut_code = 'R' WHERE id_trajet = :id");
            $updRes->execute([':id' => $idTrajet]);

            $_SESSION['flash_success'] = "Le trajet a été annulé et les passagers notifiés.";

        } else {
            // --- CAS B : AUCUN PASSAGER -> SUPPRESSION DÉFINITIVE ---
            
            $db->prepare("DELETE FROM MESSAGES WHERE id_trajet = :id")->execute([':id' => $idTrajet]);
            $db->prepare("DELETE FROM RESERVATIONS WHERE id_trajet = :id")->execute([':id' => $idTrajet]);
            $del = $db->prepare("DELETE FROM TRAJETS WHERE id_trajet = :id");
            $del->execute([':id' => $idTrajet]);

            $_SESSION['flash_success'] = "Le trajet a été supprimé.";
        }

        $db->commit();

    } catch (PDOException $e) {
        $db->rollBack();
        $_SESSION['flash_error'] = "Erreur technique : " . $e->getMessage();
    }

    Flight::redirect('/mes_trajets');
});

// MES TRAJETS (Affichage et Tris)
Flight::route('/mes_trajets', function(){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');
    
    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];

    // 1. Récupération des données brutes
    $sql = "SELECT t.*, v.marque, v.modele, v.immatriculation, v.nb_places_totales 
            FROM TRAJETS t
            JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
            WHERE t.id_conducteur = :id";
            
    $stmt = $db->prepare($sql);
    $stmt->execute([':id' => $idUser]);
    $trajets = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $now = new DateTime();

    // 2. Calculs et Enrichissement
    foreach ($trajets as &$trajet) {
        // Passagers
        $sqlPass = "SELECT u.nom, u.prenom, u.photo_profil, r.nb_places_reservees
                    FROM RESERVATIONS r
                    JOIN UTILISATEURS u ON r.id_passager = u.id_utilisateur
                    WHERE r.id_trajet = :id_trajet 
                    AND r.statut_code = 'V'";
        $stmtPass = $db->prepare($sqlPass);
        $stmtPass->execute([':id_trajet' => $trajet['id_trajet']]);
        $trajet['passagers'] = $stmtPass->fetchAll(PDO::FETCH_ASSOC);

        // Calcul places
        $nb_occupes = 0;
        foreach($trajet['passagers'] as $p) { $nb_occupes += $p['nb_places_reservees']; }
        $trajet['places_prises'] = $nb_occupes;
        $trajet['places_restantes'] = $trajet['places_proposees'] - $nb_occupes;
        
        // Dates
        $depart = new DateTime($trajet['date_heure_depart']);
        $trajet['date_fmt'] = $depart->format('d / m / Y');
        $trajet['heure_fmt'] = $depart->format('H\hi');
        
        // Durée
        $dureeParts = explode(':', $trajet['duree_estimee']);
        $trajet['duree_fmt'] = (int)$dureeParts[0] . 'h' . $dureeParts[1];

        // --- STATUT VISUEL ---
        $arrivee = clone $depart;
        $arrivee->add(new DateInterval('PT' . $dureeParts[0] . 'H' . $dureeParts[1] . 'M'));

        // 1. Priorité au statut ANNULÉ
        if ($trajet['statut_flag'] == 'C') {
            $trajet['statut_visuel'] = 'annule';
            $trajet['statut_libelle'] = 'Annulé';
            $trajet['statut_couleur'] = 'danger'; // Rouge
        } 
        // 2. Sinon, est-ce TERMINÉ ?
        elseif ($trajet['statut_flag'] == 'T' || $now > $arrivee) {
            $trajet['statut_visuel'] = 'termine';
            $trajet['statut_libelle'] = 'Terminé';
            $trajet['statut_couleur'] = 'secondary'; // Gris
        } 
        // 3. Sinon, est-ce EN COURS ?
        elseif ($now >= $depart && $now <= $arrivee) {
            $trajet['statut_visuel'] = 'encours';
            $trajet['statut_libelle'] = 'En cours';
            $trajet['statut_couleur'] = 'success'; // Vert
            
            $diff = $now->diff($arrivee);
            if ($diff->h > 0) $trajet['temps_restant'] = $diff->format('%hh %Im');
            else $trajet['temps_restant'] = $diff->format('%I min');

        } 
        // 4. Sinon, c'est À VENIR
        else {
            $trajet['statut_visuel'] = 'avenir';
            $trajet['statut_libelle'] = 'À venir';
            $trajet['statut_couleur'] = 'primary'; // Violet
        }
    }

    // 3. SÉPARATION DES LISTES
    $trajets_actifs = [];
    $trajets_archives = [];

    foreach ($trajets as $t) {
        // On met les trajets ANNULÉS et TERMINÉS dans l'historique
        if ($t['statut_visuel'] === 'termine' || $t['statut_visuel'] === 'annule') {
            $trajets_archives[] = $t;
        } else {
            $trajets_actifs[] = $t;
        }
    }

    // 4. TRIS

    // A. Actifs : En cours d'abord, puis chronologique (Demain avant la semaine pro)
    usort($trajets_actifs, function($a, $b) {
        if ($a['statut_visuel'] === 'encours' && $b['statut_visuel'] !== 'encours') return -1;
        if ($b['statut_visuel'] === 'encours' && $a['statut_visuel'] !== 'encours') return 1;
        return strtotime($a['date_heure_depart']) - strtotime($b['date_heure_depart']);
    });

    // B. Archives : Décroissant (Le plus récent en haut)
    usort($trajets_archives, function($a, $b) {
        return strtotime($b['date_heure_depart']) - strtotime($a['date_heure_depart']);
    });

    Flight::render('mes_trajets.tpl', [
        'titre' => 'Mes trajets',
        'trajets_actifs' => $trajets_actifs,
        'trajets_archives' => $trajets_archives
    ]);
});
?>