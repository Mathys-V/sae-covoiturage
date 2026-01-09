<?php

Flight::route('/carte', function(){
    $db = Flight::get('db');
    $userId = isset($_SESSION['user']) ? $_SESSION['user']['id_utilisateur'] : 0;

    // 1. Lieux
    $stmt = $db->query("SELECT * FROM LIEUX_FREQUENTS");
    $lieux = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 2. Recherche Publique (Stricte : Futur + Actif + Pas moi)
    $sqlPublic = "SELECT * FROM TRAJETS 
                  WHERE statut_flag = 'A' 
                  AND date_heure_depart >= NOW() 
                  AND id_conducteur != :uid 
                  ORDER BY date_heure_depart ASC";
    $stmt2 = $db->prepare($sqlPublic);
    $stmt2->execute([':uid' => $userId]);
    $trajets = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    // 3. Mes Données (Pour l'initialisation)
    $mesAnnonces = [];     
    $mesReservations = []; 

    if ($userId > 0) {
        // A. Mes Annonces (Filtre FUTUR ajouté)
        $stmtCond = $db->prepare("
            SELECT *, 'conducteur' as mon_role 
            FROM TRAJETS 
            WHERE id_conducteur = :uid 
            AND date_heure_depart >= NOW() 
            ORDER BY date_heure_depart ASC
        ");
        $stmtCond->execute([':uid' => $userId]);
        $mesAnnonces = $stmtCond->fetchAll(PDO::FETCH_ASSOC);

        // B. Mes Réservations (Filtre FUTUR ajouté)
        $stmtPass = $db->prepare("
            SELECT t.*, 'passager' as mon_role, r.nb_places_reservees
            FROM RESERVATIONS r
            JOIN TRAJETS t ON r.id_trajet = t.id_trajet
            WHERE r.id_passager = :uid
            AND r.statut_code = 'V'
            AND t.date_heure_depart >= NOW()
            ORDER BY t.date_heure_depart ASC
        ");
        $stmtPass->execute([':uid' => $userId]);
        $mesReservations = $stmtPass->fetchAll(PDO::FETCH_ASSOC);
    }

    // Gestion des coordonnées
    foreach($lieux as &$lieu) {
        if(!$lieu['latitude']) { 
             $lieu['latitude'] = 49.89407; 
             $lieu['longitude'] = 2.29575; 
        }
    }

    Flight::render('carte/carte.tpl', [
        'titre' => 'Carte interactive',
        'lieux_frequents' => $lieux,
        'trajets' => $trajets,
        'mes_annonces' => $mesAnnonces, 
        'mes_reservations' => $mesReservations,
        'user' => isset($_SESSION['user']) ? $_SESSION['user'] : null
    ]);
});

// ============================================================
// ROUTE API POUR LES BOUTONS (Avec filtre temporel)
// ============================================================
Flight::route('GET /api/mes-trajets-carte', function(){
    if(!isset($_SESSION['user'])) { Flight::json(['annonces' => [], 'reservations' => []]); return; }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // 1. Mes Annonces : Uniquement dans le futur
    $stmtA = $db->prepare("
        SELECT *, 'conducteur' as mon_role 
        FROM TRAJETS 
        WHERE id_conducteur = :uid 
        AND date_heure_depart >= NOW() 
        ORDER BY date_heure_depart ASC
    ");
    $stmtA->execute([':uid' => $userId]);
    
    // 2. Mes Réservations : Uniquement dans le futur
    $stmtR = $db->prepare("
        SELECT t.*, 'passager' as mon_role, r.nb_places_reservees
        FROM RESERVATIONS r 
        JOIN TRAJETS t ON r.id_trajet = t.id_trajet 
        WHERE r.id_passager = :uid 
        AND r.statut_code = 'V' 
        AND t.date_heure_depart >= NOW() 
        ORDER BY t.date_heure_depart ASC
    ");
    $stmtR->execute([':uid' => $userId]);

    Flight::json([
        'success' => true,
        'annonces' => $stmtA->fetchAll(PDO::FETCH_ASSOC),
        'reservations' => $stmtR->fetchAll(PDO::FETCH_ASSOC)
    ]);
});
?>