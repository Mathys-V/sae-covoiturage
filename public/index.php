
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

Flight::route('/', function(){
    Flight::render('accueil.tpl', ['nom' => 'Equipe W']);
});

// -----------------------------------------------------------
// DÉMARRAGE
// -----------------------------------------------------------
Flight::start();
?>