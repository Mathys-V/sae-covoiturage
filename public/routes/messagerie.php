<?php

// ============================================================
// MESSAGERIE
// ============================================================

Flight::route('GET /messagerie/conversation/@id', function($id){
    // 1. Sécurité : Utilisateur connecté ?
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // 2. Vérifier que l'utilisateur fait partie du trajet (Conducteur ou Passager)
    // On vérifie s'il est conducteur
    $stmt = $db->prepare("SELECT * FROM TRAJETS WHERE id_trajet = :id");
    $stmt->execute([':id' => $id]);
    $trajet = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$trajet) { Flight::redirect('/mes_reservations'); return; }

    // On vérifie s'il est passager (réservation validée)
    $stmtPass = $db->prepare("SELECT COUNT(*) FROM RESERVATIONS WHERE id_trajet = :id AND id_passager = :user AND statut_code = 'V'");
    $stmtPass->execute([':id' => $id, ':user' => $userId]);
    $isPassager = $stmtPass->fetchColumn() > 0;

    $isConducteur = ($trajet['id_conducteur'] == $userId);

    if (!$isConducteur && !$isPassager) {
        $_SESSION['flash_error'] = "Vous n'avez pas accès à cette conversation.";
        Flight::redirect('/mes_reservations'); // Ou accueil
        return;
    }

    // 3. Formatage de la date pour l'en-tête
    $dateObj = new DateTime($trajet['date_heure_depart']);
    $trajet['date_fmt'] = $dateObj->format('d/m/Y à H\hi');

    // 4. (Optionnel) Récupérer les anciens messages ici si vous avez une table MESSAGES
    // $messages = ...

    Flight::render('messagerie/conversation.tpl', [
        'titre' => 'Conversation',
        'trajet' => $trajet
        // 'messages' => $messages
    ]);
});







?>