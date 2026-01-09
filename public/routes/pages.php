<?php

// ============================================================
// PARTIE 1 : PAGES STATIQUES DU FOOTER
// ============================================================

// Page FAQ (Foire Aux Questions)
Flight::route('/faq', function(){
    Flight::render('pages_footer/faq.tpl', ['titre' => 'FAQ Covoiturage']);
});

// Page de Contact (Affichage du formulaire)
Flight::route('GET /contact', function(){
    Flight::render('pages_footer/contact.tpl', [
        'titre' => 'Nous contacter'
    ]);
});

// Page de Contact (Traitement du formulaire)
Flight::route('POST /contact', function(){
    $data = Flight::request()->data;
    
    // 1. Validation basique des champs requis
    if(empty($data->email) || empty($data->message)) {
        $_SESSION['flash_error'] = "Veuillez remplir tous les champs.";
        Flight::redirect('/contact');
        return;
    }

    // 2. Préparation du contenu du "Faux Email" (Simulation)
    $timestamp = date('Y-m-d H:i:s');
    $contenu = "=== NOUVEAU MESSAGE DE CONTACT (SIMULATION) ===\n";
    $contenu .= "Date réception : " . $timestamp . "\n";
    $contenu .= "De : " . $data->email . "\n";
    $contenu .= "Sujet (Problème) : " . $data->problem . "\n";
    $contenu .= "------------------------------------------------\n";
    $contenu .= "Message :\n";
    $contenu .= $data->message . "\n";
    $contenu .= "================================================\n";

    // 3. Création du dossier de stockage s'il n'existe pas
    $dossier = 'emails_simules'; // Le dossier sera à la racine du projet
    if (!is_dir($dossier)) {
        mkdir($dossier, 0777, true);
    }

    // 4. Écriture dans un fichier texte unique (Simule l'envoi SMTP)
    $nomFichier = 'contact_' . date('Y-m-d_His') . '.txt';
    file_put_contents($dossier . '/' . $nomFichier, $contenu);

    // 5. Notification de succès et redirection
    $_SESSION['flash_success'] = "Votre message a bien été simulé ! (Voir dossier '$dossier')";
    Flight::redirect('/contact');
});

// ============================================================
// PARTIE 2 : CARTE INTERACTIVE (Doublon partiel de carte.php)
// ============================================================
// Note : Cette route semble être une copie de celle dans carte.php. 
// Si carte.php est inclus, celle-ci pourrait être redondante.

Flight::route('/carte', function(){
    $db = Flight::get('db');

    // A. Récupération des lieux fréquents (Points d'intérêt)
    $stmt = $db->query("SELECT * FROM LIEUX_FREQUENTS");
    $lieux = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // B. Récupération des trajets actifs pour les afficher sur la carte
    $stmt2 = $db->query("SELECT * FROM TRAJETS WHERE statut_flag = 'A'");
    $trajets = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    // C. ATTRIBUTION MANUELLE DES COORDONNÉES GPS (PHP)
    // On surcharge les données BDD avec des coordonnées précises pour l'affichage Leaflet
    foreach($lieux as &$lieu) {
        $nom = strtolower($lieu['nom_lieu']);
        $ville = strtolower($lieu['ville']);

        // 1. IUT d'Amiens
        if (strpos($nom, 'iut') !== false) {
            $lieu['latitude'] = 49.870683;
            $lieu['longitude'] = 2.264032;
        } 
        // 2. Gare d'Amiens
        elseif (strpos($nom, 'gare') !== false && strpos($ville, 'amiens') !== false) {
            $lieu['latitude'] = 49.890583; 
            $lieu['longitude'] = 2.306739;
        }
        // 3. Gare de Longueau
        elseif (strpos($nom, 'gare') !== false && strpos($ville, 'longueau') !== false) {
            $lieu['latitude'] = 49.864238; 
            $lieu['longitude'] = 2.353159;
        }
        // 4. Mairie de Dury
        elseif (strpos($ville, 'dury') !== false) {
            $lieu['latitude'] = 49.846271; 
            $lieu['longitude'] = 2.268248;
        }
        // 5. Centre-ville de Longueau
        elseif (strpos($ville, 'longueau') !== false) {
            $lieu['latitude'] = 49.86830; 
            $lieu['longitude'] = 2.35780;
        }
        // 6. Amiens Centre / Boulevard Faidherbe
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

    Flight::render('carte/carte.tpl', [
        'titre' => 'Carte',
        'lieux_frequents' => $lieux,
        'trajets' => $trajets
    ]);
});

// ============================================================
// PARTIE 3 : GESTION DES COOKIES
// ============================================================

// Affichage de la page de choix des cookies (AVEC MÉMOIRE)
Flight::route('GET /cookies', function(){
    
    // 1. Valeurs par défaut (Premier visiteur)
    $consent = [
        'performance' => 1, // On propose "Accepter" par défaut
        'marketing'   => 0  // On propose "Refuser" par défaut
    ];

    // 2. Si l'utilisateur a déjà choisi, on récupère ses préférences
    if (isset($_COOKIE['cookie_consent'])) {
        $saved = json_decode($_COOKIE['cookie_consent'], true);
        if (is_array($saved)) {
            $consent = array_merge($consent, $saved); // On écrase les défauts avec les choix sauvegardés
        }
    }

    Flight::render('pages_footer/cookies.tpl', [
        'titre' => 'Gestion des cookies',
        'consent' => $consent
    ]);
});

// Enregistrement des préférences Cookies
Flight::route('POST /cookies/save', function(){
    $data = Flight::request()->data;
    
    // Récupération des choix du formulaire
    $preferences = [
        'performance' => isset($data->perf) ? (int)$data->perf : 0,
        'marketing'   => isset($data->marketing) ? (int)$data->marketing : 0
    ];

    // Stockage dans un cookie "maître" valable 1 an (365 jours)
    setcookie('cookie_consent', json_encode($preferences), time() + (86400 * 365), "/");

    // LOGIQUE DE NETTOYAGE :
    // Si l'utilisateur refuse les cookies de performance, on doit supprimer l'historique de recherche existant
    if ($preferences['performance'] == 0) {
        setcookie('historique_recherche', '', time() - 3600, "/");
    }

    // Redirection vers l'accueil
    Flight::redirect('/');
});

// Page Mentions Légales
Flight::route('/mentions_legales', function(){
    Flight::render('pages_footer/mentions_legales.tpl', ['titre' => 'Mentions_Legales']);
});

?>