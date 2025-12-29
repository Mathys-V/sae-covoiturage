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

    // 1. Récupérer l'utilisateur
    $stmt = $db->prepare("SELECT * FROM UTILISATEURS WHERE id_utilisateur = ?");
    $stmt->execute([$idUser]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    // Mettre à jour la session
    if ($user) {
        unset($user['mot_de_passe']);
        $_SESSION['user'] = $user;
    }

    // 2. Récupérer le véhicule de l'utilisateur (via la table POSSESSIONS)
    $stmtVehicule = $db->prepare("
        SELECT v.* FROM VEHICULES v
        JOIN POSSESSIONS p ON v.id_vehicule = p.id_vehicule
        WHERE p.id_utilisateur = ?
        LIMIT 1
    ");
    $stmtVehicule->execute([$idUser]);
    $vehicule = $stmtVehicule->fetch(PDO::FETCH_ASSOC);

    // --- CORRECTION DU BUG 500 ICI ---
    // Si l'utilisateur n'a pas de voiture, fetch() renvoie false.
    // On convertit false en NULL pour que le {if isset($vehicule)} du template fonctionne correctement.
    if ($vehicule === false) {
        $vehicule = null;
    }

    Flight::render('profil.tpl', [
        'titre' => 'Mon Profil',
        'vehicule' => $vehicule // On envoie le véhicule à la vue
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

// 3. MODIFIER / AJOUTER VÉHICULE
Flight::route('POST /profil/update-vehicule', function(){
    // 1. Sécurité : Utilisateur connecté ?
    if(!isset($_SESSION['user'])) {
        Flight::redirect('/connexion');
        return;
    }

    // 2. Récupération des données du formulaire
    $data = Flight::request()->data;
    $idUser = $_SESSION['user']['id_utilisateur'];
    $db = Flight::get('db');

    // 3. Nettoyage des données
    $marque = trim($data->marque);
    $modele = trim($data->modele);
    $couleur = trim($data->couleur);
    $nb_places = (int) $data->nb_places;
    // On met la plaque en majuscules et on enlève les espaces superflus
    $immat = strtoupper(trim(str_replace(' ', '', $data->immat))); 

    try {
        // 4. Vérifier si l'utilisateur possède DÉJÀ un véhicule
        // On regarde dans la table de liaison POSSESSIONS
        $stmtCheck = $db->prepare("SELECT id_vehicule FROM POSSESSIONS WHERE id_utilisateur = ? LIMIT 1");
        $stmtCheck->execute([$idUser]);
        $possede = $stmtCheck->fetch(PDO::FETCH_ASSOC);

        if ($possede) {
            // --- CAS A : MISE À JOUR (UPDATE) ---
            // L'utilisateur a déjà une voiture, on met à jour ses infos
            $idVehicule = $possede['id_vehicule'];
            
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
                ':marque' => $marque,
                ':modele' => $modele,
                ':couleur' => $couleur,
                ':places' => $nb_places,
                ':immat' => $immat,
                ':id' => $idVehicule
            ]);
            
            $_SESSION['flash_success'] = "Véhicule modifié avec succès !";

        } else {
            // --- CAS B : CRÉATION (INSERT) ---
            // L'utilisateur n'a pas de voiture, on en crée une nouvelle
            $db->beginTransaction(); // On sécurise l'opération

            // 1. Création du véhicule
            $stmtInsert = $db->prepare("
                INSERT INTO VEHICULES (marque, modele, couleur, nb_places_totales, immatriculation, type_vehicule) 
                VALUES (:marque, :modele, :couleur, :places, :immat, 'voiture')
            ");
            
            $stmtInsert->execute([
                ':marque' => $marque,
                ':modele' => $modele,
                ':couleur' => $couleur,
                ':places' => $nb_places,
                ':immat' => $immat
            ]);
            
            // On récupère l'ID de la voiture qu'on vient de créer
            $idNewCar = $db->lastInsertId();

            // 2. Création du lien avec l'utilisateur (POSSESSIONS)
            $stmtLink = $db->prepare("INSERT INTO POSSESSIONS (id_utilisateur, id_vehicule) VALUES (?, ?)");
            $stmtLink->execute([$idUser, $idNewCar]);

            $db->commit(); // On valide tout
            $_SESSION['flash_success'] = "Nouveau véhicule ajouté !";
        }

    } catch (Exception $e) {
        // En cas d'erreur (ex: Plaque déjà prise par quelqu'un d'autre)
        if($db->inTransaction()) $db->rollBack();
        $_SESSION['flash_error'] = "Erreur : Vérifiez que cette plaque n'est pas déjà enregistrée.";
    }

    // Retour au profil
    Flight::redirect('/profil');
});


Flight::route('GET /api/check-email', function(){
    $email = Flight::request()->query->email;
    $db = Flight::get('db');

    $stmt = $db->prepare("SELECT COUNT(*) FROM UTILISATEURS WHERE email = :email");
    $stmt->execute([':email' => $email]);
    $count = $stmt->fetchColumn();

    // Renvoie une réponse JSON
    Flight::json(['exists' => ($count > 0)]);
});

// -----------------------------------------------------------
// PAGE MES AVIS 
// -----------------------------------------------------------
Flight::route('GET /profil/avis', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];

    // CORRECTION SQL : On passe par la table RESERVATIONS pour atteindre le TRAJET
    $sql = "SELECT 
                a.*, 
                u.prenom, 
                u.nom, 
                u.photo_profil, 
                t.id_conducteur,
                a.role_destinataire -- Votre table contient déjà le rôle ('C' ou 'P'), on peut l'utiliser !
            FROM AVIS a
            JOIN RESERVATIONS r ON a.id_reservation = r.id_reservation
            JOIN TRAJETS t ON r.id_trajet = t.id_trajet
            JOIN UTILISATEURS u ON a.id_auteur = u.id_utilisateur
            WHERE a.id_destinataire = :id
            ORDER BY a.date_avis DESC";
            
    $stmt = $db->prepare($sql);
    $stmt->execute([':id' => $idUser]);
    $allAvis = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Initialisation des tableaux
    $avisConducteur = [];
    $avisPassager = [];
    
    $totalCond = 0; $countCond = 0;
    $totalPass = 0; $countPass = 0;

    foreach($allAvis as $avis) {
        // Option 1 : On utilise la colonne role_destinataire de votre BDD (plus fiable)
        // 'C' = Conducteur, 'P' = Passager
        if ($avis['role_destinataire'] === 'C') {
            $avisConducteur[] = $avis;
            $totalCond += $avis['note'];
            $countCond++;
        } 
        // Option 2 (Secours) : Si role_destinataire est vide, on vérifie via l'ID conducteur du trajet
        elseif ($avis['id_conducteur'] == $idUser) {
            $avisConducteur[] = $avis;
            $totalCond += $avis['note'];
            $countCond++;
        } 
        else {
            $avisPassager[] = $avis;
            $totalPass += $avis['note'];
            $countPass++;
        }
    }

    // Calcul des moyennes
    $moyenneCond = ($countCond > 0) ? round($totalCond / $countCond, 1) : 0;
    $moyennePass = ($countPass > 0) ? round($totalPass / $countPass, 1) : 0;

    // Envoi à la vue
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

// 1. AFFICHER LA PAGE (GET)
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

// 2. TRAITER LE FORMULAIRE (POST) - VERSION CORRIGÉE & NETTOYÉE
Flight::route('POST /profil/modifier_adresse', function(){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];
    
    // Récupération de l'ID adresse
    $stmtUser = $db->prepare("SELECT id_adresse FROM UTILISATEURS WHERE id_utilisateur = :id");
    $stmtUser->execute([':id' => $idUser]);
    $userRef = $stmtUser->fetch(PDO::FETCH_ASSOC);
    $idAdresse = $userRef['id_adresse'];

    // --- NETTOYAGE DES DONNÉES (TRIM) ---
    // On enlève les espaces avant/après chaque valeur reçue
    $rue = trim(Flight::request()->data->rue); 
    $complement = trim(Flight::request()->data->complement);
    $ville = trim(Flight::request()->data->ville);
    $cp = trim(Flight::request()->data->cp);

    // Concaténation 'voie'
    $voieComplete = $rue;
    if(!empty($complement)) {
        $voieComplete .= ' ' . $complement;
    }

    // Mise à jour BDD
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

    // Succès
    Flight::render('modifier_adresse.tpl', [
        'titre' => 'Modifier mon adresse',
        'success' => true,
        'adresse' => ['voie' => $voieComplete, 'ville' => $ville, 'code_postal' => $cp]
    ]);
});


// ============================================================
// MENU GESTION MOT DE PASSE (Page intermédiaire)
// ============================================================

Flight::route('GET /profil/gestion_mdp', function(){
    // Vérification de sécurité
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    Flight::render('gestion_mdp.tpl', [
        'titre' => 'Gérer le mot de passe'
    ]);
});


// ============================================================
// GESTION MODIFICATION MOT DE PASSE
// ============================================================

// 1. ROUTE GET : Indispensable pour AFFICHER la page
Flight::route('GET /profil/modifier_mdp', function(){
    // Sécurité : Si pas connecté, on redirige
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    Flight::render('modifier_mdp.tpl', [
        'titre' => 'Modifier le mot de passe'
    ]);
});

// 2. ROUTE POST : Pour TRAITER le formulaire (celle que vous avez déjà sûrement)
Flight::route('POST /profil/modifier_mdp', function(){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];
    $data = Flight::request()->data;

    // Récupérer le hash actuel
    $stmt = $db->prepare("SELECT mot_de_passe FROM UTILISATEURS WHERE id_utilisateur = :id");
    $stmt->execute([':id' => $idUser]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    $errors = [];

    // A. Vérif MDP Actuel
    if (!password_verify($data->current_password, $user['mot_de_passe'])) {
        $errors['current'] = "Le mot de passe n'est pas celui actuel";
    }

    // B. Vérif Format Nouveau (Redondance sécurité serveur)
    $regex = '/^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/';
    if (!preg_match($regex, $data->new_password)) {
        $errors['format'] = "Format invalide.";
    }

    // C. Vérif Correspondance
    if ($data->new_password !== $data->confirm_password) {
        $errors['confirm'] = "Erreur correspondance.";
    }

    // ERREUR : On renvoie vers le form
    if (!empty($errors)) {
        Flight::render('modifier_mdp.tpl', [
            'titre' => 'Modifier le mot de passe',
            'errors' => $errors,
            'formData' => ['new_password' => $data->new_password] 
        ]);
        return;
    }

    // SUCCÈS : Update + Affichage Modale
    $newHash = password_hash($data->new_password, PASSWORD_BCRYPT);
    $update = $db->prepare("UPDATE UTILISATEURS SET mot_de_passe = :mdp WHERE id_utilisateur = :id");
    $update->execute([':mdp' => $newHash, ':id' => $idUser]);

    Flight::render('modifier_mdp.tpl', [
        'titre' => 'Modifier le mot de passe',
        'success' => true // Déclenche la modale
    ]);
});


// ============================================================
// PRÉFÉRENCES DE COMMUNICATION (Menu & Sous-pages)
// ============================================================

// 1. LE MENU PRINCIPAL
Flight::route('GET /profil/preferences', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    Flight::render('preferences/menu.tpl', ['titre' => 'Préférences de communication']);
});

// 2. PAGE NOTIFICATIONS PUSH
Flight::route('GET /profil/preferences/push', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    Flight::render('preferences/push.tpl', ['titre' => 'Notifications Push']);
});

// 3. PAGE E-MAILS
Flight::route('GET /profil/preferences/emails', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    Flight::render('preferences/emails.tpl', ['titre' => 'Gestion des E-mails']);
});

// ============================================================
// PAGE TÉLÉPHONE : LECTURE ET SAUVEGARDE BDD
// ============================================================

// 1. AFFICHER LA PAGE (Lecture BDD)
Flight::route('GET /profil/preferences/telephone', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    
    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur']; //

    // Récupération du numéro dans la table UTILISATEURS
    $stmt = $db->prepare("SELECT telephone FROM UTILISATEURS WHERE id_utilisateur = :id");
    $stmt->execute([':id' => $idUser]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Si null, on met une chaine vide
    $telBDD = $result['telephone'] ?? '';

    Flight::render('preferences/telephone.tpl', [
        'titre' => 'Notifications par téléphone',
        'tel_bdd' => $telBDD 
    ]);
});

// 2. SAUVEGARDER (AJAX POST)
Flight::route('POST /profil/preferences/telephone/save', function(){
    if(!isset($_SESSION['user'])) return; 
    
    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];
    
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
    $rawTel = $data['telephone'] ?? '';

    // A. NETTOYAGE : On enlève tout ce qui n'est pas un chiffre (espaces, tirets...)
    $cleanTel = preg_replace('/[^0-9]/', '', $rawTel);

    // B. VALIDATION : On vérifie si c'est un numéro français valide (10 chiffres, commence par 0)
    // Si c'est vide, on accepte (l'utilisateur supprime son numéro)
    if (!empty($cleanTel) && !preg_match('/^0[1-9][0-9]{8}$/', $cleanTel)) {
        Flight::json(['success' => false, 'message' => 'Format invalide (10 chiffres requis)']);
        return;
    }

    // C. MISE A JOUR BDD
    try {
        $stmt = $db->prepare("UPDATE UTILISATEURS SET telephone = :tel WHERE id_utilisateur = :id");
        $stmt->execute([
            ':tel' => $cleanTel, // On enregistre le numéro "propre" (0612345678)
            ':id' => $idUser
        ]);

        // Mise à jour session
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

    // Récupérer les signalements faits par l'utilisateur
    // On joint avec UTILISATEURS pour avoir le nom de la personne signalée
    // Et avec TRAJETS pour le contexte (facultatif mais mieux)
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