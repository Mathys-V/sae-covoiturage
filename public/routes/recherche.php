<?php

// AFFICHER LE FORMULAIRE DE RECHERCHE
Flight::route('GET /recherche', function(){
    $db = Flight::get('db');

    // Récupérer l'historique
    $historique = [];
    if(isset($_COOKIE['historique_recherche'])) {
        $historique = json_decode($_COOKIE['historique_recherche'], true);
    }

    // Récupérer les Lieux Fréquents
    $stmt = $db->query("SELECT * FROM LIEUX_FREQUENTS");
    $lieux = $stmt->fetchAll(PDO::FETCH_ASSOC);

    Flight::render('recherche.tpl', [
        'titre' => 'Rechercher un trajet',
        'historique' => array_reverse($historique),
        'lieux_frequents' => $lieux
    ]);
});

// TRAITEMENT DE LA RECHERCHE (Résultats)
Flight::route('GET /recherche/resultats', function(){
    $depart = Flight::request()->query->depart;
    $arrivee = Flight::request()->query->arrivee;
    $date = Flight::request()->query->date;

    // GESTION COOKIES HISTORIQUE
    $consent = ['performance' => 1]; 
    if (isset($_COOKIE['cookie_consent'])) {
        $consent = json_decode($_COOKIE['cookie_consent'], true);
    }
    if ($consent['performance'] == 1) {
        $nouvelleRecherche = ['depart' => $depart, 'arrivee' => $arrivee, 'date' => $date, 'timestamp' => time()];
        $historique = [];
        if(isset($_COOKIE['historique_recherche'])) {
            $historique = json_decode($_COOKIE['historique_recherche'], true);
        }
        $historique = array_filter($historique, function($h) use ($nouvelleRecherche) {
            return !($h['depart'] == $nouvelleRecherche['depart'] && $h['arrivee'] == $nouvelleRecherche['arrivee'] && $h['date'] == $nouvelleRecherche['date']);
        });
        $historique[] = $nouvelleRecherche;
        if(count($historique) > 3) $historique = array_slice($historique, -3);
        setcookie('historique_recherche', json_encode($historique), time() + (86400 * 30), "/");
    } 

    // FONCTION DE NETTOYAGE
    function nettoyerInput($str) {
        $str = strtolower($str);
        $str = preg_replace('/\s*\(.*?\)/', '', $str);
        $str = preg_replace('/\d{5}/', '', $str);
        $mots = ['gare de ', 'gare d\'', 'iut ', 'campus ', 'ville de ', 'mairie de ', 'place ', 'rue '];
        $str = str_replace($mots, '', $str);
        return trim($str);
    }

    $depClean = nettoyerInput($depart);
    $arrClean = nettoyerInput($arrivee);

    $db = Flight::get('db');
    
    // REQUÊTE PRINCIPALE
    $sql = "SELECT t.*, u.prenom, u.nom, u.photo_profil, v.marque, v.modele
            FROM TRAJETS t
            JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
            JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
            WHERE 
                (t.ville_depart LIKE :depClean OR :depRaw LIKE CONCAT('%', t.ville_depart, '%'))
            AND 
                (t.ville_arrivee LIKE :arrClean OR :arrRaw LIKE CONCAT('%', t.ville_arrivee, '%'))
            AND t.date_heure_depart >= :date
            AND t.statut_flag = 'A'
            ORDER BY t.date_heure_depart ASC";
            
    $stmt = $db->prepare($sql);
    $stmt->execute([
        ':depClean' => "%$depClean%",
        ':depRaw'   => $depart,
        ':arrClean' => "%$arrClean%",
        ':arrRaw'   => $arrivee,
        ':date'     => $date . ' 00:00:00'
    ]);
    
    $trajets = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // GESTION ALTERNATIVES
    $message = null;
    $typeResultat = 'exact';

    if (empty($trajets)) {
        $typeResultat = 'alternatif';

        // Tentative 2 : Recherche par destination uniquement
        $sqlAlt = "SELECT t.*, u.prenom, u.nom, u.photo_profil, v.marque, v.modele
                   FROM TRAJETS t
                   JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
                   JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
                   WHERE (t.ville_arrivee LIKE :arrClean OR :arrRaw LIKE CONCAT('%', t.ville_arrivee, '%'))
                   AND t.date_heure_depart >= :date
                   AND t.statut_flag = 'A'
                   ORDER BY t.date_heure_depart ASC LIMIT 5";
                   
        $stmtAlt = $db->prepare($sqlAlt);
        $stmtAlt->execute([
            ':arrClean' => "%$arrClean%",
            ':arrRaw'   => $arrivee,
            ':date'     => $date . ' 00:00:00'
        ]);
        $trajets = $stmtAlt->fetchAll(PDO::FETCH_ASSOC);
        
        if (!empty($trajets)) {
            $message = "Trajet exact indisponible. Voici des <strong>alternatives</strong> vers votre destination :";
        } else {
            // Tentative 3 : Tous les prochains départs
            $trajets = $db->query("SELECT t.*, u.prenom, u.nom, u.photo_profil, v.marque, v.modele FROM TRAJETS t JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule WHERE t.date_heure_depart >= '$date 00:00:00' AND t.statut_flag = 'A' ORDER BY t.date_heure_depart ASC LIMIT 5")->fetchAll(PDO::FETCH_ASSOC);
            $message = "Aucun trajet correspondant. Voici les <strong>prochains départs</strong> disponibles sur la plateforme :";
        }
    }

    Flight::render('resultats_recherche.tpl', [
        'titre' => 'Résultats',
        'trajets' => $trajets,
        'recherche' => ['depart' => $depart, 'arrivee' => $arrivee, 'date' => $date],
        'message_info' => $message,
        'type_resultat' => $typeResultat
    ]);
});
?>