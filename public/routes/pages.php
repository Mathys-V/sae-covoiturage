<?php
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


?>
