
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

// 6. Page de recherche (Formulaire)
Flight::route('GET /recherche', function(){
    // TODO: Récupérer l'historique des recherches en BDD (plus tard)
    // Pour l'instant on envoie un tableau vide
    Flight::render('recherche.tpl', [
        'titre' => 'Rechercher un trajet',
        'historique' => [] // Vide pour l'instant
    ]);
});

// 7. Page de résultats (Traitement du formulaire)
Flight::route('GET /recherche/resultats', function(){
    // Récupérer les données du formulaire
    $depart = Flight::request()->query->depart;
    $arrivee = Flight::request()->query->arrivee;
    $date = Flight::request()->query->date;

    // Connexion BDD
    $db = Flight::get('db');
    
    // Requête SQL (Version simple pour commencer)
    // On cherche les trajets qui correspondent au départ/arrivée et à la date
    // On joint avec UTILISATEURS pour avoir le nom du conducteur
    // On joint avec VEHICULES (via POSSESSIONS ou direct si simplifié) pour la voiture
    $sql = "SELECT t.*, u.prenom, u.nom, u.photo_profil, v.marque, v.modele, v.details_supplementaires
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