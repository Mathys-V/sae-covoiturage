<?php

// ============================================================
// PARTIE 1 : LISTE DES CONVERSATIONS (MESSAGERIE)
// ============================================================
Flight::route('GET /messagerie', function(){
    // Vérification de connexion
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // --- RÉCUPÉRATION DES TRAJETS ---
    // On sélectionne les trajets où l'utilisateur est soit Conducteur, soit Passager (Validé, Annulé ou Refusé)
    // On a besoin de récupérer le statut de réservation 'mon_statut_reservation' pour savoir si l'utilisateur a annulé sa propre place.
    $sql = "SELECT t.id_trajet, t.id_conducteur, t.ville_depart, t.ville_arrivee, t.date_heure_depart, 
                   t.duree_estimee, t.statut_flag,
                   u.prenom as conducteur_prenom, u.nom as conducteur_nom,
                   r.statut_code as mon_statut_reservation
            FROM TRAJETS t
            LEFT JOIN RESERVATIONS r ON t.id_trajet = r.id_trajet
            JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur
            WHERE t.id_conducteur = :uid 
            OR (r.id_passager = :uid AND r.statut_code IN ('V', 'A', 'R')) 
            GROUP BY t.id_trajet"; 

    $stmt = $db->prepare($sql);
    $stmt->execute([':uid' => $userId]);
    $rawConversations = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Initialisation des groupes pour l'affichage (En cours, À venir, Terminé)
    $groupes = ['encours' => [], 'avenir'  => [], 'termine' => []];
    $notifs = ['encours' => 0, 'avenir'  => 0, 'termine' => 0];

    foreach ($rawConversations as &$conv) {
        $id = $conv['id_trajet'];
        $now = new DateTime();
        $depart = new DateTime($conv['date_heure_depart']);
        
        // Calcul de la date d'arrivée estimée
        if(isset($conv['duree_estimee'])) {
            $dureeParts = explode(':', $conv['duree_estimee']);
            $arrivee = clone $depart;
            $arrivee->add(new DateInterval('PT' . $dureeParts[0] . 'H' . $dureeParts[1] . 'M'));
        } else {
            // Fallback : Si pas de durée, on ajoute 1h par défaut
            $arrivee = clone $depart; 
            $arrivee->modify('+1 hour');
        }

        // --- DÉTECTION DU STATUT ANNULÉ ---
        // 1. Vérification si un message système d'annulation globale existe
        $stmtCancel = $db->prepare("SELECT COUNT(*) FROM MESSAGES WHERE id_trajet = ? AND contenu LIKE '::sys_cancel::%'");
        $stmtCancel->execute([$id]);
        $hasCancelMessage = $stmtCancel->fetchColumn() > 0;
        
        // 2. Le trajet est annulé globalement SI message système OU flag 'S' (Supprimé)
        $isGlobalCancel = ($hasCancelMessage || $conv['statut_flag'] == 'S');
        
        // 3. Annulation personnelle : L'utilisateur a annulé SA réservation ('A') ou a été refusé ('R')
        $isMyCancel = ($conv['mon_statut_reservation'] == 'A' || $conv['mon_statut_reservation'] == 'R');

        $isAnnule = ($isGlobalCancel || $isMyCancel);

        // --- AUTOMATISATION FIN DE TRAJET ---
        // Si la date d'arrivée est passée et que le trajet n'est pas déjà marqué comme terminé ou annulé
        if (!$isAnnule && $conv['statut_flag'] != 'T' && $now > $arrivee) {
            // On vérifie si le message de fin "::sys_end::" existe déjà
            $stmtCheckEnd = $db->prepare("SELECT COUNT(*) FROM MESSAGES WHERE id_trajet = ? AND contenu = '::sys_end::'");
            $stmtCheckEnd->execute([$id]);
            
            // S'il n'existe pas, on l'ajoute automatiquement pour clore la conversation
            if ($stmtCheckEnd->fetchColumn() == 0) {
                $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (?, ?, '::sys_end::', NOW())")
                    ->execute([$id, $conv['id_conducteur']]);
            }
        }

        // --- RÉCUPÉRATION DU DERNIER MESSAGE ---
        // Pour afficher un aperçu dans la liste
        $stmtMsg = $db->prepare("
            SELECT m.contenu, m.date_envoi, u.prenom 
            FROM MESSAGES m 
            JOIN UTILISATEURS u ON m.id_expediteur = u.id_utilisateur 
            WHERE m.id_trajet = ? 
            ORDER BY m.date_envoi DESC LIMIT 1
        ");
        $stmtMsg->execute([$id]);
        $lastMsg = $stmtMsg->fetch(PDO::FETCH_ASSOC);
        
        if ($lastMsg) {
            $contenu = $lastMsg['contenu'];
            // Traduction des messages système pour l'affichage
            if (strpos($contenu, '::sys_') === 0) {
                if (strpos($contenu, '::sys_cancel::') === 0) {
                    $contenu = "Le trajet a été annulé.";
                } elseif (strpos($contenu, '::sys_join::') === 0) {
                    $parts = explode('::', $contenu);
                    $nb = isset($parts[2]) ? (int)$parts[2] : 1;
                    $contenu = "a rejoint le trajet" . ($nb > 1 ? " ($nb places)" : ".");
                } elseif (strpos($contenu, '::sys_update::') === 0) {
                    $contenu = "Trajet modifié par le conducteur.";
                } elseif ($contenu == '::sys_leave::') {
                    $contenu = "a quitté le trajet.";
                } elseif ($contenu == '::sys_end::') {
                    $contenu = "Le trajet est terminé.";
                } elseif (strpos($contenu, '::sys_create::') === 0) {
                    $contenu = "Trajet publié.";
                }
            }
            $conv['dernier_message'] = $contenu;
            $conv['dernier_auteur'] = $lastMsg['prenom'];
            $conv['date_tri'] = $lastMsg['date_envoi']; // Utilisé pour le tri
        } else {
            $conv['dernier_message'] = null;
            $conv['date_tri'] = null;
        }

        // --- LOGIQUE DE CLASSEMENT DANS LES ONGLETS ---
        
        if ($isAnnule) {
            // CAS 1 : ANNULÉ (Soit globalement, soit juste moi)
            $statutKey = 'termine';
            $conv['statut_visuel'] = 'annule';
            $conv['statut_libelle'] = 'Annulé';
            $conv['statut_couleur'] = 'danger';

        } elseif ($conv['statut_flag'] == 'T' || $now > $arrivee) {
            // CAS 2 : TERMINÉ (Date passée ou Flag T)
            $statutKey = 'termine';
            $conv['statut_visuel'] = 'termine';
            $conv['statut_libelle'] = 'Terminé';
            $conv['statut_couleur'] = 'secondary';

// 2. ENSUITE on vérifie si c'est annulé
} elseif ($isAnnule) {
    $statutKey = 'termine'; // ou 'annule' si vous avez un onglet spécial
    $conv['statut_visuel'] = 'annule';
    $conv['statut_libelle'] = 'Annulé';
    $conv['statut_couleur'] = 'danger';

        } elseif ($now >= $depart && $now <= $arrivee) {
            // CAS 3 : EN COURS -> Onglet En cours (Vert)
            $statutKey = 'encours';
            $conv['statut_visuel'] = 'encours';
            $conv['statut_libelle'] = 'En cours';
            $conv['statut_couleur'] = 'success';
            
            // Calcul du temps restant
            $diff = $now->diff($arrivee);
            $conv['temps_restant'] = ($diff->h > 0) ? $diff->format('%hh %Im') : $diff->format('%I min');

        } else {
            // CAS 4 : À VENIR -> Onglet À venir (Bleu ou Jaune si complet)
            $statutKey = 'avenir';
            $conv['statut_visuel'] = 'avenir';
            $conv['statut_libelle'] = ($conv['statut_flag'] == 'C') ? 'Complet' : 'À venir';
            $conv['statut_couleur'] = ($conv['statut_flag'] == 'C') ? 'warning' : 'primary';
        }

        // --- GESTION DES NOTIFICATIONS (NON LUS) ---
        // On utilise un COOKIE pour stocker la date de dernière lecture de chaque trajet
        $cookieName = 'last_read_' . $userId . '_' . $id;
        $lastReadDate = isset($_COOKIE[$cookieName]) ? $_COOKIE[$cookieName] : '2000-01-01 00:00:00';
        
        // On compte les messages envoyés APRÈS la date du cookie
        // On exclut nos propres messages (sauf si ce sont des messages système qu'on a déclenché)
        $sqlCount = "SELECT COUNT(*) FROM MESSAGES WHERE id_trajet = ? AND date_envoi > ? AND (id_expediteur != ? OR contenu LIKE '::sys_%')"; 
        $stmtCount = $db->prepare($sqlCount);
        $stmtCount->execute([$id, $lastReadDate, $userId]);
        $nb = $stmtCount->fetchColumn();
        $conv['nb_non_lus'] = $nb;
        
        $notifs[$statutKey] += $nb;
        $groupes[$statutKey][] = $conv;
    }

    // Fonction de tri : Messages récents en premier, sinon par date de départ
    $sortFunction = function($a, $b) {
        $hasMsgA = !empty($a['dernier_message']);
        $hasMsgB = !empty($b['dernier_message']);
        if ($hasMsgA && !$hasMsgB) return -1;
        if (!$hasMsgA && $hasMsgB) return 1;
        if ($hasMsgA && $hasMsgB) return strtotime($b['date_tri']) - strtotime($a['date_tri']);
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

// ============================================================
// PARTIE 2 : AFFICHER UNE CONVERSATION (CHAT)
// ============================================================
Flight::route('GET /messagerie/conversation/@id', function($id){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // Vérification des droits d'accès au trajet + Récupération infos
    $sqlCheck = "SELECT t.*, u.prenom as cond_prenom, u.nom as cond_nom, u.id_utilisateur as cond_id,
                        r.statut_code as mon_statut_reservation
                 FROM TRAJETS t 
                 LEFT JOIN RESERVATIONS r ON (t.id_trajet = r.id_trajet AND r.id_passager = :uid)
                 JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur 
                 WHERE t.id_trajet = :tid 
                 AND (t.id_conducteur = :uid OR (r.id_passager = :uid AND r.statut_code IN ('V', 'A', 'R'))) 
                 LIMIT 1";
                 
    $stmtCheck = $db->prepare($sqlCheck);
    $stmtCheck->execute([':tid' => $id, ':uid' => $userId]);
    $trajet = $stmtCheck->fetch(PDO::FETCH_ASSOC);

    if (!$trajet) { $_SESSION['flash_error'] = "Accès refusé."; Flight::redirect('/messagerie'); return; }

    // Récupération des participants (Conducteur + Passagers Validés) pour l'affichage à droite
    $participants = [];
    if ($trajet['cond_id'] != $userId) $participants[] = ['id' => $trajet['cond_id'], 'nom' => $trajet['cond_prenom'] . ' ' . $trajet['cond_nom'], 'role' => 'Conducteur'];
    
    $passagers = $db->prepare("SELECT u.id_utilisateur, u.prenom, u.nom FROM RESERVATIONS r JOIN UTILISATEURS u ON r.id_passager = u.id_utilisateur WHERE r.id_trajet = ? AND r.statut_code = 'V'");
    $passagers->execute([$id]);
    foreach($passagers->fetchAll(PDO::FETCH_ASSOC) as $p) { 
        if ($p['id_utilisateur'] != $userId) $participants[] = ['id' => $p['id_utilisateur'], 'nom' => $p['prenom'] . ' ' . $p['nom'], 'role' => 'Passager']; 
    }

    // ... (Logique de statut identique à la liste pour l'affichage du bandeau haut) ...
    // [CODE SIMPLIFIÉ POUR LA LISIBILITÉ, LA LOGIQUE EST LA MÊME QUE CI-DESSUS]
    // ...

    // Mise à jour du COOKIE de lecture (Marque la conversation comme lue maintenant)
    setcookie('last_read_' . $userId . '_' . $id, date('Y-m-d H:i:s'), time() + (86400 * 30), "/");

    // Récupération des messages
    $messagesBruts = $db->prepare("SELECT m.*, u.nom, u.prenom FROM MESSAGES m JOIN UTILISATEURS u ON m.id_expediteur = u.id_utilisateur WHERE m.id_trajet = ? ORDER BY m.date_envoi ASC");
    $messagesBruts->execute([$id]);
    
    $messages = [];
    $lastDate = null;
    foreach($messagesBruts->fetchAll(PDO::FETCH_ASSOC) as $msg) {
        // Ajout d'un séparateur de date si changement de jour
        $dateObj = new DateTime($msg['date_envoi']);
        $dateJour = $dateObj->format('d/m/Y');
        if ($dateJour !== $lastDate) { $messages[] = ['type' => 'separator', 'date' => $dateJour]; $lastDate = $dateJour; }
        
        // Traitement des messages système pour l'affichage dans la bulle
        if (strpos($msg['contenu'], '::sys_') === 0) {
            $msg['type'] = 'system';
            // ... (Traduction des messages système comme ci-dessus) ...
            if (strpos($msg['contenu'], '::sys_join::') === 0) {
                // ...
            }
            // ...
        } else {
            // Message classique : Définition de l'alignement (Moi = droite, Autre = gauche)
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

// ============================================================
// PARTIE 3 : API ENVOI DE MESSAGE (POST via AJAX)
// ============================================================
Flight::route('POST /api/messagerie/send', function(){
    if(!isset($_SESSION['user'])) Flight::json(['success' => false], 401);
    
    $data = json_decode(file_get_contents('php://input'), true);
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];
    $trajetId = $data['trajet_id'];
    $contenu = htmlspecialchars(trim($data['message']));
    
    // Sécurité : Interdiction d'envoyer des messages commençant par ::sys_ (réservé système)
    if (strpos($contenu, '::sys_') === 0) {
        Flight::json(['success' => false, 'msg' => 'Contenu interdit']);
        return;
    }

    if(!empty($contenu)) {
        $stmt = $db->prepare("INSERT INTO MESSAGES (id_trajet, id_expediteur, contenu, date_envoi) VALUES (:tid, :uid, :msg, NOW())");
        if($stmt->execute([':tid' => $trajetId, ':uid' => $userId, ':msg' => $contenu])) {
            // Mise à jour du cookie de lecture pour l'expéditeur (il a lu son propre message)
            setcookie('last_read_' . $userId . '_' . $trajetId, date('Y-m-d H:i:s'), time() + (86400 * 30), "/");
            Flight::json(['success' => true]);
        } else { Flight::json(['success' => false]); }
    } else { Flight::json(['success' => false]); }
});
?>