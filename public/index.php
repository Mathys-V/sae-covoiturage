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

Flight::map('render', function($template, $data){
    
    if (!is_array($data)) { $data = []; }

    // Injection Utilisateur
    if(isset($_SESSION['user'])){
        $data['user'] = $_SESSION['user'];

        // --- AJOUT : CALCUL DES NOTIFICATIONS (COMPATIBLE BDD FIGÉE) ---
        try {
            $db = Flight::get('db');
            $userId = $_SESSION['user']['id_utilisateur'];
            
            // 1. On récupère TOUS les trajets où l'utilisateur est impliqué (Conducteur OU Passager)
            $sqlIds = "SELECT t.id_trajet 
                       FROM TRAJETS t
                       LEFT JOIN RESERVATIONS r ON t.id_trajet = r.id_trajet
                       WHERE t.id_conducteur = :uid 
                       OR (r.id_passager = :uid AND r.statut_code = 'V')
                       GROUP BY t.id_trajet";
            
            $stmtIds = $db->prepare($sqlIds);
            $stmtIds->execute([':uid' => $userId]);
            $mesTrajets = $stmtIds->fetchAll(PDO::FETCH_COLUMN);

            $countNotifs = 0;

            if (!empty($mesTrajets)) {
                // 2. Pour chaque trajet, on regarde les messages
                // On crée une chaîne pour le IN (ex: "1, 2, 5")
                $idsString = implode(',', $mesTrajets);
                
                $sqlMsgs = "SELECT id_trajet, date_envoi FROM MESSAGES 
                            WHERE id_trajet IN ($idsString) 
                            AND id_expediteur != :uid"; // On ne compte pas ses propres messages
                
                $stmtMsgs = $db->prepare($sqlMsgs);
                $stmtMsgs->execute([':uid' => $userId]);
                $allMessages = $stmtMsgs->fetchAll(PDO::FETCH_ASSOC);

                foreach($allMessages as $msg) {
                    $tid = $msg['id_trajet'];
                    $cookieName = 'last_read_' . $tid;
                    
                    // Si pas de cookie, on considère tout comme non lu (ou on peut mettre une date par défaut)
                    $lastRead = isset($_COOKIE[$cookieName]) ? $_COOKIE[$cookieName] : '2000-01-01 00:00:00';
                    
                    if ($msg['date_envoi'] > $lastRead) {
                        $countNotifs++;
                    }
                }
            }
            
            $data['nb_notifs'] = ($countNotifs > 99) ? '99+' : $countNotifs;

        } catch (Exception $e) {
            $data['nb_notifs'] = 0;
        }
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
require 'routes/trajets.php';    // Proposer, Mes Trajets
require 'routes/recherche.php';  // Recherche, Résultats
require 'routes/reservation.php'; // Réserver, Mes Réservations, Annuler
require 'routes/carte.php';        // La carte

// -----------------------------------------------------------
// DÉMARRAGE
// -----------------------------------------------------------

Flight::start();
?>