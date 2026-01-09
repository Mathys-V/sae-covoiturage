<?php

// Route : Afficher le profil public d'un utilisateur (via son ID)
Flight::route('GET /profil/voir/@id', function($id){
    $db = Flight::get('db');

    // 1. Récupération des informations de l'utilisateur
    // On sélectionne les infos publiques (Nom, Prénom, Photo, Description)
    $sqlUser = "SELECT id_utilisateur, nom, prenom, photo_profil, date_inscription, description 
                FROM UTILISATEURS 
                WHERE id_utilisateur = :id";
                
    $stmt = $db->prepare($sqlUser);
    $stmt->execute([':id' => $id]);
    $membre = $stmt->fetch(PDO::FETCH_ASSOC);

    // Si l'utilisateur n'existe pas, redirection vers la recherche
    if (!$membre) {
        $_SESSION['flash_error'] = "Utilisateur introuvable.";
        Flight::redirect('/recherche');
        return;
    }

    // Adaptation pour le template : on mappe le champ BDD 'description' vers la variable 'bio'
    $membre['bio'] = $membre['description'];

    // 2. Récupération des avis reçus par cet utilisateur
    // La jointure avec TRAJETS est essentielle pour déterminer si l'utilisateur était Conducteur ou Passager au moment de l'avis
    $sqlAvis = "SELECT a.*, u.prenom as auteur_prenom, u.nom as auteur_nom, u.photo_profil as auteur_photo,
                       t.id_conducteur
                FROM AVIS a
                JOIN UTILISATEURS u ON a.id_auteur = u.id_utilisateur
                JOIN RESERVATIONS r ON a.id_reservation = r.id_reservation
                JOIN TRAJETS t ON r.id_trajet = t.id_trajet
                WHERE a.id_destinataire = :id
                ORDER BY a.date_avis DESC";
    
    $stmtAvis = $db->prepare($sqlAvis);
    $stmtAvis->execute([':id' => $id]);
    $avisList = $stmtAvis->fetchAll(PDO::FETCH_ASSOC);

    // 3. Calcul des statistiques (Moyenne Conducteur vs Moyenne Passager)
    $stats = [
        'conducteur' => ['total' => 0, 'count' => 0, 'moyenne' => null],
        'passager'   => ['total' => 0, 'count' => 0, 'moyenne' => null]
    ];

    foreach ($avisList as $avis) {
        // Si l'ID du conducteur du trajet concerné est l'ID du profil qu'on regarde
        // Alors c'est un avis reçu en tant que Conducteur
        if ($avis['id_conducteur'] == $id) {
            $stats['conducteur']['total'] += $avis['note'];
            $stats['conducteur']['count']++;
        } else {
            // Sinon, c'est un avis reçu en tant que Passager
            $stats['passager']['total'] += $avis['note'];
            $stats['passager']['count']++;
        }
    }

    // Calcul mathématique des moyennes
    if ($stats['conducteur']['count'] > 0) {
        $stats['conducteur']['moyenne'] = round($stats['conducteur']['total'] / $stats['conducteur']['count'], 1);
    }
    if ($stats['passager']['count'] > 0) {
        $stats['passager']['moyenne'] = round($stats['passager']['total'] / $stats['passager']['count'], 1);
    }

    // 4. Formatage de la date d'inscription (ex: "jan. 2024")
    if (!empty($membre['date_inscription'])) {
        $date = new DateTime($membre['date_inscription']);
        $membre['membre_depuis'] = $date->format('M Y');
    } else {
        $membre['membre_depuis'] = '-';
    }

    // 5. Affichage de la vue
    Flight::render('profil/profil_public.tpl', [
        'titre' => 'Profil de ' . $membre['prenom'],
        'membre' => $membre,
        'avis_list' => $avisList,
        'stats' => $stats
    ]);
});
?>