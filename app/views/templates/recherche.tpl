{include file='includes/header.tpl'}

<div class="container mt-5">
    <div class="card border-0 shadow-lg" style="border-radius: 20px; overflow: hidden;">
        
        <div class="card-header text-center py-4" style="background-color: #3b2875; color: white;">
            <h2 class="fw-bold mb-0">Rechercher un trajet</h2>
        </div>

        <div class="card-body p-5" style="background-color: #3b2875;">
            <form action="/sae-covoiturage/public/recherche/resultats" method="GET">
                <div class="row g-3 align-items-end">
                    
                    <div class="col-md-5">
                        <label class="form-label text-white fw-bold">Départ</label>
                        <input type="text" name="depart" class="form-control rounded-pill py-2" placeholder="Ex: Dury" required>
                    </div>

                    <div class="col-md-2">
                        <input type="date" name="date" class="form-control rounded-pill py-2" required>
                    </div>
                </div>

                <div class="row g-3 mt-2 align-items-end">
                    <div class="col-md-5">
                        <label class="form-label text-white fw-bold">Destination</label>
                        <input type="text" name="arrivee" class="form-control rounded-pill py-2" placeholder="Ex: IUT Amiens" required>
                    </div>

                    <div class="col-md-2 d-flex gap-2">
                        <input type="number" class="form-control rounded-pill text-center" placeholder="11" min="0" max="23">
                        <span class="text-white align-self-center fw-bold">H</span>
                        <input type="number" class="form-control rounded-pill text-center" placeholder="15" min="0" max="59">
                    </div>
                </div>

                <div class="text-center mt-5">
                    <button type="submit" class="btn text-white px-5 py-2 fw-bold" style="background-color: #8c52ff; border-radius: 50px;">
                        Rechercher
                    </button>
                </div>
            </form>

            <div class="mt-5">
                <div class="d-flex align-items-center mb-4">
                    <hr class="flex-grow-1 border-white opacity-50">
                    <span class="mx-3 text-white fs-5">Historique de vos recherches</span>
                    <hr class="flex-grow-1 border-white opacity-50">
                </div>

                <div class="border rounded-4 p-3 border-white border-opacity-25">
                    <div class="text-white text-center py-3">
                        <i class="bi bi-clock-history fs-1 mb-2 d-block opacity-50"></i>
                        Aucune recherche récente
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

{include file='includes/footer.tpl'}