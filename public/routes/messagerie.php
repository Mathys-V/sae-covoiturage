<?php


// LISTE DES CONVERSATIONS
Flight::route('GET /messagerie', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // 1. Récupérer les trajets (AJOUT DE duree_estimee et statut_flag)
    $sql = "SELECT t.id_trajet, t.ville_depart, t.ville_arrivee, t.date_heure_depart, 
                   t.duree_estimee, t.statut_flag,
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
        
        // --- CALCUL STATUT TRAJET (Même logique que le détail) ---
        $now = new DateTime();
        $depart = new DateTime($conv['date_heure_depart']);
        
        // Calcul arrivée
        if(isset($conv['duree_estimee'])) {
            $dureeParts = explode(':', $conv['duree_estimee']);
            $arrivee = clone $depart;
            $arrivee->add(new DateInterval('PT' . $dureeParts[0] . 'H' . $dureeParts[1] . 'M'));
        } else {
            $arrivee = clone $depart; 
            $arrivee->modify('+1 hour'); // Valeur par défaut si erreur
        }

        if ($conv['statut_flag'] == 'T' || $now > $arrivee) {
            $conv['statut_visuel'] = 'termine';
            $conv['statut_libelle'] = 'Terminé';
            $conv['statut_couleur'] = 'secondary';
        } elseif ($now >= $depart && $now <= $arrivee) {
            $conv['statut_visuel'] = 'encours';
            $conv['statut_libelle'] = 'En cours';
            $conv['statut_couleur'] = 'success';
        } else {
            if ($conv['statut_flag'] == 'C') {
                $conv['statut_visuel'] = 'complet';
                $conv['statut_libelle'] = 'Complet';
                $conv['statut_couleur'] = 'warning';
            } else {
                $conv['statut_visuel'] = 'avenir';
                $conv['statut_libelle'] = 'À venir';
                $conv['statut_couleur'] = 'primary';
            }
        }
        // -------------------------------------------------------

        // Dernier message
        $stmtMsg = $db->prepare("SELECT contenu, date_envoi FROM MESSAGES WHERE id_trajet = ? ORDER BY date_envoi DESC LIMIT 1");
        $stmtMsg->execute([$id]);
        $lastMsg = $stmtMsg->fetch(PDO::FETCH_ASSOC);
        
        $conv['dernier_message'] = $lastMsg ? $lastMsg['contenu'] : null;
        $conv['date_tri'] = ($lastMsg && !empty($lastMsg['date_envoi'])) 
                            ? $lastMsg['date_envoi'] 
                            : $conv['date_heure_depart'];

        // Cookie Non Lu
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

// AFFICHER UNE CONVERSATION (Chat)
Flight::route('GET /messagerie/conversation/@id', function($id){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // 1. Vérifier accès + Infos Trajet
    $sqlCheck = "SELECT t.* FROM TRAJETS t
                 LEFT JOIN RESERVATIONS r ON t.id_trajet = r.id_trajet
                 WHERE t.id_trajet = :tid 
                 AND (t.id_conducteur = :uid OR (r.id_passager = :uid AND r.statut_code = 'V'))
                 LIMIT 1";
    
    $stmtCheck = $db->prepare($sqlCheck);
    $stmtCheck->execute([':tid' => $id, ':uid' => $userId]);
    $trajet = $stmtCheck->fetch(PDO::FETCH_ASSOC);

    if (!$trajet) {
        $_SESSION['flash_error'] = "Vous ne faites pas partie de ce trajet.";
        Flight::redirect('/messagerie'); 
        return;
    }

    // --- CALCUL STATUT TRAJET (Hybride BDD + Temps) ---
    $now = new DateTime();
    $depart = new DateTime($trajet['date_heure_depart']);
    
    // Calcul de l'arrivée
    $dureeParts = explode(':', $trajet['duree_estimee']);
    $arrivee = clone $depart;
    $arrivee->add(new DateInterval('PT' . $dureeParts[0] . 'H' . $dureeParts[1] . 'M'));

    // 1. Si le trajet est marqué "Terminé" en BDD OU que la date est passée
    if ($trajet['statut_flag'] == 'T' || $now > $arrivee) {
        $trajet['statut_visuel'] = 'termine';
        $trajet['statut_libelle'] = 'Terminé';
        $trajet['statut_couleur'] = 'secondary'; // Gris
    } 
    // 2. Si on est pile dans le créneau horaire
    elseif ($now >= $depart && $now <= $arrivee) {
        $trajet['statut_visuel'] = 'encours';
        $trajet['statut_libelle'] = 'Trajet en cours';
        $trajet['statut_couleur'] = 'success'; // Vert
    } 
    // 3. Si c'est dans le futur
    else {
        // C'est ici que votre colonne BDD est utile !
        if ($trajet['statut_flag'] == 'C') {
            $trajet['statut_visuel'] = 'complet';
            $trajet['statut_libelle'] = 'Complet';
            $trajet['statut_couleur'] = 'warning'; // Jaune/Orange
        } else {
            $trajet['statut_visuel'] = 'avenir';
            $trajet['statut_libelle'] = 'Départ à venir';
            $trajet['statut_couleur'] = 'primary'; // Bleu/Violet
        }
    }
    


    // 2. Mise à jour cookie lecture
    $nowStr = date('Y-m-d H:i:s');
    setcookie('last_read_' . $userId . '_' . $id, $nowStr, time() + (86400 * 30), "/");

    // 3. Récupérer les messages
    $sqlMsg = "SELECT m.*, u.nom, u.prenom 
               FROM MESSAGES m
               JOIN UTILISATEURS u ON m.id_expediteur = u.id_utilisateur
               WHERE m.id_trajet = :tid
               ORDER BY m.date_envoi ASC";
               
    $stmtMsg = $db->prepare($sqlMsg);
    $stmtMsg->execute([':tid' => $id]);
    $messagesBruts = $stmtMsg->fetchAll(PDO::FETCH_ASSOC);

    // 4. Formatage
    $messages = [];
    $lastDate = null;

    foreach($messagesBruts as $msg) {
        $dateObj = new DateTime($msg['date_envoi']);
        $dateJour = $dateObj->format('d/m/Y');
        
        if ($dateJour !== $lastDate) {
            $messages[] = ['type' => 'separator', 'date' => $dateJour];
            $lastDate = $dateJour;
        }

        // --- GESTION MESSAGES SYSTEMES ---
        if ($msg['contenu'] === '::sys_join::') {
            $msg['type'] = 'system';
            $msg['text_affiche'] = $msg['prenom'] . ' ' . $msg['nom'] . ' a rejoint le trajet.';
        } elseif ($msg['contenu'] === '::sys_leave::') {
            $msg['type'] = 'system';
            $msg['text_affiche'] = $msg['prenom'] . ' ' . $msg['nom'] . ' a quitté le trajet.';
        } else {
            $msg['type'] = ($msg['id_expediteur'] == $userId) ? 'self' : 'other';
            $msg['nom_affiche'] = ($msg['type'] == 'self') ? 'Moi' : $msg['prenom'] . ' ' . substr($msg['nom'], 0, 1) . '.';
        }
        
        $msg['heure_fmt'] = $dateObj->format('H:i');
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