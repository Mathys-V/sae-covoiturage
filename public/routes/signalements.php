<?php

// API : CRÉER UN SIGNALEMENT (Appelé via AJAX/JS depuis le modal de signalement)
Flight::route('POST /api/signalement/nouveau', function(){
    
    // 1. Sécurité : Vérifier que l'utilisateur est bien connecté
    if(!isset($_SESSION['user'])) Flight::json(['success' => false, 'msg' => 'Non connecté'], 401);

    $db = Flight::get('db');
    $userId = $_SESSION['user']['id_utilisateur'];
    
    // 2. Récupération des données JSON envoyées par le Javascript
    $data = json_decode(file_get_contents('php://input'), true);

    $idTrajet = $data['id_trajet'];
    $idSignale = $data['id_signale']; // L'ID de la personne qu'on signale
    $motif = htmlspecialchars(trim($data['motif'])); // Nettoyage XSS du motif
    $desc = htmlspecialchars(trim($data['description'])); // Nettoyage XSS de la description

    // 3. Validations de cohérence
    if(!$idSignale) { Flight::json(['success' => false, 'msg' => 'Aucun utilisateur sélectionné']); return; }
    // On ne peut pas se signaler soi-même
    if($idSignale == $userId) { Flight::json(['success' => false, 'msg' => 'Auto-signalement interdit']); return; }

    try {
        // 4. Insertion du signalement en base de données
        // Le statut est forcé à 'E' (En attente) pour qu'il apparaisse dans le dashboard admin
        $stmt = $db->prepare("INSERT INTO SIGNALEMENTS (id_signaleur, id_signale, id_trajet, motif, description, statut_code, date_signalement) 
                            VALUES (:signaleur, :signale, :trajet, :motif, :desc, 'E', NOW())"); 
        
        $stmt->execute([
            ':signaleur' => $userId,
            ':signale'   => $idSignale,
            ':trajet'    => $idTrajet,
            ':motif'     => $motif,
            ':desc'      => $desc
        ]);

        // Retour succès au format JSON pour le JS
        Flight::json(['success' => true]);

    } catch(Exception $e) {
        // Retour erreur
        Flight::json(['success' => false, 'msg' => 'Erreur SQL : ' . $e->getMessage()]);
    }
});

?>