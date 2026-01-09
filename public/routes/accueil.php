<?php

// Définition de la route pour la page d'accueil (racine du site)
Flight::route('/', function(){
    
    // Récupération de l'instance de la base de données enregistrée dans Flight
    $db = Flight::get('db');

    // 1. Récupération des Lieux Fréquents
    // On sélectionne tous les lieux prédéfinis (ex: Gare, IUT) pour les suggérer à l'utilisateur
    $stmt = $db->query("SELECT * FROM LIEUX_FREQUENTS ORDER BY nom_lieu ASC");
    $lieux_frequents = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 2. Gestion de l'historique de recherche
    // On initialise un tableau vide par défaut
    $derniere_recherche = [];
    
    // Si un cookie d'historique existe, on tente de le récupérer
    if(isset($_COOKIE['historique_recherche'])) {
        // On décode le JSON stocké dans le cookie pour le transformer en tableau PHP
        $json = json_decode($_COOKIE['historique_recherche'], true);
        
        // Sécurité : on vérifie que le résultat est bien un tableau avant de l'utiliser
        if(is_array($json)) {
            $derniere_recherche = $json;
        }
    }

    // 3. Affichage de la vue
    // On appelle le template Smarty 'accueil.tpl' en lui passant les variables nécessaires
    Flight::render('accueil/accueil.tpl', [
        'titre' => 'Accueil - Covoiturage IUT Amiens',
        'recherche_precedente' => $derniere_recherche, // Sert à pré-remplir ou afficher l'historique
        'lieux_frequents' => $lieux_frequents           // Sert pour l'autocomplétion
    ]);
});