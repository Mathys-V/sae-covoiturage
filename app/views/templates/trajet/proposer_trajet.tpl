{include file='includes/header.tpl'}

{* Inclusion de la feuille de style spécifique à la proposition de trajet *}
<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/trajet/style_proposer_trajet.css">

{* --- VARIABLES DATES (Calculées par Smarty) --- *}
{* $today : Date minimale (aujourd'hui) *}
{* $maxDate : Date maximale (aujourd'hui + 1 an) *}
{* $nowTime : Heure actuelle pour restreindre la sélection si le trajet est aujourd'hui *}
{$today = $smarty.now|date_format:'%Y-%m-%d'}
{$maxDate = ($smarty.now + 63072000)|date_format:'%Y-%m-%d'}
{$nowTime = $smarty.now|date_format:'%H:%M'}

<div class="main-wrapper">
    <div class="propose-section">
        <div class="form-card">
            <h1 class="form-title">Proposer un trajet</h1>

            {* Affichage des erreurs serveur (ex: formulaire incomplet) *}
            {if isset($error)}
                <div class="alert alert-danger text-center rounded-4 mb-4">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> {$error}
                </div>
            {/if}

            {* Conteneur pour les erreurs JS (ex: adresse non reconnue) *}
            <div id="js-error-message" class="alert alert-warning text-center rounded-4 mb-4 d-none">
                <i class="bi bi-exclamation-circle me-2"></i> Veuillez sélectionner une adresse valide.
            </div>

            <form id="trajetForm" action="/sae-covoiturage/public/trajet/nouveau" method="POST" autocomplete="off">
                
                {* Champs cachés : Durée et Distance (Calculés via API JS externe) *}
                <input type="hidden" name="duree_calc" id="duree_calc" value="01:00:00">
                <input type="hidden" name="distance_calc" id="distance_calc" value="0">
                
                {* --- LIEU DE DÉPART --- *}
                <div class="mb-4">
                    <label class="custom-label">Lieu de départ ?<span class="required-star">*</span></label>
                    <div class="autocomplete-wrapper">
                        {* Input visible pour la recherche *}
                        <input type="text" id="depart" name="depart" class="form-control form-control-rounded" placeholder="Ex: Gare d'Amiens, Dury..." required data-valid="false">
                        
                        {* Inputs cachés pour les données structurées (Ville, CP, Rue) *}
                        <input type="hidden" name="ville_depart" id="val_ville_depart">
                        <input type="hidden" name="cp_depart" id="val_cp_depart">
                        <input type="hidden" name="rue_depart" id="val_rue_depart">

                        {* Div pour afficher les suggestions d'adresse *}
                        <div id="suggestions-depart" class="autocomplete-suggestions" style="border: none;"></div>
                    </div>
                </div>

                {* --- DESTINATION --- *}
                <div class="mb-4">
                    <label class="custom-label">Destination ?<span class="required-star">*</span></label>
                    <div class="autocomplete-wrapper">
                        <input type="text" id="arrivee" name="arrivee" class="form-control form-control-rounded" placeholder="Ex: IUT Amiens" required data-valid="false">

                        <input type="hidden" name="ville_arrivee" id="val_ville_arrivee">
                        <input type="hidden" name="cp_arrivee" id="val_cp_arrivee">
                        <input type="hidden" name="rue_arrivee" id="val_rue_arrivee">

                        <div id="suggestions-arrivee" class="autocomplete-suggestions" style="border: none;"></div>
                    </div>
                </div>

                {* --- PLACES --- *}
                <div class="mb-4 text-center">
                    <label class="custom-label">Combien de places disponibles ?<span class="required-star">*</span></label>
                    <div class="input-number-group">
                        <input type="number" name="places" class="form-control form-control-rounded" value="1" min="1" max="8" required>
                    </div>
                </div>

                {* --- DATE ET HEURE --- *}
                <div class="mb-4">
                    <label class="custom-label">Date et Heure du (premier) départ ?<span class="required-star">*</span></label>
                    <div class="row g-2">
                        <div class="col-7">
                            {* Date min = aujourd'hui *}
                            <input type="date" id="date_depart" name="date" class="form-control form-control-rounded" 
                                   value="{$today}" min="{$today}" max="{$maxDate}" onchange="updateSummary()" required>
                        </div>
                        <div class="col-5">
                            {* Si la date choisie est aujourd'hui, on empêche de choisir une heure passée *}
                            <input type="time" id="heure_depart" name="heure" class="form-control form-control-rounded" 
                                   onchange="updateSummary()" required
                                   {if $today == $smarty.now|date_format:'%Y-%m-%d'}min="{$nowTime}"{/if}>
                        </div>
                    </div>
                </div>

                {* --- RÉCURRENCE (Trajet régulier) --- *}
                <div class="mb-4 text-center">
                    <label class="custom-label">Ce trajet est-il régulier ?<span class="required-star">*</span></label>
                    <p class="small text-muted mb-2">
                        (Si oui, nous créerons automatiquement les trajets pour les semaines suivantes)
                    </p>
                    
                    {* Toggle Switch Oui/Non *}
                    <div class="toggle-container">
                        <input type="radio" class="toggle-radio" name="regulier" id="regulier_non" value="N" checked onclick="toggleDateFin(false)">
                        <label for="regulier_non" class="toggle-label">Non</label>

                        <input type="radio" class="toggle-radio" name="regulier" id="regulier_oui" value="Y" onclick="toggleDateFin(true)">
                        <label for="regulier_oui" class="toggle-label">Oui</label>
                    </div>

                    {* Zone de date de fin (visible uniquement si "Oui" est coché) *}
                    <div id="date_fin_wrapper">
                        <div class="p-3 mt-3 rounded-4 border border-2 border-white" style="background-color: rgba(255,255,255,0.5);">
                            <label class="custom-label mb-2">Jusqu'à quelle date répéter ce trajet ?</label>
                            
                            <input type="date" id="date_fin" name="date_fin" class="form-control form-control-rounded" 
                                   min="{$today}" max="{$maxDate}" onchange="updateSummary()">
                            
                            {* Résumé dynamique généré par JS (ex: "5 trajets seront créés") *}
                            <div id="summary-card" class="alert alert-info mt-3 mb-0 d-none text-start" style="font-size: 0.9rem;">
                                <i class="bi bi-info-circle-fill me-2"></i> <span id="summary-text"></span>
                            </div>
                        </div>
                    </div>
                </div>

                {* --- DESCRIPTION --- *}
                <div class="mb-4">
                    <label class="custom-label">Une description rapide ?</label>
                    <textarea name="description" class="form-control form-control-rounded" rows="3" placeholder="Ex: Je passe par la gare, pas de détour..."></textarea>
                </div>

                <p class="small text-danger text-center mt-3">* champ obligatoire</p>

                <button type="submit" class="btn-submit-trajet">
                    Poster le(s) trajet(s)
                </button>

            </form>
        </div>
    </div>
</div>

{* Injection des lieux fréquents pour l'autocomplétion (optimisation UX) *}
<script>
    window.lieuxFrequents = [];
    try {
        window.lieuxFrequents = JSON.parse('{$lieux_frequents|default:[]|json_encode|escape:"javascript"}');
    } catch(e) {
        console.warn("Pas de lieux fréquents", e);
    }
</script>

{* Script JS pour la gestion du formulaire (API Adresse, Date fin, Validation) *}
<script src="/sae-covoiturage/public/assets/javascript/trajet/js_proposer_trajet.js"></script>

{include file='includes/footer.tpl'}