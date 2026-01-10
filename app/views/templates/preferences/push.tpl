{include file='includes/header.tpl'}

{* Inclusion de la feuille de style spécifique aux notifications push *}
<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/preferences/style_push.css">

<div class="pref-main">
    
    {* En-tête avec bouton de retour vers le menu des préférences *}
    <div class="header-top">
        <a href="/sae-covoiturage/public/profil/preferences" class="back-btn"><i class="bi bi-chevron-left"></i></a>
        <h2 class="title">Notifications Mobile</h2>
    </div>

    {* Bloc d'information : Avertissement sur le mode simulation (App mobile fictive) *}
    <div class="sae-info">
        <i class="bi bi-info-circle sae-icon"></i>
        <div>
            <strong>Mode Simulation</strong><br>
            Cette page simule les réglages pour une future application mobile (iOS/Android). Les notifications internes du site web restent toujours actives.
        </div>
    </div>

    <form id="pushForm">
        
        {* Option 1 : Alertes liées au déroulement du trajet (Retards, Annulations) *}
        <div class="option-row">
            <div class="text-content">
                <h4>Alertes de trajet</h4>
                <p>Recevoir une notif. mobile en cas de retard ou d'annulation.</p>
            </div>
            <label class="switch">
                <input type="checkbox" id="push_trajet">
                <span class="slider"></span>
            </label>
        </div>

        {* Option 2 : Notifications de messagerie privée *}
        <div class="option-row">
            <div class="text-content">
                <h4>Messages privés</h4>
                <p>Être notifié sur mon téléphone quand je reçois un message.</p>
            </div>
            <label class="switch">
                <input type="checkbox" id="push_messages">
                <span class="slider"></span>
            </label>
        </div>

        {* Option 3 : Offres commerciales et promotions *}
        <div class="option-row">
            <div class="text-content">
                <h4>Offres promotionnelles</h4>
                <p>Recevoir des codes promos fictifs.</p>
            </div>
            <label class="switch">
                <input type="checkbox" id="push_promo">
                <span class="slider"></span>
            </label>
        </div>

        <button type="submit" class="btn-save">Sauvegarder les préférences</button>
    </form>
</div>

{* Script JS pour la sauvegarde des préférences (Simulée) *}
<script src="/sae-covoiturage/public/assets/javascript/preferences/js_push.js"></script>

{include file='includes/footer.tpl'}