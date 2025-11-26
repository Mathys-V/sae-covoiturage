<?php
require '../../vendor/autoload.php';
require '../../app/config/db.php';

// 1. Configuration de Smarty
$smarty = new Smarty();
$smarty->setTemplateDir('../../app/views/templates');
$smarty->setCompileDir('../../tmp/templates_c');

// 2. Configuration de Flight pour utiliser Smarty
Flight::register('view', 'Smarty', [], function($smarty) {
    return $smarty;
});

Flight::map('render', function($template, $data){
    Flight::view()->assign($data);
    Flight::view()->display($template);
});

// 3. Vos Routes
Flight::route('/', function(){
    Flight::render('accueil.tpl', ['nom' => 'Equipe W']);
});

// 4. Démarrage
Flight::start();
?>