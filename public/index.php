<?php
// Démarrage de la session OBLIGATOIRE
session_start();

// 1. CHARGEMENT DES DÉPENDANCES
require '../vendor/autoload.php';
require '../app/config/db.php';

use Smarty\Smarty;

// ===========================================================
// 1. DÉFINITION DES LISTES GLOBALES
// ===========================================================
$GLOBALS['voiture_marques'] = [
    'Abarth', 'Alfa Romeo', 'Alpine', 'Audi', 'Bentley', 'BMW', 'Citroen', 'Cupra', 
    'Dacia', 'DS', 'Ferrari', 'Fiat', 'Ford', 'Honda', 'Hyundai', 'Jaguar', 'Jeep', 
    'Kia', 'Lamborghini', 'Land Rover', 'Lexus', 'Maserati', 'Mazda', 'McLaren', 
    'Mercedes', 'MG', 'Mini', 'Mitsubishi', 'Nissan', 'Opel', 'Peugeot', 'Porsche', 
    'Renault', 'Seat', 'Skoda', 'Smart', 'Subaru', 'Suzuki', 'Tesla', 'Toyota', 
    'Volkswagen', 'Volvo', 'Autre'
];

$GLOBALS['voiture_couleurs'] = [
    'Blanc', 'Noir', 'Gris', 'Argent', 'Bleu', 'Rouge', 'Marron', 'Beige', 
    'Vert', 'Jaune', 'Orange', 'Violet', 'Rose', 'Or', 'Autre'
];

// -----------------------------------------------------------
// 2. CONFIGURATION SMARTY & FLIGHT
// -----------------------------------------------------------

Flight::register('view', 'Smarty\Smarty', [], function($smarty) {
    $path = __DIR__ . '/../app/views/templates';
    $smarty->setTemplateDir($path);
    $smarty->setCompileDir(__DIR__ . '/../tmp/templates_c');

    // Injection des listes directement dans Smarty (Dispo partout)
    $smarty->assign('marques', $GLOBALS['voiture_marques']);
    $smarty->assign('couleurs', $GLOBALS['voiture_couleurs']);
});

Flight::map('render', function($template, $data){
    
    if (!is_array($data)) { $data = []; }

    // Injection Utilisateur
    if(isset($_SESSION['user'])){
        $data['user'] = $_SESSION['user'];

        // --- CALCUL NOTIFICATIONS ---
        try {
            $db = Flight::get('db');
            $userId = $_SESSION['user']['id_utilisateur'];
            
            $sqlIds = "SELECT t.id_trajet FROM TRAJETS t
                       LEFT JOIN RESERVATIONS r ON t.id_trajet = r.id_trajet
                       WHERE t.id_conducteur = :uid OR (r.id_passager = :uid AND r.statut_code = 'V')
                       GROUP BY t.id_trajet";
            
            $stmtIds = $db->prepare($sqlIds);
            $stmtIds->execute([':uid' => $userId]);
            $mesTrajets = $stmtIds->fetchAll(PDO::FETCH_COLUMN);

            $countNotifs = 0;

            if (!empty($mesTrajets)) {
                $idsString = implode(',', $mesTrajets);
                $sqlMsgs = "SELECT id_trajet, date_envoi, id_expediteur, contenu FROM MESSAGES 
                            WHERE id_trajet IN ($idsString) AND (id_expediteur != :uid OR contenu LIKE '::sys_%')";
                
                $stmtMsgs = $db->prepare($sqlMsgs);
                $stmtMsgs->execute([':uid' => $userId]);
                $allMessages = $stmtMsgs->fetchAll(PDO::FETCH_ASSOC);

                foreach($allMessages as $msg) {
                    $tid = $msg['id_trajet'];
                    $cookieName = 'last_read_' . $userId . '_' . $tid;
                    $lastRead = isset($_COOKIE[$cookieName]) ? $_COOKIE[$cookieName] : '2000-01-01 00:00:00';
                    if ($msg['date_envoi'] > $lastRead) {
                        $countNotifs++;
                    }
                }
            }
            $data['nb_notifs'] = ($countNotifs > 99) ? '99+' : $countNotifs;
        } catch (Exception $e) { $data['nb_notifs'] = 0; }
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
// 3. CHARGEMENT DES ROUTES
// -----------------------------------------------------------

require 'routes/accueil.php'; 
require 'routes/pages.php';      
require 'routes/auth.php';       
require 'routes/profil.php';      // Toutes les routes profil sont ici maintenant
require 'routes/messagerie.php'; 
require 'routes/trajets.php';    
require 'routes/recherche.php';  
require 'routes/reservation.php';
require 'routes/carte.php';      
require 'routes/avis.php';       
require 'routes/signalements.php';
require 'routes/admin.php';      
require 'routes/profil_public.php'; 

// -----------------------------------------------------------
// DÉMARRAGE
// -----------------------------------------------------------

Flight::start();





?>