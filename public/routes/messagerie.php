<?php

// 1. LISTE DES CONVERSATIONS
Flight::route('GET /messagerie', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // Récupérer les trajets (AJOUT DE t.id_conducteur dans le SELECT pour l'insertion auto)
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
    $conversations = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Enrichissement des données
    foreach ($conversations as &$conv) {
        $id = $conv['id_trajet'];
        
        // --- CALCUL STATUT & TEMPS RESTANT ---
        $now = new DateTime();
        $depart = new DateTime($conv['date_heure_depart']);
        
        if(isset($conv['duree_estimee'])) {
            $dureeParts = explode(':', $conv['duree_estimee']);
            $arrivee = clone $depart;
            $arrivee->add(new DateInterval('PT' . $dureeParts[0] . 'H' . $dureeParts[1] . 'M'));
        } else {
            $arrivee = clone $depart; 
            $arrivee->modify('+1 hour');
        }

        // --- AUTOMATISATION DANS LA LISTE (NOUVEAU) ---
        // Si l'heure d'arrivée est passée, on force la clôture et le message
        if ($conv['statut_flag'] != 'T' && $now > $arrivee) {
            // 1. Vérifier si message existe
            $stmtCheckEnd = $db->prepare("SELECT COUNT(*) FROM MESSAGES WHERE id_trajet = ? AND contenu = '::sys_end::'");
            $stmtCheckEnd->execute([$id]);
            
            if ($stmtCheckEnd->fetchColumn() == 0) {
                // 2. Insérer le message de fin MAINTENANT
                $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (?, ?, '::sys_end::', NOW())")
                   ->execute([$id, $conv['id_conducteur']]);
            }
            // (Optionnel : On pourrait aussi mettre à jour le statut_flag à 'T' dans la table TRAJETS ici)
        }
        // -----------------------------------------------

        if ($conv['statut_flag'] == 'T' || $now > $arrivee) {
            $conv['statut_visuel'] = 'termine';
            $conv['statut_libelle'] = 'Terminé';
            $conv['statut_couleur'] = 'secondary';
        } elseif ($now >= $depart && $now <= $arrivee) {
            $conv['statut_visuel'] = 'encours';
            $conv['statut_libelle'] = 'En cours';
            $conv['statut_couleur'] = 'success';

            $diff = $now->diff($arrivee);
            if ($diff->h > 0) {
                $conv['temps_restant'] = $diff->format('%hh %Im');
            } else {
                $conv['temps_restant'] = $diff->format('%I min');
            }

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

        // --- DERNIER MESSAGE ---
        $stmtMsg = $db->prepare("SELECT contenu, date_envoi FROM MESSAGES WHERE id_trajet = ? ORDER BY date_envoi DESC LIMIT 1");
        $stmtMsg->execute([$id]);
        $lastMsg = $stmtMsg->fetch(PDO::FETCH_ASSOC);
        
        $conv['dernier_message'] = $lastMsg ? $lastMsg['contenu'] : null;
        $conv['date_tri'] = ($lastMsg && !empty($lastMsg['date_envoi'])) 
                            ? $lastMsg['date_envoi'] 
                            : $conv['date_heure_depart'];

        // --- COMPTEUR NON LUS ---
        $cookieName = 'last_read_' . $userId . '_' . $id;
        $lastReadDate = isset($_COOKIE[$cookieName]) ? $_COOKIE[$cookieName] : '2000-01-01 00:00:00';
        
        $stmtCount = $db->prepare("SELECT COUNT(*) FROM MESSAGES WHERE id_trajet = ? AND date_envoi > ? AND id_expediteur != ?");
        $stmtCount->execute([$id, $lastReadDate, $userId]);
        $conv['nb_non_lus'] = $stmtCount->fetchColumn();
    }

    // 3. TRI INTÉLLIGENT
    usort($conversations, function($a, $b) {
        // Priorité absolue : En cours
        $isEnCoursA = ($a['statut_visuel'] === 'encours');
        $isEnCoursB = ($b['statut_visuel'] === 'encours');

        if ($isEnCoursA && !$isEnCoursB) return -1;
        if (!$isEnCoursA && $isEnCoursB) return 1;

        // Sinon tri par date d'activité (message récent)
        $dateA = strtotime($a['date_tri']);
        $dateB = strtotime($b['date_tri']);

        if ($dateA == $dateB) return 0;
        return ($dateA > $dateB) ? -1 : 1; 
    });

    Flight::render('messagerie/liste.tpl', [
        'titre' => 'Mes Discussions',
        'conversations' => $conversations
    ]);
});

// 2. AFFICHER UNE CONVERSATION (Chat) - Code inchangé, sert de sécurité
Flight::route('GET /messagerie/conversation/@id', function($id){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // Infos Trajet + Participants
    $sqlCheck = "SELECT t.*, 
                 u.prenom as cond_prenom, u.nom as cond_nom, u.id_utilisateur as cond_id
                 FROM TRAJETS t
                 LEFT JOIN RESERVATIONS r ON t.id_trajet = r.id_trajet
                 JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
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

    // Participants
    $participants = [];
    if ($trajet['cond_id'] != $userId) {
        $participants[] = ['id' => $trajet['cond_id'], 'nom' => $trajet['cond_prenom'] . ' ' . $trajet['cond_nom'], 'role' => 'Conducteur'];
    }
    $passagers = $db->prepare("SELECT u.id_utilisateur, u.prenom, u.nom FROM RESERVATIONS r JOIN UTILISATEURS u ON r.id_passager = u.id_utilisateur WHERE r.id_trajet = ? AND r.statut_code = 'V'");
    $passagers->execute([$id]);
    foreach($passagers->fetchAll(PDO::FETCH_ASSOC) as $p) {
        if ($p['id_utilisateur'] != $userId) {
            $participants[] = ['id' => $p['id_utilisateur'], 'nom' => $p['prenom'] . ' ' . $p['nom'], 'role' => 'Passager'];
        }
    }

    // Calcul Statut
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
        if ($trajet['statut_flag'] == 'C') {
            $trajet['statut_visuel'] = 'complet'; $trajet['statut_libelle'] = 'Complet'; $trajet['statut_couleur'] = 'warning';
        } else {
            $trajet['statut_visuel'] = 'avenir'; $trajet['statut_libelle'] = 'À venir'; $trajet['statut_couleur'] = 'primary';
        }
    }

    // Sécurité : on laisse la vérif ici aussi au cas où l'user arrive par un lien direct
    if ($trajet['statut_visuel'] == 'termine') {
        $stmtCheckEnd = $db->prepare("SELECT COUNT(*) FROM MESSAGES WHERE id_trajet = ? AND contenu = '::sys_end::'");
        $stmtCheckEnd->execute([$id]);
        if ($stmtCheckEnd->fetchColumn() == 0) {
            $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (?, ?, '::sys_end::', NOW())")
               ->execute([$id, $trajet['id_conducteur']]);
        }
    }

    // Cookie Lecture
    setcookie('last_read_' . $userId . '_' . $id, date('Y-m-d H:i:s'), time() + (86400 * 30), "/");

    // Messages
    $messagesBruts = $db->prepare("SELECT m.*, u.nom, u.prenom FROM MESSAGES m JOIN UTILISATEURS u ON m.id_expediteur = u.id_utilisateur WHERE m.id_trajet = ? ORDER BY m.date_envoi ASC");
    $messagesBruts->execute([$id]);
    $messagesBruts = $messagesBruts->fetchAll(PDO::FETCH_ASSOC);

    $messages = [];
    $lastDate = null;
    foreach($messagesBruts as $msg) {
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

    Flight::render('messagerie/conversation.tpl', [
        'titre' => 'Conversation',
        'trajet' => $trajet,
        'messages' => $messages,
        'participants' => $participants
    ]);
});

// 3. API : ENVOYER UN MESSAGE
Flight::route('POST /api/messagerie/send', function(){
    if(!isset($_SESSION['user'])) Flight::json(['success' => false], 401);

    $data = json_decode(file_get_contents('php://input'), true);
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    $trajetId = $data['trajet_id'];
    $contenu = htmlspecialchars(trim($data['message']));

    if(!empty($contenu)) {
        try {
            $stmt = $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (:tid, :uid, :msg, NOW())");
            $res = $stmt->execute([
                ':tid' => $trajetId,
                ':uid' => $userId,
                ':msg' => $contenu
            ]);
            
            if($res) {
                setcookie('last_read_' . $userId . '_' . $trajetId, date('Y-m-d H:i:s'), time() + (86400 * 30), "/");
                Flight::json(['success' => true]);
            } else {
                Flight::json(['success' => false, 'msg' => 'Echec insertion']);
            }
        } catch(Exception $e) {
            Flight::json(['success' => false, 'msg' => 'Erreur SQL']);
        }
    } else {
        Flight::json(['success' => false, 'msg' => 'Message vide']);
    }
});

?>