{include file='includes/header.tpl'}

<style>
    /* --- CSS PERSONNALISÉ POUR LES SWITCHES --- */
    
    /* STYLE DE BASE (Non coché) : Fond blanc, texte violet */
    .btn-toggle-custom {
        background-color: white;
        color: #3b2875;
        border: 1px solid white;
        font-weight: bold;
    }
    .btn-toggle-custom:hover {
        background-color: #f0f0f0;
        color: #3b2875;
    }

    /* ETAT COCHÉ - ACCEPTER : Devenient Vert */
    .btn-check:checked + .btn-accept {
        background-color: #4CAF50 !important; /* Vert */
        color: white !important;
        border-color: #4CAF50 !important;
        box-shadow: none;
    }

    /* ETAT COCHÉ - REFUSER : Devenient Rouge */
    .btn-check:checked + .btn-refuse {
        background-color: #dc3545 !important; /* Rouge */
        color: white !important;
        border-color: #dc3545 !important;
        box-shadow: none;
    }

    /* Animation du chevron */
    .transition-icon { transition: transform 0.3s ease; }
    [aria-expanded="true"] .transition-icon { transform: rotate(180deg); }
</style>

<div class="container mt-5 mb-5 flex-grow-1">
    
    <div class="text-center text-white py-4 rounded-top-4" style="background-color: #3b2875;">
        <h1 class="fw-bold m-0">Paramètres des cookies</h1>
    </div>

    <div class="p-5 rounded-bottom-4 text-white" style="background-color: #3b2875; border-top: 1px solid rgba(255,255,255,0.1);">
        
        <form action="/sae-covoiturage/public/cookies/save" method="POST">
            
            <div class="row align-items-center mb-2">
                <div class="col-md-6 d-flex align-items-center">
                    <i class="bi bi-check-circle-fill me-3 fs-4"></i>
                    <span class="fs-5 fw-bold">Essentiels</span>
                </div>
                
                <div class="col-md-5 text-end">
                    <button type="button" class="btn btn-light rounded-pill px-4 fw-bold" disabled style="opacity: 0.8; cursor: not-allowed;">
                        Requis
                    </button>
                </div>

                <div class="col-md-1 text-end">
                    <button type="button" class="btn btn-link text-white p-0" data-bs-toggle="collapse" data-bs-target="#descEssentiels">
                        <i class="bi bi-chevron-down fs-4 transition-icon"></i>
                    </button>
                </div>
            </div>
            
            <div class="collapse mb-4 ps-4 border-start border-2 border-white border-opacity-25" id="descEssentiels">
                <p class="small text-white-50 mt-2 mb-0">
                    Ces cookies sont indispensables au bon fonctionnement du site (connexion, sécurité). Ils ne peuvent pas être désactivés.
                </p>
            </div>

            <hr class="border-white opacity-25 my-4">

            <div class="row align-items-center mb-2">
                <div class="col-md-6 d-flex align-items-center">
                    <i class="bi bi-speedometer2 me-3 fs-4"></i>
                    <span class="fs-5 fw-bold">Performance de contenu</span>
                </div>
                
                <div class="col-md-5 text-end">
                    <div class="btn-group" role="group">
    <input type="radio" class="btn-check" name="perf" id="perf_accept" value="1" 
           {if $consent.performance == 1}checked{/if}>
    <label class="btn btn-toggle-custom btn-accept rounded-start-pill px-3" for="perf_accept">Accepter</label>

    <input type="radio" class="btn-check" name="perf" id="perf_refuse" value="0" 
           {if $consent.performance == 0}checked{/if}>
    <label class="btn btn-toggle-custom btn-refuse rounded-end-pill px-3" for="perf_refuse">Refuser</label>
</div>
                </div>

                <div class="col-md-1 text-end">
                    <button type="button" class="btn btn-link text-white p-0" data-bs-toggle="collapse" data-bs-target="#descPerf">
                        <i class="bi bi-chevron-down fs-4 transition-icon"></i>
                    </button>
                </div>
            </div>

            <div class="collapse mb-4 ps-4 border-start border-2 border-white border-opacity-25" id="descPerf">
                <p class="small text-white-50 mt-2 mb-0">
                    Activez cette option pour sauvegarder votre historique de recherche et retrouver vos trajets précédents facilement.
                </p>
            </div>

            <hr class="border-white opacity-25 my-4">

            <div class="row align-items-center mb-2">
                <div class="col-md-6 d-flex align-items-center">
                    <i class="bi bi-megaphone-fill me-3 fs-4"></i>
                    <span class="fs-5 fw-bold">Marketing et ciblage</span>
                </div>
                
                <div class="col-md-5 text-end">
                    <div class="btn-group" role="group">
    <input type="radio" class="btn-check" name="marketing" id="market_accept" value="1" 
           {if $consent.marketing == 1}checked{/if}>
    <label class="btn btn-toggle-custom btn-accept rounded-start-pill px-3" for="market_accept">Accepter</label>

    <input type="radio" class="btn-check" name="marketing" id="market_refuse" value="0" 
           {if $consent.marketing == 0}checked{/if}>
    <label class="btn btn-toggle-custom btn-refuse rounded-end-pill px-3" for="market_refuse">Refuser</label>
</div>
                </div>

                <div class="col-md-1 text-end">
                    <button type="button" class="btn btn-link text-white p-0" data-bs-toggle="collapse" data-bs-target="#descMarket">
                        <i class="bi bi-chevron-down fs-4 transition-icon"></i>
                    </button>
                </div>
            </div>

            <div class="collapse mb-5 ps-4 border-start border-2 border-white border-opacity-25" id="descMarket">
                <p class="small text-white-50 mt-2 mb-0">
                    Ces cookies permettent de vous proposer des offres adaptées (Option fictive pour ce projet).
                </p>
            </div>

            <div class="text-center mt-5">
                <button type="submit" class="btn btn-light text-primary px-5 py-2 fw-bold fs-5 shadow" style="border-radius: 10px; color: #3b2875 !important;">
                    Enregistrer
                </button>
            </div>

        </form>
    </div>
</div>

{include file='includes/footer.tpl'}