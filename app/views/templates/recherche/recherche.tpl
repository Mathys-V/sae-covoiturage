{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/recherche/style_recherche.css">

<style>
    .autocomplete-wrapper {
        border: none !important;      /* Supprime la ligne blanche */
        box-shadow: none !important;  /* Supprime d'éventuelles ombres */
        background: transparent !important;
    }
    /* Sécurité pour ne pas afficher de cadre vide si la liste est vide */
    .autocomplete-suggestions:empty {
        display: none !important;
        border: none !important;
    }
</style>

<div class="container mt-5 mb-5 flex-grow-1">
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
                    <div class="border rounded-4 p-3 border-white border-opacity-25" id="history-message-box">
                        <div class="text-white text-center py-3">
                            <i class="bi bi-clock-history fs-1 mb-2 d-block opacity-50"></i>
                            <span id="history-text">Aucune recherche récente</span>
                            
                            <p id="cookie-warning" class="small text-white-50 mt-2 d-none">
                                <i class="bi bi-info-circle me-1"></i>
                                L'historique est désactivé car vous avez refusé les cookies de performance.
                                <a href="/sae-covoiturage/public/cookies" class="text-white text-decoration-underline ms-1">Modifier mes choix</a>
                            </p>
                        </div>
                    </div>
                {/if}
            </div>
        </div>
    </div>
</div>

<script>
    window.lieuxFrequents = [];
    try {
        window.lieuxFrequents = JSON.parse('{$lieux_frequents|default:[]|json_encode|escape:"javascript"}');
    } catch(e) { console.warn("Erreur chargement données lieux", e); }

    // --- SCRIPT DE DÉTECTION DES COOKIES ---
    document.addEventListener('DOMContentLoaded', function() {
        function getCookie(name) {
            let matches = document.cookie.match(new RegExp(
                "(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, '\\$1') + "=([^;]*)"
            ));
            return matches ? decodeURIComponent(matches[1]) : undefined;
        }

        const cookieConsent = getCookie('cookie_consent');
        const warningText = document.getElementById('cookie-warning');
        
        if (warningText) {
            let showWarning = true;

            if (cookieConsent) {
                try {
                    const consentData = JSON.parse(cookieConsent);
                    // Si performance = 1, alors l'historique marche, donc pas besoin du message d'erreur
                    if (consentData.performance == 1) {
                        showWarning = false;
                    }
                } catch (e) {
                    console.error("Erreur lecture cookie", e);
                }
            } else {
                // Si pas de cookie du tout, on suppose que c'est le premier passage ou tout refusé
                // On peut laisser le warning ou l'afficher différemment. 
                // Ici, on part du principe que si pas de consentement explicite, pas d'historique.
            }

            if (showWarning) {
                warningText.classList.remove('d-none');
            }
        }
    });
</script>

<script src="/sae-covoiturage/public/assets/javascript/js_recherche.js"></script>

{include file='includes/footer.tpl'}