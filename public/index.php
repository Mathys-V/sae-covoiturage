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

        // --- CALCUL NOTIFICATIONS (CORRIGÉ) ---
        try {
            $db = Flight::get('db');
            $userId = $_SESSION['user']['id_utilisateur'];
            
            // 1. Récupérer les trajets de l'utilisateur
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
                $idsString = implode(',', $mesTrajets);
                
                // On récupère les messages des autres
                $sqlMsgs = "SELECT id_trajet, date_envoi FROM MESSAGES 
                            WHERE id_trajet IN ($idsString) 
                            AND id_expediteur != :uid";
                
                $stmtMsgs = $db->prepare($sqlMsgs);
                $stmtMsgs->execute([':uid' => $userId]);
                $allMessages = $stmtMsgs->fetchAll(PDO::FETCH_ASSOC);

                foreach($allMessages as $msg) {
                    $tid = $msg['id_trajet'];
                    // --- FIX : On ajoute l'ID User dans le nom du cookie ---
                    $cookieName = 'last_read_' . $userId . '_' . $tid;
                    
                    // Si pas de cookie, date par défaut très vieille (tout est non lu)
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

    // Gestion Flash Messages
    if(isset($_SESSION['flash_success'])){
        $data['flash_success'] = $_SESSION['flash_success'];
        unset($_SESSION['flash_success']); 
    }
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
require 'routes/signalements.php'; // Signaler un utilisateur
require 'routes/admin.php'; // Admin - Modération


// -----------------------------------------------------------
// DÉMARRAGE
// -----------------------------------------------------------

Flight::start();
?>

