<?php
// Accueil
Flight::route('/', function(){
    Flight::render('accueil.tpl', ['nom' => 'Equipe W']);
});

// Connexion (Affichage)
Flight::route('GET /connexion', function(){
    // Si déjà connecté, on redirige vers l'accueil
    if(isset($_SESSION['user'])) Flight::redirect('/');
    Flight::render('connexion.tpl', ['titre' => 'Se connecter']);
});

//Connexion (Traitement) - LE CŒUR DU SYSTÈME
Flight::route('POST /connexion', function(){
    $email = Flight::request()->data->email;
    $password = Flight::request()->data->password;
    
    $db = Flight::get('db');

    $stmt = $db->prepare("SELECT * FROM UTILISATEURS WHERE email = :email");
    $stmt->execute([':email' => $email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user && password_verify($password, $user['mot_de_passe'])) {
        unset($user['mot_de_passe']); 
        $_SESSION['user'] = $user;
        
        // --- CRÉATION DU MESSAGE FLASH ---
        // On personnalise le message avec le prénom
        $_SESSION['flash_success'] = "Connexion réussie ! Ravi de vous revoir, " . $user['prenom'] . ".";
        
        Flight::redirect('/');
    } else {
        Flight::render('connexion.tpl', [
            'titre' => 'Se connecter',
            'error' => 'Adresse email ou mot de passe incorrect.'
        ]);
    }
});

// Déconnexion
Flight::route('/deconnexion', function(){
    session_destroy(); // Détruit la session
    Flight::redirect('/');
});

// Inscription
Flight::route('/inscription', function(){
    Flight::render('inscription.tpl', ['titre' => 'S\'inscrire']);
});

// TRAITEMENT DE L'INSCRIPTION
Flight::route('POST /inscription', function(){
    $data = Flight::request()->data;
    $db = Flight::get('db');

    // 1. Vérification Mots de passe
    if ($data->mdp !== $data->{'conf-mdp'}) {
        Flight::render('inscription.tpl', [
            'titre' => 'S\'inscrire',
            'error' => 'Les mots de passe ne correspondent pas.',
            'formData' => $data
        ]);
        return;
    }

    try {
        $db->beginTransaction();

        // 2. Insertion Adresse
        $stmtAddr = $db->prepare("INSERT INTO ADRESSES (voie, code_postal, ville, pays) VALUES (:voie, :cp, :ville, 'France')");
        $voie_complete = $data->rue . ($data->complement ? ' ' . $data->complement : '');
        
        $stmtAddr->execute([
            ':voie' => $voie_complete,
            ':cp' => $data->post,
            ':ville' => $data->ville
        ]);
        $id_adresse = $db->lastInsertId();

        // 3. Insertion Utilisateur (BCRYPT)
        $hash = password_hash($data->mdp, PASSWORD_BCRYPT);
        
        $stmtUser = $db->prepare("
            INSERT INTO UTILISATEURS (id_adresse, email, mot_de_passe, nom, prenom, date_naissance, telephone, active_flag, date_inscription) 
            VALUES (:id_addr, :email, :mdp, :nom, :prenom, :dob, :tel, 'Y', NOW())
        ");
        
        $stmtUser->execute([
            ':id_addr' => $id_adresse,
            ':email' => $data->email,
            ':mdp' => $hash,
            ':nom' => $data->nom,
            ':prenom' => $data->prenom,
            ':dob' => $data->date,
            ':tel' => $data->telephone
        ]);
        $id_utilisateur = $db->lastInsertId();

        // 4. Insertion Véhicule (Si voiture = oui)
        if ($data->voiture === 'oui') {
            
            $immat = strtoupper(trim($data->immat)); // Mise en majuscule et nettoyage

            // MODIFICATION DEMANDÉE : Vérification format Plaque (Nouveau AA-123-AA ou Ancien 123 AAA 00)
            // Regex : 2 lettres - 3 chiffres - 2 lettres OU 1 à 4 chiffres - 2/3 lettres - 2 chiffres
            $regexImmat = '~^(([A-Z]{2}[- ]?\d{3}[- ]?[A-Z]{2})|(\d{1,4}[- ]?[A-Z]{2,3}[- ]?\d{2}))$~';

            if (!preg_match($regexImmat, $immat)) {
                $db->rollBack(); // On annule tout
                Flight::render('inscription.tpl', [
                    'titre' => 'S\'inscrire',
                    'error' => 'Format de plaque d\'immatriculation invalide (ex: AA-123-AA).',
                    'formData' => $data
                ]);
                return;
            }

            $stmtCar = $db->prepare("
                INSERT INTO VEHICULES (marque, modele, nb_places_totales, couleur, immatriculation, type_vehicule, details_supplementaires) 
                VALUES (:marque, :modele, :places, :couleur, :immat, 'voiture', ' ')
            ");
            
            $stmtCar->execute([
                ':marque' => $data->marque,
                ':modele' => $data->modele,
                ':places' => (int)$data->nb_places,
                ':couleur' => $data->couleur,
                ':immat' => $immat
            ]);
            $id_vehicule = $db->lastInsertId();

            $stmtPoss = $db->prepare("INSERT INTO POSSESSIONS (id_utilisateur, id_vehicule) VALUES (:id_user, :id_car)");
            $stmtPoss->execute([':id_user' => $id_utilisateur, ':id_car' => $id_vehicule]);
        }

        $db->commit();

        $_SESSION['flash_success'] = "Compte créé avec succès ! Connectez-vous.";
        Flight::redirect('/connexion');

    } catch (PDOException $e) {
        $db->rollBack();
        $errorMsg = "Erreur technique.";
        if (strpos($e->getMessage(), 'Duplicate entry') !== false) {
            $errorMsg = "Cet email est déjà utilisé.";
        }
        Flight::render('inscription.tpl', ['error' => $errorMsg, 'formData' => $data]);
    }
});

// ============================================================
// GESTION MOT DE PASSE OUBLIÉ
// ============================================================

// ÉTAPE 1 : DEMANDER L'EMAIL
Flight::route('GET /mot-de-passe-oublie', function(){
    Flight::render('mdp/etape1_email.tpl', ['titre' => 'Mot de passe oublié']);
});

Flight::route('POST /mot-de-passe-oublie', function(){
    $email = Flight::request()->data->email;
    $db = Flight::get('db');

    // 1. Vérifier si l'utilisateur existe
    $stmt = $db->prepare("SELECT id_utilisateur FROM UTILISATEURS WHERE email = :email");
    $stmt->execute([':email' => $email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        // 2. Générer un code à 6 chiffres
        $code = rand(100000, 999999);
        $expiration = date('Y-m-d H:i:s', strtotime('+15 minutes')); // Valide 15 min

        // 3. Sauvegarder dans la BDD
        $update = $db->prepare("UPDATE UTILISATEURS SET token_recuperation = :code, date_expiration_token = :exp WHERE email = :email");
        $update->execute([':code' => $code, ':exp' => $expiration, ':email' => $email]);

        // 4. SIMULATION D'ENVOI D'EMAIL (Pour le dev local)
        // On écrit le code dans un fichier 'code_mail.txt' à la racine pour que tu puisses le lire
        file_put_contents('../code_mail.txt', "Le code pour $email est : $code");

        // On stocke l'email en session pour l'étape d'après
        $_SESSION['reset_email'] = $email;
        Flight::redirect('/mot-de-passe-oublie/code');
    } else {
        // Pour la sécurité, on peut dire "Si le compte existe, un email a été envoyé"
        // Mais pour le dev, on affiche une erreur
        Flight::render('mdp/etape1_email.tpl', ['error' => 'Aucun compte associé à cet email.']);
    }
});

// ÉTAPE 2 : SAISIR LE CODE
Flight::route('GET /mot-de-passe-oublie/code', function(){
    if(!isset($_SESSION['reset_email'])) Flight::redirect('/mot-de-passe-oublie');
    Flight::render('mdp/etape2_code.tpl', ['titre' => 'Vérification du code']);
});

Flight::route('POST /mot-de-passe-oublie/verify', function(){
    $code = Flight::request()->data->code;
    $email = $_SESSION['reset_email'];
    $db = Flight::get('db');

    // Vérifier le code et l'expiration
    $stmt = $db->prepare("SELECT * FROM UTILISATEURS WHERE email = :email AND token_recuperation = :code AND date_expiration_token > NOW()");
    $stmt->execute([':email' => $email, ':code' => $code]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        // Code bon ! On autorise le changement
        $_SESSION['reset_authorized'] = true;
        Flight::redirect('/mot-de-passe-oublie/nouveau');
    } else {
        Flight::render('mdp/etape2_code.tpl', ['error' => 'Code invalide ou expiré.']);
    }
});

// ÉTAPE 3 : NOUVEAU MOT DE PASSE
Flight::route('GET /mot-de-passe-oublie/nouveau', function(){
    if(!isset($_SESSION['reset_authorized']) || !$_SESSION['reset_authorized']) Flight::redirect('/mot-de-passe-oublie');
    Flight::render('mdp/etape3_nouveau.tpl', ['titre' => 'Nouveau mot de passe']);
});

Flight::route('POST /mot-de-passe-oublie/save', function(){
    $mdp = Flight::request()->data->mdp;
    $confirm = Flight::request()->data->confirm_mdp;
    $email = $_SESSION['reset_email'];

    if ($mdp !== $confirm) {
        Flight::render('mdp/etape3_nouveau.tpl', ['error' => 'Les mots de passe ne correspondent pas.']);
        return;
    }

    // Hashage et sauvegarde
    $hash = password_hash($mdp, PASSWORD_BCRYPT);
    $db = Flight::get('db');

    // On met à jour le MDP et on vide le token pour qu'il ne soit plus réutilisable
    $stmt = $db->prepare("UPDATE UTILISATEURS SET mot_de_passe = :hash, token_recuperation = NULL, date_expiration_token = NULL WHERE email = :email");
    $stmt->execute([':hash' => $hash, ':email' => $email]);

    // Nettoyage session
    unset($_SESSION['reset_email']);
    unset($_SESSION['reset_authorized']);

    if (file_exists('../code_mail.txt')) {
        unlink('../code_mail.txt');
    }

    // Redirection vers connexion avec succès (tu peux ajouter un paramètre GET pour afficher un message)
    Flight::redirect('/connexion');
});








?>