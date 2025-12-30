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


// TRAITEMENT DU FORMULAIRE DE CONNEXION
Flight::route('POST /connexion', function(){
    $db = Flight::get('db');
    $email = Flight::request()->data->email;
    $password = Flight::request()->data->password;

    // 1. Récupérer l'utilisateur
    $stmt = $db->prepare("SELECT * FROM UTILISATEURS WHERE email = :email");
    $stmt->execute([':email' => $email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    // 2. Vérifications Mot de Passe
    if ($user && password_verify($password, $user['mot_de_passe'])) {
        
        // --- VÉRIFICATION BANNISSEMENT (LOGIQUE COMPLÈTE) ---
        if ($user['active_flag'] === 'N') {
            
            // Cas 1 : Bannissement Temporaire (il y a une date dans le token)
            if (!empty($user['date_expiration_token'])) {
                $finBan = new DateTime($user['date_expiration_token']);
                $now = new DateTime();

                if ($now > $finBan) {
                    // LE BAN EST FINI : On réactive le compte
                    $db->prepare("UPDATE UTILISATEURS SET active_flag = 'Y', date_expiration_token = NULL WHERE id_utilisateur = :id")
                       ->execute([':id' => $user['id_utilisateur']]);
                    
                    // IMPORTANT : On met à jour la variable locale pour que la connexion continue juste après
                    $user['active_flag'] = 'Y'; 
                } else {
                    // BAN EN COURS (Date non dépassée)
                    $_SESSION['flash_error'] = "Compte suspendu temporairement jusqu'au " . $finBan->format('d/m/Y à H:i');
                    Flight::redirect('/connexion');
                    return; // On arrête tout ici
                }
            } 
            // Cas 2 : Bannissement Définitif (pas de date)
            else {
                $_SESSION['flash_error'] = "Votre compte a été suspendu définitivement par l'administration.";
                Flight::redirect('/connexion');
                return; // On arrête tout ici
            }
        }
        // -----------------------------------------------------

        // Si on arrive ici, c'est que l'utilisateur est Actif (Y) ou vient d'être débanni
        $_SESSION['user'] = $user;
        Flight::redirect('/'); 

    } else {
        // Mauvais mot de passe ou email inconnu
        $_SESSION['flash_error'] = "Email ou mot de passe incorrect.";
        Flight::redirect('/connexion');
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
        // Gestion du complément d'adresse s'il est vide
        $complement = isset($data->complement) ? $data->complement : '';
        $voie_complete = $data->rue . ($complement ? ' ' . $complement : '');
        
        $stmtAddr->execute([
            ':voie' => $voie_complete,
            ':cp' => $data->post,
            ':ville' => $data->ville
        ]);
        $id_adresse = $db->lastInsertId();

        // 3. Insertion Utilisateur
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
        // On vérifie que la variable existe ET qu'elle vaut 'oui'
        if (isset($data->voiture) && $data->voiture === 'oui') {
            
            $immat = strtoupper(trim($data->immat));

            // Regex de validation (Identique à celle du JS pour cohérence)
            $regexImmat = '~^(([A-Z]{2}[- ]?\d{3}[- ]?[A-Z]{2})|(\d{1,4}[- ]?[A-Z]{2,3}[- ]?\d{2}))$~';

            if (!preg_match($regexImmat, $immat)) {
                $db->rollBack();
                Flight::render('inscription.tpl', [
                    'titre' => 'S\'inscrire',
                    'error' => 'Format de plaque invalide. Ex: AA-123-AA',
                    'formData' => $data
                ]);
                return;
            }

            $stmtCar = $db->prepare("
                INSERT INTO VEHICULES (marque, modele, nb_places_totales, couleur, immatriculation, type_vehicule, details_supplementaires) 
                VALUES (:marque, :modele, :places, :couleur, :immat, 'voiture', ' ')
            ");
            
            // CORRECTION ICI : On utilise $data->model (nom du champ HTML) et pas $data->modele
            $stmtCar->execute([
                ':marque' => $data->marque,
                ':modele' => $data->model, // <--- C'était l'erreur (model vs modele)
                ':places' => (int)$data->nb_places,
                ':couleur' => isset($data->couleur) ? $data->couleur : '', // Gestion si couleur vide
                ':immat' => $immat
            ]);
            $id_vehicule = $db->lastInsertId();

            $stmtPoss = $db->prepare("INSERT INTO POSSESSIONS (id_utilisateur, id_vehicule) VALUES (:id_user, :id_car)");
            $stmtPoss->execute([':id_user' => $id_utilisateur, ':id_car' => $id_vehicule]);
        }

        $db->commit();

        // Succès : On peut rediriger vers la connexion ou connecter l'utilisateur directement
        Flight::redirect('/connexion');

    } catch (PDOException $e) {
        $db->rollBack();
        
        // Debug : Décommentez la ligne suivante si l'erreur persiste pour voir le message exact
        // die($e->getMessage()); 

        $errorMsg = "Une erreur est survenue lors de l'inscription.";
        
        if (strpos($e->getMessage(), 'Duplicate entry') !== false) {
            $errorMsg = "Cette adresse email ou ce numéro de téléphone existe déjà.";
        }
        
        Flight::render('inscription.tpl', [
            'titre' => 'S\'inscrire',
            'error' => $errorMsg, // Le message s'affichera dans le TPL
            'formData' => $data
        ]);
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