<?php

// IMPORTANT : On force le fuseau horaire pour avoir la bonne heure par défaut
date_default_timezone_set('Europe/Paris');

// AFFICHER LE FORMULAIRE DE RECHERCHE
Flight::route('GET /recherche', function(){
    $db = Flight::get('db');
    $req = Flight::request();

    // Gestion historique (inchangée)
    $historique = [];
    if(isset($_COOKIE['historique_recherche'])) {
        $historique = json_decode($_COOKIE['historique_recherche'], true);
    }

    $stmt = $db->query("SELECT * FROM LIEUX_FREQUENTS");
    $lieux = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // --- LOGIQUE DE PRÉ-REMPLISSAGE ROBUSTE ---
    // Si des paramètres sont dans l'URL (via le bouton Modifier), on les utilise.
    // Sinon, on injecte les valeurs par défaut (Date du jour, Heure actuelle).
    
    $preRempli = [
        'depart'  => $req->query->depart ?? '',
        'arrivee' => $req->query->arrivee ?? '',
        // Si pas de date, date du jour
        'date'    => !empty($req->query->date) ? $req->query->date : date('Y-m-d'),
        // Si pas d'heure, heure actuelle (format 2 chiffres)
        'heure'   => isset($req->query->heure) && $req->query->heure !== '' ? $req->query->heure : date('H'),
        // Si pas de minute, minute actuelle
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
    // On récupère les paramètres
    $depart = Flight::request()->query->depart;
    $arrivee = Flight::request()->query->arrivee;
    $date = Flight::request()->query->date;
    
    // Récupération de l'heure et minute (avec valeurs par défaut si vide pour éviter les erreurs SQL)
    $heure = Flight::request()->query->heure;
    if ($heure === null || $heure === '') $heure = '00';
    
    $minute = Flight::request()->query->minute;
    if ($minute === null || $minute === '') $minute = '00';
    
    // Construction de la date complète pour le filtre SQL
    $dateComplete = $date . ' ' . $heure . ':' . $minute . ':00';

    $userId = isset($_SESSION['user']) ? $_SESSION['user']['id_utilisateur'] : 0;

    // --- GESTION COOKIES (Historique) ---
    $consent = ['performance' => 1]; 
    if (isset($_COOKIE['cookie_consent'])) $consent = json_decode($_COOKIE['cookie_consent'], true);
    
    if ($consent['performance'] == 1) {
        $nouvelleRecherche = ['depart' => $depart, 'arrivee' => $arrivee, 'date' => $date, 'timestamp' => time()];
        $historique = isset($_COOKIE['historique_recherche']) ? json_decode($_COOKIE['historique_recherche'], true) : [];
        // Filtre doublons
        $historique = array_filter($historique, function($h) use ($nouvelleRecherche) {
            return !($h['depart'] == $nouvelleRecherche['depart'] && $h['arrivee'] == $nouvelleRecherche['arrivee']);
        });
        $historique[] = $nouvelleRecherche;
        if(count($historique) > 3) $historique = array_slice($historique, -3);
        setcookie('historique_recherche', json_encode($historique), time() + (86400 * 30), "/");
    } 

    // --- FONCTIONS NETTOYAGE ---
    function extraireCP($str) { return preg_match('/(\d{5})/', $str, $matches) ? $matches[1] : null; }
    function nettoyerInputLight($str) {
        $str = mb_strtolower($str, 'UTF-8');
        $str = str_replace(['’', '‘'], "'", $str);
        $str = preg_replace('/\d{5}/', '', $str); 
        $str = preg_replace('/\s*\(.*?\)/', '', $str);
        return trim($str);
    }

    $cpDep = extraireCP($depart);
    $cpArr = extraireCP($arrivee);
    $villeDepClean = nettoyerInputLight($depart); 
    $villeArrClean = nettoyerInputLight($arrivee);

    $db = Flight::get('db');
    
    // --- REQUÊTE DE BASE ---
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
        WHERE t.date_heure_depart >= :dateComplete 
        AND t.date_heure_depart > NOW()
        AND t.statut_flag = 'A'
        AND t.id_conducteur != :userId
    ";

    // 1. RECHERCHE EXACTE
    $sqlExact = $baseSelect . "
        AND ( (:cpDep IS NOT NULL AND t.code_postal_depart = :cpDep) OR t.ville_depart LIKE :depClean OR t.rue_depart LIKE :depClean )
        AND ( (:cpArr IS NOT NULL AND t.code_postal_arrivee = :cpArr) OR t.ville_arrivee LIKE :arrClean OR t.rue_arrivee LIKE :arrClean )
        ORDER BY t.date_heure_depart ASC";

    $stmt = $db->prepare($sqlExact);
    $stmt->execute([
        ':dateComplete' => $dateComplete,
        ':userId'       => $userId,
        ':cpDep'        => $cpDep,
        ':depClean'     => "%$villeDepClean%",
        ':cpArr'        => $cpArr,
        ':arrClean'     => "%$villeArrClean%"
    ]);
    
    $trajets = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $typeResultat = 'exact';
    $message = null;

    // 2. RECHERCHE ALTERNATIVE
    if (empty($trajets)) {
        $typeResultat = 'alternatif';
        $sqlAlt = $baseSelect . "
            AND ( (:cpArr IS NOT NULL AND t.code_postal_arrivee = :cpArr) OR t.ville_arrivee LIKE :arrClean OR t.rue_arrivee LIKE :arrClean )
            ORDER BY t.date_heure_depart ASC LIMIT 10";
        
        $stmtAlt = $db->prepare($sqlAlt);
        $stmtAlt->execute([
            ':dateComplete' => $dateComplete,
            ':userId'       => $userId,
            ':cpArr'        => $cpArr,
            ':arrClean'     => "%$villeArrClean%"
        ]);
        $trajets = $stmtAlt->fetchAll(PDO::FETCH_ASSOC);

        if (!empty($trajets)) {
            $message = "Aucun trajet exact. Voici des trajets <strong>vers votre destination</strong> :";
        } else {
            // 3. DÉFAUT
            $typeResultat = 'defaut';
            $sqlDernier = $baseSelect . " ORDER BY t.date_heure_depart ASC LIMIT 5";
            $stmtDernier = $db->prepare($sqlDernier);
            $stmtDernier->execute([':dateComplete' => $dateComplete, ':userId' => $userId]);
            $trajets = $stmtDernier->fetchAll(PDO::FETCH_ASSOC);
            $message = "Aucun trajet trouvé. Voici les <strong>prochains départs</strong> :";
        }
    }

    // On renvoie toutes les infos à la vue pour qu'elle puisse les réutiliser dans le bouton Modifier
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