<?php

// On force le fuseau horaire
date_default_timezone_set('Europe/Paris');

// AFFICHER LE FORMULAIRE DE RECHERCHE
Flight::route('GET /recherche', function(){
    $db = Flight::get('db');
    $req = Flight::request();

    $historique = [];
    if(isset($_COOKIE['historique_recherche'])) {
        $historique = json_decode($_COOKIE['historique_recherche'], true);
    }

    $stmt = $db->query("SELECT * FROM LIEUX_FREQUENTS");
    $lieux = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $preRempli = [
        'depart'  => $req->query->depart ?? '',
        'arrivee' => $req->query->arrivee ?? '',
        'date'    => !empty($req->query->date) ? $req->query->date : date('Y-m-d'),
        'heure'   => isset($req->query->heure) && $req->query->heure !== '' ? $req->query->heure : date('H'),
        'minute'  => isset($req->query->minute) && $req->query->minute !== '' ? $req->query->minute : date('i')
    ];

    Flight::render('recherche/recherche.tpl', [
        'titre' => 'Rechercher un trajet',
        'historique' => array_reverse($historique),
        'lieux_frequents' => $lieux,
        'recherche_precedente' => $preRempli
    ]);
});

// TRAITEMENT DE LA RECHERCHE (Résultats)
Flight::route('GET /recherche/resultats', function(){
    $req = Flight::request()->query;
    $depart = $req->depart;
    $arrivee = $req->arrivee;
    $date = $req->date;
    $heure = (isset($req->heure) && $req->heure !== '') ? $req->heure : '00';
    $minute = (isset($req->minute) && $req->minute !== '') ? $req->minute : '00';
    
    $dateComplete = $date . ' ' . $heure . ':' . $minute . ':00';
    $userId = isset($_SESSION['user']) ? $_SESSION['user']['id_utilisateur'] : 0;

    // Cookies
    $consent = ['performance' => 1]; 
    if (isset($_COOKIE['cookie_consent'])) $consent = json_decode($_COOKIE['cookie_consent'], true);
    if ($consent['performance'] == 1) {
        $nouvelleRecherche = ['depart' => $depart, 'arrivee' => $arrivee, 'date' => $date, 'timestamp' => time()];
        $historique = isset($_COOKIE['historique_recherche']) ? json_decode($_COOKIE['historique_recherche'], true) : [];
        $historique = array_filter($historique, function($h) use ($nouvelleRecherche) {
            return !($h['depart'] == $nouvelleRecherche['depart'] && $h['arrivee'] == $nouvelleRecherche['arrivee']);
        });
        $historique[] = $nouvelleRecherche;
        if(count($historique) > 3) $historique = array_slice($historique, -3);
        setcookie('historique_recherche', json_encode($historique), time() + (86400 * 30), "/");
    } 

    // Nettoyage
    function nettoyerInputLight($str) {
        $str = mb_strtolower($str, 'UTF-8');
        $str = str_replace(['’', '‘'], "'", $str);
        $str = preg_replace('/\d{5}/', '', $str); 
        $str = preg_replace('/\s*\(.*?\)/', '', $str);
        return trim($str);
    }
    function extraireCP($str) { return preg_match('/(\d{5})/', $str, $matches) ? $matches[1] : null; }

    $cpDep = extraireCP($depart);
    $cpArr = extraireCP($arrivee);
    $villeDepClean = nettoyerInputLight($depart); 
    $villeArrClean = nettoyerInputLight($arrivee);

    $db = Flight::get('db');
    
    // Requête de base
    $baseSelect = "
        SELECT t.*, ADDTIME(t.date_heure_depart, t.duree_estimee) as date_arrivee, 
               u.prenom, u.nom, u.photo_profil, v.marque, v.modele,
               lf_dep.nom_lieu AS nom_lieu_depart,
               lf_arr.nom_lieu AS nom_lieu_arrivee,
               (t.places_proposees - COALESCE((SELECT SUM(r.nb_places_reservees) FROM RESERVATIONS r WHERE r.id_trajet = t.id_trajet AND r.statut_code = 'V'), 0)) as places_restantes,
               (SELECT COUNT(*) FROM RESERVATIONS r2 WHERE r2.id_trajet = t.id_trajet AND r2.id_passager = :userId AND r2.statut_code = 'V') as deja_reserve
        FROM TRAJETS t
        JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
        JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
        LEFT JOIN LIEUX_FREQUENTS lf_dep ON (t.rue_depart = lf_dep.rue AND t.ville_depart = lf_dep.ville)
        LEFT JOIN LIEUX_FREQUENTS lf_arr ON (t.rue_arrivee = lf_arr.rue AND t.ville_arrivee = lf_arr.ville)
    ";

    // Condition Lieu
    $whereLieuExact = "
        AND ( 
            (:cpDep IS NOT NULL AND t.code_postal_depart = :cpDep) 
            OR t.ville_depart LIKE :depClean 
            OR t.rue_depart LIKE :depClean 
            OR lf_dep.nom_lieu LIKE :depClean 
            OR (t.ville_depart != '' AND :depClean LIKE CONCAT('%', t.ville_depart, '%'))
            OR (t.rue_depart != '' AND :depClean LIKE CONCAT('%', t.rue_depart, '%'))
        )
        AND ( 
            (:cpArr IS NOT NULL AND t.code_postal_arrivee = :cpArr) 
            OR t.ville_arrivee LIKE :arrClean 
            OR t.rue_arrivee LIKE :arrClean 
            OR lf_arr.nom_lieu LIKE :arrClean 
            OR (t.ville_arrivee != '' AND :arrClean LIKE CONCAT('%', t.ville_arrivee, '%'))
            OR (t.rue_arrivee != '' AND :arrClean LIKE CONCAT('%', t.rue_arrivee, '%'))
        )
    ";

    // 1. RECHERCHE EXACTE (Futurs)
    $sqlExact = $baseSelect . " WHERE t.date_heure_depart >= :dateComplete AND t.statut_flag = 'A' AND t.id_conducteur != :userId " . $whereLieuExact . " ORDER BY t.date_heure_depart ASC";

    $stmt = $db->prepare($sqlExact);
    $stmt->execute([
        ':dateComplete' => $dateComplete, ':userId' => $userId,
        ':cpDep' => $cpDep, ':depClean' => "%$villeDepClean%",
        ':cpArr' => $cpArr, ':arrClean' => "%$villeArrClean%"
    ]);
    
    $trajets = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $typeResultat = 'exact';
    $message = null;

    // 2. SI VIDE : Vérifier Passé
    if (empty($trajets)) {
        
        $sqlCheckPast = "SELECT 1 FROM TRAJETS t 
            LEFT JOIN LIEUX_FREQUENTS lf_dep ON (t.rue_depart = lf_dep.rue AND t.ville_depart = lf_dep.ville)
            LEFT JOIN LIEUX_FREQUENTS lf_arr ON (t.rue_arrivee = lf_arr.rue AND t.ville_arrivee = lf_arr.ville)
            WHERE t.date_heure_depart BETWEEN :dateStart AND :dateEnd 
            AND t.statut_flag = 'A' 
            AND t.id_conducteur != :userId " . $whereLieuExact . " 
            LIMIT 1";

        $stmtCheck = $db->prepare($sqlCheckPast);
        $stmtCheck->execute([
            ':dateStart' => $date . ' 00:00:00', 
            ':dateEnd'   => $date . ' 23:59:59',
            ':userId'    => $userId,
            ':cpDep' => $cpDep, ':depClean' => "%$villeDepClean%",
            ':cpArr' => $cpArr, ':arrClean' => "%$villeArrClean%"
        ]);
        
        $trajetPasseExiste = $stmtCheck->fetchColumn();

        // --- CHOIX DU MESSAGE ---
        if ($trajetPasseExiste) {
            // CORRECTION ICI : Message plus clair sur la chronologie
            $prefixeMsg = "<strong>Attention</strong>, tous les départs pour ce trajet précis sont <strong>déjà passés à l'heure demandée</strong>.";
        } else {
            $prefixeMsg = "Aucun trajet exact trouvé pour ce parcours.";
        }

        // 3. ALTERNATIVES
        $typeResultat = 'alternatif';
        $sqlAlt = $baseSelect . "
            WHERE ( 
                (:cpArr IS NOT NULL AND t.code_postal_arrivee = :cpArr) 
                OR t.ville_arrivee LIKE :arrClean 
                OR t.rue_arrivee LIKE :arrClean 
                OR lf_arr.nom_lieu LIKE :arrClean
                OR (t.ville_arrivee != '' AND :arrClean LIKE CONCAT('%', t.ville_arrivee, '%'))
            )
            AND t.date_heure_depart >= :dateComplete
            AND t.statut_flag = 'A' AND t.id_conducteur != :userId
            ORDER BY t.date_heure_depart ASC LIMIT 10";
        
        $stmtAlt = $db->prepare($sqlAlt);
        $stmtAlt->execute([
            ':dateComplete' => $dateComplete, ':userId' => $userId,
            ':cpArr' => $cpArr, ':arrClean' => "%$villeArrClean%"
        ]);
        $trajets = $stmtAlt->fetchAll(PDO::FETCH_ASSOC);

        if (!empty($trajets)) {
            $message = $prefixeMsg . " Voici des <strong>alternatives</strong> vers votre destination :";
        } else {
            // 4. DÉFAUT
            $typeResultat = 'defaut';
            $sqlDernier = $baseSelect . " WHERE t.date_heure_depart >= :dateComplete AND t.statut_flag = 'A' AND t.id_conducteur != :userId ORDER BY t.date_heure_depart ASC LIMIT 5";
            $stmtDernier = $db->prepare($sqlDernier);
            $stmtDernier->execute([':dateComplete' => $dateComplete, ':userId' => $userId]);
            $trajets = $stmtDernier->fetchAll(PDO::FETCH_ASSOC);
            $message = $prefixeMsg . " Voici les <strong>prochains départs</strong> sur la plateforme :";
        }
    }

    Flight::render('recherche/resultats_recherche.tpl', [
        'titre' => 'Résultats',
        'trajets' => $trajets,
        'recherche' => [
            'depart' => $depart, 
            'arrivee' => $arrivee, 
            'date' => $date,
            'heure' => $heure,
            'minute' => $minute
        ],
        'message_info' => $message,
        'type_resultat' => $typeResultat
    ]);
});
?>