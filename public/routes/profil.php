<?php

// -----------------------------------------------------------
// GESTION DU PROFIL
// -----------------------------------------------------------

// 1. AFFICHER LE PROFIL
Flight::route('GET /profil', function(){
    if(!isset($_SESSION['user'])) {
        Flight::redirect('/connexion');
        return;
    }

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];

    // 1. Récupérer l'utilisateur AVEC LES MOYENNES DES AVIS
    $sql = "SELECT U.*, 
            (SELECT AVG(note) FROM AVIS WHERE id_destinataire = U.id_utilisateur AND role_destinataire = 'C') as note_conducteur,
            (SELECT AVG(note) FROM AVIS WHERE id_destinataire = U.id_utilisateur AND role_destinataire = 'P') as note_passager
            FROM UTILISATEURS U
            WHERE U.id_utilisateur = ?";
            
    $stmt = $db->prepare($sql);
    $stmt->execute([$idUser]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    // Mettre à jour la session
    if ($user) {
        unset($user['mot_de_passe']);
        $_SESSION['user'] = $user;
    }

    // 2. Récupérer le véhicule de l'utilisateur
    $stmtVehicule = $db->prepare("
        SELECT v.* FROM VEHICULES v
        JOIN POSSESSIONS p ON v.id_vehicule = p.id_vehicule
        WHERE p.id_utilisateur = ?
        LIMIT 1
    ");
    $stmtVehicule->execute([$idUser]);
    $vehicule = $stmtVehicule->fetch(PDO::FETCH_ASSOC);

    if ($vehicule === false) {
        $vehicule = null;
    }

    Flight::render('profil.tpl', [
        'titre' => 'Mon Profil',
        'vehicule' => $vehicule
    ]);
});

// 2. MODIFIER LA DESCRIPTION
Flight::route('POST /profil/update-description', function(){
    if(!isset($_SESSION['user'])) return;
    
    $desc = Flight::request()->data->description;
    $db = Flight::get('db');
    
    $stmt = $db->prepare("UPDATE UTILISATEURS SET description = ? WHERE id_utilisateur = ?");
    $stmt->execute([$desc, $_SESSION['user']['id_utilisateur']]);

    $_SESSION['flash_success'] = "Description mise à jour !";
    Flight::redirect('/profil');
});

// 3. MODIFIER / AJOUTER VÉHICULE (SÉCURISÉ)
Flight::route('POST /profil/update-vehicule', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $data = Flight::request()->data;
    $idUser = $_SESSION['user']['id_utilisateur'];
    $db = Flight::get('db');

    // 1. Nettoyage et Validation Whitelist
    // CORRECTION MAJUSCULES : On garde la valeur exacte (ex: "BMW") pour la whitelist
    $marqueInput = trim($data->marque); 
    $couleurInput = trim($data->couleur);
    
    $modele = strip_tags(trim($data->modele));
    $nb_places = (int)$data->nb_places;
    
    // Pour la plaque : On enlève tout sauf lettres et chiffres
    $immatBrut = strtoupper(trim($data->immat));
    $immatClean = preg_replace('/[^A-Z0-9]/', '', $immatBrut); 

    // SÉCURITÉ : Whitelists
    if (!in_array($marqueInput, $GLOBALS['voiture_marques'])) {
        $_SESSION['flash_error'] = "Marque invalide. Veuillez choisir dans la liste.";
        Flight::redirect('/profil'); return;
    }
    if (!in_array($couleurInput, $GLOBALS['voiture_couleurs'])) {
        $_SESSION['flash_error'] = "Couleur invalide.";
        Flight::redirect('/profil'); return;
    }
    if (strlen($modele) > 30) { 
        $_SESSION['flash_error'] = "Modèle trop long."; Flight::redirect('/profil'); return; 
    }
    
    //  Max 8 places (Minibus)
    if ($nb_places < 1 || $nb_places > 8) $nb_places = 5;

    // SÉCURITÉ : Format Plaque
    if (!preg_match('/^([A-Z]{2}\d{3}[A-Z]{2}|\d{1,4}[A-Z]{2,3}\d{2})$/', $immatClean)) {
        $_SESSION['flash_error'] = "Format plaque invalide (AA-123-AA).";
        Flight::redirect('/profil'); return;
    }

    // 2. RE-FORMATAGE AVEC TIRETS (Pour la BDD)
    $immatFinale = $immatBrut; // Fallback
    if (preg_match('/^[A-Z]{2}\d{3}[A-Z]{2}$/', $immatClean)) {
        // AA123BB -> AA-123-BB
        $immatFinale = substr($immatClean, 0, 2) . '-' . substr($immatClean, 2, 3) . '-' . substr($immatClean, 5);
    }

    // 3. ENREGISTREMENT
    try {
        $stmtCheck = $db->prepare("SELECT id_vehicule FROM POSSESSIONS WHERE id_utilisateur = ? LIMIT 1");
        $stmtCheck->execute([$idUser]);
        $possede = $stmtCheck->fetch(PDO::FETCH_ASSOC);

        if ($possede) {
            // UPDATE
            $stmtUpdate = $db->prepare("
                UPDATE VEHICULES SET 
                    marque = :marque, 
                    modele = :modele, 
                    couleur = :couleur, 
                    nb_places_totales = :places, 
                    immatriculation = :immat
                WHERE id_vehicule = :id
            ");
            $stmtUpdate->execute([
                ':marque' => $marqueInput,
                ':modele' => $modele,
                ':couleur' => $couleurInput,
                ':places' => $nb_places,
                ':immat' => $immatFinale,
                ':id' => $possede['id_vehicule']
            ]);
            $_SESSION['flash_success'] = "Véhicule modifié avec succès !";

        } else {
            // INSERT
            $db->beginTransaction();
            $stmtInsert = $db->prepare("
                INSERT INTO VEHICULES (marque, modele, couleur, nb_places_totales, immatriculation, type_vehicule) 
                VALUES (:marque, :modele, :couleur, :places, :immat, 'voiture')
            ");
            $stmtInsert->execute([
                ':marque' => $marqueInput,
                ':modele' => $modele,
                ':couleur' => $couleurInput,
                ':places' => $nb_places,
                ':immat' => $immatFinale
            ]);
            $idNewCar = $db->lastInsertId();
            $db->prepare("INSERT INTO POSSESSIONS (id_utilisateur, id_vehicule) VALUES (?, ?)")
               ->execute([$idUser, $idNewCar]);
            $db->commit();
            $_SESSION['flash_success'] = "Nouveau véhicule ajouté !";
        }

    } catch (Exception $e) {
        if($db->inTransaction()) $db->rollBack();
        $_SESSION['flash_error'] = "Erreur : Vérifiez que cette plaque n'est pas déjà enregistrée.";
    }

    Flight::redirect('/profil');
});


// API : VÉRIFIER EMAIL (pour AJAX)
Flight::route('GET /api/check-email', function(){
    $email = Flight::request()->query->email;
    $db = Flight::get('db');

    $stmt = $db->prepare("SELECT COUNT(*) FROM UTILISATEURS WHERE email = :email");
    $stmt->execute([':email' => $email]);
    $count = $stmt->fetchColumn();

    Flight::json(['exists' => ($count > 0)]);
});

// ============================================================
// GESTION PHOTO DE PROFIL
// ============================================================

Flight::route('POST /profil/update-photo', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];

    if (isset($_FILES['photo_profil']) && $_FILES['photo_profil']['error'] === 0) {
        
        $file = $_FILES['photo_profil'];
        $allowed = ['jpg' => 'image/jpeg', 'jpeg' => 'image/jpeg', 'png' => 'image/png', 'webp' => 'image/webp'];
        $filename = $file['name'];
        $filesize = $file['size'];

        // Vérification Extension
        $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
        if (!array_key_exists($ext, $allowed)) {
            $_SESSION['flash_error'] = "Format invalide (JPG, PNG, WEBP uniquement).";
            Flight::redirect('/profil'); return;
        }

        // Vérification Taille (5Mo)
        if ($filesize > 5 * 1024 * 1024) {
            $_SESSION['flash_error'] = "Image trop lourde (max 5Mo).";
            Flight::redirect('/profil'); return;
        }

        // Nom unique et Chemin
        $newFilename = "user_" . $idUser . "_" . uniqid() . "." . $ext;
        $uploadDir = __DIR__ . '/../../public/uploads/';
        
        if (!file_exists($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }

        if (move_uploaded_file($file['tmp_name'], $uploadDir . $newFilename)) {
            
            // Suppression ancienne photo
            $oldPhoto = $_SESSION['user']['photo_profil'];
            if (!empty($oldPhoto) && $oldPhoto !== 'default.png' && file_exists($uploadDir . $oldPhoto)) {
                unlink($uploadDir . $oldPhoto);
            }

            // Mise à jour BDD
            $stmt = $db->prepare("UPDATE UTILISATEURS SET photo_profil = ? WHERE id_utilisateur = ?");
            $stmt->execute([$newFilename, $idUser]);

            // Mise à jour Session
            $_SESSION['user']['photo_profil'] = $newFilename;
            
            $_SESSION['flash_success'] = "Photo modifiée avec succès !";
        } else {
            $_SESSION['flash_error'] = "Erreur technique lors de l'enregistrement.";
        }
    }

    Flight::redirect('/profil');
});

// ============================================================
// SUPPRESSION DU COMPTE (Soft Delete)
// ============================================================
Flight::route('POST /profil/delete-account', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];

    try {
        $stmt = $db->prepare("UPDATE UTILISATEURS SET active_flag = 'N' WHERE id_utilisateur = ?");
        $stmt->execute([$idUser]);

        session_destroy();
        Flight::redirect('/?msg=account_closed');

    } catch (Exception $e) {
        $_SESSION['flash_error'] = "Erreur lors de la fermeture du compte.";
        Flight::redirect('/profil');
    }
});

// -----------------------------------------------------------
// PAGE MES AVIS 
// -----------------------------------------------------------
Flight::route('GET /profil/avis', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];

    $sql = "SELECT 
                a.*, 
                u.prenom, 
                u.nom, 
                u.photo_profil, 
                t.id_conducteur,
                a.role_destinataire
            FROM AVIS a
            JOIN RESERVATIONS r ON a.id_reservation = r.id_reservation
            JOIN TRAJETS t ON r.id_trajet = t.id_trajet
            JOIN UTILISATEURS u ON a.id_auteur = u.id_utilisateur
            WHERE a.id_destinataire = :id
            ORDER BY a.date_avis DESC";
            
    $stmt = $db->prepare($sql);
    $stmt->execute([':id' => $idUser]);
    $allAvis = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $avisConducteur = [];
    $avisPassager = [];
    $totalCond = 0; $countCond = 0;
    $totalPass = 0; $countPass = 0;

    foreach($allAvis as $avis) {
        if ($avis['role_destinataire'] === 'C') {
            $avisConducteur[] = $avis;
            $totalCond += $avis['note'];
            $countCond++;
        } elseif ($avis['id_conducteur'] == $idUser) {
            $avisConducteur[] = $avis;
            $totalCond += $avis['note'];
            $countCond++;
        } else {
            $avisPassager[] = $avis;
            $totalPass += $avis['note'];
            $countPass++;
        }
    }

    $moyenneCond = ($countCond > 0) ? round($totalCond / $countCond, 1) : 0;
    $moyennePass = ($countPass > 0) ? round($totalPass / $countPass, 1) : 0;

    Flight::render('avis/avis.tpl', [
        'titre' => 'Mes Avis',
        'avis_cond' => $avisConducteur,
        'nb_cond' => $countCond,
        'moy_cond' => $moyenneCond,
        'avis_pass' => $avisPassager,
        'nb_pass' => $countPass,
        'moy_pass' => $moyennePass
    ]);
});


// -----------------------------------------------------------
// GESTION PROFIL : MODIFICATION ADRESSE
// -----------------------------------------------------------

Flight::route('GET /profil/modifier_adresse', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];

    $sql = "SELECT a.* FROM ADRESSES a
            JOIN UTILISATEURS u ON u.id_adresse = a.id_adresse
            WHERE u.id_utilisateur = :id";
            
    $stmt = $db->prepare($sql);
    $stmt->execute([':id' => $idUser]);
    $adresse = $stmt->fetch(PDO::FETCH_ASSOC);

    Flight::render('modifier_adresse.tpl', [
        'titre' => 'Modifier mon adresse',
        'adresse' => $adresse
    ]);
});

Flight::route('POST /profil/modifier_adresse', function(){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];
    
    $stmtUser = $db->prepare("SELECT id_adresse FROM UTILISATEURS WHERE id_utilisateur = :id");
    $stmtUser->execute([':id' => $idUser]);
    $userRef = $stmtUser->fetch(PDO::FETCH_ASSOC);
    $idAdresse = $userRef['id_adresse'];

    $rue = trim(Flight::request()->data->rue); 
    $complement = trim(Flight::request()->data->complement);
    $ville = trim(Flight::request()->data->ville);
    $cp = trim(Flight::request()->data->cp);

    $voieComplete = $rue;
    if(!empty($complement)) {
        $voieComplete .= ' ' . $complement;
    }

    $update = $db->prepare("UPDATE ADRESSES SET 
                            numero = NULL, 
                            voie = :voie, 
                            ville = :ville, 
                            code_postal = :cp 
                            WHERE id_adresse = :id_addr");
                            
    $update->execute([
        ':voie' => $voieComplete,
        ':ville' => $ville,
        ':cp' => $cp,
        ':id_addr' => $idAdresse
    ]);

    Flight::render('modifier_adresse.tpl', [
        'titre' => 'Modifier mon adresse',
        'success' => true,
        'adresse' => ['voie' => $voieComplete, 'ville' => $ville, 'code_postal' => $cp]
    ]);
});


// ============================================================
// MENU GESTION MOT DE PASSE
// ============================================================

Flight::route('GET /profil/gestion_mdp', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    Flight::render('gestion_mdp.tpl', ['titre' => 'Gérer le mot de passe']);
});


// ============================================================
// GESTION MODIFICATION MOT DE PASSE
// ============================================================

Flight::route('GET /profil/modifier_mdp', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    Flight::render('modifier_mdp.tpl', ['titre' => 'Modifier le mot de passe']);
});

Flight::route('POST /profil/modifier_mdp', function(){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];
    $data = Flight::request()->data;POST

    $stmt = $db->prepare("SELECT mot_de_passe FROM UTILISATEURS WHERE id_utilisateur = :id");
    $stmt->execute([':id' => $idUser]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    $errors = [];

    if (!password_verify($data->current_password, $user['mot_de_passe'])) {
        $errors['current'] = "Le mot de passe n'est pas celui actuel";
    }

    $regex = '/^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/';
    if (!preg_match($regex, $data->new_password)) {
        $errors['format'] = "Format invalide.";
    }

    if ($data->new_password !== $data->confirm_password) {
        $errors['confirm'] = "Erreur correspondance.";
    }

    if (!empty($errors)) {
        Flight::render('modifier_mdp.tpl', [
            'titre' => 'Modifier le mot de passe',
            'errors' => $errors,
            'formData' => ['new_password' => $data->new_password] 
        ]);
        return;
    }

    $newHash = password_hash($data->new_password, PASSWORD_BCRYPT);
    $update = $db->prepare("UPDATE UTILISATEURS SET mot_de_passe = :mdp WHERE id_utilisateur = :id");
    $update->execute([':mdp' => $newHash, ':id' => $idUser]);

    Flight::render('modifier_mdp.tpl', [
        'titre' => 'Modifier le mot de passe',
        'success' => true
    ]);
});


// ============================================================
// PRÉFÉRENCES DE COMMUNICATION
// ============================================================

Flight::route('GET /profil/preferences', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    Flight::render('preferences/menu.tpl', ['titre' => 'Préférences de communication']);
});

Flight::route('GET /profil/preferences/push', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    Flight::render('preferences/push.tpl', ['titre' => 'Notifications Push']);
});

Flight::route('GET /profil/preferences/emails', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    Flight::render('preferences/emails.tpl', ['titre' => 'Gestion des E-mails']);
});

// ============================================================
// PAGE TÉLÉPHONE
// ============================================================

Flight::route('GET /profil/preferences/telephone', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    
    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur']; 

    $stmt = $db->prepare("SELECT telephone FROM UTILISATEURS WHERE id_utilisateur = :id");
    $stmt->execute([':id' => $idUser]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    $telBDD = $result['telephone'] ?? '';

    Flight::render('preferences/telephone.tpl', [
        'titre' => 'Notifications par téléphone',
        'tel_bdd' => $telBDD 
    ]);
});

Flight::route('POST /profil/preferences/telephone/save', function(){
    if(!isset($_SESSION['user'])) return; 
    
    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];
    
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
    $rawTel = $data['telephone'] ?? '';

    $cleanTel = preg_replace('/[^0-9]/', '', $rawTel);

    if (!empty($cleanTel) && !preg_match('/^0[1-9][0-9]{8}$/', $cleanTel)) {
        Flight::json(['success' => false, 'message' => 'Format invalide (10 chiffres requis)']);
        return;
    }

    try {
        $stmt = $db->prepare("UPDATE UTILISATEURS SET telephone = :tel WHERE id_utilisateur = :id");
        $stmt->execute([
            ':tel' => $cleanTel,
            ':id' => $idUser
        ]);

        $_SESSION['user']['telephone'] = $cleanTel;

        Flight::json(['success' => true]);
    } catch(Exception $e) {
        Flight::json(['success' => false, 'message' => 'Erreur SQL']);
    }
});

// PAGE MES SIGNALEMENTS
Flight::route('GET /profil/mes_signalements', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    $sql = "SELECT s.*, 
                   u.nom as nom_signale, u.prenom as prenom_signale,
                   t.ville_depart, t.ville_arrivee
            FROM SIGNALEMENTS s
            JOIN UTILISATEURS u ON s.id_signale = u.id_utilisateur
            LEFT JOIN TRAJETS t ON s.id_trajet = t.id_trajet
            WHERE s.id_signaleur = :uid
            ORDER BY s.date_signalement DESC";
            
    $stmt = $db->prepare($sql);
    $stmt->execute([':uid' => $userId]);
    $signalements = $stmt->fetchAll(PDO::FETCH_ASSOC);

    Flight::render('profil/mes_signalements.tpl', [
        'titre' => 'Mes signalements',
        'signalements' => $signalements
    ]);
});

?>