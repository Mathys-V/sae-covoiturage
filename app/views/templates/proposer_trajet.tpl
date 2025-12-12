{include file='includes/header.tpl'}

<style>
    /* --- CSS (Les accolades sont suivies d'espaces pour plaire à Smarty) --- */
    .propose-section { background-color: #f8f9fa; min-height: 90vh; display: flex; justify-content: center; padding: 40px 20px; }
    
    .form-card { 
        background-color: #e9e4f5; 
        border-radius: 20px; 
        box-shadow: 0 10px 30px rgba(69, 43, 133, 0.15); 
        max-width: 600px; 
        width: 100%; 
        padding: 40px; 
        border: 2px solid #fff; 
        position: relative; 
        z-index: 1;
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

    /* --- STYLE POUR L'AUTOCOMPLÉTION --- */
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
    .autocomplete-suggestion {
        padding: 10px 15px;
        cursor: pointer;
        font-size: 0.9rem;
    }
    .autocomplete-suggestion:hover {
        background-color: #f0f0f0;
        color: #8c52ff;
    }
    .autocomplete-wrapper {
        position: relative;
    }
</style>

<div class="propose-section">
    <div class="form-card">
        <h1 class="form-title">Proposer un trajet</h1>

        {if isset($error)}
            <div class="alert alert-danger text-center rounded-4 mb-4">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> {$error}
            </div>
        {/if}

        <form action="/sae-covoiturage/public/trajet/nouveau" method="POST" autocomplete="off">
            
            <div class="mb-4">
                <label class="custom-label">Lieu de départ ?<span class="required-star">*</span></label>
                <div class="autocomplete-wrapper">
                    <input type="text" id="depart" name="depart" class="form-control form-control-rounded" placeholder="Entrez une adresse précise..." required>
                    <div id="suggestions-depart" class="autocomplete-suggestions"></div>
                </div>
            </div>

            <div class="mb-4">
                <label class="custom-label">Destination ?<span class="required-star">*</span></label>
                <div class="autocomplete-wrapper">
                    <input type="text" id="arrivee" name="arrivee" class="form-control form-control-rounded" placeholder="Entrez une adresse précise..." required>
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

<script>
    // --- GESTION DATE FIN (Toggle) ---
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

    // --- AUTOCOMPLÉTION D'ADRESSE (API GOUV FR) ---
    function setupAutocomplete(inputId, resultsId) {
        const input = document.getElementById(inputId);
        const results = document.getElementById(resultsId);
        let timeout = null;

        input.addEventListener('input', function() {
            const query = this.value;
            if (query.length < 3) {
                results.innerHTML = '';
                return;
            }

            // Debounce
            clearTimeout(timeout);
            timeout = setTimeout(() => {
                // MODIFICATION ICI : On utilise la concaténation (+) au lieu de ${}
                // Cela évite l'erreur de parsing Smarty sans avoir besoin de {literal}
                fetch('https://api-adresse.data.gouv.fr/search/?q=' + query + '&limit=5')
                    .then(response => response.json())
                    .then(data => {
                        results.innerHTML = '';
                        if (data.features && data.features.length > 0) {
                            data.features.forEach(feature => {
                                const div = document.createElement('div');
                                div.className = 'autocomplete-suggestion';
                                div.textContent = feature.properties.label;
                                div.addEventListener('click', function() {
                                    input.value = feature.properties.label;
                                    results.innerHTML = '';
                                });
                                results.appendChild(div);
                            });
                        }
                    });
            }, 300);
        });

        // Fermer la liste si on clique ailleurs
        document.addEventListener('click', function(e) {
            if (e.target !== input && e.target !== results) {
                results.innerHTML = '';
            }
        });
    }

    // Activer l'autocomplétion sur les deux champs
    setupAutocomplete('depart', 'suggestions-depart');
    setupAutocomplete('arrivee', 'suggestions-arrivee');
</script>

{include file='includes/footer.tpl'}