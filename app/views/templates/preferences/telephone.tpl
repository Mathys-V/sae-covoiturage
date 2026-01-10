{include file='includes/header.tpl'}

{* Inclusion de la feuille de style spécifique à la gestion du téléphone *}
<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/preferences/style_telephone.css">

<div class="pref-main">
    
    {* En-tête avec bouton retour vers le menu préférences *}
    <div class="header-top">
        <a href="/sae-covoiturage/public/profil/preferences" class="back-btn"><i class="bi bi-chevron-left"></i></a>
        <h2 class="title">Mobile & SMS</h2>
    </div>

    {* Bloc d'information : Précise que le numéro est stocké mais que l'envoi de SMS est désactivé (SAE) *}
    <div class="sae-info">
        <i class="bi bi-info-circle-fill sae-icon" style="font-size: 1.5rem; color: #8C52FF;"></i>
        <div>
            <strong>Stockage Réel / Usage Inactif</strong><br>
            Votre numéro est bien <strong>sauvegardé</strong> en base de données.
            Cependant, l'application <strong>n'enverra jamais</strong> de SMS (ni urgence, ni pub), car aucun service de messagerie n'est connecté.
        </div>
    </div>

    <div class="section-title">Votre Numéro (Sécurisé)</div>
    <p class="small text-white-50 mb-3">
        Numéro stocké pour compléter votre profil. (La fonctionnalité d'appel d'urgence n'est pas implémentée).
    </p>
    
    {* Champ de saisie du numéro de téléphone (Pré-rempli avec la BDD) *}
    <div class="input-group-custom">
        <input type="tel" id="user_tel" value="{$tel_bdd}" placeholder="06 12 34 56 78" maxlength="14">
        {* Icône pour effacer le champ rapidement *}
        <i class="bi bi-x-circle-fill clear-icon" onclick="document.getElementById('user_tel').value=''; checkVal();"></i>
    </div>
    
    {* Message d'erreur masqué par défaut (Validation JS) *}
    <div id="telError" style="color: #ff4444; font-size: 0.9rem; display: none; margin-bottom: 10px;">
        Format invalide (10 chiffres requis).
    </div>

    <div class="section-title">Préférences SMS (Simulation)</div>
    
    {* Option de simulation : Réception de SMS marketing *}
    <div class="option-row">
        <div>
            <div style="font-weight: bold;">Recevoir des SMS marketing</div>
            <small style="color: #b0a4c5;">Codes promos et partenaires.</small>
        </div>
        <label class="switch">
            <input type="checkbox" id="simu_sms_marketing">
            <span class="slider"></span>
        </label>
    </div>

    {* Bouton de sauvegarde déclenchant la fonction JS saveAll() *}
    <button type="button" id="btnSave" class="btn-save" onclick="saveAll()">Enregistrer</button>
</div>

{* Script JS pour la validation du format téléphone et la sauvegarde AJAX *}
<script src="/sae-covoiturage/public/assets/javascript/preferences/js_telephone.js"></script>

{include file='includes/footer.tpl'}