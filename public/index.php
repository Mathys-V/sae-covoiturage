
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

    // --- GESTION DE L'HISTORIQUE (COOKIES) ---
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

    // On évite les doublons (si la recherche existe déjà, on ne l'ajoute pas)
    // On filtre pour enlever une éventuelle recherche identique existante
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

    // --- REQUÊTE SQL (Code existant) ---
    $db = Flight::get('db');
    // ... (Votre code SQL actuel ici pour récupérer $trajets) ...
    // Pour l'exemple vide :
    $trajets = []; 

    Flight::render('resultats_recherche.tpl', [
        'titre' => 'Résultats',
        'trajets' => $trajets,
        'recherche' => ['depart' => $depart, 'arrivee' => $arrivee, 'date' => $date]
    ]);
});


// -----------------------------------------------------------
// DÉMARRAGE
// -----------------------------------------------------------


Flight::start();
?>