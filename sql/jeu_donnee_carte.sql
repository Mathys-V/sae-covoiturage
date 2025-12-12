-- Insertion des lieux fréquents pour MonCovoitJV

INSERT INTO LIEUX_FREQUENTS (nom_lieu, ville, code_postal, rue, latitude, longitude) VALUES
('IUT d''Amiens', 'Amiens', '80000', 'Avenue des Facultés', 49.8717200, 2.2643000),
('Gare d''Amiens', 'Amiens', '80000', 'Place Alphonse Fiquet', 49.8929440, 2.3037780),
('Boulevard Faidherbe', 'Amiens', '80000', 'Boulevard Faidherbe', 49.8947220, 2.2972220),
('Centre-ville de Longueau', 'Longueau', '80330', 'Place du 8 Mai 1945', 49.8718330, 2.3595830),
('Centre-ville de Dury', 'Dury', '80480', 'Rue de la Mairie', 49.8536110, 2.2672220);
('Centre-ville de Dreil', 'Dreuil-lès-Amiens', '80470', 'All. des Lilas', 49.914743, 2.228472);

INSERT INTO ADRESSES (numero, voie, code_postal, ville, pays) VALUES
('15', 'Rue de la République', '80000', 'Amiens', 'France'),
('42', 'Avenue Jean Jaurès', '80000', 'Amiens', 'France');

INSERT INTO UTILISATEURS (id_adresse, email, mot_de_passe, nom, prenom, date_naissance, photo_profil, telephone, description, admin_flag, verified_flag, active_flag) VALUES
(1, 'conducteur@etu.u-picardie.fr', '$2y$10$abcdefghijklmnopqrstuvwxyz1234567890', 'Dupont', 'Conducteur', '2003-05-15', 'default.png', '0612345678', 'Étudiant en informatique, je propose régulièrement des trajets !', 'N', 'Y', 'Y');

INSERT INTO UTILISATEURS (id_adresse, email, mot_de_passe, nom, prenom, date_naissance, photo_profil, telephone, description, admin_flag, verified_flag, active_flag) VALUES
(2, 'passager@etu.u-picardie.fr', '$2y$10$abcdefghijklmnopqrstuvwxyz0987654321', 'Martin', 'Passager', '2002-09-20', 'default.png', '0698765432', 'Étudiant en informatique sans voiture.', 'N', 'Y', 'Y');

INSERT INTO VEHICULES (marque, modele, nb_places_totales, couleur, immatriculation, type_vehicule, details_supplementaires) VALUES
('Peugeot', '208', 4, 'Bleu', 'AB-123-CD', 'voiture', 'Petite citadine économique, climatisation.');

INSERT INTO POSSESSIONS (id_utilisateur, id_vehicule, est_proprietaire_principal) VALUES
(1, 1, 'Y');

INSERT INTO TRAJETS (id_conducteur, id_vehicule, ville_depart, code_postal_depart, rue_depart, ville_arrivee, code_postal_arrivee, rue_arrivee, date_heure_depart, duree_estimee, places_proposees, statut_flag, commentaires) VALUES
(1, 1, 'Dury', '80480', 'Rue de la Mairie', 'Amiens', '80000', 'Avenue des Facultés', '2025-01-15 08:00:00', '00:15:00', 3, 'A', 'Trajet quotidien pour les cours du matin. Départ ponctuel à 8h !'),
(1, 1, 'Amiens', '80000', 'Place Alphonse Fiquet', 'Amiens', '80000', 'Avenue des Facultés', '2025-01-15 08:30:00', '00:10:00', 2, 'A', 'Je récupère les étudiants arrivant en train de Paris.'),
(1, 1, 'Longueau', '80330', 'Place du 8 Mai 1945', 'Amiens', '80000', 'Avenue des Facultés', '2025-01-16 07:45:00', '00:20:00', 3, 'A', 'Trajet régulier du lundi au vendredi. Musique en route 🎵'),
(1, 1, 'Amiens', '80000', 'Boulevard Faidherbe', 'Amiens', '80000', 'Avenue des Facultés', '2025-01-16 13:30:00', '00:12:00', 2, 'A', 'Retour après la pause déjeuner en centre-ville.'),
(1, 1, 'Amiens', '80000', 'Avenue des Facultés', 'Amiens', '80000', 'Place Alphonse Fiquet', '2025-01-15 18:00:00', '00:10:00', 3, 'A', 'Fin des cours à 17h30, départ 18h pour le train de 18h25.'),
(1, 1, 'Amiens', '80000', 'Avenue des Facultés', 'Dury', '80480', 'Rue de la Mairie', '2025-01-15 17:45:00', '00:15:00', 2, 'A', 'Retour tranquille après les TPs.'),
(1, 1, 'Amiens', '80000', 'Avenue des Facultés', 'Longueau', '80330', 'Place du 8 Mai 1945', '2025-01-17 16:30:00', '00:20:00', 3, 'A', 'Cours terminés tôt aujourd''hui !'),
(1, 1, 'Amiens', '80000', 'Place Alphonse Fiquet', 'Amiens', '80000', 'Boulevard Faidherbe', '2025-01-18 12:00:00', '00:08:00', 1, 'A', 'Je vais déjeuner en centre-ville, 1 place dispo.'),
(1, 1, 'Dury', '80480', 'Rue de la Mairie', 'Amiens', '80000', 'Place Alphonse Fiquet', '2025-01-19 07:00:00', '00:18:00', 2, 'A', 'Départ matinal pour prendre le train de 7h30.'),
(1, 1, 'Longueau', '80330', 'Place du 8 Mai 1945', 'Amiens', '80000', 'Boulevard Faidherbe', '2025-01-20 14:00:00', '00:25:00', 3, 'A', 'Shopping en centre-ville, plusieurs places disponibles.');
