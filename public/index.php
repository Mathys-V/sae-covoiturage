<?php
// Démarrage de la session OBLIGATOIRE pour mémoriser l'email entre les pages
session_start();

// 1. CHARGEMENT DES DÉPENDANCES
// "vendor" et "app" sont au niveau racine, donc on remonte d'un cran (..) depuis "public"
require '../vendor/autoload.php';
require '../app/config/db.php';

use Smarty\Smarty;

// -----------------------------------------------------------
// CONFIGURATION SMARTY & FLIGHT
// -----------------------------------------------------------

Flight::register('view', 'Smarty\Smarty', [], function($smarty) {
    // Les templates sont dans app/views/templates (on remonte d'un cran)
    $path = __DIR__ . '/../app/views/templates';
    $smarty->setTemplateDir($path);
    $smarty->setCompileDir(__DIR__ . '/../tmp/templates_c');
});

// 2. MOTEUR DE RENDU
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

    // Injection Erreur (Rouge)
    if(isset($_SESSION['flash_error'])){
        $data['flash_error'] = $_SESSION['flash_error'];
        unset($_SESSION['flash_error']); 
    }

    Flight::view()->assign($data);
    Flight::view()->display($template);
});

// -----------------------------------------------------------
// CHARGEMENT DES ROUTES
// -----------------------------------------------------------

require 'routes/pages.php';      // Accueil, FAQ, Mentions...
require 'routes/auth.php';       // Connexion, Inscription, MDP...
require 'routes/profil.php';     // Profil, Véhicule...
require 'routes/messagerie.php'; // Messagerie
require 'routes/trajets.php';      // Proposer, Mes Trajets
require 'routes/recherche.php';    // Recherche, Résultats
require 'routes/reservation.php'; // Réserver, Mes Réservations, Annuler
require 'routes/carte.php';        // <-- La carte (Le fichier ajouté ci-dessus)

// -----------------------------------------------------------
// DÉMARRAGE
// -----------------------------------------------------------

Flight::start();
?>
