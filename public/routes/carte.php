<?php

Flight::route('/carte', function(){
    $db = Flight::get('db');
    $userId = isset($_SESSION['user']) ? $_SESSION['user']['id_utilisateur'] : 0;

    // 1. Lieux
    $stmt = $db->query("SELECT * FROM LIEUX_FREQUENTS");
    $lieux = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 2. Recherche Publique (Stricte : Futur + Actif + Pas moi)
    // On force l'exclusion du conducteur connecté
    $sqlPublic = "SELECT * FROM TRAJETS 
                  WHERE statut_flag = 'A' 
                  AND date_heure_depart >= NOW() 
                  AND id_conducteur != :uid 
                  ORDER BY date_heure_depart ASC";
    $stmt2 = $db->prepare($sqlPublic);
    $stmt2->execute([':uid' => $userId]);
    $trajets = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    // 3. Mes Données (Si connecté)
    $mesAnnonces = [];     
    $mesReservations = []; 

    if ($userId > 0) {
        // A. Mes Annonces (Tous les trajets de l'utilisateur, sans filtre de statut)
        // Même logique que dans mes_trajets.php
        $stmtCond = $db->prepare("
            SELECT *, 'conducteur' as mon_role 
            FROM TRAJETS 
            WHERE id_conducteur = :uid 
            ORDER BY date_heure_depart DESC
        ");
        $stmtCond->execute([':uid' => $userId]);
        $mesAnnonces = $stmtCond->fetchAll(PDO::FETCH_ASSOC);

        // B. Mes Réservations (Tout l'historique validé)
        $stmtPass = $db->prepare("
            SELECT t.*, 'passager' as mon_role, r.nb_places_reservees
            FROM RESERVATIONS r
            JOIN TRAJETS t ON r.id_trajet = t.id_trajet
            WHERE r.id_passager = :uid
            AND r.statut_code = 'V'
            ORDER BY t.date_heure_depart DESC
        ");
        $stmtPass->execute([':uid' => $userId]);
        $mesReservations = $stmtPass->fetchAll(PDO::FETCH_ASSOC);
    }

    // Gestion des coordonnées (simplifié ici pour la lisibilité, gardez votre bloc foreach existant)
    foreach($lieux as &$lieu) {
        if(!$lieu['latitude']) { // Fallback simple si pas de coordonnée
             $lieu['latitude'] = 49.89407; 
             $lieu['longitude'] = 2.29575; 
        }
    }

    Flight::render('carte/carte.tpl', [
        'titre' => 'Carte interactive',
        'lieux_frequents' => $lieux,
        'trajets' => $trajets,
        'mes_annonces' => $mesAnnonces, 
        'mes_reservations' => $mesReservations 
    ]);
});
?>