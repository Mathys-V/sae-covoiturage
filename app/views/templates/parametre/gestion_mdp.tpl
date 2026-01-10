{include file='includes/header.tpl'}

{* Inclusion de la feuille de style spécifique à la gestion du mot de passe *}
<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/parametre/style_gestion_mdp.css">

<main>
    <h1>Gérer le mot de passe</h1>

    {* Menu de navigation pour les actions liées au mot de passe *}
    <div class="menu-container">
        
        {* Lien vers le formulaire de modification (si l'utilisateur connaît son mot de passe actuel) *}
        <a href="/sae-covoiturage/public/profil/modifier_mdp" class="menu-item">
            <span>Changer le mot de passe</span>
            <span class="chevron">&rsaquo;</span>
        </a>

        {* Lien vers la procédure de récupération (si le mot de passe est perdu) *}
        <a href="/sae-covoiturage/public/mot-de-passe-oublie" class="menu-item">
            <span>Mot de passe oublié</span>
            <span class="chevron">&rsaquo;</span>
        </a>
    </div>

</main>

{include file='includes/footer.tpl'}