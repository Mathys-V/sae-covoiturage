{include file='includes/header.tpl'}

<style>
    /* --- STYLE COPIÉ DE LA CARTE (PARFAITEMENT ALIGNÉ) --- */
    .autocomplete-wrapper { position: relative; }

    .autocomplete-suggestions {
        position: absolute; top: 100%; left: 0; width: 100%;
        background: white; border-radius: 0 0 15px 15px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.15);
        z-index: 9999; max-height: 280px; overflow-y: auto;
        border: 1px solid #eee; border-top: none;
        margin-top: -5px;
    }

    .autocomplete-suggestion { 
        padding: 12px 15px; 
        cursor: pointer; 
        font-size: 0.95rem; 
        border-bottom: 1px solid #f0f0f0; 
        color: #333;
        display: flex; 
        align-items: center; /* Centre verticalement */
        gap: 15px; /* Espace garanti */
    }

    .autocomplete-suggestion:hover { background-color: #f3efff; color: #8c52ff; }
    .autocomplete-suggestion:last-child { border-bottom: none; }

    .is-frequent { background-color: #fffbf0; }
    .is-frequent .sugg-icon { color: #ffc107; } /* Etoile Jaune */
    .is-api .sugg-icon { color: #6c757d; } /* Pin Gris */

    .sugg-icon {
        width: 24px; height: 24px;
        display: flex; align-items: center; justify-content: center;
        font-size: 1.2rem; flex-shrink: 0;
    }

    .sugg-text { display: flex; flex-direction: column; line-height: 1.2; overflow: hidden; }
    .sugg-main { font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .sugg-sub { font-size: 0.8rem; color: #888; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
</style>

<div class="container mt-5">
    <div class="card border-0 shadow-lg" style="border-radius: 20px; overflow: visible;">
        <div class="card-header text-center py-4" style="background-color: #3b2875; color: white; border-radius: 20px 20px 0 0;">
            <h2 class="fw-bold mb-0">Rechercher un trajet</h2>
        </div>

        <div class="card-body p-5" style="background-color: #3b2875; border-radius: 0 0 20px 20px;">
            <form action="/sae-covoiturage/public/recherche/resultats" method="GET" autocomplete="off">
                <div class="row g-3 align-items-end">
                    
                    <div class="col-md-5">
                        <label class="form-label text-white fw-bold">Départ</label>
                        <div class="autocomplete-wrapper">
                            <input type="text" id="depart" name="depart" class="form-control rounded-pill py-2" placeholder="Ex: Gare d'Amiens..." required>
                            <div id="suggestions-depart" class="autocomplete-suggestions"></div>
                        </div>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label text-white fw-bold d-md-none">Date</label>
                        <input type="date" name="date" class="form-control rounded-pill py-2" value="{$smarty.now|date_format:'%Y-%m-%d'}" required>
                    </div>
                </div>

                <div class="row g-3 mt-2 align-items-end">
                    <div class="col-md-5">
                        <label class="form-label text-white fw-bold">Destination</label>
                        <div class="autocomplete-wrapper">
                            <input type="text" id="arrivee" name="arrivee" class="form-control rounded-pill py-2" placeholder="Ex: IUT Amiens..." required>
                            <div id="suggestions-arrivee" class="autocomplete-suggestions"></div>
                        </div>
                    </div>

                    <div class="col-md-2 d-flex gap-2">
                        <input type="number" class="form-control rounded-pill text-center" value="{$smarty.now|date_format:'%H'}" min="0" max="23">
                        <span class="text-white align-self-center fw-bold">:</span>
                        <input type="number" class="form-control rounded-pill text-center" value="{$smarty.now|date_format:'%M'}" min="0" max="59">
                    </div>
                </div>

                <div class="text-center mt-5">
                    <button type="submit" class="btn text-white px-5 py-2 fw-bold" style="background-color: #8c52ff; border-radius: 50px; transition: transform 0.2s;">Rechercher</button>
                </div>
            </form>

            <div class="mt-5">
                <div class="d-flex align-items-center mb-4">
                    <hr class="flex-grow-1 border-white opacity-50">
                    <span class="mx-3 text-white fs-5">Historique de vos recherches</span>
                    <hr class="flex-grow-1 border-white opacity-50">
                </div>

                {if isset($historique) && $historique|@count > 0}
                    <div class="d-flex flex-column gap-3">
                        {foreach from=$historique item=h}
                            <a href="/sae-covoiturage/public/recherche/resultats?depart={$h.depart}&arrivee={$h.arrivee}&date={$h.date}" class="text-decoration-none">
                                <div class="card border-0 shadow-sm" style="background-color: rgba(255, 255, 255, 0.1); border-radius: 15px; transition: background 0.3s;">
                                    <div class="card-body d-flex align-items-center justify-content-between text-white py-3">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="rounded-circle bg-white bg-opacity-25 p-2 d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">
                                                <i class="bi bi-clock-history fs-5"></i>
                                            </div>
                                            <div>
                                                <div class="fw-bold fs-5">{$h.depart} <i class="bi bi-arrow-right mx-2 text-white-50"></i> {$h.arrivee}</div>
                                                <small class="text-white-50">Le {$h.date|date_format:"%d/%m/%Y"}</small>
                                            </div>
                                        </div>
                                        <i class="bi bi-chevron-right text-white-50"></i>
                                    </div>
                                </div>
                            </a>
                        {/foreach}
                    </div>
                {else}
                    <div class="border rounded-4 p-3 border-white border-opacity-25">
                        <div class="text-white text-center py-3">
                            <i class="bi bi-clock-history fs-1 mb-2 d-block opacity-50"></i>
                            Aucune recherche récente
                        </div>
                    </div>
                {/if}
            </div>
        </div>
    </div>
</div>

<script>
    // Injection PHP -> JS (Sans Literal)
    var lieuxFrequents = [];
    try {
        lieuxFrequents = JSON.parse('{$lieux_frequents|default:[]|json_encode|escape:"javascript"}');
    } catch(e) { console.warn("Erreur data", e); }
</script>

{literal}
<script>
    // --- AUTOCOMPLÉTION ---
    function setupAutocomplete(inputId, resultsId) {
        const input = document.getElementById(inputId);
        const results = document.getElementById(resultsId);
        let timeout = null;

        input.addEventListener('input', function() {
            const query = this.value.toLowerCase().trim();
            results.innerHTML = ''; 
            if (query.length < 2) return;

            // A. Locale (Lieux Fréquents)
            const matchesLocal = lieuxFrequents.filter(lieu => 
                lieu.nom_lieu.toLowerCase().includes(query) || 
                lieu.ville.toLowerCase().includes(query)
            );

            if (matchesLocal.length > 0) {
                matchesLocal.forEach(lieu => {
                    const div = document.createElement('div');
                    div.className = 'autocomplete-suggestion is-frequent';
                    div.innerHTML = `
                        <div class="sugg-icon"><i class="bi bi-star-fill"></i></div>
                        <div class="sugg-text">
                            <span class="sugg-main">${lieu.nom_lieu}</span>
                            <span class="sugg-sub">${lieu.ville}</span>
                        </div>`;
                    div.addEventListener('click', function() { input.value = lieu.nom_lieu; results.innerHTML = ''; });
                    results.appendChild(div);
                });
            }

            // B. API
            if (query.length > 3) {
                clearTimeout(timeout);
                timeout = setTimeout(() => {
                    fetch('https://api-adresse.data.gouv.fr/search/?q=' + query + '&limit=5')
                        .then(response => response.json())
                        .then(data => {
                            if (data.features && data.features.length > 0) {
                                data.features.forEach(feature => {
                                    const div = document.createElement('div');
                                    div.className = 'autocomplete-suggestion is-api';
                                    div.innerHTML = `
                                        <div class="sugg-icon"><i class="bi bi-geo-alt-fill"></i></div>
                                        <div class="sugg-text">
                                            <span class="sugg-main">${feature.properties.name}</span>
                                            <span class="sugg-sub">${feature.properties.city || ''}</span>
                                        </div>`;
                                    div.addEventListener('click', function() { input.value = feature.properties.label; results.innerHTML = ''; });
                                    results.appendChild(div);
                                });
                            }
                        });
                }, 300);
            }
        });
        document.addEventListener('click', function(e) { if (e.target !== input && e.target !== results) results.innerHTML = ''; });
    }

    setupAutocomplete('depart', 'suggestions-depart');
    setupAutocomplete('arrivee', 'suggestions-arrivee');
</script>
{/literal}

{include file='includes/footer.tpl'}