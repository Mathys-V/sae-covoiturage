{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/trajet/style_proposer_trajet.css">

{* --- VARIABLES DATES --- *}
{$today = $smarty.now|date_format:'%Y-%m-%d'}
{$maxDate = ($smarty.now + 63072000)|date_format:'%Y-%m-%d'}

<div class="main-wrapper">
    <div class="propose-section">
        <div class="form-card">
            <h1 class="form-title">Proposer un trajet</h1>

            {if isset($error)}
                <div class="alert alert-danger text-center rounded-4 mb-4">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> {$error}
                </div>
            {/if}

            <div id="js-error-message" class="alert alert-warning text-center rounded-4 mb-4 d-none">
                <i class="bi bi-exclamation-circle me-2"></i> Veuillez sélectionner une adresse valide.
            </div>

            <form id="trajetForm" action="/sae-covoiturage/public/trajet/nouveau" method="POST" autocomplete="off">
                
                <input type="hidden" name="duree_calc" id="duree_calc" value="01:00:00">
                <input type="hidden" name="distance_calc" id="distance_calc" value="0">
                
                <div class="mb-4">
                    <label class="custom-label">Lieu de départ ?<span class="required-star">*</span></label>
                    <div class="autocomplete-wrapper">
                        <input type="text" id="depart" name="depart" class="form-control form-control-rounded" placeholder="Ex: Gare d'Amiens, Dury..." required data-valid="false">
                        
                        <input type="hidden" name="ville_depart" id="val_ville_depart">
                        <input type="hidden" name="cp_depart" id="val_cp_depart">
                        <input type="hidden" name="rue_depart" id="val_rue_depart">

                        <div id="suggestions-depart" class="autocomplete-suggestions"></div>
                    </div>
                </div>

                <div class="mb-4">
                    <label class="custom-label">Destination ?<span class="required-star">*</span></label>
                    <div class="autocomplete-wrapper">
                        <input type="text" id="arrivee" name="arrivee" class="form-control form-control-rounded" placeholder="Ex: IUT Amiens" required data-valid="false">

                        <input type="hidden" name="ville_arrivee" id="val_ville_arrivee">
                        <input type="hidden" name="cp_arrivee" id="val_cp_arrivee">
                        <input type="hidden" name="rue_arrivee" id="val_rue_arrivee">

                        <div id="suggestions-arrivee" class="autocomplete-suggestions"></div>
                    </div>
                </div>

                <div class="mb-4 text-center">
                    <label class="custom-label">Combien de places disponibles ?<span class="required-star">*</span></label>
                    <div class="input-number-group">
                        <input type="number" name="places" class="form-control form-control-rounded" value="1" min="1" max="8" required>
                    </div>
                </div>

                <div class="mb-4">
                    <label class="custom-label">Date et Heure du (premier) départ ?<span class="required-star">*</span></label>
                    <div class="row g-2">
                        <div class="col-7">
                            <input type="date" id="date_depart" name="date" class="form-control form-control-rounded" 
                                   value="{$today}" min="{$today}" max="{$maxDate}" onchange="updateSummary()" required>

                        </div>
                        <div class="col-5">
                            <input type="time" id="heure_depart" name="heure" class="form-control form-control-rounded" onchange="updateSummary()" required>
                        </div>
                    </div>
                </div>

                <div class="mb-4 text-center">
                    <label class="custom-label">Ce trajet est-il régulier ?<span class="required-star">*</span></label>
                    <p class="small text-muted mb-2">
                        (Si oui, nous créerons automatiquement les trajets pour les semaines suivantes)
                    </p>
                    
                    <div class="toggle-container">
                        <input type="radio" class="toggle-radio" name="regulier" id="regulier_non" value="N" checked onclick="toggleDateFin(false)">
                        <label for="regulier_non" class="toggle-label">Non</label>

                        <input type="radio" class="toggle-radio" name="regulier" id="regulier_oui" value="Y" onclick="toggleDateFin(true)">
                        <label for="regulier_oui" class="toggle-label">Oui</label>
                    </div>

                    <div id="date_fin_wrapper">
                        <div class="p-3 mt-3 rounded-4 border border-2 border-white" style="background-color: rgba(255,255,255,0.5);">
                            <label class="custom-label mb-2">Jusqu'à quelle date répéter ce trajet ?</label>
                            
                            {* AJOUT : onchange pour le résumé *}
                            <input type="date" id="date_fin" name="date_fin" class="form-control form-control-rounded" 
                                   min="{$today}" max="{$maxDate}" onchange="updateSummary()">
                            
                            {* ZONE DE RÉSUMÉ (Feedback) *}
                            <div id="summary-card" class="alert alert-info mt-3 mb-0 d-none text-start" style="font-size: 0.9rem;">
                                <i class="bi bi-info-circle-fill me-2"></i> <span id="summary-text"></span>
                            </div>
                        </div>
                    </div>
                </div>

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

<script>
    window.lieuxFrequents = [];
    try {
        window.lieuxFrequents = JSON.parse('{$lieux_frequents|default:[]|json_encode|escape:"javascript"}');
    } catch(e) {
        console.warn("Pas de lieux fréquents", e);
    }
</script>

<script src="/sae-covoiturage/public/assets/javascript/js_proposer_trajet.js"></script>

{include file='includes/footer.tpl'}