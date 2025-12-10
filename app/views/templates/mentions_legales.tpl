<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mentions Légales - MonCovoitJV</title>
    
    <style>
        /* 1. On force le fond violet sur toute la page */
        html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            font-family: 'Segoe UI', system-ui, sans-serif;
            background-color: #463077 !important; /* Force le violet */
            color: white !important; /* Force le texte en blanc */
        }

        /* 2. Wrapper pour pousser le footer en bas */
        .page-wrapper {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* 3. Le contenu */
        .main-content {
            flex: 1;
            width: 100%;
            max-width: 900px;
            margin: 0 auto;
            padding: 60px 20px;
            box-sizing: border-box;
        }

        /* --- STYLES SPÉCIFIQUES --- */
        .page-title {
            text-align: center;
            margin-bottom: 60px;
            font-size: 2.8em;
            font-weight: 800;
            letter-spacing: -1px;
        }

        .legal-section {
            margin-bottom: 40px;
            padding-bottom: 30px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .legal-section:last-child {
            border-bottom: none;
        }

        .section-title {
            font-size: 1.4em;
            font-weight: 700;
            margin-bottom: 15px;
            color: #dcd6f7; /* Un violet très clair pour les sous-titres */
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .legal-text {
            font-size: 1.05em;
            line-height: 1.7;
            color: #f0f0f0;
            text-align: justify;
        }

        .legal-text p {
            margin-bottom: 15px;
        }

        .legal-text strong {
            color: white;
            font-weight: 600;
        }
        
        /* Lien email ou autre */
        .legal-link {
            color: #bfaee3;
            text-decoration: underline;
        }
    </style>
</head>

<body>
    
    <div class="page-wrapper">

        {include file='includes/header.tpl'}

        <main class="main-content">
            
            <h1 class="page-title">Mentions Légales</h1>

            <div class="legal-section">
                <h2 class="section-title">1. Édition du site</h2>
                <div class="legal-text">
                    <p>
                        Le site <strong>MonCovoitJV</strong> est édité dans le cadre d'un projet universitaire (Situation d'Apprentissage et d'Évaluation) par l'équipe d'étudiants du département Informatique de l'<strong>IUT d'Amiens</strong> (Université de Picardie Jules Verne).
                    </p>
                    <p>
                        <strong>Directeur de la publication :</strong> L'équipe projet MonCovoitJV.<br>
                        <strong>Contact :</strong> contact@moncovoitjv.fr (Adresse fictive dans le cadre du projet).
                    </p>
                </div>
            </div>

            <div class="legal-section">
                <h2 class="section-title">2. Hébergement</h2>
                <div class="legal-text">
                    <p>
                        Le site est hébergé par un prestataire technique tiers assurant le stockage et la sécurité des données conformément aux standards actuels.
                    </p>
                </div>
            </div>

            <div class="legal-section">
                <h2 class="section-title">3. Propriété intellectuelle</h2>
                <div class="legal-text">
                    <p>
                        L’ensemble des éléments figurant sur ce site (structure générale, logiciels, textes, images animées ou non, son, savoir-faire, etc.) est protégé par les lois en vigueur sur la propriété intellectuelle.
                    </p>
                    <p>
                        Toute reproduction, représentation, adaptation, traduction ou diffusion, totale ou partielle, de ces éléments sans l'autorisation expresse de l'équipe éditoriale est interdite et constituerait une contrefaçon sanctionnée par les articles L.335-2 et suivants du Code de la propriété intellectuelle.
                    </p>
                </div>
            </div>

            <div class="legal-section">
                <h2 class="section-title">4. Protection des données personnelles</h2>
                <div class="legal-text">
                    <p>
                        Conformément au Règlement Général sur la Protection des Données (RGPD) et à la loi « Informatique et Libertés » du 6 janvier 1978 modifiée, MonCovoitJV s'engage à ce que la collecte et le traitement de vos données soient effectués de manière licite, loyale et transparente.
                    </p>
                    <p>
                        Les données collectées (nom, prénom, email, données de trajet) sont strictement nécessaires au bon fonctionnement du service de mise en relation. Elles ne sont ni vendues ni cédées à des tiers.
                    </p>
                    <p>
                        Chaque utilisateur dispose d’un droit d’accès, de rectification, d'effacement et de portabilité de ses données. Pour exercer ce droit, l'utilisateur peut nous contacter via la page dédiée ou directement depuis son espace personnel.
                    </p>
                </div>
            </div>

            <div class="legal-section">
                <h2 class="section-title">5. Limitation de responsabilité</h2>
                <div class="legal-text">
                    <p>
                        MonCovoitJV agit en tant qu'intermédiaire technique de mise en relation. L'équipe éditoriale ne saurait être tenue pour responsable des échanges, de la bonne exécution des trajets, des annulations ou de tout incident survenant entre les utilisateurs (conducteurs et passagers).
                    </p>
                    <p>
                        Chaque utilisateur est seul responsable des informations qu'il publie et de son comportement lors des trajets, conformément aux <a href="#" class="legal-link">Conditions Générales d'Utilisation (CGU)</a>.
                    </p>
                </div>
            </div>

        </main>

        {include file='includes/footer.tpl'}

    </div>
    
</body>
</html>