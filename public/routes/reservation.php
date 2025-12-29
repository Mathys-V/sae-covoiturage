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
                 AND statut_code IN ('V', 'A')";
                 
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

    foreach ($reservations as &$reservation) {
        $dateObj = new DateTime($reservation['date_heure_depart']);
        $reservation['date_fmt'] = $dateObj->format('d/m/Y');
        $reservation['heure_fmt'] = $dateObj->format('H\hi');
        
        if (isset($reservation['duree_estimee'])) {
            $dureeObj = new DateTime($reservation['duree_estimee']);
            $heures = (int)$dureeObj->format('G');
            $minutes = (int)$dureeObj->format('i');
            
            if ($heures > 0 && $minutes > 0) $reservation['duree_fmt'] = $heures . "h" . $minutes;
            elseif ($heures > 0) $reservation['duree_fmt'] = $heures . " heure" . ($heures > 1 ? "s" : "");
            else $reservation['duree_fmt'] = $minutes . " minutes";
        } else {
            $reservation['duree_fmt'] = "10 minutes";
        }
    }

    Flight::render('mes_reservations.tpl', [
        'titre' => 'Mes réservations',
        'reservations' => $reservations
    ]);
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

        $sqlUpdate = "UPDATE RESERVATIONS SET statut_code = 'A' WHERE id_reservation = :id";
        $stmtUpdate = $db->prepare($sqlUpdate);
        $stmtUpdate->execute([':id' => $id]);

        $sqlTrajet = "UPDATE TRAJETS SET statut_flag = 'A' WHERE id_trajet = :trajet AND statut_flag = 'C'";
        $stmtTrajet = $db->prepare($sqlTrajet);
        $stmtTrajet->execute([':trajet' => $reservation['id_trajet']]);

        // --- AJOUT SYSTEM : Message automatique "A quitté" ---
        $msgContent = "::sys_leave::";
        $sqlMsg = "INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (:tid, :uid, :content, NOW())";
        $stmtMsg = $db->prepare($sqlMsg);
        $stmtMsg->execute([':tid' => $reservation['id_trajet'], ':uid' => $userId, ':content' => $msgContent]);
        // -----------------------------------------------------

        $db->commit();
        $_SESSION['flash_success'] = "Réservation annulée avec succès.";
        
    } catch (Exception $e) {
        $db->rollBack();
        $_SESSION['flash_error'] = $e->getMessage();
    }

    Flight::redirect('/mes_reservations');
});


?>