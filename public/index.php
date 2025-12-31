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

    // ===========================================================
    // CORRECTION ICI : On utilise les noms exacts "marques" et "couleurs"
    // ===========================================================
    $data['marques'] = $GLOBALS['voiture_marques'];   // <-- C'est le nom utilisé dans inscription.tpl
    $data['couleurs'] = $GLOBALS['voiture_couleurs']; // <-- C'est le nom utilisé dans inscription.tpl

    Flight::view()->assign($data);
    Flight::view()->display($template);
});

// -----------------------------------------------------------
// 3. CHARGEMENT DES ROUTES
// -----------------------------------------------------------

require 'routes/pages.php';      
require 'routes/auth.php';       
require 'routes/profil.php';     
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
// ROUTE UPDATE VÉHICULE (SÉCURITÉ)
// -----------------------------------------------------------
Flight::route('POST /profil/update-vehicule', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $data = Flight::request()->data;
    $idUser = $_SESSION['user']['id_utilisateur'];
    $db = Flight::get('db');

    $marqueInput = ucfirst(strtolower(trim($data->marque)));
    $couleurInput = ucfirst(strtolower(trim($data->couleur)));
    $modele = strip_tags(trim($data->modele));
    $nb_places = (int)$data->nb_places;
    $immat = strtoupper(trim(str_replace([' ', '-'], '', $data->immat)));

    if (!in_array($marqueInput, $GLOBALS['voiture_marques'])) {
        $_SESSION['flash_error'] = "Marque invalide."; Flight::redirect('/profil'); return;
    }
    if (!in_array($couleurInput, $GLOBALS['voiture_couleurs'])) {
        $_SESSION['flash_error'] = "Couleur invalide."; Flight::redirect('/profil'); return;
    }
    if (strlen($modele) > 30) { $_SESSION['flash_error'] = "Modèle trop long."; Flight::redirect('/profil'); return; }
    
    // Suite du traitement SQL (identique à avant)
    try {
        $stmtCheck = $db->prepare("SELECT id_vehicule FROM POSSESSIONS WHERE id_utilisateur = ? LIMIT 1");
        $stmtCheck->execute([$idUser]);
        $possede = $stmtCheck->fetch(PDO::FETCH_ASSOC);

        if ($possede) {
            $stmtUpd = $db->prepare("UPDATE VEHICULES SET marque=?, modele=?, couleur=?, nb_places_totales=?, immatriculation=? WHERE id_vehicule=?");
            $stmtUpd->execute([$marqueInput, $modele, $couleurInput, $nb_places, $immat, $possede['id_vehicule']]);
            $_SESSION['flash_success'] = "Véhicule modifié !";
        } else {
            $db->beginTransaction();
            $stmtIns = $db->prepare("INSERT INTO VEHICULES (marque, modele, couleur, nb_places_totales, immatriculation, type_vehicule) VALUES (?, ?, ?, ?, ?, 'voiture')");
            $stmtIns->execute([$marqueInput, $modele, $couleurInput, $nb_places, $immat]);
            $idNew = $db->lastInsertId();
            $db->prepare("INSERT INTO POSSESSIONS (id_utilisateur, id_vehicule) VALUES (?, ?)")->execute([$idUser, $idNew]);
            $db->commit();
            $_SESSION['flash_success'] = "Véhicule ajouté !";
        }
    } catch (Exception $e) {
        if($db->inTransaction()) $db->rollBack();
        $_SESSION['flash_error'] = "Erreur technique.";
    }
    Flight::redirect('/profil');
});

Flight::start();





?>