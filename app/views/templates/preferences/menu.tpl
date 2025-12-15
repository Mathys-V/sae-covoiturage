<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$titre}</title>
    <style>
        /* --- STYLES COMMUNS --- */
        :root { --primary-purple: #422875; --accent-purple: #8C52FF; --white: #ffffff; }
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f0f0f0; display: flex; flex-direction: column; min-height: 100vh; }
        main { background-color: var(--primary-purple); flex-grow: 1; display: flex; flex-direction: column; align-items: center; padding: 40px 20px; color: white; }
        
        h1 { font-size: 2rem; margin-bottom: 40px; font-weight: bold; text-align: center; }

        /* LISTE DE MENU STYLE IOS/ANDROID */
        .menu-list { width: 100%; max-width: 600px; display: flex; flex-direction: column; }
        .menu-item {
            display: flex; justify-content: space-between; align-items: center;
            padding: 20px 0; text-decoration: none; color: white; font-size: 1.3rem;
            border-bottom: 1px solid var(--accent-purple); transition: padding-left 0.2s;
        }
        .menu-item:hover { padding-left: 10px; opacity: 0.9; }
        .chevron { font-size: 1.2rem; font-weight: bold; }
    </style>
</head>
<body>
    {include file='includes/header.tpl'}
    <main>
        <h1>Préférences de communication</h1>
        <div class="menu-list">
            <a href="/sae-covoiturage/public/profil/preferences/push" class="menu-item">
                <span>Notifications push</span><span class="chevron">&rsaquo;</span>
            </a>
            <a href="/sae-covoiturage/public/profil/preferences/emails" class="menu-item">
                <span>E-mails</span><span class="chevron">&rsaquo;</span>
            </a>
            <a href="/sae-covoiturage/public/profil/preferences/telephone" class="menu-item">
                <span>Notifications par téléphone</span><span class="chevron">&rsaquo;</span>
            </a>
        </div>
    </main>
    {include file='includes/footer.tpl'}
</body>
</html>