<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$titre}</title>
    
    <style>
        /* --- STYLES GLOBAUX (Même base que tes autres pages) --- */
        :root { 
            --primary-purple: #422875;
            --accent-purple: #8C52FF; 
            --white: #ffffff; 
        }

        body { 
            margin: 0;
            font-family: 'Segoe UI', sans-serif; 
            background-color: #f0f0f0; 
            display: flex; flex-direction: column; min-height: 100vh;
        }

        main { 
            background-color: var(--primary-purple);
            flex-grow: 1; 
            display: flex; flex-direction: column; align-items: center; 
            padding: 40px 20px; color: white;
        }

        h1 { 
            font-size: 2.2rem; 
            margin-bottom: 50px; 
            font-weight: bold; 
            text-align: center;
        }

        /* --- STYLE DU MENU --- */
        .menu-container {
            width: 100%;
            max-width: 600px;
            display: flex;
            flex-direction: column;
        }

        .menu-item {
            display: flex;
            justify-content: space-between; /* Texte à gauche, flèche à droite */
            align-items: center;
            padding: 25px 0;
            text-decoration: none;
            color: white;
            font-size: 1.4rem;
            border-bottom: 2px solid var(--accent-purple); /* La ligne violet clair */
            transition: opacity 0.3s;
        }

        .menu-item:hover {
            opacity: 0.8;
            padding-left: 10px; /* Petit effet de mouvement au survol */
            transition: all 0.2s;
        }

        /* Flèche chevron simple */
        .chevron {
            font-size: 1.5rem;
            font-weight: bold;
        }
    </style>
</head>
<body>

    {include file='includes/header.tpl'}

    <main>
        <h1>Gérer le mot de passe</h1>

        <div class="menu-container">
            <a href="/sae-covoiturage/public/profil/modifier_mdp" class="menu-item">
                <span>Changer le mot de passe</span>
                <span class="chevron">&rsaquo;</span>
            </a>

            <a href="/sae-covoiturage/public/mot-de-passe-oublie" class="menu-item">
                <span>Mot de passe oublié</span>
                <span class="chevron">&rsaquo;</span>
            </a>
        </div>

    </main>

    {include file='includes/footer.tpl'}

</body>
</html>