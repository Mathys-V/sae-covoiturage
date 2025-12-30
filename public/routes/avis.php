<?php

// 1. CHOISIR QUI NOTER (Liste des participants du trajet)
Flight::route('GET /avis/choix/@id_trajet', function($id_trajet) {
    if (!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // Récupérer le trajet et le conducteur
    $sqlTrajet = "SELECT t.*, u.id_utilisateur as id_cond, u.prenom, u.nom, u.photo_profil 
                  FROM TRAJETS t 
                  JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur 
                  WHERE t.id_trajet = ?";
    $stmt = $db->prepare($sqlTrajet);
    $stmt->execute([$id_trajet]);
    $trajet = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$trajet) Flight::redirect('/');

    $participants = [];

    // --- FONCTION D'AIDE POUR VÉRIFIER SI DÉJÀ NOTÉ ---
    // Puisque AVIS n'a pas id_trajet, on joint avec RESERVATIONS
    $checkAvis = function($destinataireId) use ($db, $id_trajet, $userId) {
        $sql = "SELECT COUNT(*) 
                FROM AVIS a 
                JOIN RESERVATIONS r ON a.id_reservation = r.id_reservation 
                WHERE r.id_trajet = ? AND a.id_auteur = ? AND a.id_destinataire = ?";
        $stmt = $db->prepare($sql);
        $stmt->execute([$id_trajet, $userId, $destinataireId]);
        return $stmt->fetchColumn() > 0;
    };
    // --------------------------------------------------

    // Si JE SUIS passager -> Je peux noter le conducteur
    if ($userId != $trajet['id_cond']) {
        if(!$checkAvis($trajet['id_cond'])) {
            $participants[] = [
                'id' => $trajet['id_cond'],
                'nom' => $trajet['prenom'] . ' ' . $trajet['nom'],
                'photo' => $trajet['photo_profil'],
                'role_badge' => 'Conducteur',
                'role_color' => 'warning'
            ];
        }
    }

    // Récupérer les passagers
    $sqlPass = "SELECT u.id_utilisateur, u.prenom, u.nom, u.photo_profil 
                FROM RESERVATIONS r
                JOIN UTILISATEURS u ON r.id_passager = u.id_utilisateur
                WHERE r.id_trajet = ? AND r.statut_code = 'V'";
    $stmtPass = $db->prepare($sqlPass);
    $stmtPass->execute([$id_trajet]);
    $passagers = $stmtPass->fetchAll(PDO::FETCH_ASSOC);

    foreach($passagers as $p) {
        if ($p['id_utilisateur'] == $userId) continue; // On ne se note pas soi-même

        if(!$checkAvis($p['id_utilisateur'])) {
            $participants[] = [
                'id' => $p['id_utilisateur'],
                'nom' => $p['prenom'] . ' ' . $p['nom'],
                'photo' => $p['photo_profil'],
                'role_badge' => 'Passager',
                'role_color' => 'primary'
            ];
        }
    }

    if(empty($participants)) {
        $_SESSION['flash_success'] = "Vous avez noté tous les participants !";
        Flight::redirect('/profil');
        return;
    }

    // S'il ne reste qu'une personne, on va direct au formulaire
    if(count($participants) == 1) {
        Flight::redirect("/avis/laisser/$id_trajet/" . $participants[0]['id']);
        return;
    }

    Flight::render('avis/choix.tpl', [
        'titre' => 'Qui voulez-vous noter ?',
        'participants' => $participants,
        'id_trajet' => $id_trajet
    ]);
});

// 2. FORMULAIRE D'AVIS
Flight::route('GET /avis/laisser/@id_trajet/@id_dest', function($id_trajet, $id_dest) {
    if (!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    $db = Flight::get('db');
    
    $stmt = $db->prepare("SELECT prenom, nom, photo_profil FROM UTILISATEURS WHERE id_utilisateur = ?");
    $stmt->execute([$id_dest]);
    $destinataire = $stmt->fetch(PDO::FETCH_ASSOC);

    Flight::render('avis/formulaire.tpl', [
        'titre' => 'Laisser un avis',
        'destinataire' => $destinataire,
        'id_dest' => $id_dest,
        'id_trajet' => $id_trajet
    ]);
});

// 3. ENREGISTREMENT (CORRIGÉ : GESTION ID_RESERVATION)
Flight::route('POST /avis/ajouter', function() {
    if (!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $data = Flight::request()->data;

    $id_auteur = $_SESSION['user']['id_utilisateur'];
    $id_dest = $data->id_destinataire;
    $id_trajet = $data->id_trajet;
    $note = (int)$data->note;
    $commentaire = htmlspecialchars($data->commentaire);

    // 1. Déterminer qui est le conducteur
    $stmtRole = $db->prepare("SELECT id_conducteur FROM TRAJETS WHERE id_trajet = ?");
    $stmtRole->execute([$id_trajet]);
    $idConducteur = $stmtRole->fetchColumn();

    $roleDestinataire = ($id_dest == $idConducteur) ? 'C' : 'P';

    // 2. TROUVER LA RÉSERVATION ASSOCIÉE (Obligatoire pour la BDD)
    // - Si je note le conducteur => C'est MA réservation (moi passager) qui compte.
    // - Si le conducteur me note => C'est MA réservation (moi passager) qui compte.
    // - Si passager note passager => On prend la réservation du destinataire par convention.
    
    // Règle simple : On cherche la réservation du PASSAGER impliqué dans l'échange.
    $id_passager_concerne = ($id_dest == $idConducteur) ? $id_auteur : $id_dest;

    $stmtRes = $db->prepare("SELECT id_reservation FROM RESERVATIONS WHERE id_trajet = ? AND id_passager = ?");
    $stmtRes->execute([$id_trajet, $id_passager_concerne]);
    $id_reservation = $stmtRes->fetchColumn();

    if(!$id_reservation) {
        $_SESSION['flash_error'] = "Impossible de lier cet avis à une réservation.";
        Flight::redirect('/profil'); 
        return;
    }

    try {
        // Insertion SANS id_trajet (car la colonne n'existe pas), mais AVEC id_reservation
        $sql = "INSERT INTO AVIS (id_reservation, id_auteur, id_destinataire, role_destinataire, note, commentaire, date_avis) 
                VALUES (:res, :aut, :dest, :role, :note, :comm, NOW())";
        
        $stmt = $db->prepare($sql);
        $stmt->execute([
            ':res' => $id_reservation,
            ':aut' => $id_auteur,
            ':dest' => $id_dest,
            ':role' => $roleDestinataire,
            ':note' => $note,
            ':comm' => $commentaire
        ]);

        $_SESSION['flash_success'] = "Avis publié avec succès !";
        Flight::redirect("/avis/choix/$id_trajet");

    } catch (Exception $e) {
        $_SESSION['flash_error'] = "Erreur SQL : " . $e->getMessage();
        Flight::redirect("back");
    }
});
?>