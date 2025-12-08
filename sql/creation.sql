-- SCRIPT DE CREATION BDD - COVOITURAGE - Equipe W

-- ============================================================
-- 1. TABLE ADRESSES
-- ============================================================
CREATE TABLE ADRESSES (
    id_adresse INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(10),
    voie VARCHAR(150) NOT NULL,
    code_postal VARCHAR(10) NOT NULL,
    ville VARCHAR(100) NOT NULL,
    pays VARCHAR(100) DEFAULT 'France',
    INDEX idx_ville (ville),
    INDEX idx_cp (code_postal)
);

-- ============================================================
-- 2. TABLE UTILISATEURS
-- ============================================================
CREATE TABLE UTILISATEURS (
    id_utilisateur INT AUTO_INCREMENT PRIMARY KEY,
    id_adresse INT NOT NULL, -- Obligatoire
    email VARCHAR(255) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    date_naissance DATE NOT NULL,
    photo_profil VARCHAR(255) DEFAULT 'default.png',
    telephone VARCHAR(20),
    description TEXT NULL,
    
    -- Flags Admin/Vérifié/Actif
    admin_flag CHAR(1) DEFAULT 'N' CHECK (admin_flag IN ('Y', 'N')),
    verified_flag CHAR(1) DEFAULT 'N' CHECK (verified_flag IN ('Y', 'N')),
    active_flag CHAR(1) DEFAULT 'Y' CHECK (active_flag IN ('Y', 'N')),
    
    token_recuperation VARCHAR(10) NULL,
    date_expiration_token DATETIME NULL,
    date_inscription DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_user_adresse FOREIGN KEY (id_adresse) REFERENCES ADRESSES(id_adresse) ON DELETE RESTRICT,
    CONSTRAINT chk_age CHECK (date_naissance >= '1900-01-01')
);

-- ============================================================
-- 3. TABLE VEHICULES
-- ============================================================
CREATE TABLE VEHICULES (
    id_vehicule INT AUTO_INCREMENT PRIMARY KEY,
    -- Pas de conducteur ici (gestion par POSSESSIONS)
    marque VARCHAR(50) NOT NULL,
    modele VARCHAR(50) NOT NULL,
    nb_places_totales TINYINT NOT NULL,
    couleur VARCHAR(30),
    immatriculation VARCHAR(20),
    type_vehicule ENUM('voiture', 'moto', 'autre') DEFAULT 'voiture',
    details_supplementaires TEXT NULL
);

-- ============================================================
-- 4. TABLE POSSESSIONS (Liaison Utilisateur <-> Véhicule)
-- ============================================================
CREATE TABLE POSSESSIONS (
    id_utilisateur INT NOT NULL,
    id_vehicule INT NOT NULL,
    est_proprietaire_principal CHAR(1) DEFAULT 'Y',
    
    PRIMARY KEY (id_utilisateur, id_vehicule),
    
    CONSTRAINT fk_poss_user FOREIGN KEY (id_utilisateur) REFERENCES UTILISATEURS(id_utilisateur) ON DELETE CASCADE,
    CONSTRAINT fk_poss_vehicule FOREIGN KEY (id_vehicule) REFERENCES VEHICULES(id_vehicule) ON DELETE CASCADE
);

-- ============================================================
-- 5. TABLE LIEUX_FREQUENTS
-- ============================================================
CREATE TABLE LIEUX_FREQUENTS (
    id_lieu INT AUTO_INCREMENT PRIMARY KEY,
    nom_lieu VARCHAR(100) NOT NULL,
    ville VARCHAR(100) NOT NULL,
    code_postal VARCHAR(10) NOT NULL,
    rue VARCHAR(150) NULL,
    
    INDEX idx_nom (nom_lieu),
    INDEX idx_ville (ville)
);

-- ============================================================
-- 6. TABLE TRAJETS
-- ============================================================
CREATE TABLE TRAJETS (
    id_trajet INT AUTO_INCREMENT PRIMARY KEY,
    id_conducteur INT NOT NULL,
    id_vehicule INT NOT NULL, -- La voiture utilisée pour CE trajet
    
    ville_depart VARCHAR(100) NOT NULL,
    code_postal_depart VARCHAR(10) NOT NULL,
    rue_depart VARCHAR(150) NULL,
    
    ville_arrivee VARCHAR(100) NOT NULL,
    code_postal_arrivee VARCHAR(10) NOT NULL,
    rue_arrivee VARCHAR(150) NULL,
    
    date_heure_depart DATETIME NOT NULL,
    duree_estimee TIME NOT NULL,
    
    places_proposees TINYINT NOT NULL,
    prix_passager DECIMAL(5,2) DEFAULT 0, -- (J'ai remis le prix car c'est standard)
    
    statut_flag CHAR(1) DEFAULT 'A' CHECK (statut_flag IN ('A', 'C', 'T')),
    
    commentaires TEXT,
    
    CONSTRAINT fk_trajet_user FOREIGN KEY (id_conducteur) REFERENCES UTILISATEURS(id_utilisateur),
    -- CORRECTION ICI : Ajout de la liaison vers le véhicule
    CONSTRAINT fk_trajet_vehicule FOREIGN KEY (id_vehicule) REFERENCES VEHICULES(id_vehicule)
);

-- ============================================================
-- 7. TABLE RESERVATIONS
-- ============================================================
CREATE TABLE RESERVATIONS (
    id_reservation INT AUTO_INCREMENT PRIMARY KEY,
    id_trajet INT NOT NULL,
    id_passager INT NOT NULL,
    nb_places_reservees TINYINT NOT NULL DEFAULT 1,
    date_reservation DATETIME DEFAULT CURRENT_TIMESTAMP,
    statut_code CHAR(1) DEFAULT 'V' CHECK (statut_code IN ('V', 'A', 'R')),
    
    CONSTRAINT fk_res_trajet FOREIGN KEY (id_trajet) REFERENCES TRAJETS(id_trajet),
    CONSTRAINT fk_res_user FOREIGN KEY (id_passager) REFERENCES UTILISATEURS(id_utilisateur)
);

-- ============================================================
-- 8. TABLE AVIS
-- ============================================================
CREATE TABLE AVIS (
    id_avis INT AUTO_INCREMENT PRIMARY KEY,
    id_reservation INT NOT NULL,
    id_auteur INT NOT NULL,
    id_destinataire INT NOT NULL,
    
    role_destinataire CHAR(1) NOT NULL CHECK (role_destinataire IN ('C', 'P')),
    
    note TINYINT NOT NULL CHECK (note BETWEEN 0 AND 5),
    commentaire TEXT,
    date_avis DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_avis_res FOREIGN KEY (id_reservation) REFERENCES RESERVATIONS(id_reservation),
    CONSTRAINT fk_avis_auteur FOREIGN KEY (id_auteur) REFERENCES UTILISATEURS(id_utilisateur),
    CONSTRAINT fk_avis_dest FOREIGN KEY (id_destinataire) REFERENCES UTILISATEURS(id_utilisateur)
);

-- ============================================================
-- 9. TABLE MESSAGES
-- ============================================================
CREATE TABLE MESSAGES (
    id_message INT AUTO_INCREMENT PRIMARY KEY,
    id_trajet INT NOT NULL,
    id_expediteur INT NOT NULL,
    contenu TEXT NOT NULL,
    date_envoi DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_msg_trajet FOREIGN KEY (id_trajet) REFERENCES TRAJETS(id_trajet),
    CONSTRAINT fk_msg_exp FOREIGN KEY (id_expediteur) REFERENCES UTILISATEURS(id_utilisateur)
);

-- ============================================================
-- 10. TABLE SIGNALEMENTS
-- ============================================================
CREATE TABLE SIGNALEMENTS (
    id_signalement INT AUTO_INCREMENT PRIMARY KEY,
    id_signaleur INT NOT NULL,
    id_signale INT NOT NULL,
    id_trajet INT NULL,
    
    motif VARCHAR(255) NOT NULL,
    description TEXT,
    statut_code CHAR(1) DEFAULT 'E' CHECK (statut_code IN ('E', 'P', 'R', 'J')),
    date_signalement DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_sig_signaleur FOREIGN KEY (id_signaleur) REFERENCES UTILISATEURS(id_utilisateur),
    CONSTRAINT fk_sig_signale FOREIGN KEY (id_signale) REFERENCES UTILISATEURS(id_utilisateur),
    CONSTRAINT fk_sig_trajet FOREIGN KEY (id_trajet) REFERENCES TRAJETS(id_trajet) ON DELETE SET NULL
);