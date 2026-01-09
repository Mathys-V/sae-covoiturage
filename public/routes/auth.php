<?php
// ============================================================
// PARTIE 1 : PAGE D'ACCUEIL SIMPLE
// ============================================================
Flight::route('/', function(){
    // Route racine : affiche simplement le template d'accueil
    Flight::render('accueil/accueil.tpl', ['nom' => 'Equipe W']);
});

// ============================================================
// PARTIE 2 : CONNEXION (LOGIN)
// ============================================================

// Route GET : Affichage du formulaire de connexion
Flight::route('GET /connexion', function(){
    // Si l'utilisateur est déjà connecté en session, inutile de se reconnecter -> redirection Accueil
    if(isset($_SESSION['user'])) Flight::redirect('/');
    Flight::render('connexion/connexion.tpl', ['titre' => 'Se connecter']);
});

// Route POST : Traitement du formulaire de connexion
Flight::route('POST /connexion', function(){
    $db = Flight::get('db');
    $email = Flight::request()->data->email;
    $password = Flight::request()->data->password;

    // 1. Recherche de l'utilisateur par son email
    $stmt = $db->prepare("SELECT * FROM UTILISATEURS WHERE email = :email");
    $stmt->execute([':email' => $email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    // 2. Vérification du mot de passe (comparaison du hash stocké en base)
    if ($user && password_verify($password, $user['mot_de_passe'])) {
        
        // --- GESTION DU BANNISSEMENT ---
        // Si le compte est marqué comme inactif ('N')
        if ($user['active_flag'] === 'N') {
            
            // Cas A : Bannissement temporaire (présence d'une date d'expiration)
            if (!empty($user['date_expiration_token'])) {
                $finBan = new DateTime($user['date_expiration_token']);
                $now = new DateTime();

                // Si la date de fin de ban est passée
                if ($now > $finBan) {
                    // LE BAN EST FINI : On réactive le compte en base de données
                    $db->prepare("UPDATE UTILISATEURS SET active_flag = 'Y', date_expiration_token = NULL WHERE id_utilisateur = :id")
                        ->execute([':id' => $user['id_utilisateur']]);
                    
                    // On met à jour la variable locale pour permettre la connexion immédiate
                    $user['active_flag'] = 'Y'; 
                } else {
                    // BAN EN COURS : On affiche un message d'erreur avec la date de fin
                    $_SESSION['flash_error'] = "Compte suspendu temporairement jusqu'au " . $finBan->format('d/m/Y à H:i');
                    Flight::redirect('/connexion');
                    return; // Arrêt du script
                }
            } 
            // Cas B : Bannissement définitif (pas de date d'expiration)
            else {
                $_SESSION['flash_error'] = "Votre compte a été suspendu définitivement par l'administration.";
                Flight::redirect('/connexion');
                return; // Arrêt du script
            }
        }
        // -----------------------------------------------------

        // Si tout est OK (Actif ou Débanni), on enregistre l'utilisateur en session
        $_SESSION['user'] = $user;
        Flight::redirect('/'); 

    } else {
        // Echec : Email inconnu ou mot de passe incorrect
        $_SESSION['flash_error'] = "Email ou mot de passe incorrect.";
        Flight::redirect('/connexion');
    }
});

// Route : Déconnexion
Flight::route('/deconnexion', function(){
    session_destroy(); // Destruction complète de la session
    Flight::redirect('/');
});

// ============================================================
// PARTIE 3 : INSCRIPTION
// ============================================================

// Route GET : Affichage du formulaire d'inscription
Flight::route('/inscription', function(){
    Flight::render('inscription/inscription.tpl', ['titre' => 'S\'inscrire']);
});

// Route POST : Traitement de l'inscription
Flight::route('POST /inscription', function(){
    $data = Flight::request()->data;
    $db = Flight::get('db');

    // 1. Vérification : Les deux mots de passe doivent être identiques
    if ($data->mdp !== $data->{'conf-mdp'}) {
        Flight::render('inscription/inscription.tpl', [
            'titre' => 'S\'inscrire',
            'error' => 'Les mots de passe ne correspondent pas.',
            'formData' => $data // On renvoie les données pour ne pas tout perdre
        ]);
        return;
    }

    // 2. Vérification : Âge (Doit être >= 13 ans)
    $dateNaiss = new DateTime($data->date);
    $dateMin1900 = new DateTime('1900-01-01');
    $dateLimite13ans = new DateTime('-13 years');

    if ($dateNaiss > $dateLimite13ans) {
        Flight::render('inscription/inscription.tpl', [
            'titre' => 'S\'inscrire',
            'error' => 'Vous devez avoir au moins 13 ans pour vous inscrire.',
            'formData' => $data
        ]);
        return;
    }

    // 3. Vérification : Date valide (pas avant 1900)
    if ($dateNaiss < $dateMin1900) {
        Flight::render('inscription/inscription.tpl', [
            'titre' => 'S\'inscrire',
            'error' => 'Date de naissance invalide.',
            'formData' => $data
        ]);
        return;
    }

    try {
        // Démarrage d'une transaction SQL (Tout ou rien)
        $db->beginTransaction();

        // A. Insertion de l'Adresse
        $stmtAddr = $db->prepare("INSERT INTO ADRESSES (voie, code_postal, ville, pays) VALUES (:voie, :cp, :ville, 'France')");
        // Concaténation rue + complément
        $complement = isset($data->complement) ? $data->complement : '';
        $voie_complete = $data->rue . ($complement ? ' ' . $complement : '');
        
        $stmtAddr->execute([
            ':voie' => $voie_complete,
            ':cp' => $data->post,
            ':ville' => $data->ville
        ]);
        $id_adresse = $db->lastInsertId(); // Récupération de l'ID généré

        // B. Insertion de l'Utilisateur
        // Hachage sécurisé du mot de passe
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
        $id_utilisateur = $db->lastInsertId(); // Récupération de l'ID utilisateur

        // C. Insertion du Véhicule (Optionnel, si voiture = 'oui')
        if (isset($data->voiture) && $data->voiture === 'oui') {
            
            $immat = strtoupper(trim($data->immat));

            // Validation du format de la plaque d'immatriculation (Regex)
            $regexImmat = '~^(([A-Z]{2}[- ]?\d{3}[- ]?[A-Z]{2})|(\d{1,4}[- ]?[A-Z]{2,3}[- ]?\d{2}))$~';

            if (!preg_match($regexImmat, $immat)) {
                $db->rollBack(); // Annulation de TOUTES les requêtes précédentes
                Flight::render('inscription/inscription.tpl', [
                    'titre' => 'S\'inscrire',
                    'error' => 'Format de plaque invalide. Ex: AA-123-AA',
                    'formData' => $data
                ]);
                return;
            }

            // Insertion dans la table VEHICULES
            $stmtCar = $db->prepare("
                INSERT INTO VEHICULES (marque, modele, nb_places_totales, couleur, immatriculation, type_vehicule, details_supplementaires) 
                VALUES (:marque, :modele, :places, :couleur, :immat, 'voiture', ' ')
            ");
            
            $stmtCar->execute([
                ':marque' => $data->marque,
                ':modele' => $data->model, 
                ':places' => (int)$data->nb_places,
                ':couleur' => isset($data->couleur) ? $data->couleur : '',
                ':immat' => $immat
            ]);
            $id_vehicule = $db->lastInsertId();

            // Liaison Utilisateur <-> Véhicule (Table POSSESSIONS)
            $stmtPoss = $db->prepare("INSERT INTO POSSESSIONS (id_utilisateur, id_vehicule) VALUES (:id_user, :id_car)");
            $stmtPoss->execute([':id_user' => $id_utilisateur, ':id_car' => $id_vehicule]);
        }

        // Validation finale de la transaction
        $db->commit();

        // Succès : Redirection vers connexion
        Flight::redirect('/connexion?success=inscription');

    } catch (PDOException $e) {
        $db->rollBack(); // Annulation en cas d'erreur SQL
        
        $errorMsg = "Une erreur est survenue lors de l'inscription.";
        
        // Gestion spécifique des erreurs de doublons (Email ou Tel déjà pris)
        if (strpos($e->getMessage(), 'Duplicate entry') !== false) {
            $errorMsg = "Cette adresse email ou ce numéro de téléphone existe déjà.";
        }

        Flight::render('inscription/inscription.tpl', [
            'titre' => 'S\'inscrire',
            'error' => $errorMsg,
            'formData' => $data
        ]);
    }
});

// ============================================================
// PARTIE 4 : MOT DE PASSE OUBLIÉ (Flux en 3 étapes)
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
        // 2. Génération d'un code à 6 chiffres
        $code = rand(100000, 999999);
        $expiration = date('Y-m-d H:i:s', strtotime('+15 minutes'));

        // 3. Stockage du code en base de données
        $update = $db->prepare("UPDATE UTILISATEURS SET token_recuperation = :code, date_expiration_token = :exp WHERE email = :email");
        $update->execute([':code' => $code, ':exp' => $expiration, ':email' => $email]);

        // 4. Simulation d'envoi de mail (Stockage dans un fichier txt pour démo)
        file_put_contents('../code_mail.txt', "Le code pour $email est : $code");
        
        // 5. Mise en session de l'email pour l'étape suivante
        $_SESSION['reset_email'] = $email;
        Flight::redirect('/mot-de-passe-oublie/code');
    } else {
        // Email inconnu
        Flight::render('mdp/etape1_email.tpl', [
            'titre' => 'Mot de passe oublié',
            'error' => 'Aucun compte associé à cet email.'
        ]);
    }
});

// ÉTAPE 2 : SAISIR LE CODE
Flight::route('GET /mot-de-passe-oublie/code', function(){
    // Sécurité : On ne peut pas accéder ici sans avoir fait l'étape 1
    if(!isset($_SESSION['reset_email'])) {
        Flight::redirect('/mot-de-passe-oublie');
        return;
    }
    
    Flight::render('mdp/etape2_code.tpl', ['titre' => 'Vérification']);
});

Flight::route('POST /mot-de-passe-oublie/verify', function(){
    $code = Flight::request()->data->code;
    $email = $_SESSION['reset_email'] ?? '';
    $db = Flight::get('db');

    // Vérification : Le code doit correspondre ET la date ne doit pas être expirée
    $stmt = $db->prepare("SELECT nom, prenom FROM UTILISATEURS WHERE email = :email AND token_recuperation = :code AND date_expiration_token > NOW()");
    $stmt->execute([':email' => $email, ':code' => $code]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        // Code valide : On autorise l'étape suivante
        $_SESSION['reset_authorized'] = true;
        $_SESSION['reset_user_name'] = $user['prenom'] . ' ' . substr($user['nom'], 0, 1) . '.';
        Flight::redirect('/mot-de-passe-oublie/nouveau');
    } else {
        Flight::render('mdp/etape2_code.tpl', ['error' => 'Code invalide ou expiré.']);
    }
});

// ÉTAPE 3 : NOUVEAU MOT DE PASSE
Flight::route('GET /mot-de-passe-oublie/nouveau', function(){
    // Sécurité : Vérification de l'autorisation de l'étape 2
    if(!isset($_SESSION['reset_authorized'])) {
        Flight::redirect('/mot-de-passe-oublie');
        return;
    }
    
    $nomAffiche = $_SESSION['reset_user_name'] ?? 'Utilisateur';
    Flight::render('mdp/etape3_nouveau.tpl', ['titre' => 'Nouveau mot de passe', 'nom_user' => $nomAffiche]);
});

Flight::route('POST /mot-de-passe-oublie/save', function(){
    $mdp = Flight::request()->data->mdp;
    $confirm = Flight::request()->data->confirm_mdp;
    $email = $_SESSION['reset_email'];

    // Vérification correspondance
    if ($mdp !== $confirm) {
        Flight::render('mdp/etape3_nouveau.tpl', ['error' => 'Les mots de passe ne correspondent pas.']);
        return;
    }

    // Vérification complexité (Regex : 8 chars, 1 chiffre, 1 spécial)
    $regexMdp = '/^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/';
    if (!preg_match($regexMdp, $mdp)) {
        Flight::render('mdp/etape3_nouveau.tpl', ['error' => 'Le mot de passe doit contenir 8 caractères, 1 chiffre et 1 caractère spécial (@$!%*#?&).']);
        return;
    }

    // Mise à jour du mot de passe et nettoyage du token
    $hash = password_hash($mdp, PASSWORD_BCRYPT);
    $db = Flight::get('db');

    $stmt = $db->prepare("UPDATE UTILISATEURS SET mot_de_passe = :hash, token_recuperation = NULL, date_expiration_token = NULL WHERE email = :email");
    $stmt->execute([':hash' => $hash, ':email' => $email]);

    // Nettoyage de la session de réinitialisation
    unset($_SESSION['reset_email']);
    unset($_SESSION['reset_authorized']);
    unset($_SESSION['reset_user_name']);
    if (file_exists('../code_mail.txt')) unlink('../code_mail.txt');

    Flight::redirect('/connexion?msg=mdp_updated');
});
?>