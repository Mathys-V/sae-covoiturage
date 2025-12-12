
<?php
// Démarrage de la session OBLIGATOIRE pour mémoriser l'email entre les pages
session_start();
require '../vendor/autoload.php';
require '../app/config/db.php';
use Smarty\Smarty;

// -----------------------------------------------------------
// CONFIGURATION SMARTY & FLIGHT
// -----------------------------------------------------------

// -----------------------------------------------------------
// CONFIGURATION SMARTY & FLIGHT
// -----------------------------------------------------------

// 1. On enregistre Smarty
Flight::register('view', 'Smarty\Smarty', [], function($smarty) {
    $smarty->setTemplateDir('../app/views/templates');
    $smarty->setCompileDir('../tmp/templates_c');
});

// 2. MOTEUR DE RENDU (Mise à jour pour gérer les ERREURS)
Flight::map('render', function($template, $data){
    
    if (!is_array($data)) { $data = []; }

    // Injection Utilisateur
    if(isset($_SESSION['user'])){
        $data['user'] = $_SESSION['user'];
    }

    // Injection Succès (Vert)
    if(isset($_SESSION['flash_success'])){
        $data['flash_success'] = $_SESSION['flash_success'];
        unset($_SESSION['flash_success']); 
    }

    // --- NOUVEAU : Injection Erreur (Rouge) ---
    if(isset($_SESSION['flash_error'])){
        $data['flash_error'] = $_SESSION['flash_error'];
        unset($_SESSION['flash_error']); 
    }

    Flight::view()->assign($data);
    Flight::view()->display($template);
});

// -----------------------------------------------------------
// ROUTES
// -----------------------------------------------------------

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
                ':modele' => $data->model,
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

Flight::route('/mes_trajets', function(){
    Flight::render('mes_trajets.tpl', ['titre' => 'Mes trajets']);
});

// FAQ
Flight::route('/faq', function(){
    Flight::render('faq.tpl', ['titre' => 'FAQ Covoiturage']);
});

// Contact
Flight::route('/contact', function(){
    Flight::render('contact.tpl', ['titre' => 'Contactez-nous']);
});

// 5. Carte (AVEC GESTION DES COORDONNÉES EN PHP)

Flight::route('/carte', function(){
    $db = Flight::get('db');

    // A. Récupérer les lieux depuis la BDD
    $stmt = $db->query("SELECT * FROM LIEUX_FREQUENTS");
    $lieux = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // B. Récupérer les trajets pour les filtres
    $stmt2 = $db->query("SELECT * FROM TRAJETS WHERE statut_flag = 'A'");
    $trajets = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    // C. ASTUCE : On ajoute les coordonnées PRÉCISES en PHP
    foreach($lieux as &$lieu) {
        $nom = strtolower($lieu['nom_lieu']);
        $ville = strtolower($lieu['ville']);

        // 1. IUT d'Amiens (Entrée principale, Avenue des Facultés)
        if (strpos($nom, 'iut') !== false) {
            $lieu['latitude'] = 49.870683;
            $lieu['longitude'] = 2.264032;
        } 
        // 2. Gare d'Amiens (Parvis de la gare, Place Alphonse Fiquet)
        elseif (strpos($nom, 'gare') !== false && strpos($ville, 'amiens') !== false) {
            $lieu['latitude'] = 49.890583; 
            $lieu['longitude'] = 2.306739;
        }
        // 3. Gare de Longueau (Devant le bâtiment voyageurs)
        elseif (strpos($nom, 'gare') !== false && strpos($ville, 'longueau') !== false) {
            $lieu['latitude'] = 49.864238; 
            $lieu['longitude'] = 2.353159;
        }
        // 4. Mairie de Dury (Place de la Mairie)
        elseif (strpos($ville, 'dury') !== false) {
            $lieu['latitude'] = 49.846271; 
            $lieu['longitude'] = 2.268248;
        }
        // 5. Centre-ville de Longueau (Mairie de Longueau par défaut)
        elseif (strpos($ville, 'longueau') !== false) {
            $lieu['latitude'] = 49.86830; 
            $lieu['longitude'] = 2.35780;
        }
        // 6. Amiens Centre / Boulevard Faidherbe (Coordonnées exactes du boulevard)
        elseif (strpos($ville, 'amiens') !== false && strpos($nom, 'faidherbe') !== false) {
            $lieu['latitude'] = 49.88720; 
            $lieu['longitude'] = 2.30890;
        }
        // Par défaut (Centre Amiens)
        else {
            $lieu['latitude'] = 49.89407; 
            $lieu['longitude'] = 2.29575;
        }
    }

    Flight::render('carte.tpl', [
        'titre' => 'Carte',
        'lieux_frequents' => $lieux,
        'trajets' => $trajets
    ]);
});

// PAGE DE RECHERCHE (Affiche le formulaire et l'historique)
Flight::route('GET /recherche', function(){
    // On récupère le cookie 'historique_recherche'
    $historique = [];
    if(isset($_COOKIE['historique_recherche'])) {
        // Le cookie contient du JSON, on le décode en tableau PHP
        $historique = json_decode($_COOKIE['historique_recherche'], true);
    }

    Flight::render('recherche.tpl', [
        'titre' => 'Rechercher un trajet',
        'historique' => array_reverse($historique) // On inverse pour avoir les plus récents en haut
    ]);
});

// TRAITEMENT DE LA RECHERCHE (Sauvegarde + Résultats)
Flight::route('GET /recherche/resultats', function(){
    $depart = Flight::request()->query->depart;
    $arrivee = Flight::request()->query->arrivee;
    $date = Flight::request()->query->date;

    // --- 1. GESTION DE L'HISTORIQUE (COOKIES) ---
    // On vérifie d'abord si l'utilisateur a accepté les cookies de performance
    $consent = ['performance' => 1]; // Par défaut on accepte (ou 0 selon ta politique)
    if (isset($_COOKIE['cookie_consent'])) {
        $consent = json_decode($_COOKIE['cookie_consent'], true);
    }

    // Si l'utilisateur a accepté la performance, on sauvegarde l'historique
    if ($consent['performance'] == 1) {
        
        $nouvelleRecherche = [
            'depart' => $depart,
            'arrivee' => $arrivee,
            'date' => $date,
            'timestamp' => time()
        ];

        $historique = [];
        if(isset($_COOKIE['historique_recherche'])) {
            $historique = json_decode($_COOKIE['historique_recherche'], true);
        }

        // On filtre pour enlever les doublons exacts
        $historique = array_filter($historique, function($h) use ($nouvelleRecherche) {
            return !($h['depart'] == $nouvelleRecherche['depart'] 
                && $h['arrivee'] == $nouvelleRecherche['arrivee'] 
                && $h['date'] == $nouvelleRecherche['date']);
        });

        // On ajoute la nouvelle à la fin
        $historique[] = $nouvelleRecherche;

        // On garde seulement les 3 dernières
        if(count($historique) > 3) {
            $historique = array_slice($historique, -3);
        }

        // On sauvegarde le Cookie (Valable 30 jours)
        setcookie('historique_recherche', json_encode($historique), time() + (86400 * 30), "/");
    } 
    // FIN DU IF COOKIES : Le code continue pour afficher les résultats même si refusé

    // --- 2. REQUÊTE SQL (RECHERCHE) ---
    $db = Flight::get('db');
    
    // On récupère les trajets qui correspondent + infos conducteur + infos voiture
    $sql = "SELECT t.*, u.prenom, u.nom, u.photo_profil, v.marque, v.modele
            FROM TRAJETS t
            JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
            JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
            WHERE t.ville_depart LIKE :depart 
            AND t.ville_arrivee LIKE :arrivee
            AND t.date_heure_depart >= :date
            AND t.statut_flag = 'A'"; // A = Actif
            
    $stmt = $db->prepare($sql);
    $stmt->execute([
        ':depart' => "%$depart%", 
        ':arrivee' => "%$arrivee%",
        ':date' => $date . ' 00:00:00' // À partir de minuit ce jour-là
    ]);
    
    $trajets = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // --- 3. AFFICHAGE ---
    Flight::render('resultats_recherche.tpl', [
        'titre' => 'Résultats',
        'trajets' => $trajets,
        'recherche' => ['depart' => $depart, 'arrivee' => $arrivee, 'date' => $date]
    ]);
});

//Page cookies 
// Afficher la page de choix des cookies (AVEC MÉMOIRE)
Flight::route('GET /cookies', function(){
    
    // 1. Valeurs par défaut (si l'utilisateur vient pour la première fois)
    $consent = [
        'performance' => 1, // On propose "Accepter" par défaut
        'marketing'   => 0  // On propose "Refuser" par défaut
    ];

    // 2. Si le cookie existe déjà, on écrase avec les choix de l'utilisateur
    if (isset($_COOKIE['cookie_consent'])) {
        $saved = json_decode($_COOKIE['cookie_consent'], true);
        // Sécurité : on s'assure que c'est bien un tableau avant de fusionner
        if (is_array($saved)) {
            $consent = array_merge($consent, $saved);
        }
    }

    // 3. On envoie la variable $consent à la vue Smarty
    Flight::render('cookies.tpl', [
        'titre' => 'Gestion des cookies',
        'consent' => $consent
    ]);
});

//Page cookies préférences
Flight::route('POST /cookies/save', function(){
    $data = Flight::request()->data;
    
    // On crée un tableau des préférences
    $preferences = [
        'performance' => isset($data->perf) ? (int)$data->perf : 0,
        'marketing'   => isset($data->marketing) ? (int)$data->marketing : 0
    ];

    // On stocke ce choix dans un cookie "maitre" valable 1 an
    setcookie('cookie_consent', json_encode($preferences), time() + (86400 * 365), "/");

    // Si l'utilisateur refuse la performance, on supprime l'historique existant !
    if ($preferences['performance'] == 0) {
        setcookie('historique_recherche', '', time() - 3600, "/");
    }

    // Redirection vers l'accueil ou message de succès
    Flight::redirect('/');
});

// Mentions légales
Flight::route('/mentions_legales', function(){
    Flight::render('mentions_legales.tpl', ['titre' => 'Mentions_Legales']);
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

    // Hashage et sauvegarde [cite: 904]
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



// ============================================================
// GESTION DES TRAJETS (PROPOSER)
// ============================================================

// 1. AFFICHER LE FORMULAIRE (Route GET)


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

    // --- AJOUT EXPERT : Récupérer les Lieux Fréquents ---
    $stmtLieux = $db->query("SELECT * FROM LIEUX_FREQUENTS");
    $lieux = $stmtLieux->fetchAll(PDO::FETCH_ASSOC);

    Flight::render('proposer_trajet.tpl', [
        'titre' => 'Proposer un trajet',
        'lieux_frequents' => $lieux // On envoie les lieux à la vue
    ]);
});

// 2. TRAITEMENT DU FORMULAIRE (Route POST)
// TRAITEMENT DU FORMULAIRE
Flight::route('POST /trajet/nouveau', function(){
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion');

    $data = Flight::request()->data;
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // 1. Véhicule
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
            
            // On insère l'adresse complète dans ville_depart/arrivee
            // C'est temporaire mais ça suffit pour le géocodage sur la carte
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
                ':depart'     => $data->depart, // Contient maintenant "15 Rue X, Amiens"
                ':arrivee'    => $data->arrivee,
                ':dateheure'  => $dateDebut->format('Y-m-d H:i:s'),
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

// PAGE PROFIL
Flight::route('GET /profil', function(){
    // On vérifie si l'utilisateur est connecté, sinon on le vire vers la connexion
    if(!isset($_SESSION['user'])) {
        Flight::redirect('/connexion');
        return;
    }

    Flight::render('profil.tpl', ['titre' => 'Mon Profil']);
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
// DÉMARRAGE
// -----------------------------------------------------------


Flight::start();
?>

