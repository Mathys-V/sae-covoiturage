{include file='includes/header.tpl'}

<div class="container mt-4 flex-grow-1">
    
    <div class="card border-0 mb-4 text-white" style="background-color: #3b2875; border-radius: 20px;">
        <div class="card-body text-center py-4">
            <h2 class="fw-bold mb-4">Résultat de la recherche</h2>
            
            <form action="/sae-covoiturage/public/recherche/resultats" method="GET" class="d-flex justify-content-center flex-wrap gap-3 align-items-center">
                <input type="text" name="depart" value="{$recherche.depart}" class="form-control rounded-pill text-center" style="width: 250px;" readonly>
                <input type="text" name="arrivee" value="{$recherche.arrivee}" class="form-control rounded-pill text-center" style="width: 250px;" readonly>
                {if isset($recherche.date)}
                    <span class="badge bg-white text-dark rounded-pill px-3 py-2 fs-6">{$recherche.date}</span>
                {/if}
                
                <a href="/sae-covoiturage/public/recherche" class="btn btn-sm text-white fw-bold px-4" style="background-color: #8c52ff; border-radius: 20px; width: auto !important;">
                    Modifier
                </a>
            </form>
        </div>
    </div>

    {if isset($trajets) && $trajets|@count > 0}
        {foreach from=$trajets item=trajet}
            <div class="card border-0 shadow-sm mb-3" style="background-color: #f0ebf8; border-radius: 20px;">
                <div class="card-body p-4">
                    <div class="row">
                        <div class="col-md-4 border-end border-secondary border-opacity-25">
                            <h5 class="fw-bold mb-3">Informations du conducteur</h5>
                            <div class="d-flex align-items-center mb-3">
                                <div class="me-3">
                                    <img src="/sae-covoiturage/public/uploads/{$trajet.photo_profil|default:'default.png'}" alt="Avatar" class="rounded-circle" width="50" height="50" style="object-fit: cover;">
                                </div>
                                <div>
                                    <div class="fw-bold">{$trajet.prenom} {$trajet.nom|upper}</div>
                                    <small class="text-muted">Étudiant</small>
                                </div>
                            </div>
                            
                            <h6 class="fw-bold mt-4">Trajet prévu</h6>
                            <p class="mb-1">Le {$trajet.date_heure_depart|date_format:"%d/%m/%Y"}</p>
                            <p class="mb-1 fw-bold">{$trajet.ville_depart} <i class="bi bi-arrow-right"></i> {$trajet.ville_arrivee}</p>
                            <p class="mb-0">Départ : {$trajet.date_heure_depart|date_format:"%H:%M"}</p>
                        </div>

                        <div class="col-md-8 ps-md-4">
                            <h5 class="fw-bold mb-3">Informations véhicule</h5>
                            <p class="mb-1">
                                <span class="fw-bold">{$trajet.places_proposees} places</span> disponibles
                            </p>
                            <p class="text-muted">{$trajet.marque} {$trajet.modele}</p>

                            <h5 class="fw-bold mt-4">Description rapide</h5>
                            <p class="text-muted fst-italic">
                                "{$trajet.commentaires|default:'Aucune description renseignée.'}"
                            </p>

                            <div class="d-flex justify-content-center mt-4 gap-3">
                                <a href="/sae-covoiturage/public/trajet/reserver/{$trajet.id_trajet}" class="btn text-white px-5 py-2 fw-bold fs-5" style="background-color: #8c52ff; border-radius: 50px; width: auto !important;">
                                    Réserver
                                </a>
                                <button class="btn btn-dark btn-sm rounded-pill px-3">Signaler</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        {/foreach}
    {else}
        <div class="alert alert-info text-center rounded-4 py-5 mb-5" role="alert" style="background-color: #d1ecf1; border-color: #bee5eb; color: #0c5460;">
            <i class="bi bi-emoji-frown fs-1 d-block mb-3"></i>
            <h4 class="fw-bold">Oups ! Aucun trajet disponible.</h4>
            <p>Personne n'a proposé de trajet pour <strong>{$recherche.depart}</strong> vers <strong>{$recherche.arrivee}</strong> à cette date.</p>
            
            <a href="/sae-covoiturage/public/trajet/nouveau" class="btn btn-purple mt-3 px-4" style="width: auto !important;">
                Soyez le premier à en proposer un !
            </a>
        </div>
    {/if}

</div>

{include file='includes/footer.tpl'}