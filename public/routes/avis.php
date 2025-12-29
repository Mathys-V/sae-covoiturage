<?php

// Route : Afficher le formulaire pour laisser un avis
// URL attendue : /avis/laisser/ID_TRAJET/ID_DESTINATAIRE
Flight::route('/avis/laisser/@id_trajet/@id_destinataire', function($id_trajet, $id_destinataire) {
    
    // Vérifier si connecté
    if (!isset($_SESSION['user'])) {
        Flight::redirect('/connexion');
        return;
    }

    // On prépare les données pour le formulaire
    // (Idéalement, vérifier ici si le trajet a bien eu lieu et si l'utilisateur était présent)
    
    Flight::render('avis_form.tpl', [
        'id_trajet' => $id_trajet,
        'id_destinataire' => $id_destinataire
    ]);
});

// Route : Traitement du formulaire d'ajout (POST)
Flight::route('POST /avis/ajouter', function() {
    
    if (!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $data = Flight::request()->data;

    // Récupération des données
    $id_auteur       = $_SESSION['user']['id_utilisateur'];
    $id_destinataire = $data->id_destinataire;
    $id_trajet       = $data->id_trajet;
    $note            = $data->note;           // Nombre entre 1 et 5
    $commentaire     = $data->commentaire;

    // Validation basique
    if (empty($note) || $note < 1 || $note > 5) {
        $_SESSION['flash_error'] = "Veuillez mettre une note valide.";
        Flight::redirect("back"); // Retour au formulaire
        return;
    }

    try {
        // Insertion en base
        $sql = "INSERT INTO AVIS (id_trajet, id_auteur, id_destinataire, note, commentaire, date_avis) 
                VALUES (:trajet, :auteur, :dest, :note, :comm, NOW())";
        
        $stmt = $db->prepare($sql);
        $stmt->execute([
            ':trajet' => $id_trajet,
            ':auteur' => $id_auteur,
            ':dest'   => $id_destinataire,
            ':note'   => $note,
            ':comm'   => $commentaire
        ]);

        $_SESSION['flash_success'] = "Votre avis a bien été publié !";
        // Redirection vers le profil de la personne notée
        Flight::redirect("/profil/$id_destinataire");

    } catch (Exception $e) {
        // Gestion erreur SQL (ex: doublon si on essaie de noter 2 fois le même trajet)
        $_SESSION['flash_error'] = "Erreur lors de l'enregistrement de l'avis.";
        Flight::redirect("back");
    }
});
?>