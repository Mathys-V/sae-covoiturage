<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$titre}</title>

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/parametre/style_gestion_mdp.css">

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