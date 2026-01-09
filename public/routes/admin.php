<?php

// Route : Accès à la page de modération
Flight::route('GET /moderation', function(){
    
    // Sécurité : Seuls les admins connectés peuvent accéder à cette page
    if(!isset($_SESSION['user']) || $_SESSION['user']['admin_flag'] !== 'Y') {
        Flight::redirect('/'); return;
    }

    $db = Flight::get('db');

    // 1. Récupération des signalements EN ATTENTE (Code 'E')
    // On joint les tables pour avoir les noms des signaleurs, signalés et les détails du trajet
    $enAttente = $db->query("SELECT s.*, u1.nom as nom_signaleur, u1.prenom as prenom_signaleur,
                   u2.nom as nom_signale, u2.prenom as prenom_signale, u2.email as email_signale,
                   t.ville_depart, t.ville_arrivee
            FROM SIGNALEMENTS s
            JOIN UTILISATEURS u1 ON s.id_signaleur = u1.id_utilisateur
            JOIN UTILISATEURS u2 ON s.id_signale = u2.id_utilisateur
            LEFT JOIN TRAJETS t ON s.id_trajet = t.id_trajet
            WHERE s.statut_code = 'E'
            ORDER BY s.date_signalement ASC")->fetchAll(PDO::FETCH_ASSOC);

    // 2. Récupération de l'HISTORIQUE des signalements traités (Rejetés 'R' ou Jugés 'J')
    $historique = $db->query("SELECT s.*, u2.nom as nom_signale, u2.prenom as prenom_signale, u1.nom as nom_signaleur
            FROM SIGNALEMENTS s
            JOIN UTILISATEURS u1 ON s.id_signaleur = u1.id_utilisateur
            JOIN UTILISATEURS u2 ON s.id_signale = u2.id_utilisateur
            WHERE s.statut_code IN ('R', 'J')
            ORDER BY s.date_signalement DESC")->fetchAll(PDO::FETCH_ASSOC);

    // 3. Récupération des utilisateurs BANNIS (active_flag = 'N')
    $bannis = $db->query("SELECT * FROM UTILISATEURS WHERE active_flag = 'N' ORDER BY nom ASC")->fetchAll(PDO::FETCH_ASSOC);

    // Calcul du temps restant pour chaque banni
    foreach($bannis as &$b) {
        // On utilise le champ 'date_expiration_token' pour stocker la fin du ban
        if($b['date_expiration_token']) {
            $fin = new DateTime($b['date_expiration_token']);
            $now = new DateTime();
            
            // Si la date de fin est dans le futur
            if($fin > $now) {
                $diff = $now->diff($fin);
                // Si la durée est supérieure à 10 ans, on considère que c'est un ban définitif
                if($diff->y > 10) {
                    $b['type_ban'] = 'Définitif';
                    $b['temps_restant'] = 'Jamais';
                } else {
                    $b['temps_restant'] = $diff->days . 'j ' . $diff->h . 'h';
                    $b['type_ban'] = 'Temporaire';
                }
            } else {
                // Le temps est écoulé mais le compte n'a pas encore été réactivé (le sera à la prochaine connexion)
                $b['temps_restant'] = 'Expiré (Déban auto)';
                $b['type_ban'] = 'Expiré';
            }
        } else {
            // Si aucune date n'est précisée (NULL), c'est un ban définitif par défaut
            $b['type_ban'] = 'Définitif';
            $b['temps_restant'] = 'Jamais';
        }
    }

    // Affichage de la vue admin
    Flight::render('admin/moderation.tpl', [
        'titre' => 'Espace Modération',
        'en_attente' => $enAttente,
        'historique' => $historique,
        'bannis' => $bannis
    ]);
});

// API : Traitement des actions (Bannir, Ignorer, Débannir)
Flight::route('POST /admin/signalement/traiter', function(){
    // Vérification des droits admin pour l'API également
    if(!isset($_SESSION['user']) || $_SESSION['user']['admin_flag'] !== 'Y') Flight::json(['success'=>false], 403);

    $db = Flight::get('db');
    $data = json_decode(file_get_contents('php://input'), true);
    $action = $data['action'];
    
    try {
        // ACTION 1 : Marquer comme vu (sans suite)
        if ($action == 'vu') {
            $stmt = $db->prepare("UPDATE SIGNALEMENTS SET statut_code = 'R' WHERE id_signalement = ?");
            $stmt->execute([$data['id']]);
            Flight::json(['success' => true, 'msg' => 'Classé sans suite.']);
        } 
        // ACTION 2 : Bannir un utilisateur
        elseif ($action == 'ban') {
            $idSig = $data['id'];
            $duree = $data['duree']; 

            // Calcul de la date de fin de bannissement
            $dateFin = null;
            if($duree !== 'definitif') {
                $dateFin = date('Y-m-d H:i:s', strtotime("+$duree days"));
            } else {
                // NULL signifie banni indéfiniment
                $dateFin = NULL; 
            }

            // On retrouve l'ID de l'utilisateur signalé
            $stmtGet = $db->prepare("SELECT id_signale FROM SIGNALEMENTS WHERE id_signalement = ?");
            $stmtGet->execute([$idSig]);
            $idCoupable = $stmtGet->fetchColumn();

            if($idCoupable) {
                $db->beginTransaction();
                
                // On désactive le compte et on enregistre la date de fin
                $sqlUser = "UPDATE UTILISATEURS SET active_flag = 'N', date_expiration_token = :dateFin WHERE id_utilisateur = :id";
                $db->prepare($sqlUser)->execute([':dateFin' => $dateFin, ':id' => $idCoupable]);
                
                // On marque tous les signalements en attente de cet utilisateur comme "Jugés" (J)
                $db->prepare("UPDATE SIGNALEMENTS SET statut_code = 'J' WHERE id_signale = ? AND statut_code = 'E'")->execute([$idCoupable]);
                $db->commit();
                
                Flight::json(['success' => true]);
            } else {
                Flight::json(['success' => false, 'msg' => 'Utilisateur introuvable.']);
            }
        }
        // ACTION 3 : Débannir un utilisateur
        elseif ($action == 'unban') {
            // On réactive le compte et on nettoie la date d'expiration
            $db->prepare("UPDATE UTILISATEURS SET active_flag = 'Y', date_expiration_token = NULL WHERE id_utilisateur = ?")->execute([$data['id_user']]);
            Flight::json(['success' => true]);
        }
    } catch (Exception $e) {
        if($db->inTransaction()) $db->rollBack();
        Flight::json(['success' => false, 'msg' => $e->getMessage()]);
    }
});
?>