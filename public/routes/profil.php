<?php

// ============================================================
// PARTIE 1 : GESTION DU PROFIL UTILISATEUR
// ============================================================

// AFFICHER LE PROFIL (Route Unique)
Flight::route('GET /profil', function(){
    // Vérification de connexion
    if(!isset($_SESSION['user'])) {
        Flight::redirect('/connexion');
        return;
    }

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];

    // --- A. RÉCUPÉRATION UTILISATEUR & MOYENNES DES AVIS ---
    // On récupère toutes les infos de l'utilisateur ET on calcule à la volée sa moyenne en tant que Conducteur et Passager
    // Note : AVG() retourne NULL s'il n'y a pas encore d'avis, ce qui est géré plus bas.
    $sql = "SELECT U.*, 
            (SELECT AVG(note) FROM AVIS WHERE id_destinataire = U.id_utilisateur AND role_destinataire = 'C') as note_conducteur,
            (SELECT AVG(note) FROM AVIS WHERE id_destinataire = U.id_utilisateur AND role_destinataire = 'P') as note_passager
            FROM UTILISATEURS U
            WHERE U.id_utilisateur = ?";
            
    $stmt = $db->prepare($sql);
    $stmt->execute([$idUser]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    // --- AUTO-VÉRIFICATION DU COMPTE ---
    // Si l'utilisateur n'est pas encore "Vérifié" (verified_flag = 'N'), mais qu'il a reçu au moins une note positive
    // cela signifie qu'il a effectué un trajet réel. On passe donc son compte en "Vérifié" ('Y').
    if ($user && $user['verified_flag'] === 'N') {
        if ((!is_null($user['note_conducteur']) && $user['note_conducteur'] > 0) || 
            (!is_null($user['note_passager']) && $user['note_passager'] > 0)) {
            
            $updFlag = $db->prepare("UPDATE UTILISATEURS SET verified_flag = 'Y' WHERE id_utilisateur = ?");
            $updFlag->execute([$idUser]);
            $user['verified_flag'] = 'Y';
            $_SESSION['user']['verified_flag'] = 'Y'; // Mise à jour immédiate de la session
        }
    }

    // Mise à jour des données en session (sauf mot de passe)
    if ($user) {
        unset($user['mot_de_passe']);
        $_SESSION['user'] = array_merge($_SESSION['user'], $user); 
    }

    // --- B. RÉCUPÉRATION DU VÉHICULE ---
    // On récupère le véhicule associé à l'utilisateur (via la table POSSESSIONS)
    $stmtVehicule = $db->prepare("
        SELECT v.* FROM VEHICULES v
        JOIN POSSESSIONS p ON v.id_vehicule = p.id_vehicule
        WHERE p.id_utilisateur = ?
        LIMIT 1
    ");
    $stmtVehicule->execute([$idUser]);
    $vehicule = $stmtVehicule->fetch(PDO::FETCH_ASSOC);
    if ($vehicule === false) $vehicule = null;

    // --- C. RÉCUPÉRATION DE L'HISTORIQUE DES TRAJETS ---
    // On récupère les trajets passés (date < NOW()) où l'utilisateur était Conducteur OU Passager
    $sqlHistory = "
        SELECT 
            t.id_trajet, 
            t.date_heure_depart, 
            t.duree_estimee,
            t.ville_depart, 
            t.ville_arrivee,
            t.id_conducteur,
            u_cond.nom AS conducteur_nom,
            u_cond.prenom AS conducteur_prenom,
            u_cond.photo_profil AS conducteur_photo,
            u_cond.date_naissance AS conducteur_naissance,
            v.marque AS vehicule_marque,
            v.modele AS vehicule_modele,
            v.couleur AS vehicule_couleur, 
            v.nb_places_totales AS vehicule_places
        FROM TRAJETS t
        JOIN UTILISATEURS u_cond ON t.id_conducteur = u_cond.id_utilisateur
        LEFT JOIN VEHICULES v ON t.id_vehicule = v.id_vehicule
        LEFT JOIN RESERVATIONS r ON t.id_trajet = r.id_trajet
        WHERE 
            (t.id_conducteur = :uid OR (r.id_passager = :uid AND r.statut_code = 'V'))
            AND t.date_heure_depart < NOW()
        GROUP BY t.id_trajet
        ORDER BY t.date_heure_depart DESC
    ";

    $stmtHist = $db->prepare($sqlHistory);
    $stmtHist->execute([':uid' => $idUser]);
    $historique = $stmtHist->fetchAll(PDO::FETCH_ASSOC);

    // --- D. TRAITEMENT DES DONNÉES DE L'HISTORIQUE ---
    // Formatage des dates et calcul de l'âge du conducteur pour l'affichage
    foreach ($historique as &$trajet) {
        $datetime = new DateTime($trajet['date_heure_depart']);
        $trajet['date'] = $datetime->format('d/m/Y');
        $trajet['heure_depart'] = $datetime->format('H:i');
        $trajet['duree'] = substr($trajet['duree_estimee'], 0, 5); 

        if (!empty($trajet['conducteur_naissance'])) {
            $birthDate = new DateTime($trajet['conducteur_naissance']);
            $currentDate = new DateTime();
            $age = $currentDate->diff($birthDate)->y;
            $trajet['conducteur_age'] = $age;
        } else {
            $trajet['conducteur_age'] = '--';
        }

        // Récupération des passagers du trajet pour affichage
        $sqlPass = "SELECT u.id_utilisateur, u.prenom, u.nom, u.photo_profil
                    FROM RESERVATIONS res
                    JOIN UTILISATEURS u ON res.id_passager = u.id_utilisateur
                    WHERE res.id_trajet = ? AND res.statut_code = 'V'";
        $stmtPass = $db->prepare($sqlPass);
        $stmtPass->execute([$trajet['id_trajet']]);
        $trajet['passagers'] = $stmtPass->fetchAll(PDO::FETCH_ASSOC);
    }

    // Listes statiques pour les formulaires de modification de véhicule
    $marques = ['Peugeot', 'Renault', 'Citroën', 'Volkswagen', 'Audi', 'BMW', 'Mercedes', 'Toyota', 'Ford', 'Fiat', 'Autre'];
    $couleurs = ['Blanc', 'Noir', 'Gris', 'Argent', 'Bleu', 'Rouge', 'Vert', 'Jaune', 'Autre'];

    Flight::render('profil/profil.tpl', [
        'titre' => 'Mon Profil',
        'vehicule' => $vehicule,
        'historique_trajets' => $historique,
        'marques' => $marques,
        'couleurs' => $couleurs
    ]);
});

// ============================================================
// PARTIE 2 : ACTIONS DE MISE À JOUR (POST)
// ============================================================

// MODIFIER LA DESCRIPTION (BIO)
Flight::route('POST /profil/update-description', function(){
    if(!isset($_SESSION['user'])) return;
    $desc = Flight::request()->data->description;
    $db = Flight::get('db');
    $stmt = $db->prepare("UPDATE UTILISATEURS SET description = ? WHERE id_utilisateur = ?");
    $stmt->execute([$desc, $_SESSION['user']['id_utilisateur']]);
    $_SESSION['flash_success'] = "Description mise à jour !";
    Flight::redirect('/profil');
});

// MODIFIER L'IDENTITÉ (Nom/Prénom)
Flight::route('POST /profil/update-identity', function(){
    if(!isset($_SESSION['user'])) return;

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];
    $data = Flight::request()->data;
    $prenom = trim(strip_tags($data->prenom));
    $nom = trim(strip_tags($data->nom));

    if (empty($prenom) || empty($nom)) {
        $_SESSION['flash_error'] = "Le prénom et le nom ne peuvent pas être vides.";
        Flight::redirect('/profil');
        return;
    }

    $stmt = $db->prepare("UPDATE UTILISATEURS SET prenom = :prenom, nom = :nom WHERE id_utilisateur = :id");
    $stmt->execute([':prenom' => $prenom, ':nom' => $nom, ':id' => $idUser]);

    $_SESSION['user']['prenom'] = $prenom;
    $_SESSION['user']['nom'] = $nom;
    $_SESSION['flash_success'] = "Identité modifiée avec succès !";
    Flight::redirect('/profil');
});

// MODIFIER OU AJOUTER UN VÉHICULE
Flight::route('POST /profil/update-vehicule', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    $data = Flight::request()->data;
    $idUser = $_SESSION['user']['id_utilisateur'];
    $db = Flight::get('db');

    // Nettoyage et validation des entrées
    $marqueInput = trim($data->marque); 
    $couleurInput = trim($data->couleur);
    $modele = strip_tags(trim($data->modele));
    $nb_places = (int)$data->nb_places;
    $immatBrut = strtoupper(trim($data->immat));
    
    // Validation côté serveur (Sécurité)
    $marques = ['Peugeot', 'Renault', 'Citroën', 'Volkswagen', 'Audi', 'BMW', 'Mercedes', 'Toyota', 'Ford', 'Fiat', 'Autre'];
    if (!in_array($marqueInput, $marques)) $marqueInput = 'Autre';
    
    if (strlen($modele) > 30) { $_SESSION['flash_error'] = "Modèle trop long."; Flight::redirect('/profil'); return; }
    if ($nb_places < 1 || $nb_places > 8) $nb_places = 5;
    
    // Validation Format Plaque (Regex)
    if (!preg_match('/^([A-Z]{2}[-\s]?\d{3}[-\s]?[A-Z]{2})|(\d{1,4}[-\s]?[A-Z]{2,3}[-\s]?[A-Z]{2})$/', $immatBrut)) { 
        $_SESSION['flash_error'] = "Format de plaque invalide."; 
        Flight::redirect('/profil'); 
        return; 
    }

    try {
        // Vérification si l'utilisateur a déjà un véhicule
        $stmtCheck = $db->prepare("SELECT id_vehicule FROM POSSESSIONS WHERE id_utilisateur = ? LIMIT 1");
        $stmtCheck->execute([$idUser]);
        $possede = $stmtCheck->fetch(PDO::FETCH_ASSOC);

        if ($possede) {
            // Mise à jour du véhicule existant
            $stmtUpd = $db->prepare("UPDATE VEHICULES SET marque=:m, modele=:mo, couleur=:c, nb_places_totales=:p, immatriculation=:i WHERE id_vehicule=:id");
            $stmtUpd->execute([':m'=>$marqueInput, ':mo'=>$modele, ':c'=>$couleurInput, ':p'=>$nb_places, ':i'=>$immatBrut, ':id'=>$possede['id_vehicule']]);
            $_SESSION['flash_success'] = "Véhicule modifié !";
        } else {
            // Création d'un nouveau véhicule et liaison
            $db->beginTransaction();
            $stmtIns = $db->prepare("INSERT INTO VEHICULES (marque, modele, couleur, nb_places_totales, immatriculation, type_vehicule) VALUES (:m, :mo, :c, :p, :i, 'voiture')");
            $stmtIns->execute([':m'=>$marqueInput, ':mo'=>$modele, ':c'=>$couleurInput, ':p'=>$nb_places, ':i'=>$immatBrut]);
            $idNew = $db->lastInsertId();
            $db->prepare("INSERT INTO POSSESSIONS (id_utilisateur, id_vehicule) VALUES (?, ?)")->execute([$idUser, $idNew]);
            $db->commit();
            $_SESSION['flash_success'] = "Véhicule ajouté !";
        }
    } catch (Exception $e) {
        if($db->inTransaction()) $db->rollBack();
        $_SESSION['flash_error'] = "Erreur base de données.";
    }
    Flight::redirect('/profil');
});

// API VÉRIFICATION EMAIL (AJAX)
Flight::route('GET /api/check-email', function(){
    $email = Flight::request()->query->email;
    $db = Flight::get('db');
    $stmt = $db->prepare("SELECT COUNT(*) FROM UTILISATEURS WHERE email = :email");
    $stmt->execute([':email' => $email]);
    Flight::json(['exists' => ($stmt->fetchColumn() > 0)]);
});

// MODIFIER LA PHOTO DE PROFIL
Flight::route('POST /profil/update-photo', function(){
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }
    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];

    if (isset($_FILES['photo_profil']) && $_FILES['photo_profil']['error'] === 0) {
        $file = $_FILES['photo_profil'];
        $allowed = ['jpg','jpeg','png','webp'];
        $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        
        // Vérification extension et taille (max 5Mo)
        if (!in_array($ext, $allowed) || $file['size'] > 5*1024*1024) { 
            $_SESSION['flash_error'] = "Image invalide."; 
            Flight::redirect('/profil'); 
            return; 
        }

        // Nom unique pour éviter les collisions
        $newFilename = "user_" . $idUser . "_" . uniqid() . "." . $ext;
        $uploadDir = __DIR__ . '/../../public/uploads/';
        if (!file_exists($uploadDir)) mkdir($uploadDir, 0755, true);

        if (move_uploaded_file($file['tmp_name'], $uploadDir . $newFilename)) {
            // Suppression de l'ancienne photo (sauf si c'est l'image par défaut)
            $old = $_SESSION['user']['photo_profil'];
            if (!empty($old) && $old !== 'default.png' && file_exists($uploadDir . $old)) unlink($uploadDir . $old);
            
            $db->prepare("UPDATE UTILISATEURS SET photo_profil = ? WHERE id_utilisateur = ?")->execute([$newFilename, $idUser]);
            $_SESSION['user']['photo_profil'] = $newFilename;
            $_SESSION['flash_success'] = "Photo modifiée !";
        }
    }
    Flight::redirect('/profil');
});

// SUPPRIMER LE COMPTE (Désactivation logique + Marqueur 'CLOSED')
Flight::route('POST /profil/delete-account', function(){
    // 1. Sécurité : Si pas connecté, on vire
    if(!isset($_SESSION['user'])) { Flight::redirect('/connexion'); return; }

    $db = Flight::get('db');
    $idUser = $_SESSION['user']['id_utilisateur'];

    // 2. MODIFICATION : On passe le flag à 'N' ET on met le token à 'CLOSED'
    // Cela permet de distinguer une fermeture volontaire d'un bannissement admin
    $sql = "UPDATE UTILISATEURS SET active_flag = 'N', token_recuperation = 'CLOSED' WHERE id_utilisateur = ?";
    $db->prepare($sql)->execute([$idUser]);

    // 3. Destruction de la session et redirection
    session_destroy();
    Flight::redirect('/?msg=account_closed');
});

// ============================================================
// PARTIE 3 : SOUS-PAGES DU PROFIL (Routes simplifiées)
// ============================================================

// Afficher mes avis
Flight::route('GET /profil/avis', function(){ 
    if(!isset($_SESSION['user'])) Flight::redirect('/connexion'); 
    $db=Flight::get('db'); 
    // Récupération des avis reçus
    $sql="SELECT a.*, u.prenom, u.nom, u.photo_profil, t.id_conducteur, a.role_destinataire 
          FROM AVIS a JOIN RESERVATIONS r ON a.id_reservation=r.id_reservation 
          JOIN TRAJETS t ON r.id_trajet=t.id_trajet 
          JOIN UTILISATEURS u ON a.id_auteur=u.id_utilisateur 
          WHERE a.id_destinataire=:id ORDER BY a.date_avis DESC"; 
    $stmt=$db->prepare($sql); 
    $stmt->execute([':id'=>$_SESSION['user']['id_utilisateur']]); 
    $all=$stmt->fetchAll(PDO::FETCH_ASSOC); 
    
    // Séparation Avis Conducteur / Avis Passager
    $ac=[]; $ap=[]; $tc=0;$cc=0;$tp=0;$cp=0; 
    foreach($all as $av){ 
        if($av['role_destinataire']=='C'){$ac[]=$av;$tc+=$av['note'];$cc++;}
        else{$ap[]=$av;$tp+=$av['note'];$cp++;}
    } 
    Flight::render('avis/avis.tpl', [
        'titre'=>'Mes Avis',
        'avis_cond'=>$ac,'nb_cond'=>$cc,'moy_cond'=>($cc>0?round($tc/$cc,1):0),
        'avis_pass'=>$ap,'nb_pass'=>$cp,'moy_pass'=>($cp>0?round($tp/$cp,1):0)
    ]); 
});

// Modifier Adresse
Flight::route('GET /profil/modifier_adresse', function(){ 
    if(!isset($_SESSION['user'])){Flight::redirect('/connexion');return;} 
    $db=Flight::get('db'); 
    $stmt=$db->prepare("SELECT a.* FROM ADRESSES a JOIN UTILISATEURS u ON u.id_adresse=a.id_adresse WHERE u.id_utilisateur=?"); 
    $stmt->execute([$_SESSION['user']['id_utilisateur']]); 
    Flight::render('parametre/modifier_adresse.tpl',['titre'=>'Adresse','adresse'=>$stmt->fetch(PDO::FETCH_ASSOC)]); 
});

Flight::route('POST /profil/modifier_adresse', function(){ 
    if(!isset($_SESSION['user']))Flight::redirect('/connexion'); 
    $db=Flight::get('db'); 
    $uid=$_SESSION['user']['id_utilisateur']; 
    $uref=$db->prepare("SELECT id_adresse FROM UTILISATEURS WHERE id_utilisateur=?"); 
    $uref->execute([$uid]); 
    $aid=$uref->fetchColumn(); 
    $v=trim(Flight::request()->data->rue).' '.trim(Flight::request()->data->complement); 
    $db->prepare("UPDATE ADRESSES SET numero=NULL, voie=?, ville=?, code_postal=? WHERE id_adresse=?")
       ->execute([$v,trim(Flight::request()->data->ville),trim(Flight::request()->data->cp),$aid]); 
    Flight::render('parametre/modifier_adresse.tpl',['titre'=>'Adresse','success'=>true,'adresse'=>['voie'=>$v,'ville'=>trim(Flight::request()->data->ville),'code_postal'=>trim(Flight::request()->data->cp)]]); 
});

// Gestion Mot de Passe
Flight::route('GET /profil/gestion_mdp', function(){ if(!isset($_SESSION['user']))Flight::redirect('/connexion'); Flight::render('parametre/gestion_mdp.tpl',['titre'=>'MDP']); });
Flight::route('GET /profil/modifier_mdp', function(){ if(!isset($_SESSION['user']))Flight::redirect('/connexion'); Flight::render('parametre/modifier_mdp.tpl',['titre'=>'Modifier MDP']); });

Flight::route('POST /profil/modifier_mdp', function(){ 
    if(!isset($_SESSION['user']))Flight::redirect('/connexion'); 
    $db=Flight::get('db'); 
    $id=$_SESSION['user']['id_utilisateur']; 
    $d=Flight::request()->data; 
    
    // Vérification ancien MDP
    $curr=$db->prepare("SELECT mot_de_passe FROM UTILISATEURS WHERE id_utilisateur=?"); 
    $curr->execute([$id]); 
    if(!password_verify($d->current_password,$curr->fetchColumn())){
        Flight::render('parametre/modifier_mdp.tpl',['errors'=>['current'=>'Incorrect']]);return;
    } 
    // Vérification correspondance nouveau MDP
    if($d->new_password!==$d->confirm_password){
        Flight::render('parametre/modifier_mdp.tpl',['errors'=>['confirm'=>'Différents']]);return;
    } 
    // Mise à jour
    $db->prepare("UPDATE UTILISATEURS SET mot_de_passe=? WHERE id_utilisateur=?")
       ->execute([password_hash($d->new_password, PASSWORD_BCRYPT),$id]); 
    Flight::render('parametre/modifier_mdp.tpl',['success'=>true]); 
});

// Préférences et Divers
Flight::route('GET /profil/preferences', function(){ if(!isset($_SESSION['user'])) Flight::redirect('/connexion'); Flight::render('preferences/menu.tpl', ['titre'=>'Prefs']); });
Flight::route('GET /profil/preferences/push', function(){ if(!isset($_SESSION['user'])) Flight::redirect('/connexion'); Flight::render('preferences/push.tpl', ['titre'=>'Push']); });
Flight::route('GET /profil/preferences/emails', function(){ if(!isset($_SESSION['user'])) Flight::redirect('/connexion'); Flight::render('preferences/emails.tpl', ['titre'=>'Emails']); });

Flight::route('GET /profil/preferences/telephone', function(){ 
    if(!isset($_SESSION['user']))Flight::redirect('/connexion'); 
    $db=Flight::get('db'); 
    $stmt=$db->prepare("SELECT telephone FROM UTILISATEURS WHERE id_utilisateur=?"); 
    $stmt->execute([$_SESSION['user']['id_utilisateur']]); 
    Flight::render('preferences/telephone.tpl',['titre'=>'Tel','tel_bdd'=>$stmt->fetchColumn()??'']); 
});

Flight::route('POST /profil/preferences/telephone/save', function(){ 
    if(!isset($_SESSION['user']))return; 
    $db=Flight::get('db'); 
    $id=$_SESSION['user']['id_utilisateur']; 
    $d=json_decode(file_get_contents('php://input'),true); 
    $t=preg_replace('/[^0-9]/','',$d['telephone']??''); 
    if(!empty($t)&&!preg_match('/^0[1-9][0-9]{8}$/',$t)){Flight::json(['success'=>false]);return;} 
    $db->prepare("UPDATE UTILISATEURS SET telephone=? WHERE id_utilisateur=?")->execute([$t,$id]); 
    $_SESSION['user']['telephone']=$t; 
    Flight::json(['success'=>true]); 
});

// Mes Signalements émis
Flight::route('GET /profil/mes_signalements', function(){ 
    if(!isset($_SESSION['user']))Flight::redirect('/connexion'); 
    $db=Flight::get('db'); 
    $stmt=$db->prepare("SELECT s.*, u.nom as nom_signale, u.prenom as prenom_signale, t.ville_depart, t.ville_arrivee FROM SIGNALEMENTS s JOIN UTILISATEURS u ON s.id_signale=u.id_utilisateur LEFT JOIN TRAJETS t ON s.id_trajet=t.id_trajet WHERE s.id_signaleur=? ORDER BY s.date_signalement DESC"); 
    $stmt->execute([$_SESSION['user']['id_utilisateur']]); 
    Flight::render('profil/mes_signalements.tpl',['titre'=>'Signalements','signalements'=>$stmt->fetchAll(PDO::FETCH_ASSOC)]); 
});

?>