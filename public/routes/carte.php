<?php

// ============================================================
// PARTIE 1 : AFFICHAGE DE LA CARTE (Route Principale)
// ============================================================
Flight::route('/carte', function(){
    $db = Flight::get('db');
    // Récupération de l'ID utilisateur s'il est connecté, sinon 0
    $userId = isset($_SESSION['user']) ? $_SESSION['user']['id_utilisateur'] : 0;

    // 1. Récupération des Lieux Fréquents (Gares, Campus...)
    $stmt = $db->query("SELECT * FROM LIEUX_FREQUENTS");
    $lieux = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 2. Récupération des Trajets Publics (Pour la recherche)
    // Filtres stricts : 
    // - Statut 'A' (Actif)
    // - Date > Maintenant (Futurs uniquement)
    // - Conducteur != Moi (On ne s'affiche pas soi-même dans la recherche publique)
    $sqlPublic = "SELECT * FROM TRAJETS 
                  WHERE statut_flag = 'A' 
                  AND date_heure_depart >= NOW() 
                  AND id_conducteur != :uid 
                  ORDER BY date_heure_depart ASC";
    $stmt2 = $db->prepare($sqlPublic);
    $stmt2->execute([':uid' => $userId]);
    $trajets = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    // 3. Récupération des données personnelles (Si connecté)
    $mesAnnonces = [];     
    $mesReservations = []; 

    if ($userId > 0) {
        // A. Mes Annonces (Je suis conducteur)
        // On filtre aussi pour ne garder que les trajets futurs
        $stmtCond = $db->prepare("
            SELECT *, 'conducteur' as mon_role 
            FROM TRAJETS 
            WHERE id_conducteur = :uid 
            AND date_heure_depart >= NOW() 
            ORDER BY date_heure_depart ASC
        ");
        $stmtCond->execute([':uid' => $userId]);
        $mesAnnonces = $stmtCond->fetchAll(PDO::FETCH_ASSOC);

        // B. Mes Réservations (Je suis passager)
        // On récupère uniquement les réservations validées ('V') et futures
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

    // Gestion de sécurité des coordonnées
    // Si un lieu n'a pas de latitude/longitude en base, on place un point par défaut (Centre Amiens)
    foreach($lieux as &$lieu) {
        if(!$lieu['latitude']) { 
             $lieu['latitude'] = 49.89407; 
             $lieu['longitude'] = 2.29575; 
        }
    }

    // Envoi des données au template Smarty
    Flight::render('carte/carte.tpl', [
        'titre' => 'Carte interactive',
        'lieux_frequents' => $lieux,
        'trajets' => $trajets,          // Trajets publics
        'mes_annonces' => $mesAnnonces, // Mes trajets conducteur
        'mes_reservations' => $mesReservations, // Mes trajets passager
        'user' => isset($_SESSION['user']) ? $_SESSION['user'] : null
    ]);
});

// ============================================================
// PARTIE 2 : API POUR LES FILTRES DYNAMIQUES (AJAX)
// ============================================================
// Cette route est appelée par le JavaScript pour rafraîchir "Mes Trajets" sans recharger la page
Flight::route('GET /api/mes-trajets-carte', function(){
    if(!isset($_SESSION['user'])) { Flight::json(['annonces' => [], 'reservations' => []]); return; }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // 1. API : Mes Annonces (Futurs uniquement)
    $stmtA = $db->prepare("
        SELECT *, 'conducteur' as mon_role 
        FROM TRAJETS 
        WHERE id_conducteur = :uid 
        AND date_heure_depart >= NOW() 
        ORDER BY date_heure_depart ASC
    ");
    $stmtA->execute([':uid' => $userId]);
    
    // 2. API : Mes Réservations (Futurs uniquement)
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

    // Retour au format JSON pour consommation par Leaflet (JS)
    Flight::json([
        'success' => true,
        'annonces' => $stmtA->fetchAll(PDO::FETCH_ASSOC),
        'reservations' => $stmtR->fetchAll(PDO::FETCH_ASSOC)
    ]);
});
?>