{include file='includes/header.tpl'}

{* Inclusion de la feuille de style spécifique au menu des préférences *}
<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/preferences/style_menu.css">

<div class="pref-container">
    <h1>Préférences</h1>
    
    {* Carte regroupant les différentes catégories de réglages *}
    <div class="menu-card">
        
        {* Lien vers la configuration des notifications Push *}
        <a href="/sae-covoiturage/public/profil/preferences/push" class="menu-item">
            <div class="icon-box"><i class="bi bi-bell-fill"></i></div>
            <span>Notifications Push</span>
            <i class="bi bi-chevron-right chevron"></i>
        </a>

        {* Lien vers la configuration des E-mails *}
        <a href="/sae-covoiturage/public/profil/preferences/emails" class="menu-item">
            <div class="icon-box"><i class="bi bi-envelope-fill"></i></div>
            <span>E-mails & Newsletter</span>
            <i class="bi bi-chevron-right chevron"></i>
        </a>

        {* Lien vers la configuration du Téléphone *}
        <a href="/sae-covoiturage/public/profil/preferences/telephone" class="menu-item">
            <div class="icon-box"><i class="bi bi-phone-fill"></i></div>
            <span>Téléphone & SMS</span>
            <i class="bi bi-chevron-right chevron"></i>
        </a>
    </div>

    {* Bouton de retour vers le profil utilisateur *}
    <div class="text-center mt-4">
        <a href="/sae-covoiturage/public/profil" class="btn btn-outline-light rounded-pill px-4">
            <i class="bi bi-arrow-left me-2"></i>Retour au profil
        </a>
    </div>
</div>

{include file='includes/footer.tpl'}