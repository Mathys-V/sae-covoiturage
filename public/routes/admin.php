<?php

Flight::route('GET /moderation', function(){
    if(!isset($_SESSION['user']) || $_SESSION['user']['admin_flag'] !== 'Y') {
        Flight::redirect('/'); return;
    }

    $db = Flight::get('db');

    // 1. EN ATTENTE (inchangé)
    $enAttente = $db->query("SELECT s.*, u1.nom as nom_signaleur, u1.prenom as prenom_signaleur,
                   u2.nom as nom_signale, u2.prenom as prenom_signale, u2.email as email_signale,
                   t.ville_depart, t.ville_arrivee
            FROM SIGNALEMENTS s
            JOIN UTILISATEURS u1 ON s.id_signaleur = u1.id_utilisateur
            JOIN UTILISATEURS u2 ON s.id_signale = u2.id_utilisateur
            LEFT JOIN TRAJETS t ON s.id_trajet = t.id_trajet
            WHERE s.statut_code = 'E'
            ORDER BY s.date_signalement ASC")->fetchAll(PDO::FETCH_ASSOC);

    // 2. HISTORIQUE (inchangé)
    $historique = $db->query("SELECT s.*, u2.nom as nom_signale, u2.prenom as prenom_signale, u1.nom as nom_signaleur
            FROM SIGNALEMENTS s
            JOIN UTILISATEURS u1 ON s.id_signaleur = u1.id_utilisateur
            JOIN UTILISATEURS u2 ON s.id_signale = u2.id_utilisateur
            WHERE s.statut_code IN ('R', 'J')
            ORDER BY s.date_signalement DESC")->fetchAll(PDO::FETCH_ASSOC);

    // 3. BANNIS (Avec l'astuce date_expiration_token)
    $bannis = $db->query("SELECT * FROM UTILISATEURS WHERE active_flag = 'N' ORDER BY nom ASC")->fetchAll(PDO::FETCH_ASSOC);

    // Calcul du temps restant
    foreach($bannis as &$b) {
        // ASTUCE : On utilise date_expiration_token comme date de fin de ban
        if($b['date_expiration_token']) {
            $fin = new DateTime($b['date_expiration_token']);
            $now = new DateTime();
            
            // Si la date est dans le futur (ex: 2099) c'est peut-être un ban définitif maquillé, 
            // mais ici on part du principe que si y'a une date, c'est temporaire.
            if($fin > $now) {
                $diff = $now->diff($fin);
                // Si plus de 10 ans, on considère comme définitif pour l'affichage
                if($diff->y > 10) {
                    $b['type_ban'] = 'Définitif';
                    $b['temps_restant'] = 'Jamais';
                } else {
                    $b['temps_restant'] = $diff->days . 'j ' . $diff->h . 'h';
                    $b['type_ban'] = 'Temporaire';
                }
            } else {
                $b['temps_restant'] = 'Expiré (Déban auto)';
                $b['type_ban'] = 'Expiré';
            }
        } else {
            // Si NULL, on considère que c'est définitif
            $b['type_ban'] = 'Définitif';
            $b['temps_restant'] = 'Jamais';
        }
    }

    Flight::render('admin/moderation.tpl', [
        'titre' => 'Espace Modération',
        'en_attente' => $enAttente,
        'historique' => $historique,
        'bannis' => $bannis
    ]);
});

// API : ACTIONS
Flight::route('POST /admin/signalement/traiter', function(){
    if(!isset($_SESSION['user']) || $_SESSION['user']['admin_flag'] !== 'Y') Flight::json(['success'=>false], 403);

    $db = Flight::get('db');
    $data = json_decode(file_get_contents('php://input'), true);
    $action = $data['action'];
    
    try {
        if ($action == 'vu') {
            $stmt = $db->prepare("UPDATE SIGNALEMENTS SET statut_code = 'R' WHERE id_signalement = ?");
            $stmt->execute([$data['id']]);
            Flight::json(['success' => true, 'msg' => 'Classé sans suite.']);
        } 
        elseif ($action == 'ban') {
            $idSig = $data['id'];
            $duree = $data['duree']; 

            // Calcul date de fin
            $dateFin = null;
            if($duree !== 'definitif') {
                $dateFin = date('Y-m-d H:i:s', strtotime("+$duree days"));
            } else {
                // Pour définitif, soit on met NULL, soit une date très lointaine si besoin.
                // Ici on laisse NULL pour définitif.
                $dateFin = NULL; 
            }

            $stmtGet = $db->prepare("SELECT id_signale FROM SIGNALEMENTS WHERE id_signalement = ?");
            $stmtGet->execute([$idSig]);
            $idCoupable = $stmtGet->fetchColumn();

            if($idCoupable) {
                $db->beginTransaction();
                
                // ASTUCE : On écrit dans date_expiration_token
                $sqlUser = "UPDATE UTILISATEURS SET active_flag = 'N', date_expiration_token = :dateFin WHERE id_utilisateur = :id";
                $db->prepare($sqlUser)->execute([':dateFin' => $dateFin, ':id' => $idCoupable]);
                
                $db->prepare("UPDATE SIGNALEMENTS SET statut_code = 'J' WHERE id_signale = ? AND statut_code = 'E'")->execute([$idCoupable]);
                $db->commit();
                
                Flight::json(['success' => true]);
            } else {
                Flight::json(['success' => false, 'msg' => 'Utilisateur introuvable.']);
            }
        }
        elseif ($action == 'unban') {
            // Reset date_expiration_token à NULL
            $db->prepare("UPDATE UTILISATEURS SET active_flag = 'Y', date_expiration_token = NULL WHERE id_utilisateur = ?")->execute([$data['id_user']]);
            Flight::json(['success' => true]);
        }
    } catch (Exception $e) {
        if($db->inTransaction()) $db->rollBack();
        Flight::json(['success' => false, 'msg' => $e->getMessage()]);
    }
});
?>