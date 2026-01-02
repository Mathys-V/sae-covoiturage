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
    
    // ID de l'utilisateur connecté (pour vérifier "déjà réservé")
    $userId = isset($_SESSION['user']) ? $_SESSION['user']['id_utilisateur'] : 0;

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

    // --- FONCTIONS UTILITAIRES ---
    function extraireCP($str) {
        if (preg_match('/(\d{5})/', $str, $matches)) {
            return $matches[1];
        }
        return null;
    }

    function nettoyerInput($str) {
        $str = mb_strtolower($str, 'UTF-8');
        $str = str_replace(['’', '‘'], "'", $str);
        $str = preg_replace('/\d{5}/', '', $str);
        $str = preg_replace('/\s*\(.*?\)/', '', $str);
        $mots = ['gare de ', 'gare d\'', 'gare du ', 'iut ', 'campus ', 'faculté ', 'univ ', 'ville de ', 'mairie de ', 'centre-ville', 'place ', 'rue ', 'avenue ', 'boulevard ', 'allée ', 'chemin ', 'route ', ' le ', ' la ', ' les ', ' aux ', ' du ', ' des ', ' de ', ' en '];
        $str = str_replace($mots, ' ', $str);
        $str = preg_replace("/\b(d|l|qu)'/u", '', $str); 
        $str = preg_replace('/\d+/', '', $str);
        return trim($str);
    }

    // --- VARIABLES ---
    $cpDep = extraireCP($depart);
    $villeDepClean = nettoyerInput($depart);
    $cpArr = extraireCP($arrivee);
    $villeArrClean = nettoyerInput($arrivee);

    $db = Flight::get('db');
    
    // --- REQUÊTE SQL PRINCIPALE ---
    // Modification : Calcul des places restantes et vérification "Déjà réservé"
    
    $sql = "SELECT t.*, ADDTIME(t.date_heure_depart, t.duree_estimee) as date_arrivee, 
                   u.prenom, u.nom, u.photo_profil, v.marque, v.modele,
                   lf_dep.nom_lieu AS nom_lieu_depart,
                   lf_arr.nom_lieu AS nom_lieu_arrivee,
                   
                   -- Calcul places restantes
                   (t.places_proposees - COALESCE((
                        SELECT SUM(r.nb_places_reservees) 
                        FROM RESERVATIONS r 
                        WHERE r.id_trajet = t.id_trajet AND r.statut_code = 'V'
                   ), 0)) as places_restantes,

                   -- Vérification déjà réservé
                   (SELECT COUNT(*) FROM RESERVATIONS r2 
                    WHERE r2.id_trajet = t.id_trajet 
                    AND r2.id_passager = :userId 
                    AND r2.statut_code = 'V') as deja_reserve

            FROM TRAJETS t
            JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
            JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
            LEFT JOIN LIEUX_FREQUENTS lf_dep ON (t.rue_depart = lf_dep.rue AND t.ville_depart = lf_dep.ville)
            LEFT JOIN LIEUX_FREQUENTS lf_arr ON (t.rue_arrivee = lf_arr.rue AND t.ville_arrivee = lf_arr.ville)
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
            
            -- On ne filtre pas ici les places pour pouvoir afficher 'Complet' ou 'Déjà réservé' si besoin
            ORDER BY t.date_heure_depart ASC";
            
    $stmt = $db->prepare($sql);
    $stmt->execute([
        ':cpDep'    => $cpDep,
        ':depClean' => "%$villeDepClean%",
        ':depRaw'   => $depart,
        ':cpArr'    => $cpArr,
        ':arrClean' => "%$villeArrClean%",
        ':arrRaw'   => $arrivee,
        ':date'     => $date . ' 00:00:00',
        ':userId'   => $userId
    ]);
    
    $trajets = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // --- GESTION ALTERNATIVES ---
    $message = null;
    $typeResultat = 'exact';

    if (empty($trajets)) {
        $typeResultat = 'alternatif';

        // Alternative : Destination uniquement (+ Calcul places)
        $sqlAlt = "SELECT t.*, ADDTIME(t.date_heure_depart, t.duree_estimee) as date_arrivee, 
                          u.prenom, u.nom, u.photo_profil, v.marque, v.modele,
                          lf_dep.nom_lieu AS nom_lieu_depart,
                          lf_arr.nom_lieu AS nom_lieu_arrivee,
                          
                          (t.places_proposees - COALESCE((
                                SELECT SUM(r.nb_places_reservees) 
                                FROM RESERVATIONS r 
                                WHERE r.id_trajet = t.id_trajet AND r.statut_code = 'V'
                           ), 0)) as places_restantes,

                           (SELECT COUNT(*) FROM RESERVATIONS r2 
                            WHERE r2.id_trajet = t.id_trajet 
                            AND r2.id_passager = :userId 
                            AND r2.statut_code = 'V') as deja_reserve

                   FROM TRAJETS t
                   JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
                   JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
                   LEFT JOIN LIEUX_FREQUENTS lf_dep ON (t.rue_depart = lf_dep.rue AND t.ville_depart = lf_dep.ville)
                   LEFT JOIN LIEUX_FREQUENTS lf_arr ON (t.rue_arrivee = lf_arr.rue AND t.ville_arrivee = lf_arr.ville)
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
            ':date'     => $date . ' 00:00:00',
            ':userId'   => $userId
        ]);
        $trajets = $stmtAlt->fetchAll(PDO::FETCH_ASSOC);
        
        if (!empty($trajets)) {
            $message = "Trajet exact indisponible. Voici des <strong>alternatives</strong> vers votre destination :";
        } else {
            // Dernier recours : Tout le monde (+ Calcul places)
            $sqlDernier = "SELECT t.*, ADDTIME(t.date_heure_depart, t.duree_estimee) as date_arrivee, 
                                  u.prenom, u.nom, u.photo_profil, v.marque, v.modele,
                                  lf_dep.nom_lieu AS nom_lieu_depart,
                                  lf_arr.nom_lieu AS nom_lieu_arrivee,
                                  
                                  (t.places_proposees - COALESCE((
                                        SELECT SUM(r.nb_places_reservees) 
                                        FROM RESERVATIONS r 
                                        WHERE r.id_trajet = t.id_trajet AND r.statut_code = 'V'
                                   ), 0)) as places_restantes,

                                   (SELECT COUNT(*) FROM RESERVATIONS r2 
                                    WHERE r2.id_trajet = t.id_trajet 
                                    AND r2.id_passager = :userId 
                                    AND r2.statut_code = 'V') as deja_reserve

                           FROM TRAJETS t 
                           JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur 
                           JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule 
                           LEFT JOIN LIEUX_FREQUENTS lf_dep ON (t.rue_depart = lf_dep.rue AND t.ville_depart = lf_dep.ville)
                           LEFT JOIN LIEUX_FREQUENTS lf_arr ON (t.rue_arrivee = lf_arr.rue AND t.ville_arrivee = lf_arr.ville)
                           WHERE t.date_heure_depart >= :date 
                           AND t.date_heure_depart > NOW()
                           AND t.statut_flag = 'A' 
                           ORDER BY t.date_heure_depart ASC LIMIT 5";

            $stmtDernier = $db->prepare($sqlDernier);
            $stmtDernier->execute([
                ':date'   => $date . ' 00:00:00',
                ':userId' => $userId
            ]);
            $trajets = $stmtDernier->fetchAll(PDO::FETCH_ASSOC);
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