-- ============================================
-- 1. TABLE ADRESSE 
-- ============================================
CREATE TABLE ADRESSE (
    id_adresse INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(10),
    voie VARCHAR(100) NOT NULL,
    complement VARCHAR(100),
    code_postal VARCHAR(10) NOT NULL,
    ville VARCHAR(100) NOT NULL,
    pays VARCHAR(100) DEFAULT 'France',
    
    INDEX idx_ville (ville),
    INDEX idx_code_postal (code_postal)
);

-- ============================================
-- 2. TABLE UTILISATEUR 
-- ============================================
CREATE TABLE UTILISATEUR (
    id_utilisateur INT AUTO_INCREMENT PRIMARY KEY,
    id_adresse INT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    date_naissance DATE NOT NULL,
    photo_profil VARCHAR(255) DEFAULT 'default.png', 
    telephone VARCHAR(20),
    description TEXT NULL,
    role ENUM('etudiant', 'admin') NOT NULL DEFAULT 'etudiant',
    profil_verifie BOOLEAN DEFAULT FALSE,
    note_moyenne DECIMAL(3,2) CHECK (note_moyenne >= 0 AND note_moyenne <= 5),
    nombre_trajets INT DEFAULT 0,
    date_inscription DATETIME DEFAULT CURRENT_TIMESTAMP,
    token_recuperation VARCHAR(255) NULL,
    date_expiration_token DATETIME NULL,
    
    CONSTRAINT fk_utilisateur_adresse 
        FOREIGN KEY (id_adresse) 
        REFERENCES ADRESSE(id_adresse)
        ON DELETE SET NULL,
        
 
    CONSTRAINT chk_date_naissance_valide
        CHECK (date_naissance >= '1900-01-01'),
    
    INDEX idx_email (email),
    INDEX idx_nom_prenom (nom, prenom),
    INDEX idx_token (token_recuperation)
);

-- ============================================
-- 3. TABLE VEHICULE 
-- ============================================
CREATE TABLE VEHICULE (
    id_vehicule INT AUTO_INCREMENT PRIMARY KEY,
    id_utilisateur INT NOT NULL,
    marque VARCHAR(100) NOT NULL,
    modele VARCHAR(100) NOT NULL,
    couleur VARCHAR(50),
    immatriculation VARCHAR(20) UNIQUE NOT NULL,
    nombre_places TINYINT NOT NULL CHECK (nombre_places > 0),
    
    CONSTRAINT fk_vehicule_utilisateur
        FOREIGN KEY (id_utilisateur)
        REFERENCES UTILISATEUR(id_utilisateur)
        ON DELETE RESTRICT,
    
    INDEX idx_utilisateur (id_utilisateur)
);

-- ============================================
-- 4. TABLE TRAJET 
-- ============================================
CREATE TABLE TRAJET (
    id_trajet INT AUTO_INCREMENT PRIMARY KEY,
    id_conducteur INT NOT NULL,
    lieu_depart VARCHAR(200) NOT NULL,
    lieu_arrivee VARCHAR(200) NOT NULL,
    date_trajet DATE NOT NULL,
    heure_depart TIME NOT NULL,
    duree_estimee TIME NOT NULL, 
    places_totales TINYINT NOT NULL,
    places_disponibles TINYINT NOT NULL,
    est_regulier BOOLEAN DEFAULT FALSE,
    statut_trajet ENUM('actif', 'termine', 'annule', 'signale') 
        DEFAULT 'actif',
    informations_complementaires TEXT NULL,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_trajet_conducteur
        FOREIGN KEY (id_conducteur)
        REFERENCES UTILISATEUR(id_utilisateur)
        ON DELETE RESTRICT,
    
    CONSTRAINT chk_places_coherentes
        CHECK (places_disponibles <= places_totales),
    
    CONSTRAINT chk_places_positives
        CHECK (places_totales > 0 AND places_disponibles >= 0),
    
    INDEX idx_date_trajet (date_trajet),
    INDEX idx_lieu_depart (lieu_depart),
    INDEX idx_lieu_arrivee (lieu_arrivee),
    INDEX idx_statut (statut_trajet),
    INDEX idx_conducteur (id_conducteur)
);

-- ============================================
-- 5. TABLE RESERVATION 
-- ============================================
CREATE TABLE RESERVATION (
    id_reservation INT AUTO_INCREMENT PRIMARY KEY,
    id_trajet INT NOT NULL,
    id_passager INT NOT NULL,
    statut_reservation ENUM('en_attente', 'confirmee', 'refusee', 
                            'annulee', 'terminee') DEFAULT 'en_attente',
    date_reservation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_reservation_trajet
        FOREIGN KEY (id_trajet)
        REFERENCES TRAJET(id_trajet)
        ON DELETE CASCADE,
    
    CONSTRAINT fk_reservation_passager
        FOREIGN KEY (id_passager)
        REFERENCES UTILISATEUR(id_utilisateur)
        ON DELETE RESTRICT,
    
    INDEX idx_trajet (id_trajet),
    INDEX idx_passager (id_passager),
    INDEX idx_statut (statut_reservation)
); 

-- ============================================
-- 6. TABLE AVIS 
-- ============================================
CREATE TABLE AVIS (
    id_avis INT AUTO_INCREMENT PRIMARY KEY,
    id_reservation INT NOT NULL,
    id_evaluateur INT NOT NULL,
    id_evalue INT NOT NULL,
    note TINYINT NOT NULL CHECK (note BETWEEN 1 AND 5),
    commentaire TEXT,
    date_avis DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_avis_reservation
        FOREIGN KEY (id_reservation)
        REFERENCES RESERVATION(id_reservation)
        ON DELETE CASCADE,
    
    CONSTRAINT fk_avis_evaluateur
        FOREIGN KEY (id_evaluateur)
        REFERENCES UTILISATEUR(id_utilisateur)
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_avis_evalue
        FOREIGN KEY (id_evalue)
        REFERENCES UTILISATEUR(id_utilisateur)
        ON DELETE RESTRICT,
    
    INDEX idx_reservation (id_reservation),
    INDEX idx_evalue (id_evalue)
);

-- ============================================
-- 7. TABLE MESSAGE 
-- ============================================
CREATE TABLE MESSAGE (
    id_message INT AUTO_INCREMENT PRIMARY KEY,
    id_expediteur INT NOT NULL,
    id_destinataire INT NOT NULL,
    contenu VARCHAR(500) NOT NULL,
    date_envoi DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_message_expediteur
        FOREIGN KEY (id_expediteur)
        REFERENCES UTILISATEUR(id_utilisateur)
        ON DELETE CASCADE,
    
    CONSTRAINT fk_message_destinataire
        FOREIGN KEY (id_destinataire)
        REFERENCES UTILISATEUR(id_utilisateur)
        ON DELETE CASCADE,
    
    INDEX idx_expediteur (id_expediteur),
    INDEX idx_destinataire (id_destinataire),
    INDEX idx_date (date_envoi)
);

-- ============================================
-- 8. TABLE SIGNALEMENT 
-- ============================================
CREATE TABLE SIGNALEMENT (
    id_signalement INT AUTO_INCREMENT PRIMARY KEY,
    id_signaleur INT NOT NULL,
    id_signale INT NOT NULL,
    id_trajet INT NULL,
    motif VARCHAR(255) NOT NULL,
    description VARCHAR(500),
    statut_signalement ENUM('en_attente', 'en_cours', 'resolu', 'rejete') 
        DEFAULT 'en_attente',
    date_signalement DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_signalement_signaleur
        FOREIGN KEY (id_signaleur)
        REFERENCES UTILISATEUR(id_utilisateur)
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_signalement_signale
        FOREIGN KEY (id_signale)
        REFERENCES UTILISATEUR(id_utilisateur)
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_signalement_trajet
        FOREIGN KEY (id_trajet)
        REFERENCES TRAJET(id_trajet)
        ON DELETE SET NULL,
    
    INDEX idx_statut (statut_signalement),
    INDEX idx_signale (id_signale)
);