{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/preferences/style_emails.css">

<div class="pref-main">
    <div class="header-top">
        <a href="/sae-covoiturage/public/profil/preferences" class="back-btn"><i class="bi bi-chevron-left"></i></a>
        <h2 class="title">Préférences E-mail</h2>
    </div>

    <div class="sae-info">
        <i class="bi bi-envelope-exclamation sae-icon" style="font-size: 1.5rem; color: #8C52FF;"></i>
        <div>
            <strong>Configuration Fictive</strong><br>
            Aucun e-mail réel ne sera envoyé. Ces options servent à démontrer la gestion des préférences utilisateur (RGPD).
        </div>
    </div>

    <form id="emailForm">
        <label class="checkbox-card">
            <input type="checkbox" id="mail_newsletter">
            <div class="indicator"></div>
            <div>
                <div class="fw-bold">Newsletter Mensuelle</div>
                <small style="color: #b0a4c5;">Actualités et mises à jour de la plateforme.</small>
            </div>
        </label>

        <label class="checkbox-card">
            <input type="checkbox" id="mail_recap">
            <div class="indicator"></div>
            <div>
                <div class="fw-bold">Récapitulatif de trajet</div>
                <small style="color: #b0a4c5;">Recevoir un PDF après chaque voyage.</small>
            </div>
        </label>

        <label class="checkbox-card">
            <input type="checkbox" id="mail_partenaires">
            <div class="indicator"></div>
            <div>
                <div class="fw-bold">Offres partenaires</div>
                <small style="color: #b0a4c5;">Promotions de nos partenaires (Assurances, etc.).</small>
            </div>
        </label>

        <button type="submit" class="btn-save">Enregistrer</button>
    </form>
</div>

<script src="/sae-covoiturage/public/assets/javascript/preferences/js_emails.js"></script>

{include file='includes/footer.tpl'}