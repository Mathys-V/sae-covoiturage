<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo isset($titre) ? $titre : 'Mentions_Legales'; ?></title>
    
    <style>
        /* 1. On force le fond violet sur toute la page (Style global conservé) */
        html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            font-family: 'Segoe UI', sans-serif;
            background-color: #463077 !important; /* Force le violet */
            color: white !important; /* Force le texte en blanc */
        }

        /* 2. Wrapper pour pousser le footer en bas */
        .page-wrapper {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* 3. Le contenu pousse le footer */
        .main-content {
            flex: 1;
            width: 100%;
            max-width: 900px;
            margin: 0 auto;
            padding: 40px 20px;
            box-sizing: border-box;
        }

        /* --- STYLES SPECIFIQUES MENTIONS LEGALES --- */
        .page-title {
            text-align: center;
            margin-bottom: 50px;
            font-size: 2.5em;
            font-weight: bold;
            color: white;
        }

        .section-title {
            font-size: 1.8em;
            font-weight: 600;
            margin-bottom: 25px;
            margin-top: 0;
            text-align: left;
            color: white;
        }

        .legal-text-block {
            font-size: 1.1em;
            line-height: 1.6;
            color: #f0f0f0;
            text-align: left;
        }

        .legal-text-block p {
            margin-bottom: 20px; /* Espace entre les paragraphes */
        }
    </style>
</head>

<body>
    
    <div class="page-wrapper">

        {include file='includes/header.tpl'}

        <main class="main-content">
            
            <h1 class="page-title">Informations légales</h1>

            <div class="legal-text-block">
                <h2 class="section-title">Mention légale</h2>
                
                <p>Le site MonCovoitJV est édité par l’équipe de développement du projet MonCovoitJV.</p>
                
                <p>Responsable de la publication : l’équipe MonCovoitJV.</p>
                
                <p>Le site est hébergé par un prestataire assurant le stockage et la sécurité des données.</p>
                
                <p>MonCovoitJV est une plateforme de mise en relation entre particuliers souhaitant partager un trajet en voiture dans le cadre du covoiturage.</p>
                
                <p>Les données personnelles collectées sont utilisées uniquement pour le bon fonctionnement du service. Conformément à la réglementation en vigueur, chaque utilisateur dispose d’un droit d’accès, de rectification et de suppression de ses données, sur simple demande.</p>
                
                <p>L’ensemble du contenu présent sur le site (textes, images, logo, code, etc.) est protégé par le droit d’auteur. Toute reproduction ou utilisation non autorisée est interdite.</p>
                
                <p>MonCovoitJV ne saurait être tenu responsable des échanges, trajets ou incidents survenant entre utilisateurs. Chacun reste responsable des informations qu’il publie et des trajets qu’il organise.</p>
            </div>

        </main>

        {include file='includes/footer.tpl'}

    </div>
    
    </body>
</html>