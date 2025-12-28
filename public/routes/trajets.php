<?php

// AFFICHER LE FORMULAIRE
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

// TRAITEMENT (POST)
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
                        :dateheure, '01:00:00', 
                        :places, :desc, 'A'
                    )";
            
            $stmt = $db->prepare($sql);
            $stmt->execute([
                ':conducteur' => $userId,
                ':vehicule'   => $vehicule['id_vehicule'],
                ':depart'     => $data->depart,
                ':arrivee'    => $data->arrivee,
                ':dateheure'  => $dateDebut->format('Y-m-d H:i:s'),
                ':places'     => (int)$data->places,
                ':desc'       => $data->description
            ]);

            // --- CORRECTION : AUCUNE CRÉATION DE CONVERSATION ICI ---
            // La conversation est implicite au trajet.

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

// MES TRAJETS (Conducteur)
Flight::route('/mes_trajets', function(){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');
    
    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];

    $sql = "SELECT t.*, v.marque, v.modele, v.immatriculation, v.nb_places_totales 
            FROM TRAJETS t
            JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
            WHERE t.id_conducteur = :id
            ORDER BY t.date_heure_depart ASC";
            
    $stmt = $db->prepare($sql);
    $stmt->execute([':id' => $idUser]);
    $trajets = $stmt->fetchAll(PDO::FETCH_ASSOC);

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

        $nb_occupes = 0;
        foreach($trajet['passagers'] as $p) {
            $nb_occupes += $p['nb_places_reservees'];
        }

        $trajet['places_prises'] = $nb_occupes;
        $trajet['places_restantes'] = $trajet['places_proposees'] - $nb_occupes;
        
        $dateObj = new DateTime($trajet['date_heure_depart']);
        $trajet['date_fmt'] = $dateObj->format('d / m / Y');
        $trajet['heure_fmt'] = $dateObj->format('H\hi');
        
        $dureeObj = new DateTime($trajet['duree_estimee']);
        $heures = $dureeObj->format('G');
        $minutes = $dureeObj->format('i');
        if($minutes == '00') $trajet['duree_fmt'] = $heures . " heures";
        else $trajet['duree_fmt'] = $heures . "h" . $minutes;
    }

    Flight::render('mes_trajets.tpl', [
        'titre' => 'Mes trajets',
        'trajets' => $trajets
    ]);
});
?>