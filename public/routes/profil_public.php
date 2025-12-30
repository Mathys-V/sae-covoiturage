<?php

Flight::route('GET /profil/voir/@id', function($id){
    $db = Flight::get('db');

    // 1. Récupérer les infos de l'utilisateur (Données réelles uniquement)
    // On récupère 'description' car 'bio' n'existe pas dans la BDD
    $sqlUser = "SELECT id_utilisateur, nom, prenom, photo_profil, date_inscription, description 
                FROM UTILISATEURS 
                WHERE id_utilisateur = :id";
                
    $stmt = $db->prepare($sqlUser);
    $stmt->execute([':id' => $id]);
    $membre = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$membre) {
        $_SESSION['flash_error'] = "Utilisateur introuvable.";
        Flight::redirect('/recherche');
        return;
    }

    // Assignation simple : on utilise la colonne 'description' pour remplir la 'bio' du template
    $membre['bio'] = $membre['description'];

    // 2. Récupérer les avis reçus
    // On passe par RESERVATIONS pour faire le lien AVIS <-> TRAJETS
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

    // 3. Calcul des moyennes (Conducteur vs Passager)
    $stats = [
        'conducteur' => ['total' => 0, 'count' => 0, 'moyenne' => null],
        'passager'   => ['total' => 0, 'count' => 0, 'moyenne' => null]
    ];

    foreach ($avisList as $avis) {
        if ($avis['id_conducteur'] == $id) {
            $stats['conducteur']['total'] += $avis['note'];
            $stats['conducteur']['count']++;
        } else {
            $stats['passager']['total'] += $avis['note'];
            $stats['passager']['count']++;
        }
    }

    if ($stats['conducteur']['count'] > 0) {
        $stats['conducteur']['moyenne'] = round($stats['conducteur']['total'] / $stats['conducteur']['count'], 1);
    }
    if ($stats['passager']['count'] > 0) {
        $stats['passager']['moyenne'] = round($stats['passager']['total'] / $stats['passager']['count'], 1);
    }

    // Formatage date inscription
    if (!empty($membre['date_inscription'])) {
        $date = new DateTime($membre['date_inscription']);
        $membre['membre_depuis'] = $date->format('M Y');
    } else {
        $membre['membre_depuis'] = '-';
    }

    Flight::render('profil/profil_public.tpl', [
        'titre' => 'Profil de ' . $membre['prenom'],
        'membre' => $membre,
        'avis_list' => $avisList,
        'stats' => $stats
    ]);
});
?>