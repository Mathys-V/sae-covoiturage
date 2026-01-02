{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/pages_footer/style_cookies.css">

<div class="container mt-5 mb-5 flex-grow-1">
    
    <div class="cookie-card text-white">
        
        <div class="cookie-header">
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
                            <div class="d-flex-center-v">
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
                            <div class="d-flex-center-v">
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
                            <div class="d-flex-center-v">
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