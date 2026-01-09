<?php

// ============================================================
// PARTIE 1 : PAGE DE SÉLECTION DU DESTINATAIRE (QUI NOTER ?)
// ============================================================
Flight::route('GET /avis/choix/@id_trajet', function($id_trajet) {
    // Vérification de connexion
    if (!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    
    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];

    // 1. Récupération des infos du trajet et du conducteur
    $sqlTrajet = "SELECT t.*, u.id_utilisateur as id_cond, u.prenom, u.nom, u.photo_profil 
                  FROM TRAJETS t 
                  JOIN UTILISATEURS u ON t.id_conducteur = u.id_utilisateur 
                  WHERE t.id_trajet = ?";
    $stmt = $db->prepare($sqlTrajet);
    $stmt->execute([$id_trajet]);
    $trajet = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$trajet) Flight::redirect('/');

    $participants = [];

    // --- FONCTION UTILITAIRE INTERNE ---
    // Vérifie si l'utilisateur courant a DÉJÀ laissé un avis à cette personne pour ce trajet.
    // La liaison se fait via la table RESERVATIONS car AVIS n'a pas id_trajet direct.
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

    // A. Si je suis PASSAGER, je peux noter le CONDUCTEUR (sauf si déjà fait)
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

    // B. Récupération de TOUS les passagers validés (Statut 'V')
    $sqlPass = "SELECT u.id_utilisateur, u.prenom, u.nom, u.photo_profil 
                FROM RESERVATIONS r
                JOIN UTILISATEURS u ON r.id_passager = u.id_utilisateur
                WHERE r.id_trajet = ? AND r.statut_code = 'V'";
    $stmtPass = $db->prepare($sqlPass);
    $stmtPass->execute([$id_trajet]);
    $passagers = $stmtPass->fetchAll(PDO::FETCH_ASSOC);

    // C. Ajout des passagers à la liste des personnes à noter
    foreach($passagers as $p) {
        // On ne peut pas se noter soi-même
        if ($p['id_utilisateur'] == $userId) continue; 

        // Si pas encore noté, on l'ajoute
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

    // Cas 1 : Tout le monde a déjà été noté
    if(empty($participants)) {
        $_SESSION['flash_success'] = "Vous avez noté tous les participants !";
        Flight::redirect('/profil');
        return;
    }

    // Cas 2 : Il ne reste qu'une seule personne à noter
    // -> UX : On redirige directement vers le formulaire pour gagner un clic
    if(count($participants) == 1) {
        Flight::redirect("/avis/laisser/$id_trajet/" . $participants[0]['id']);
        return;
    }

    // Cas 3 : Plusieurs personnes restantes -> Affichage de la liste de choix
    Flight::render('avis/choix.tpl', [
        'titre' => 'Qui voulez-vous noter ?',
        'participants' => $participants,
        'id_trajet' => $id_trajet
    ]);
});

// ============================================================
// PARTIE 2 : FORMULAIRE DE SAISIE DE L'AVIS
// ============================================================
Flight::route('GET /avis/laisser/@id_trajet/@id_dest', function($id_trajet, $id_dest) {
    if (!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    $db = Flight::get('db');
    
    // Récupération des infos de la personne qu'on va noter (pour afficher sa photo/nom)
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

// ============================================================
// PARTIE 3 : TRAITEMENT DE L'ENREGISTREMENT
// ============================================================
Flight::route('POST /avis/ajouter', function() {
    if (!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $data = Flight::request()->data;

    $id_auteur = $_SESSION['user']['id_utilisateur'];
    $id_dest = $data->id_destinataire;
    $id_trajet = $data->id_trajet;
    $note = (int)$data->note;
    $commentaire = htmlspecialchars($data->commentaire);

    // 1. Déterminer le rôle de la personne NOTÉE (Conducteur ou Passager ?)
    $stmtRole = $db->prepare("SELECT id_conducteur FROM TRAJETS WHERE id_trajet = ?");
    $stmtRole->execute([$id_trajet]);
    $idConducteur = $stmtRole->fetchColumn();

    $roleDestinataire = ($id_dest == $idConducteur) ? 'C' : 'P';

    // 2. Retrouver l'ID de la RÉSERVATION qui lie ces deux personnes
    // - Si je note le conducteur -> C'est MA réservation
    // - Si je note un passager -> C'est SA réservation
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
        $db->beginTransaction();

        // A. Insertion de l'avis en base
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

        // B. Mise à jour du statut "Vérifié" du destinataire
        // Recevoir un avis prouve qu'il a bien participé à un trajet -> Compte vérifié
        $stmtVerif = $db->prepare("UPDATE UTILISATEURS SET verified_flag = 'Y' WHERE id_utilisateur = :dest");
        $stmtVerif->execute([':dest' => $id_dest]);

        $db->commit();

        $_SESSION['flash_success'] = "Avis publié avec succès !";
        // Retour à la liste de choix pour noter les autres participants s'il en reste
        Flight::redirect("/avis/choix/$id_trajet");

    } catch (Exception $e) {
        $db->rollBack();
        $_SESSION['flash_error'] = "Erreur SQL : " . $e->getMessage();
        Flight::redirect("back");
    }
});
?>