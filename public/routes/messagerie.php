<?php

// 1. LISTE DES CONVERSATIONS (SEPARÉE EN ONGLETS)
Flight::route('GET /messagerie', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // Récupérer les trajets
    $sql = "SELECT t.id_trajet, t.id_conducteur, t.ville_depart, t.ville_arrivee, t.date_heure_depart, 
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
    $rawConversations = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Initialisation
    $groupes = ['encours' => [], 'avenir'  => [], 'termine' => []];
    $notifs = ['encours' => 0, 'avenir'  => 0, 'termine' => 0];

    foreach ($rawConversations as &$conv) {
        $id = $conv['id_trajet'];
        $now = new DateTime();
        $depart = new DateTime($conv['date_heure_depart']);
        
        // Calcul Arrivée
        if(isset($conv['duree_estimee'])) {
            $dureeParts = explode(':', $conv['duree_estimee']);
            $arrivee = clone $depart;
            $arrivee->add(new DateInterval('PT' . $dureeParts[0] . 'H' . $dureeParts[1] . 'M'));
        } else {
            $arrivee = clone $depart; 
            $arrivee->modify('+1 hour');
        }

        // --- AUTOMATISATION FIN DE TRAJET ---
        if ($conv['statut_flag'] != 'T' && $now > $arrivee) {
            $stmtCheckEnd = $db->prepare("SELECT COUNT(*) FROM MESSAGES WHERE id_trajet = ? AND contenu = '::sys_end::'");
            $stmtCheckEnd->execute([$id]);
            if ($stmtCheckEnd->fetchColumn() == 0) {
                $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (?, ?, '::sys_end::', NOW())")
                   ->execute([$id, $conv['id_conducteur']]);
            }
        }

        // --- DÉTERMINATION DU STATUT ---
        if ($conv['statut_flag'] == 'T' || $now > $arrivee) {
            $statutKey = 'termine';
            $conv['statut_visuel'] = 'termine';
            $conv['statut_libelle'] = 'Terminé';
            $conv['statut_couleur'] = 'secondary';
        } elseif ($now >= $depart && $now <= $arrivee) {
            $statutKey = 'encours';
            $conv['statut_visuel'] = 'encours';
            $conv['statut_libelle'] = 'En cours';
            $conv['statut_couleur'] = 'success';
            
            $diff = $now->diff($arrivee);
            $conv['temps_restant'] = ($diff->h > 0) ? $diff->format('%hh %Im') : $diff->format('%I min');

        } else {
            $statutKey = 'avenir';
            $conv['statut_visuel'] = 'avenir'; // Important pour éviter erreur 500
            
            $conv['statut_libelle'] = ($conv['statut_flag'] == 'C') ? 'Complet' : 'À venir';
            $conv['statut_couleur'] = ($conv['statut_flag'] == 'C') ? 'warning' : 'primary';
        }

        // --- INFO MESSAGES ---
        $stmtMsg = $db->prepare("SELECT contenu, date_envoi FROM MESSAGES WHERE id_trajet = ? ORDER BY date_envoi DESC LIMIT 1");
        $stmtMsg->execute([$id]);
        $lastMsg = $stmtMsg->fetch(PDO::FETCH_ASSOC);
        
        $conv['dernier_message'] = $lastMsg ? $lastMsg['contenu'] : null;
        $conv['date_tri'] = ($lastMsg && !empty($lastMsg['date_envoi'])) ? $lastMsg['date_envoi'] : null;

        // --- NON LUS (LA CORRECTION EST ICI) ---
        // On compte si : (Expediteur != moi) OU (C'est un message système ::sys_)
        $cookieName = 'last_read_' . $userId . '_' . $id;
        $lastReadDate = isset($_COOKIE[$cookieName]) ? $_COOKIE[$cookieName] : '2000-01-01 00:00:00';
        
        $sqlCount = "SELECT COUNT(*) FROM MESSAGES 
                     WHERE id_trajet = ? 
                     AND date_envoi > ? 
                     AND (id_expediteur != ? OR contenu LIKE '::sys_%')"; 
                     
        $stmtCount = $db->prepare($sqlCount);
        $stmtCount->execute([$id, $lastReadDate, $userId]);
        $nb = $stmtCount->fetchColumn();
        
        $conv['nb_non_lus'] = $nb;
        
        // Ajout aux compteurs
        $notifs[$statutKey] += $nb;
        $groupes[$statutKey][] = $conv;
    }

    // --- TRI INTELLIGENT ---
    $sortFunction = function($a, $b) {
        $hasMsgA = !empty($a['dernier_message']);
        $hasMsgB = !empty($b['dernier_message']);

        // 1. Une conversation avec message passe TOUJOURS devant une vide
        if ($hasMsgA && !$hasMsgB) return -1;
        if (!$hasMsgA && $hasMsgB) return 1;

        // 2. Si les deux ont des messages -> Le plus récent en premier
        if ($hasMsgA && $hasMsgB) {
            return strtotime($b['date_tri']) - strtotime($a['date_tri']);
        }

        // 3. Sinon tri par date de départ
        return strtotime($a['date_heure_depart']) - strtotime($b['date_heure_depart']);
    };

    usort($groupes['encours'], $sortFunction);
    usort($groupes['avenir'], $sortFunction);
    usort($groupes['termine'], $sortFunction);

    Flight::render('messagerie/liste.tpl', [
        'titre' => 'Mes Discussions',
        'groupes' => $groupes,
        'notifs' => $notifs
    ]);
});

// 2. AFFICHER UNE CONVERSATION
Flight::route('GET /messagerie/conversation/@id', function($id){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // Infos Trajet
    $sqlCheck = "SELECT t.*, u.prenom as cond_prenom, u.nom as cond_nom, u.id_utilisateur as cond_id FROM TRAJETS t LEFT JOIN RESERVATIONS r ON t.id_trajet = r.id_trajet JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur WHERE t.id_trajet = :tid AND (t.id_conducteur = :uid OR (r.id_passager = :uid AND r.statut_code = 'V')) LIMIT 1";
    $stmtCheck = $db->prepare($sqlCheck);
    $stmtCheck->execute([':tid' => $id, ':uid' => $userId]);
    $trajet = $stmtCheck->fetch(PDO::FETCH_ASSOC);

    if (!$trajet) { $_SESSION['flash_error'] = "Accès refusé."; Flight::redirect('/messagerie'); return; }

    // Participants
    $participants = [];
    if ($trajet['cond_id'] != $userId) $participants[] = ['id' => $trajet['cond_id'], 'nom' => $trajet['cond_prenom'] . ' ' . $trajet['cond_nom'], 'role' => 'Conducteur'];
    $passagers = $db->prepare("SELECT u.id_utilisateur, u.prenom, u.nom FROM RESERVATIONS r JOIN UTILISATEURS u ON r.id_passager = u.id_utilisateur WHERE r.id_trajet = ? AND r.statut_code = 'V'");
    $passagers->execute([$id]);
    foreach($passagers->fetchAll(PDO::FETCH_ASSOC) as $p) { if ($p['id_utilisateur'] != $userId) $participants[] = ['id' => $p['id_utilisateur'], 'nom' => $p['prenom'] . ' ' . $p['nom'], 'role' => 'Passager']; }

    // Statut
    $now = new DateTime();
    $depart = new DateTime($trajet['date_heure_depart']);
    $dureeParts = explode(':', $trajet['duree_estimee']);
    $arrivee = clone $depart;
    $arrivee->add(new DateInterval('PT' . $dureeParts[0] . 'H' . $dureeParts[1] . 'M'));

    if ($trajet['statut_flag'] == 'T' || $now > $arrivee) {
        $trajet['statut_visuel'] = 'termine'; $trajet['statut_libelle'] = 'Terminé'; $trajet['statut_couleur'] = 'secondary';
    } elseif ($now >= $depart && $now <= $arrivee) {
        $trajet['statut_visuel'] = 'encours'; $trajet['statut_libelle'] = 'En cours'; $trajet['statut_couleur'] = 'success';
        $diff = $now->diff($arrivee);
        if ($diff->h > 0) $trajet['temps_restant'] = $diff->format('%hh %Im');
        else $trajet['temps_restant'] = $diff->format('%I min');
    } else {
        if ($trajet['statut_flag'] == 'C') { $trajet['statut_visuel'] = 'complet'; $trajet['statut_libelle'] = 'Complet'; $trajet['statut_couleur'] = 'warning'; } 
        else { $trajet['statut_visuel'] = 'avenir'; $trajet['statut_libelle'] = 'À venir'; $trajet['statut_couleur'] = 'primary'; }
    }

    if ($trajet['statut_visuel'] == 'termine') {
        $stmtCheckEnd = $db->prepare("SELECT COUNT(*) FROM MESSAGES WHERE id_trajet = ? AND contenu = '::sys_end::'");
        $stmtCheckEnd->execute([$id]);
        if ($stmtCheckEnd->fetchColumn() == 0) { $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (?, ?, '::sys_end::', NOW())")->execute([$id, $trajet['id_conducteur']]); }
    }

    setcookie('last_read_' . $userId . '_' . $id, date('Y-m-d H:i:s'), time() + (86400 * 30), "/");

    $messagesBruts = $db->prepare("SELECT m.*, u.nom, u.prenom FROM MESSAGES m JOIN UTILISATEURS u ON m.id_expediteur = u.id_utilisateur WHERE m.id_trajet = ? ORDER BY m.date_envoi ASC");
    $messagesBruts->execute([$id]);
    
    $messages = [];
    $lastDate = null;
    foreach($messagesBruts->fetchAll(PDO::FETCH_ASSOC) as $msg) {
        $dateObj = new DateTime($msg['date_envoi']);
        $dateJour = $dateObj->format('d/m/Y');
        if ($dateJour !== $lastDate) { $messages[] = ['type' => 'separator', 'date' => $dateJour]; $lastDate = $dateJour; }
        if (strpos($msg['contenu'], '::sys_') === 0) {
            $msg['type'] = 'system';
            if ($msg['contenu'] == '::sys_join::') $msg['text_affiche'] = $msg['prenom'] . ' a rejoint le trajet.';
            elseif ($msg['contenu'] == '::sys_leave::') $msg['text_affiche'] = $msg['prenom'] . ' a quitté le trajet.';
        } else {
            $msg['type'] = ($msg['id_expediteur'] == $userId) ? 'self' : 'other';
            $msg['nom_affiche'] = ($msg['type'] == 'self') ? 'Moi' : $msg['prenom'] . ' ' . substr($msg['nom'], 0, 1) . '.';
        }
        $msg['heure_fmt'] = $dateObj->format('H:i');
        $messages[] = $msg;
    }
    $dateTrajet = new DateTime($trajet['date_heure_depart']);
    $trajet['date_fmt'] = $dateTrajet->format('d/m/Y à H\hi');
    Flight::render('messagerie/conversation.tpl', ['titre' => 'Conversation', 'trajet' => $trajet, 'messages' => $messages, 'participants' => $participants]);
});

// 3. API : ENVOYER
Flight::route('POST /api/messagerie/send', function(){
    if(!isset($_SESSION['user'])) Flight::json(['success' => false], 401);
    $data = json_decode(file_get_contents('php://input'), true);
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];
    $trajetId = $data['trajet_id'];
    $contenu = htmlspecialchars(trim($data['message']));
    
    // Sécurité anti-spoofing
    if (strpos($contenu, '::sys_') === 0) {
        Flight::json(['success' => false, 'msg' => 'Contenu interdit']);
        return;
    }

    if(!empty($contenu)) {
        $stmt = $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (:tid, :uid, :msg, NOW())");
        if($stmt->execute([':tid' => $trajetId, ':uid' => $userId, ':msg' => $contenu])) {
            setcookie('last_read_' . $userId . '_' . $trajetId, date('Y-m-d H:i:s'), time() + (86400 * 30), "/");
            Flight::json(['success' => true]);
        } else { Flight::json(['success' => false]); }
    } else { Flight::json(['success' => false]); }
});
?>