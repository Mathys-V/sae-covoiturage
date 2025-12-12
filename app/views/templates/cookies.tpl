{include file='includes/header.tpl'}

<style>
    /* --- DESIGN SYSTEM COOKIES --- */
    
    .cookie-card {
        background-color: #3b2875;
        border-radius: 20px;
        box-shadow: 0 15px 35px rgba(59, 40, 117, 0.15);
        overflow: hidden;
    }

    .cookie-header {
        background-color: rgba(0, 0, 0, 0.2);
        padding: 40px 20px;
    }

    .cookie-item {
        background-color: rgba(255, 255, 255, 0.05);
        border-radius: 12px;
        padding: 25px 20px;
        margin-bottom: 15px;
        transition: background-color 0.2s;
    }
    
    .cookie-item:hover {
        background-color: rgba(255, 255, 255, 0.1);
    }

    /* --- SWITCHES CUSTOM --- */
    .btn-group-custom {
        background-color: rgba(255, 255, 255, 0.1);
        border-radius: 50px;
        padding: 4px;
        display: inline-flex;
        align-items: center;
    }

    .btn-toggle-custom {
        border: none;
        border-radius: 50px !important;
        padding: 8px 24px;
        font-weight: 600;
        font-size: 0.9rem;
        color: rgba(255, 255, 255, 0.7);
        background: transparent;
        transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        display: flex;          
        align-items: center;    
        justify-content: center;
        height: 100%;           
    }

    .btn-toggle-custom:hover {
        color: white;
    }

    /* ETAT ACTIVE - VERT (Accepter) */
    .btn-check:checked + .btn-accept {
        background-color: #00c853 !important;
        color: white !important;
        box-shadow: 0 4px 15px rgba(0, 200, 83, 0.4);
    }

    /* ETAT ACTIVE - ROUGE (Refuser) */
    .btn-check:checked + .btn-refuse {
        background-color: #ff3d00 !important;
        color: white !important;
        box-shadow: 0 4px 15px rgba(255, 61, 0, 0.4);
    }

    /* Badge Essentiels */
    .badge-required {
        background-color: rgba(255, 255, 255, 0.15);
        color: #fff;
        padding: 8px 16px;
        border-radius: 50px;
        font-size: 0.85rem;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        cursor: default;
        height: 40px;
    }

    /* Animation Chevron */
    .btn-collapse-icon {
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        transition: background 0.2s;
    }
    .btn-collapse-icon:hover {
        background-color: rgba(255,255,255,0.2);
    }
    .transition-icon { transition: transform 0.3s ease; }
    [aria-expanded="true"] .transition-icon { transform: rotate(180deg); }
</style>

<div class="container mt-5 mb-5 flex-grow-1">
    
    <div class="cookie-card text-white">
        
        <div class="cookie-header text-center">
            <h1 class="fw-bold m-0 mb-3">🍪 Paramètres des cookies</h1>
            <p class="text-white-50 mx-auto mb-0" style="max-width: 600px;">
                Nous respectons votre vie privée. Choisissez les cookies que vous souhaitez activer pour une expérience optimale sur MonCovoitJV.
            </p>
        </div>

        <div class="p-4 p-md-5">
            <form action="/sae-covoiturage/public/cookies/save" method="POST">
                
                <div class="cookie-item">
                    <div class="row align-items-center g-3">
                        <div class="col-md-6 cursor-pointer" data-bs-toggle="collapse" data-bs-target="#descEssentiels" style="cursor: pointer;">
                            <div class="d-flex align-items-center">
                                <i class="bi bi-shield-lock-fill me-3 fs-3 text-white-50"></i>
                                <div>
                                    <div class="fs-5 fw-bold">Cookies Essentiels</div>
                                    <div class="small text-white-50 d-md-none">Indispensables au site</div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="d-flex align-items-center justify-content-md-end gap-3">
                                <span class="badge-required">
                                    <i class="bi bi-lock-fill"></i> Toujours actif
                                </span>
                                <button type="button" class="btn btn-link text-white p-0 btn-collapse-icon" data-bs-toggle="collapse" data-bs-target="#descEssentiels" aria-expanded="false">
                                    <i class="bi bi-chevron-down transition-icon"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="collapse mt-3 ps-md-5" id="descEssentiels">
                        <p class="small text-white-50 m-0 border-start border-2 border-white border-opacity-25 ps-3">
                            Ces cookies sont indispensables au bon fonctionnement du site (connexion, sécurité). Ils ne peuvent pas être désactivés.
                        </p>
                    </div>
                </div>

                <div class="cookie-item">
                    <div class="row align-items-center g-3">
                        <div class="col-md-6 cursor-pointer" data-bs-toggle="collapse" data-bs-target="#descPerf" style="cursor: pointer;">
                            <div class="d-flex align-items-center">
                                <i class="bi bi-lightning-charge-fill me-3 fs-3 text-warning"></i>
                                <div>
                                    <div class="fs-5 fw-bold">Performance de contenu</div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="d-flex align-items-center justify-content-md-end gap-3">
                                <div class="btn-group-custom" role="group">
                                    <input type="radio" class="btn-check" name="perf" id="perf_accept" value="1" {if $consent.performance == 1}checked{/if}>
                                    <label class="btn btn-toggle-custom btn-accept" for="perf_accept">Accepter</label>

                                    <input type="radio" class="btn-check" name="perf" id="perf_refuse" value="0" {if $consent.performance == 0}checked{/if}>
                                    <label class="btn btn-toggle-custom btn-refuse" for="perf_refuse">Refuser</label>
                                </div>
                                <button type="button" class="btn btn-link text-white p-0 btn-collapse-icon" data-bs-toggle="collapse" data-bs-target="#descPerf" aria-expanded="false">
                                    <i class="bi bi-chevron-down transition-icon"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="collapse mt-3 ps-md-5" id="descPerf">
                        <p class="small text-white-50 m-0 border-start border-2 border-white border-opacity-25 ps-3">
                            Activez cette option pour sauvegarder votre historique de recherche et retrouver vos trajets précédents facilement.
                        </p>
                    </div>
                </div>

                <div class="cookie-item">
                    <div class="row align-items-center g-3">
                        <div class="col-md-6 cursor-pointer" data-bs-toggle="collapse" data-bs-target="#descMarket" style="cursor: pointer;">
                            <div class="d-flex align-items-center">
                                <i class="bi bi-graph-up-arrow me-3 fs-3 text-info"></i>
                                <div>
                                    <div class="fs-5 fw-bold">Marketing et ciblage</div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="d-flex align-items-center justify-content-md-end gap-3">
                                <div class="btn-group-custom" role="group">
                                    <input type="radio" class="btn-check" name="marketing" id="market_accept" value="1" {if $consent.marketing == 1}checked{/if}>
                                    <label class="btn btn-toggle-custom btn-accept" for="market_accept">Accepter</label>

                                    <input type="radio" class="btn-check" name="marketing" id="market_refuse" value="0" {if $consent.marketing == 0}checked{/if}>
                                    <label class="btn btn-toggle-custom btn-refuse" for="market_refuse">Refuser</label>
                                </div>
                                <button type="button" class="btn btn-link text-white p-0 btn-collapse-icon" data-bs-toggle="collapse" data-bs-target="#descMarket" aria-expanded="false">
                                    <i class="bi bi-chevron-down transition-icon"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="collapse mt-3 ps-md-5" id="descMarket">
                        <p class="small text-white-50 m-0 border-start border-2 border-white border-opacity-25 ps-3">
                            Ces cookies permettent de vous proposer des offres adaptées (Option fictive pour ce projet).
                        </p>
                    </div>
                </div>

                <div class="text-center mt-5">
                    <button type="submit" class="btn btn-light text-primary px-5 py-3 fw-bold fs-5 shadow-lg" style="border-radius: 50px; color: #3b2875 !important; min-width: 250px; transition: transform 0.2s;">
                        Enregistrer
                    </button>
                </div>

            </form>
        </div>
    </div>
</div>

{include file='includes/footer.tpl'}