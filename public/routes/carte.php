<?php

Flight::route('/carte', function(){
    $db = Flight::get('db');

    // A. Récupérer les lieux depuis la BDD
    $stmt = $db->query("SELECT * FROM LIEUX_FREQUENTS");
    $lieux = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // B. Récupérer les trajets actifs pour les afficher sur la carte
    $stmt2 = $db->query("SELECT * FROM TRAJETS WHERE statut_flag = 'A'");
    $trajets = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    // C. GESTION DES COORDONNÉES PRÉCISES (Logique PHP)
    // Cette partie prend de la place mais elle est essentielle pour placer les points correctement
    foreach($lieux as &$lieu) {
        $nom = strtolower($lieu['nom_lieu']);
        $ville = strtolower($lieu['ville']);

        // 1. IUT d'Amiens (Entrée principale)
        if (strpos($nom, 'iut') !== false) {
            $lieu['latitude'] = 49.870683;
            $lieu['longitude'] = 2.264032;
        } 
        // 2. Gare d'Amiens (Parvis)
        elseif (strpos($nom, 'gare') !== false && strpos($ville, 'amiens') !== false) {
            $lieu['latitude'] = 49.890583; 
            $lieu['longitude'] = 2.306739;
        }
        // 3. Gare de Longueau
        elseif (strpos($nom, 'gare') !== false && strpos($ville, 'longueau') !== false) {
            $lieu['latitude'] = 49.864238; 
            $lieu['longitude'] = 2.353159;
        }
        // 4. Mairie de Dury
        elseif (strpos($ville, 'dury') !== false) {
            $lieu['latitude'] = 49.846271; 
            $lieu['longitude'] = 2.268248;
        }
        // 5. Centre-ville de Longueau
        elseif (strpos($ville, 'longueau') !== false) {
            $lieu['latitude'] = 49.86830; 
            $lieu['longitude'] = 2.35780;
        }
        // 6. Amiens Centre / Boulevard Faidherbe
        elseif (strpos($ville, 'amiens') !== false && strpos($nom, 'faidherbe') !== false) {
            $lieu['latitude'] = 49.88720; 
            $lieu['longitude'] = 2.30890;
        }
        // Par défaut (Centre Amiens)
        else {
            $lieu['latitude'] = 49.89407; 
            $lieu['longitude'] = 2.29575;
        }
    }

    Flight::render('carte.tpl', [
        'titre' => 'Carte interactive',
        'lieux_frequents' => $lieux,
        'trajets' => $trajets
    ]);
});
?>