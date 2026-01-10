{include file='includes/header.tpl'}

{* Inclusion de la feuille de style spécifique à la modification de trajet *}
<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/trajet/style_modifier_trajet.css">

{* --- VARIABLES DATES SMARTY --- *}
{* $today : Date du jour pour empêcher la sélection de dates passées *}
{* $maxDate : Date limite (ex: +1 an) *}
{$today = $smarty.now|date_format:'%Y-%m-%d'}
{$maxDate = ($smarty.now + 63072000)|date_format:'%Y-%m-%d'}

{* Bouton de retour vers la liste des trajets *}
<a href="/sae-covoiturage/public/mes_trajets" class="btn-retour-top">Retour</a>

<div class="main-wrapper">
    <div class="form-card">
        <h1 class="form-title">Modifier un trajet</h1>

        {* Affichage des erreurs PHP (Validation serveur) *}
        {if isset($error)}
            <div class="alert alert-danger text-center rounded-4 mb-4">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> {$error}
            </div>
        {/if}

        {* Affichage des erreurs JS (Validation client) *}
        <div id="js-error-message" class="alert alert-warning text-center rounded-4 mb-4 d-none">
            <i class="bi bi-exclamation-circle me-2"></i> Veuillez sélectionner une adresse valide.
        </div>

        {* DONNÉES POUR LE JS *}
        {* Div cachée utilisée pour transférer les "lieux fréquents" de PHP vers le script JS d'autocomplétion *}
        <div id="trajet-data" 
             data-lieux='{$lieux_frequents|default:[]|json_encode|escape:"html"}' 
             class="d-none">
        </div>

        {* Formulaire de modification *}
        <form id="trajetForm" action="/sae-covoiturage/public/trajet/modifier/{$trajet.id_trajet}" method="POST" autocomplete="off">
            
            {* Champs cachés pour stocker la durée et la distance (calculées via API JS) *}
            <input type="hidden" name="duree_calc" id="duree_calc" value="{$trajet.duree_estimee}">
            <input type="hidden" name="distance_calc" id="distance_calc" value="0">
            
            {* Champ : Destination (Arrivée) *}
            <div class="mb-4">
                <label class="custom-label">Destination ?<span class="required-star">*</span></label>
                <div class="autocomplete-wrapper">
                    {* Input visible par l'utilisateur (concaténation rue + cp + ville) *}
                    <input type="text" id="arrivee" name="arrivee" class="form-control form-control-rounded" 
                           value="{$trajet.rue_arrivee}, {$trajet.code_postal_arrivee} {$trajet.ville_arrivee}" 
                           placeholder="Ex: IUT Amiens" required data-valid="true">

                    {* Champs cachés pour stocker les détails de l'adresse séparément *}
                    <input type="hidden" name="ville_arrivee" id="val_ville_arrivee" value="{$trajet.ville_arrivee}">
                    <input type="hidden" name="cp_arrivee" id="val_cp_arrivee" value="{$trajet.code_postal_arrivee}">
                    <input type="hidden" name="rue_arrivee" id="val_rue_arrivee" value="{$trajet.rue_arrivee}">

                    {* Conteneur pour les suggestions d'autocomplétion *}
                    <div id="suggestions-arrivee" class="autocomplete-suggestions"></div>
                </div>
            </div>

            {* Champ : Lieu de départ *}
            <div class="mb-4">
                <label class="custom-label">Lieu de départ ?<span class="required-star">*</span></label>
                <div class="autocomplete-wrapper">
                    <input type="text" id="depart" name="depart" class="form-control form-control-rounded" 
                           value="{$trajet.rue_depart}, {$trajet.code_postal_depart} {$trajet.ville_depart}"
                           placeholder="Ex: Gare d'Amiens" required data-valid="true">
                    
                    <input type="hidden" name="ville_depart" id="val_ville_depart" value="{$trajet.ville_depart}">
                    <input type="hidden" name="cp_depart" id="val_cp_depart" value="{$trajet.code_postal_depart}">
                    <input type="hidden" name="rue_depart" id="val_rue_depart" value="{$trajet.rue_depart}">

                    <div id="suggestions-depart" class="autocomplete-suggestions"></div>
                </div>
            </div>

            {* Champ : Nombre de places *}
            <div class="mb-4 text-center">
                <label class="custom-label">Combien de places disponibles ?<span class="required-star">*</span></label>
                <div class="input-number-group">
                    <input type="number" name="places" class="form-control form-control-rounded" 
                           value="{$trajet.places_proposees}" min="1" max="8" required>
                </div>
            </div>

            {* Champs : Date et Heure *}
            <div class="mb-4">
                <label class="custom-label">Quand partez vous ?<span class="required-star">*</span></label>
                <div class="row g-2 align-items-center justify-content-center">
                    <div class="col-4">
                         <input type="time" id="heure_depart" name="heure" class="form-control form-control-rounded text-center" 
                               value="{$trajet.heure_seule}" required>
                    </div>
                    <div class="col-1 text-center font-weight-bold text-dark">:</div>
                    <div class="col-5">
                        <input type="date" id="date_depart" name="date" class="form-control form-control-rounded text-center" 
                               value="{$trajet.date_seule}" min="{$today}" max="{$maxDate}" required>
                    </div>
                </div>
            </div>

            {* Note : Section "Trajet régulier" supprimée comme indiqué *}

            {* Champ : Description / Commentaire *}
            <div class="mb-4">
                <label class="custom-label">Une description rapide ?</label>
                <textarea name="description" class="form-control form-control-rounded" rows="3" 
                          placeholder="Transport dans une bonne humeur.">{$trajet.commentaires}</textarea>
            </div>

            <p class="small text-danger text-center mt-3">*champ obligatoire</p>

            <button type="submit" class="btn-submit-trajet">
                Modifier le trajet
            </button>

        </form>
    </div>
</div>

{* Script JS pour gérer l'autocomplétion des adresses et la validation *}
<script src="/sae-covoiturage/public/assets/javascript/trajet/js_modifier_trajet.js"></script>

{include file='includes/footer.tpl'}