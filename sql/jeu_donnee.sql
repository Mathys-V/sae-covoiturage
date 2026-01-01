-- Insertion des lieux fréquents pour MonCovoitJV

INSERT INTO LIEUX_FREQUENTS (nom_lieu, ville, code_postal, rue) VALUES
('IUT d''Amiens', 'Amiens', '80000', 'Avenue des Facultés'),
('Gare d''Amiens', 'Amiens', '80000', 'Place Alphonse Fiquet'),
('Centre-ville', 'Amiens', '80000', 'Boulevard Faidherbe'),
('Gare de Longueau', 'Longueau', '80330', 'Place du 8 Mai 1945'),
('Mairie de Dury', 'Dury', '80480', 'Rue de la Mairie');

-- ============================================================
-- INSERTION DU COMPTE ADMINISTRATEUR
-- ============================================================

-- 1. D'abord, on crée l'adresse pour l'admin (Obligatoire à cause de la FK)
INSERT INTO ADRESSES (numero, voie, code_postal, ville, pays) 
VALUES ('1', 'Rue de l''Administration', '80000', 'Amiens', 'France');

-- 2. Ensuite, on crée le compte Admin lié à cette adresse
-- NOTE : On récupère le dernier ID inséré (celui de l'adresse) avec LAST_INSERT_ID()
INSERT INTO UTILISATEURS (
    id_adresse, 
    email, 
    mot_de_passe, 
    nom, 
    prenom, 
    date_naissance, 
    photo_profil, 
    telephone, 
    description, 
    admin_flag, 
    verified_flag, 
    active_flag, 
    date_inscription
) VALUES (
    LAST_INSERT_ID(),               -- Lie à l'adresse créée juste au-dessus
    'admin@moncovoitjv.fr',         -- Email de connexion
    '$2y$10$Ii1Ulm6gxDwIp7kiDAX3relrGae1L6Kz5OWoafLeXxnXo/3sscNea' ,  -- Mot de passe haché
    'Admin',                        -- Nom
    'Système',                      -- Prénom
    '1980-01-01',                   -- Date de naissance arbitraire
    'default_admin.png',            -- Photo par défaut
    '0123456789',                   -- Téléphone fictif
    'Compte administrateur global de l''application.',
    'Y',                            -- admin_flag : OUI (C'est le plus important)
    'Y',                            -- verified_flag : OUI (Pas besoin de valider ce compte)
    'Y',                            -- active_flag : OUI
    NOW()
);

UPDATE LIEUX_FREQUENTS 
SET rue = 'Rue du 8 Mai 1945' 
WHERE nom_lieu = 'Gare de Longueau';