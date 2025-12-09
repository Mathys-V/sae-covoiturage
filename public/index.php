
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

// -----------------------------------------------------------
// DÉMARRAGE
// -----------------------------------------------------------


Flight::start();
?>