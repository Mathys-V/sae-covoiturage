{include file='includes/header.tpl'}

<style>
    /* --- CORRECTION LAYOUT (Sticky Footer) --- */
    
    /* 1. On force la structure globale en colonne flexible */
    html, body {
        height: 100%;
        margin: 0;
        display: flex;
        flex-direction: column;
    }

    /* 2. Ce wrapper va prendre tout l'espace disponible et pousser le footer */
    .main-wrapper {
        flex: 1 0 auto;
        display: flex;
        flex-direction: column;
        background-color: #f8f9fa; /* Couleur de fond de la page */
    }

    /* 3. La section du formulaire */
    .propose-section { 
        width: 100%;
        /* Espacement : 120px haut (Header), 80px bas (Footer) */
        padding: 120px 20px 80px 20px; 
        display: flex;
        justify-content: center;
        align-items: flex-start; /* Important: aligne en haut pour éviter le débordement */
    }
    
    /* --- DESIGN DU FORMULAIRE (Gardé identique) --- */
    .form-card { 
        background-color: #e9e4f5; 
        border-radius: 20px; 
        box-shadow: 0 10px 30px rgba(69, 43, 133, 0.15); 
        max-width: 600px; 
        width: 100%; 
        padding: 40px; 
        border: 2px solid #fff; 
        position: relative; 
        z-index: 10;
    }

    .form-title { color: #000; font-weight: 800; font-size: 2rem; text-align: center; margin-bottom: 30px; font-family: 'Poppins', sans-serif; }
    .custom-label { font-weight: 600; color: #000; margin-bottom: 8px; display: block; text-align: center; }
    .required-star { color: #dc3545; margin-left: 3px; }
    
    .form-control-rounded { 
        border-radius: 12px; 
        border: 2px solid #8c52ff; 
        padding: 12px 15px; 
        text-align: center; 
        font-size: 1rem; 
        background-color: white; 
    }
    .form-control-rounded:focus { box-shadow: 0 0 0 4px rgba(140, 82, 255, 0.2); border-color: #452b85; }
    
    .input-error {
        border-color: #dc3545 !important;
        box-shadow: 0 0 0 4px rgba(220, 53, 69, 0.2) !important;
    }

    /* Toggle Switch */
    .toggle-container { display: flex; justify-content: center; margin: 10px auto; background: #fff; border: 2px solid #8c52ff; border-radius: 50px; width: fit-content; overflow: hidden; position: relative; }
    .toggle-radio { display: none; }
    .toggle-label { padding: 8px 30px; cursor: pointer; font-weight: bold; transition: all 0.3s; margin: 0; z-index: 2; }
    
    #regulier_non:checked + label { background-color: #ff4d4d; color: white; }
    #regulier_oui:checked + label { background-color: #198754; color: white; box-shadow: inset 0 2px 5px rgba(0,0,0,0.2); }

    #date_fin_wrapper { transition: all 0.3s ease-in-out; opacity: 0; max-height: 0; overflow: hidden; margin-top: 0; }
    #date_fin_wrapper.visible { opacity: 1; max-height: 200px; margin-top: 20px; }

    .btn-submit-trajet { 
        background-color: #8c52ff; 
        color: white; 
        font-weight: bold; 
        font-size: 1.2rem; 
        padding: 15px; 
        width: 100%; 
        border-radius: 15px; 
        border: none; 
        transition: transform 0.2s, box-shadow 0.2s; 
        margin-top: 20px; 
    }
    .btn-submit-trajet:hover { background-color: #703ccf; transform: translateY(-3px); box-shadow: 0 10px 20px rgba(140, 82, 255, 0.3); color: white; }
    
    .input-number-group { display: flex; justify-content: center; align-items: center; gap: 10px; }
    .input-number-group input { width: 80px; text-align: center; font-weight: bold; font-size: 1.2rem; }

    /* Autocomplétion */
    .autocomplete-suggestions {
        text-align: left;
        border: 1px solid #ddd;
        background: #fff;
        overflow: auto;
        border-radius: 0 0 12px 12px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        position: absolute;
        z-index: 9999;
        width: 100%;
        max-height: 200px;
        left: 0;
        top: 100%;
    }
    .autocomplete-suggestion { padding: 10px 15px; cursor: pointer; font-size: 0.9rem; border-bottom: 1px solid #eee; display: flex; align-items: center; }
    .autocomplete-suggestion:hover { background-color: #f0f0f0; color: #8c52ff; }
    .autocomplete-wrapper { position: relative; }
    .suggestion-icon { margin-right: 10px; font-size: 1.1rem; }
    .is-frequent { background-color: #fff9e6; font-weight: 600; color: #b8860b; }
    .is-frequent:hover { background-color: #fff0b3; }
</style>

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
                <i class="bi bi-exclamation-circle me-2"></i> Veuillez sélectionner une adresse valide dans la liste déroulante.
            </div>

            <form id="trajetForm" action="/sae-covoiturage/public/trajet/nouveau" method="POST" autocomplete="off">
                
                <div class="mb-4">
                    <label class="custom-label">Lieu de départ ?<span class="required-star">*</span></label>
                    <div class="autocomplete-wrapper">
                        <input type="text" id="depart" name="depart" class="form-control form-control-rounded" placeholder="Ex: Gare d'Amiens, Dury..." required data-valid="false">
                        <div id="suggestions-depart" class="autocomplete-suggestions"></div>
                    </div>
                </div>

                <div class="mb-4">
                    <label class="custom-label">Destination ?<span class="required-star">*</span></label>
                    <div class="autocomplete-wrapper">
                        <input type="text" id="arrivee" name="arrivee" class="form-control form-control-rounded" placeholder="Ex: IUT Amiens" required data-valid="false">
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
                            <input type="date" name="date" class="form-control form-control-rounded" 
                                   value="{$smarty.now|date_format:'%Y-%m-%d'}" required>
                        </div>
                        <div class="col-5">
                            <input type="time" name="heure" class="form-control form-control-rounded" required>
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
                            <input type="date" name="date_fin" class="form-control form-control-rounded">
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
    var lieuxFrequents = [];
    try {
        lieuxFrequents = JSON.parse('{$lieux_frequents|json_encode|escape:"javascript"}');
    } catch(e) {
        console.warn("Pas de lieux fréquents", e);
    }

    function toggleDateFin(show) {
        const wrapper = document.getElementById('date_fin_wrapper');
        const input = wrapper.querySelector('input');
        if (show) {
            wrapper.classList.add('visible');
            input.required = true;
        } else {
            wrapper.classList.remove('visible');
            input.required = false;
            input.value = '';
        }
    }

    function setupAutocomplete(inputId, resultsId) {
        const input = document.getElementById(inputId);
        const results = document.getElementById(resultsId);
        let timeout = null;

        input.addEventListener('input', function() {
            this.setAttribute('data-valid', 'false');
            this.classList.remove('is-valid');
            
            const query = this.value.toLowerCase();
            results.innerHTML = ''; 

            if (query.length < 2) return;

            const matchesLocal = lieuxFrequents.filter(lieu => 
                lieu.nom_lieu.toLowerCase().includes(query) || 
                lieu.ville.toLowerCase().includes(query)
            );

            if (matchesLocal.length > 0) {
                matchesLocal.forEach(lieu => {
                    const div = document.createElement('div');
                    div.className = 'autocomplete-suggestion is-frequent';
                    div.innerHTML = '<i class="bi bi-star-fill suggestion-icon"></i>' + lieu.nom_lieu + ' <small>(' + lieu.ville + ')</small>';
                    
                    div.addEventListener('click', function() {
                        let adresseComplete = lieu.rue + ', ' + lieu.code_postal + ' ' + lieu.ville;
                        if(!lieu.rue) adresseComplete = lieu.ville;

                        input.value = adresseComplete;
                        input.setAttribute('data-valid', 'true');
                        input.classList.remove('input-error');
                        results.innerHTML = '';
                    });
                    results.appendChild(div);
                });
            }

            if (query.length > 3) {
                clearTimeout(timeout);
                timeout = setTimeout(() => {
                    fetch('https://api-adresse.data.gouv.fr/search/?q=' + query + '&limit=5')
                        .then(response => response.json())
                        .then(data => {
                            if (data.features && data.features.length > 0) {
                                data.features.forEach(feature => {
                                    const div = document.createElement('div');
                                    div.className = 'autocomplete-suggestion';
                                    div.innerHTML = '<i class="bi bi-geo-alt suggestion-icon text-muted"></i>' + feature.properties.label;
                                    
                                    div.addEventListener('click', function() {
                                        input.value = feature.properties.label;
                                        input.setAttribute('data-valid', 'true');
                                        input.classList.remove('input-error');
                                        results.innerHTML = '';
                                    });
                                    results.appendChild(div);
                                });
                            }
                        });
                }, 300);
            }
        });

        document.addEventListener('click', function(e) {
            if (e.target !== input && e.target !== results) {
                results.innerHTML = '';
            }
        });
    }

    setupAutocomplete('depart', 'suggestions-depart');
    setupAutocomplete('arrivee', 'suggestions-arrivee');

    document.getElementById('trajetForm').addEventListener('submit', function(e) {
        const depart = document.getElementById('depart');
        const arrivee = document.getElementById('arrivee');
        const errorMsg = document.getElementById('js-error-message');
        let isValid = true;

        if (depart.getAttribute('data-valid') !== 'true') {
            e.preventDefault(); depart.classList.add('input-error'); isValid = false;
        }
        if (arrivee.getAttribute('data-valid') !== 'true') {
            e.preventDefault(); arrivee.classList.add('input-error'); isValid = false;
        }

        if (!isValid) {
            errorMsg.classList.remove('d-none');
            window.scrollTo({ top: 0, behavior: 'smooth' });
        } else {
            errorMsg.classList.add('d-none');
        }
    });
</script>

{include file='includes/footer.tpl'}