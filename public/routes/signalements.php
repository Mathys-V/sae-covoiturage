<?php

// API : CRÉER UN SIGNALEMENT
Flight::route('POST /api/signalement/nouveau', function(){
    if(!isset($_SESSION['user'])) Flight::json(['success' => false, 'msg' => 'Non connecté'], 401);

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];
    $data = json_decode(file_get_contents('php://input'), true);

    $idTrajet = $data['id_trajet'];
    $idSignale = $data['id_signale']; // L'ID de la personne qu'on signale (étape 1)
    $motif = htmlspecialchars(trim($data['motif'])); // La raison (étape 2)
    $desc = htmlspecialchars(trim($data['description'])); // Le détail (étape 3)

    if(!$idSignale) { Flight::json(['success' => false, 'msg' => 'Aucun utilisateur sélectionné']); return; }
    if($idSignale == $userId) { Flight::json(['success' => false, 'msg' => 'Auto-signalement interdit']); return; }

    try {
        $stmt = $db->prepare("INSERT INTO SIGNALEMENTS (id_signaleur, id_signale, id_trajet, motif, description, statut_code, date_signalement) 
                              VALUES (:signaleur, :signale, :trajet, :motif, :desc, 'E', NOW())"); 
        
        $stmt->execute([
            ':signaleur' => $userId,
            ':signale'   => $idSignale,
            ':trajet'    => $idTrajet,
            ':motif'     => $motif,
            ':desc'      => $desc
        ]);

        Flight::json(['success' => true]);

    } catch(Exception $e) {
        Flight::json(['success' => false, 'msg' => 'Erreur SQL : ' . $e->getMessage()]);
    }
});

?>