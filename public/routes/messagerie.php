<?php

// LISTE DES CONVERSATIONS
Flight::route('GET /messagerie', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // 1. Récupérer les trajets
    $sql = "SELECT t.id_trajet, t.ville_depart, t.ville_arrivee, t.date_heure_depart,
                   u.prenom as conducteur_prenom, u.nom as conducteur_nom
            FROM TRAJETS t
            LEFT JOIN RESERVATIONS r ON t.id_trajet = r.id_trajet
            JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
            WHERE t.id_conducteur = :uid 
            OR (r.id_passager = :uid AND r.statut_code = 'V')
            GROUP BY t.id_trajet"; 

    $stmt = $db->prepare($sql);
    $stmt->execute([':uid' => $userId]);
    $conversations = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 2. Enrichir les données
    foreach ($conversations as &$conv) {
        $id = $conv['id_trajet'];
        
        $stmtMsg = $db->prepare("SELECT contenu, date_envoi FROM MESSAGES WHERE id_trajet = ? ORDER BY date_envoi DESC LIMIT 1");
        $stmtMsg->execute([$id]);
        $lastMsg = $stmtMsg->fetch(PDO::FETCH_ASSOC);
        
        $conv['dernier_message'] = $lastMsg ? $lastMsg['contenu'] : null;
        $conv['date_tri'] = ($lastMsg && !empty($lastMsg['date_envoi'])) 
                            ? $lastMsg['date_envoi'] 
                            : $conv['date_heure_depart'];

        // --- FIX COOKIE NOMMÉ AVEC ID USER ---
        $cookieName = 'last_read_' . $userId . '_' . $id;
        $lastReadDate = isset($_COOKIE[$cookieName]) ? $_COOKIE[$cookieName] : '2000-01-01 00:00:00';
        
        $stmtCount = $db->prepare("SELECT COUNT(*) FROM MESSAGES WHERE id_trajet = ? AND date_envoi > ? AND id_expediteur != ?");
        $stmtCount->execute([$id, $lastReadDate, $userId]);
        $conv['nb_non_lus'] = $stmtCount->fetchColumn();
    }

    // 3. Tri
    usort($conversations, function($a, $b) {
        $hasMsgA = !empty($a['dernier_message']);
        $hasMsgB = !empty($b['dernier_message']);
        if ($hasMsgA && !$hasMsgB) return -1; 
        if (!$hasMsgA && $hasMsgB) return 1;  
        
        return strtotime($b['date_tri']) - strtotime($a['date_tri']);
    });

    Flight::render('messagerie/liste.tpl', [
        'titre' => 'Mes Discussions',
        'conversations' => $conversations
    ]);
});

// AFFICHER UNE CONVERSATION
Flight::route('GET /messagerie/conversation/@id', function($id){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // Vérifier accès
    $sqlCheck = "SELECT t.* FROM TRAJETS t
                 LEFT JOIN RESERVATIONS r ON t.id_trajet = r.id_trajet
                 WHERE t.id_trajet = :tid 
                 AND (t.id_conducteur = :uid OR (r.id_passager = :uid AND r.statut_code = 'V'))
                 LIMIT 1";
    
    $stmtCheck = $db->prepare($sqlCheck);
    $stmtCheck->execute([':tid' => $id, ':uid' => $userId]);
    $trajet = $stmtCheck->fetch(PDO::FETCH_ASSOC);

    if (!$trajet) {
        $_SESSION['flash_error'] = "Accès refusé.";
        Flight::redirect('/messagerie'); 
        return;
    }

    // --- FIX COOKIE NOMMÉ AVEC ID USER ---
    // On met à jour la date de lecture pour CET utilisateur spécifiquement
    $now = date('Y-m-d H:i:s');
    setcookie('last_read_' . $userId . '_' . $id, $now, time() + (86400 * 30), "/");

    // Messages
    $sqlMsg = "SELECT m.*, u.nom, u.prenom 
               FROM MESSAGES m
               JOIN UTILISATEURS u ON m.id_expediteur = u.id_utilisateur
               WHERE m.id_trajet = :tid
               ORDER BY m.date_envoi ASC";
               
    $stmtMsg = $db->prepare($sqlMsg);
    $stmtMsg->execute([':tid' => $id]);
    $messagesBruts = $stmtMsg->fetchAll(PDO::FETCH_ASSOC);

    $messages = [];
    $lastDate = null;

    foreach($messagesBruts as $msg) {
        $dateObj = new DateTime($msg['date_envoi']);
        $dateJour = $dateObj->format('d/m/Y');
        
        if ($dateJour !== $lastDate) {
            $messages[] = ['type' => 'separator', 'date' => $dateJour];
            $lastDate = $dateJour;
        }

        $msg['type'] = ($msg['id_expediteur'] == $userId) ? 'self' : 'other';
        $msg['heure_fmt'] = $dateObj->format('H:i');
        $msg['nom_affiche'] = ($msg['type'] == 'self') ? 'Moi' : $msg['prenom'] . ' ' . substr($msg['nom'], 0, 1) . '.';
        
        $messages[] = $msg;
    }

    $dateTrajet = new DateTime($trajet['date_heure_depart']);
    $trajet['date_fmt'] = $dateTrajet->format('d/m/Y à H\hi');

    Flight::render('messagerie/conversation.tpl', [
        'titre' => 'Conversation',
        'trajet' => $trajet,
        'messages' => $messages
    ]);
});

// API ENVOYER MESSAGE
Flight::route('POST /api/messagerie/send', function(){
    if(!isset($_SESSION['user'])) Flight::json(['success' => false], 401);

    $db = Flight::get('db');
    $data = json_decode(file_get_contents('php://input'), true);
    
    $idTrajet = $data['trajet_id'];
    $contenu = htmlspecialchars(trim($data['message']));
    $userId = $_SESSION['user']['id_utilisateur'];

    if(empty($contenu)) { Flight::json(['success' => false]); return; }

    $stmt = $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (:tid, :uid, :msg, NOW())");
    $res = $stmt->execute([
        ':tid' => $idTrajet,
        ':uid' => $userId,
        ':msg' => $contenu
    ]);

    if ($res) {
        // --- FIX COOKIE NOMMÉ AVEC ID USER ---
        // On met à jour le cookie de L'EXPÉDITEUR uniquement
        setcookie('last_read_' . $userId . '_' . $idTrajet, date('Y-m-d H:i:s'), time() + (86400 * 30), "/");
        Flight::json(['success' => true]);
    } else {
        Flight::json(['success' => false]);
    }
});
?>