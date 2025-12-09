{include file='includes/header.tpl'}

<div class="container mt-5 mb-5 flex-grow-1">
    
    <div class="text-center text-white py-4 rounded-top-4" style="background-color: #3b2875;">
        <h1 class="fw-bold m-0">Paramètres des cookies</h1>
    </div>

    <div class="p-5 rounded-bottom-4 text-white" style="background-color: #3b2875; border-top: 1px solid rgba(255,255,255,0.1);">
        
        <form action="/sae-covoiturage/public/cookies/save" method="POST">
            
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div class="d-flex align-items-center">
                    <i class="bi bi-check-circle-fill me-3 fs-4"></i>
                    <span class="fs-5 fw-bold">Essentiels</span>
                </div>
                <button type="button" class="btn btn-light rounded-pill px-4 fw-bold" disabled style="opacity: 0.8; cursor: not-allowed;">
                    Requis
                </button>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div class="d-flex align-items-center">
                    <i class="bi bi-speedometer2 me-3 fs-4"></i>
                    <span class="fs-5 fw-bold">Performance de contenu</span>
                </div>
                
                <div class="btn-group" role="group">
                    <input type="radio" class="btn-check" name="perf" id="perf_accept" value="1" checked>
                    <label class="btn btn-outline-light rounded-start-pill fw-bold" for="perf_accept">Accepter</label>

                    <input type="radio" class="btn-check" name="perf" id="perf_refuse" value="0">
                    <label class="btn btn-outline-light rounded-end-pill" for="perf_refuse" style="background-color: #5a4b8a; border-color: white;">Refuser</label>
                </div>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-5">
                <div class="d-flex align-items-center">
                    <i class="bi bi-megaphone-fill me-3 fs-4"></i>
                    <span class="fs-5 fw-bold">Marketing et ciblage</span>
                </div>
                
                <div class="btn-group" role="group">
                    <input type="radio" class="btn-check" name="marketing" id="market_accept" value="1">
                    <label class="btn btn-outline-light rounded-start-pill fw-bold" for="market_accept">Accepter</label>

                    <input type="radio" class="btn-check" name="marketing" id="market_refuse" value="0" checked>
                    <label class="btn btn-outline-light rounded-end-pill" for="market_refuse" style="background-color: #8f3838; border-color: white;">Refuser</label>
                </div>
            </div>

            <div class="text-center mt-5">
                <button type="submit" class="btn btn-light text-dark px-5 py-2 fw-bold fs-5 shadow" style="border-radius: 10px;">
                    Enregistrer
                </button>
            </div>

        </form>
    </div>
</div>

<script>
    // Petit script pour changer la couleur de fond du bouton actif (Vert/Rouge)
    const radios = document.querySelectorAll('.btn-check');
    radios.forEach(radio => {
        radio.addEventListener('change', function() {
            // Logique visuelle si besoin, mais Bootstrap gère déjà le fond blanc au clic
        });
    });
</script>

{include file='includes/footer.tpl'}