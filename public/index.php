
<?php
require '../vendor/autoload.php';
require '../app/config/db.php';
use Smarty\Smarty;

// -----------------------------------------------------------
// CONFIGURATION SMARTY & FLIGHT
// -----------------------------------------------------------

// 1. On enregistre Smarty dans Flight.
// IMPORTANT : On doit utiliser 'Smarty\Smarty' et non juste 'Smarty'
Flight::register('view', 'Smarty\Smarty', [], function($smarty) {
    // On configure l'objet Smarty une fois qu'il est créé par Flight
    $smarty->setTemplateDir('../app/views/templates');
    $smarty->setCompileDir('../tmp/templates_c');
    // On peut ajouter d'autres configs ici si besoin (cache, config, etc.)
});

// 2. On crée une méthode "render" simplifiée pour appeler la vue
Flight::map('render', function($template, $data){
    Flight::view()->assign($data);
    Flight::view()->display($template);
});

// -----------------------------------------------------------
// ROUTES
// -----------------------------------------------------------

// 1. Accueil
Flight::route('/', function(){
    Flight::render('accueil.tpl', ['nom' => 'Equipe W']);
});

// 2. Connexion (Simplifié)
Flight::route('/connexion', function(){
    Flight::render('connexion.tpl', ['titre' => 'Se connecter']);
});

// 3. Inscription
Flight::route('/inscription', function(){
    Flight::render('inscription.tpl', ['titre' => 'S\'inscrire']);
});

// 4. FAQ
Flight::route('/faq', function(){
    Flight::render('faq.tpl', ['titre' => 'FAQ Covoiturage']);
});

// 5. Carte
Flight::route('/carte', function(){
    Flight::render('carte.tpl', ['titre' => 'Carte']);
});

// 6. PAGE DE RECHERCHE (Affiche le formulaire et l'historique)
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

// 7. TRAITEMENT DE LA RECHERCHE (Sauvegarde + Résultats)
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

//8 Page cookies 
Flight::route('GET /cookies', function(){
    Flight::render('cookies.tpl', ['titre' => 'Gestion des cookies']);
});
//9 Page cookies préférences
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

// -----------------------------------------------------------
// DÉMARRAGE
// -----------------------------------------------------------


Flight::start();
?>