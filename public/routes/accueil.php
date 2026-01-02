<?php

Flight::route('/', function(){
    $db = Flight::get('db');

    // 1. Récupérer les Lieux Fréquents (pour l'autocomplétion)
    $stmt = $db->query("SELECT * FROM LIEUX_FREQUENTS ORDER BY nom_lieu ASC");
    $lieux_frequents = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 2. Gestion de l'historique (Cookie)
    $derniere_recherche = [];
    if(isset($_COOKIE['historique_recherche'])) {
        $json = json_decode($_COOKIE['historique_recherche'], true);
        if(is_array($json)) {
            $derniere_recherche = $json;
        }
    }

    // 3. Affichage de la vue
    Flight::render('accueil.tpl', [
        'titre' => 'Accueil - Covoiturage IUT Amiens',
        'recherche_precedente' => $derniere_recherche,
        'lieux_frequents' => $lieux_frequents // On passe les données à la vue
    ]);
});