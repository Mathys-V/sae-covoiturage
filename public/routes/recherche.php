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

// --- 2. FONCTIONS INTELLIGENTES AMÉLIORÉES ---

    function extraireCP($str) {
        if (preg_match('/(\d{5})/', $str, $matches)) {
            return $matches[1];
        }
        return null;
    }

    function nettoyerInput($str) {
        $str = mb_strtolower($str, 'UTF-8');
        // Gestion des apostrophes courbes (copier-coller Word/Web)
        $str = str_replace(['’', '‘'], "'", $str);
        
        $str = preg_replace('/\d{5}/', '', $str);
        $str = preg_replace('/\s*\(.*?\)/', '', $str);
        
        // LISTE COMPLÉTÉE (Ajout de "du", "de", "des")
        $mots = [
            'gare de ', 'gare d\'', 'gare du ', 
            'iut ', 'campus ', 'faculté ', 'univ ',
            'ville de ', 'mairie de ', 'centre-ville',
            'place ', 'rue ', 'avenue ', 'boulevard ', 'allée ', 'chemin ', 'route ',
            ' le ', ' la ', ' les ', ' aux ', ' du ', ' des ', ' de ', ' en '
        ];
        $str = str_replace($mots, ' ', $str);

        // Nettoyage final des apostrophes résiduelles (d'Amiens -> Amiens)
        $str = preg_replace("/\b(d|l|qu)'/u", '', $str); 
        $str = preg_replace('/\d+/', '', $str);

        return trim($str);
    }

    // --- 3. PRÉPARATION DES VARIABLES ---
    
    $cpDep = extraireCP($depart);      // ex: "80330"
    $villeDepClean = nettoyerInput($depart); // ex: "longueau"

    $cpArr = extraireCP($arrivee);      // ex: "80000" (ou null)
    $villeArrClean = nettoyerInput($arrivee); // ex: "amiens"

    $db = Flight::get('db');
    
    // --- 4. REQUÊTE SQL PRINCIPALE ---
    
    $sql = "SELECT t.*, ADDTIME(t.date_heure_depart, t.duree_estimee) as date_arrivee, u.prenom, u.nom, u.photo_profil, v.marque, v.modele
            FROM TRAJETS t
            JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
            JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
            WHERE 
                (
                    (:cpDep IS NOT NULL AND t.code_postal_depart = :cpDep)
                    OR t.ville_depart LIKE :depClean
                    OR t.rue_depart LIKE :depClean
                    OR :depRaw LIKE CONCAT('%', t.ville_depart, '%')
                )
            AND 
                (
                    (:cpArr IS NOT NULL AND t.code_postal_arrivee = :cpArr)
                    OR t.ville_arrivee LIKE :arrClean 
                    OR t.rue_arrivee LIKE :arrClean
                    OR :arrRaw LIKE CONCAT('%', t.ville_arrivee, '%')
                )
            AND t.date_heure_depart >= :date
            AND t.date_heure_depart > NOW()
            AND t.statut_flag = 'A'
            ORDER BY t.date_heure_depart ASC";
            
    $stmt = $db->prepare($sql);
    $stmt->execute([
        ':cpDep'    => $cpDep,
        ':depClean' => "%$villeDepClean%",
        ':depRaw'   => $depart,
        ':cpArr'    => $cpArr,
        ':arrClean' => "%$villeArrClean%",
        ':arrRaw'   => $arrivee,
        ':date'     => $date . ' 00:00:00'
    ]);
    
    $trajets = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // --- 5. GESTION ALTERNATIVES (Si vide) ---
    $message = null;
    $typeResultat = 'exact';

    if (empty($trajets)) {
        $typeResultat = 'alternatif';

        // Alternative : On cherche juste par Destination
        $sqlAlt = "SELECT t.*, ADDTIME(t.date_heure_depart, t.duree_estimee) as date_arrivee, u.prenom, u.nom, u.photo_profil, v.marque, v.modele
                   FROM TRAJETS t
                   JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
                   JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
                   WHERE 
                   (
                        (:cpArr IS NOT NULL AND t.code_postal_arrivee = :cpArr)
                        OR t.ville_arrivee LIKE :arrClean 
                        OR :arrRaw LIKE CONCAT('%', t.ville_arrivee, '%')
                   )
                   AND t.date_heure_depart >= :date
                   AND t.date_heure_depart > NOW()
                   AND t.statut_flag = 'A'
                   ORDER BY t.date_heure_depart ASC LIMIT 5";
                   
        $stmtAlt = $db->prepare($sqlAlt);
        $stmtAlt->execute([
            ':cpArr'    => $cpArr,
            ':arrClean' => "%$villeArrClean%",
            ':arrRaw'   => $arrivee,
            ':date'     => $date . ' 00:00:00'
        ]);
        $trajets = $stmtAlt->fetchAll(PDO::FETCH_ASSOC);
        
        if (!empty($trajets)) {
            $message = "Trajet exact indisponible. Voici des <strong>alternatives</strong> vers votre destination :";
        } else {
            // Dernier recours : Prochains départs globaux
            $sqlDernier = "SELECT t.*, ADDTIME(t.date_heure_depart, t.duree_estimee) as date_arrivee, u.prenom, u.nom, u.photo_profil, v.marque, v.modele
                           FROM TRAJETS t 
                           JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur 
                           JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule 
                           WHERE t.date_heure_depart >= '$date 00:00:00' 
                           AND t.date_heure_depart > NOW()
                           AND t.statut_flag = 'A' 
                           ORDER BY t.date_heure_depart ASC LIMIT 5";

            $trajets = $db->query($sqlDernier)->fetchAll(PDO::FETCH_ASSOC);
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