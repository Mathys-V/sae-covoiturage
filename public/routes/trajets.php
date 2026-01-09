<?php

// ============================================================
// PARTIE 1 : PROPOSER UN TRAJET (CREATE)
// ============================================================

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

    // --- CORRECTION ICI : Récupération et FORMATAGE des lieux globaux ---
    $stmtLieux = $db->query("SELECT * FROM LIEUX_FREQUENTS ORDER BY nom_lieu ASC");
    $lieux = $stmtLieux->fetchAll(PDO::FETCH_ASSOC);

    // On prépare une chaîne 'full_address' pour que le JavaScript puisse faire la recherche dessus
    foreach ($lieux as &$lieu) {
        $lieu['label'] = $lieu['nom_lieu']; 
        
        // On crée l'adresse complète pour la recherche et l'affichage
        // Ex: "Gare du Nord Rue de Maubeuge 75010 Paris"
        $lieu['full_address'] = $lieu['nom_lieu'] . ' ' . 
                                ($lieu['rue'] ? $lieu['rue'] . ' ' : '') . 
                                $lieu['code_postal'] . ' ' . 
                                $lieu['ville'];
    }

    Flight::render('trajet/proposer_trajet.tpl', [
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
        Flight::render('trajet/proposer_trajet.tpl', ['error' => 'Erreur : Aucun véhicule associé.']);
        return;
    }

    // --- VERIFICATION DEPART ≠ ARRIVEE ---
    $ville_dep = trim($data->ville_depart);
    $cp_dep = trim($data->cp_depart);
    $rue_dep = trim($data->rue_depart);

    $ville_arr = trim($data->ville_arrivee);
    $cp_arr = trim($data->cp_arrivee);
    $rue_arr = trim($data->rue_arrivee);

    if (
        strtolower($ville_dep) === strtolower($ville_arr) &&
        $cp_dep === $cp_arr &&
        strtolower($rue_dep) === strtolower($rue_arr)
    ) {
        Flight::render('trajet/proposer_trajet.tpl', [
            'error' => "Le lieu de départ et d'arrivée ne peuvent pas être identiques.",
            'lieux_frequents' => Flight::get('lieux_frequents') ?? []
        ]);
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
            // 1. CRÉATION DU TRAJET
            $sql = "INSERT INTO TRAJETS (
                        id_conducteur, id_vehicule, 
                        ville_depart, code_postal_depart, rue_depart,
                        ville_arrivee, code_postal_arrivee, rue_arrivee,
                        date_heure_depart, duree_estimee, 
                        places_proposees, commentaires, statut_flag
                    ) VALUES (
                        :conducteur, :vehicule, 
                        :ville_dep, :cp_dep, :rue_dep, 
                        :ville_arr, :cp_arr, :rue_arr, 
                        :dateheure, :duree,
                        :places, :desc, 'A'
                    )";

            $stmt = $db->prepare($sql);
            $stmt->execute([
                ':conducteur' => $userId,
                ':vehicule'   => $vehicule['id_vehicule'],
                ':ville_dep'  => $ville_dep,
                ':cp_dep'     => $cp_dep,
                ':rue_dep'    => $rue_dep,
                ':ville_arr'  => $ville_arr,
                ':cp_arr'     => $cp_arr,
                ':rue_arr'    => $rue_arr,
                ':dateheure'  => $dateDebut->format('Y-m-d H:i:s'),
                ':duree'      => $data->duree_calc,
                ':places'     => (int)$data->places,
                ':desc'       => $data->description
            ]);

            $id_trajet_cree = $db->lastInsertId();

            // 2. MESSAGE SYSTÈME
            $msgContent = "::sys_create:: Trajet publié.";
            $stmtMsg = $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (:id_t, :id_u, :contenu, NOW())");
            $stmtMsg->execute([
                ':id_t'    => $id_trajet_cree,
                ':id_u'    => $userId,
                ':contenu' => $msgContent
            ]);

            $compteur++;
            if ($data->regulier === 'Y') $dateDebut->modify('+1 week');
            else break;
        }

        $db->commit();

        $_SESSION['flash_success'] = $compteur > 1
            ? "$compteur trajets créés jusqu'au " . $dateFin->format('d/m/Y') . " !"
            : "Trajet publié avec succès !";

        Flight::redirect('/');

    } catch (Exception $e) {
        $db->rollBack();
        Flight::render('trajet/proposer_trajet.tpl', [
            'error' => "Erreur : " . $e->getMessage(),
            'titre' => 'Proposer un trajet'
        ]);
    }
});


// TRAITEMENT DU FORMULAIRE DE CRÉATION (POST)
Flight::route('POST /trajet/nouveau', function(){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');

    $data = Flight::request()->data;
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // 1. Récupérer le véhicule associé à l'utilisateur
    $stmtVehicule = $db->prepare("SELECT id_vehicule FROM POSSESSIONS WHERE id_utilisateur = :id LIMIT 1");
    $stmtVehicule->execute([':id' => $userId]);
    $vehicule = $stmtVehicule->fetch(PDO::FETCH_ASSOC);

    if(!$vehicule) {
        Flight::render('trajet/proposer_trajet.tpl', ['error' => 'Erreur : Aucun véhicule associé.']);
        return;
    }

    try {
        $db->beginTransaction();

        // 2. Gestion de la récurrence (Trajet régulier ou unique)
        $dateDebut = new DateTime($data->date . ' ' . $data->heure);
        
        if ($data->regulier === 'Y' && !empty($data->date_fin)) {
            $dateFin = new DateTime($data->date_fin . ' 23:59:59');
        } else {
            $dateFin = clone $dateDebut; // Si unique, date fin = date début
        }

        $compteur = 0;
        
        // Boucle pour créer les trajets (1 seul tour si unique, plusieurs si régulier)
        while ($dateDebut <= $dateFin) {
            
            // A. Insertion du trajet en base
            $sql = "INSERT INTO TRAJETS (
                        id_conducteur, id_vehicule, 
                        ville_depart, code_postal_depart, rue_depart,
                        ville_arrivee, code_postal_arrivee, rue_arrivee,
                        date_heure_depart, duree_estimee, 
                        places_proposees, commentaires, statut_flag
                    ) VALUES (
                        :conducteur, :vehicule, 
                        :ville_dep, :cp_dep, :rue_dep, 
                        :ville_arr, :cp_arr, :rue_arr, 
                        :dateheure, :duree,
                        :places, :desc, 'A'
                    )";

            $stmt = $db->prepare($sql);
            $stmt->execute([
                ':conducteur' => $userId,
                ':vehicule'   => $vehicule['id_vehicule'],
                ':ville_dep'  => $data->ville_depart,
                ':cp_dep'     => $data->cp_depart,
                ':rue_dep'    => $data->rue_depart,
                ':ville_arr'  => $data->ville_arrivee,
                ':cp_arr'     => $data->cp_arrivee,
                ':rue_arr'    => $data->rue_arrivee,
                ':dateheure'  => $dateDebut->format('Y-m-d H:i:s'),
                ':duree'      => $data->duree_calc,
                ':places'     => (int)$data->places,
                ':desc'       => $data->description
            ]);
            
            $id_trajet_cree = $db->lastInsertId();

            // B. Initialisation du chat avec un message système
            // Cela permet de créer la "conversation" vide dès le départ
            $msgContent = "::sys_create:: Trajet publié.";
            
            $stmtMsg = $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (:id_t, :id_u, :contenu, NOW())");
            $stmtMsg->execute([
                ':id_t'    => $id_trajet_cree,
                ':id_u'    => $userId,
                ':contenu' => $msgContent
            ]);

            $compteur++;

            // Incrémentation de la date pour la prochaine itération (si régulier)
            if ($data->regulier === 'Y') {
                $dateDebut->modify('+1 week'); // Ajoute 1 semaine
            } else {
                break; // Sort de la boucle si trajet unique
            }
        }

        $db->commit();

        // Message de succès adapté
        if ($compteur > 1) {
            $_SESSION['flash_success'] = "$compteur trajets créés jusqu'au " . $dateFin->format('d/m/Y') . " !";
        } else {
            $_SESSION['flash_success'] = "Trajet publié avec succès !";
        }
        
        Flight::redirect('/');

    } catch (Exception $e) {
        $db->rollBack();
        Flight::render('trajet/proposer_trajet.tpl', [
            'error' => "Erreur : " . $e->getMessage(),
            'titre' => 'Proposer un trajet'
        ]);
    }
});

// ============================================================
// PARTIE 2 : GERER MES TRAJETS (CONDUCTEUR)
// ============================================================

// AFFICHER MES TRAJETS
Flight::route('GET /mes_trajets', function(){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');
    
    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];

    // 1. Récupération des trajets créés par l'utilisateur
    $sql = "SELECT t.*, v.marque, v.modele, v.immatriculation, v.nb_places_totales 
            FROM TRAJETS t
            JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
            WHERE t.id_conducteur = :id";
            
    $stmt = $db->prepare($sql);
    $stmt->execute([':id' => $idUser]);
    $trajets = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $now = new DateTime();

    // 2. Enrichissement des données (Calcul places, statuts, dates)
    foreach ($trajets as &$trajet) {
        
        // Récupération des passagers validés pour ce trajet
        $sqlPass = "SELECT u.id_utilisateur, u.nom, u.prenom, u.photo_profil, r.nb_places_reservees
                    FROM RESERVATIONS r
                    JOIN UTILISATEURS u ON r.id_passager = u.id_utilisateur
                    WHERE r.id_trajet = :id_trajet 
                    AND r.statut_code = 'V'";
        
        $stmtPass = $db->prepare($sqlPass);
        $stmtPass->execute([':id_trajet' => $trajet['id_trajet']]);
        $trajet['passagers'] = $stmtPass->fetchAll(PDO::FETCH_ASSOC);

        // Calcul des places restantes
        $nb_occupes = 0;
        foreach($trajet['passagers'] as $p) { $nb_occupes += $p['nb_places_reservees']; }
        $trajet['places_prises'] = $nb_occupes;
        $trajet['places_restantes'] = $trajet['places_proposees'] - $nb_occupes;
        
        // Formatage Dates & Durée
        $depart = new DateTime($trajet['date_heure_depart']);
        $trajet['date_fmt'] = $depart->format('d / m / Y');
        $trajet['heure_fmt'] = $depart->format('H\hi');
        
        $dureeParts = explode(':', $trajet['duree_estimee']);
        $trajet['duree_fmt'] = (int)$dureeParts[0] . 'h' . $dureeParts[1];

        // --- DÉTERMINATION DU STATUT VISUEL ---
        $arrivee = clone $depart;
        $arrivee->add(new DateInterval('PT' . $dureeParts[0] . 'H' . $dureeParts[1] . 'M'));

        if ($trajet['statut_flag'] == 'C') { // C = Annulé/Complet selon contexte, ici C pour Cancelled dans la logique d'affichage inversée
             // NOTE : Attention, statut_flag 'C' peut vouloir dire COMPLET ou CANCEL selon ton implémentation.
             // Dans le code d'annulation plus bas, tu mets 'C'.
            $trajet['statut_visuel'] = 'annule';
            $trajet['statut_libelle'] = 'Annulé';
            $trajet['statut_couleur'] = 'danger';
        } elseif ($trajet['statut_flag'] == 'T' || $now > $arrivee) {
            $trajet['statut_visuel'] = 'termine';
            $trajet['statut_libelle'] = 'Terminé';
            $trajet['statut_couleur'] = 'secondary';
        } elseif ($now >= $depart && $now <= $arrivee) {
            $trajet['statut_visuel'] = 'encours';
            $trajet['statut_libelle'] = 'En cours';
            $trajet['statut_couleur'] = 'success';
            
            $diff = $now->diff($arrivee);
            $trajet['temps_restant'] = ($diff->h > 0) ? $diff->format('%hh %Im') : $diff->format('%I min');
        } else {
            $trajet['statut_visuel'] = 'avenir';
            $trajet['statut_libelle'] = 'À venir';
            $trajet['statut_couleur'] = 'primary';
        }
    }

    // 3. Séparation en deux listes : Actifs (Futurs/En cours) et Archives (Passés/Annulés)
    $trajets_actifs = [];
    $trajets_archives = [];

    foreach ($trajets as $t) {
        if ($t['statut_visuel'] === 'termine' || $t['statut_visuel'] === 'annule') {
            $trajets_archives[] = $t;
        } else {
            $trajets_actifs[] = $t;
        }
    }

    // 4. Tris spécifiques
    // Actifs : En cours d'abord, puis chronologique
    usort($trajets_actifs, function($a, $b) {
        if ($a['statut_visuel'] === 'encours' && $b['statut_visuel'] !== 'encours') return -1;
        if ($b['statut_visuel'] === 'encours' && $a['statut_visuel'] !== 'encours') return 1;
        return strtotime($a['date_heure_depart']) - strtotime($b['date_heure_depart']);
    });

    // Archives : Anté-chronologique (le plus récent en haut)
    usort($trajets_archives, function($a, $b) {
        return strtotime($b['date_heure_depart']) - strtotime($a['date_heure_depart']);
    });

    Flight::render('trajet/mes_trajets.tpl', [
        'titre' => 'Mes trajets',
        'trajets_actifs' => $trajets_actifs,
        'trajets_archives' => $trajets_archives
    ]);
});

// ============================================================
// PARTIE 3 : MODIFIER UN TRAJET
// ============================================================

// AFFICHER LE FORMULAIRE DE MODIFICATION
Flight::route('GET /trajet/modifier/@id', function($id){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // 1. Récupération du trajet
    $stmt = $db->prepare("SELECT * FROM TRAJETS WHERE id_trajet = :id");
    $stmt->execute([':id' => $id]);
    $trajet = $stmt->fetch(PDO::FETCH_ASSOC);

    // Sécurité : Seul le conducteur peut modifier son trajet
    if (!$trajet || $trajet['id_conducteur'] != $userId) {
        $_SESSION['flash_error'] = "Vous n'avez pas le droit de modifier ce trajet.";
        Flight::redirect('/mes_trajets');
        return;
    }

    // Pré-remplissage des champs date/heure
    $dateObj = new DateTime($trajet['date_heure_depart']);
    $trajet['date_seule'] = $dateObj->format('Y-m-d');
    $trajet['heure_seule'] = $dateObj->format('H:i');

    // Récupération des lieux pour l'autocomplétion (idem création)
    $stmtLieux = $db->query("SELECT * FROM LIEUX_FREQUENTS ORDER BY nom_lieu ASC");
    $lieux = $stmtLieux->fetchAll(PDO::FETCH_ASSOC);

    foreach ($lieux as &$lieu) {
        $lieu['label'] = $lieu['nom_lieu']; 
        $lieu['full_address'] = $lieu['nom_lieu'] . ' ' . 
                                ($lieu['rue'] ? $lieu['rue'] . ' ' : '') . 
                                $lieu['code_postal'] . ' ' . 
                                $lieu['ville'];
    }

    Flight::render('trajet/modifier_trajet.tpl', [
        'titre' => 'Modifier un trajet',
        'trajet' => $trajet,
        'lieux_frequents' => $lieux
    ]);
});

// TRAITEMENT DE LA MODIFICATION (POST)
Flight::route('POST /trajet/modifier/@id', function($id){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');

    $data = Flight::request()->data;
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // ... (Tout le bloc de vérification reste identique) ...
    $stmtVerif = $db->prepare("SELECT id_conducteur FROM TRAJETS WHERE id_trajet = :id");
    $stmtVerif->execute([':id' => $id]);
    $trajet = $stmtVerif->fetch(PDO::FETCH_ASSOC);

    if (!$trajet || $trajet['id_conducteur'] != $userId) {
        $_SESSION['flash_error'] = "Action non autorisée.";
        Flight::redirect('/mes_trajets');
        return;
    }

    // --- VERIFICATION DEPART ≠ ARRIVEE ---
    $ville_dep = trim($data->ville_depart);
    $cp_dep = trim($data->cp_depart);
    $rue_dep = trim($data->rue_depart);

    $ville_arr = trim($data->ville_arrivee);
    $cp_arr = trim($data->cp_arrivee);
    $rue_arr = trim($data->rue_arrivee);

    if (
        strtolower($ville_dep) === strtolower($ville_arr) &&
        $cp_dep === $cp_arr &&
        strtolower($rue_dep) === strtolower($rue_arr)
    ) {
        $_SESSION['flash_error'] = "Le lieu de départ et d'arrivée ne peuvent pas être identiques.";
        Flight::redirect("/trajet/modifier/$id");
        return;
    }

    try {
        $dateHeure = $data->date . ' ' . $data->heure . ':00';

        // 1. Mise à jour des données en base
        $sql = "UPDATE TRAJETS SET 
                ville_depart = :ville_dep, code_postal_depart = :cp_dep, rue_depart = :rue_dep,
                ville_arrivee = :ville_arr, code_postal_arrivee = :cp_arr, rue_arrivee = :rue_arr,
                date_heure_depart = :dateheure,
                places_proposees = :places,
                commentaires = :desc
                WHERE id_trajet = :id";

        $stmt = $db->prepare($sql);
        $stmt->execute([
            ':ville_dep' => $ville_dep,
            ':cp_dep'    => $cp_dep,
            ':rue_dep'   => $rue_dep,
            ':ville_arr' => $ville_arr,
            ':cp_arr'    => $cp_arr,
            ':rue_arr'   => $rue_arr,
            ':dateheure' => $dateHeure,
            ':places'    => (int)$data->places,
            ':desc'      => $data->description,
            ':id'        => $id
        ]);

        // 2. Notification aux passagers via le chat
        $msgContent = "::sys_update:: Le conducteur a modifié les détails du trajet.";
        $stmtMsg = $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (:id_t, :id_u, :contenu, NOW())");
        $stmtMsg->execute([
            ':id_t'    => $id,
            ':id_u'    => $userId,
            ':contenu' => $msgContent
        ]);

        $_SESSION['flash_success'] = "Trajet modifié avec succès !";
        Flight::redirect('/mes_trajets');

    } catch (PDOException $e) {
        $_SESSION['flash_error'] = "Erreur lors de la modification : " . $e->getMessage();
        Flight::redirect("/trajet/modifier/$id");
    }
});

// ============================================================
// PARTIE 4 : ANNULER UN TRAJET (CONDUCTEUR)
// ============================================================
Flight::route('POST /trajet/annuler', function(){
    if (!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    
    $db = Flight::get('db');
    $id_trajet = Flight::request()->data->id_trajet;
    $id_user = $_SESSION['user']['id_utilisateur'];

    // Vérification : Seul le conducteur peut annuler
    $stmt = $db->prepare("SELECT id_conducteur, statut_flag FROM TRAJETS WHERE id_trajet = ?");
    $stmt->execute([$id_trajet]);
    $trajet = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$trajet || $trajet['id_conducteur'] != $id_user) {
        $_SESSION['flash_error'] = "Vous n'avez pas le droit d'annuler ce trajet.";
        Flight::redirect('/mes_trajets');
        return;
    }

    if ($trajet['statut_flag'] === 'C') {
        $_SESSION['flash_error'] = "Ce trajet est déjà annulé.";
        Flight::redirect('/mes_trajets');
        return;
    }

    try {
        $db->beginTransaction();

        // 1. Passage du trajet en statut 'C' (Annulé)
        $updTrajet = $db->prepare("UPDATE TRAJETS SET statut_flag = 'C' WHERE id_trajet = ?");
        $updTrajet->execute([$id_trajet]);

        // 2. Annulation automatique de toutes les réservations validées ('V' -> 'R')
        // 'R' pour Refusé/Annulé par conducteur
        $updRes = $db->prepare("UPDATE RESERVATIONS SET statut_code = 'R' WHERE id_trajet = ? AND statut_code = 'V'");
        $updRes->execute([$id_trajet]);

        // 3. Envoi d'un message système d'annulation
        $msgContent = "::sys_cancel:: Le conducteur a annulé ce trajet.";
        $insMsg = $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (?, ?, ?, NOW())");
        $insMsg->execute([$id_trajet, $id_user, $msgContent]);

        $db->commit();
        $_SESSION['flash_success'] = "Trajet annulé.";
        
    } catch (Exception $e) {
        $db->rollBack();
        $_SESSION['flash_error'] = "Erreur lors de l'annulation.";
    }

    Flight::redirect('/mes_trajets');
});

?>