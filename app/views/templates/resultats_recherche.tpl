{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/style_resultats_recherche.css">

<div class="container mt-4 flex-grow-1">
    
    <div class="card border-0 mb-4 text-white card-search-header">
        <div class="card-body text-center py-4">
            <h2 class="fw-bold mb-4">Résultat de la recherche</h2>
            
            <form action="/sae-covoiturage/public/recherche/resultats" method="GET" class="d-flex justify-content-center flex-wrap gap-3 align-items-center">
                <input type="text" name="depart" value="{$recherche.depart}" class="form-control rounded-pill text-center search-input-fixed" readonly>
                <input type="text" name="arrivee" value="{$recherche.arrivee}" class="form-control rounded-pill text-center search-input-fixed" readonly>
                
                {if isset($recherche.date)}
                    <span class="badge bg-white text-dark rounded-pill px-3 py-2 fs-6">{$recherche.date}</span>
                {/if}
                
                <a href="/sae-covoiturage/public/recherche" class="btn btn-sm text-white fw-bold px-4 btn-modify">
                    Modifier
                </a>
            </form>
        </div>
    </div>

    {if isset($message_info) && $message_info}
        <div class="alert alert-custom-warning border-0 shadow-sm rounded-4 text-center py-3 mb-4">
            <div class="d-flex align-items-center justify-content-center gap-2 fs-5">
                <i class="bi bi-exclamation-triangle-fill text-warning"></i>
                <span>{$message_info}</span>
            </div>
        </div>
    {elseif isset($trajets) && $trajets|@count > 0}
        <div class="alert alert-custom-success border-0 shadow-sm rounded-4 text-center py-2 mb-4">
            <i class="bi bi-check-circle-fill me-2"></i> {$trajets|@count} trajet(s) exact(s) trouvé(s) !
        </div>
    {/if}

    {if isset($trajets) && $trajets|@count > 0}
        {foreach from=$trajets item=trajet}
            <div class="card border-0 shadow-sm mb-3 card-result">
                <div class="card-body p-4">
                    <div class="row">
                        <div class="col-md-4 border-end border-secondary border-opacity-25">
                            <h5 class="fw-bold mb-3 text-purple-dark">Informations du conducteur</h5>
                            
                            <a href="/sae-covoiturage/public/profil/voir/{$trajet.id_conducteur}" class="text-decoration-none text-dark group-hover">
                                <div class="d-flex align-items-center mb-3 p-2 rounded hover-profile transition">
                                    <div class="me-3">
                                        <img src="/sae-covoiturage/public/uploads/{$trajet.photo_profil|default:'default.png'}" alt="Avatar" class="rounded-circle shadow-sm avatar-img">
                                    </div>
                                    <div class="flex-grow-1">
                                        <div class="fw-bold fs-5 text-purple-primary">{$trajet.prenom} {$trajet.nom|upper}</div>
                                        <small class="text-muted d-block"><i class="bi bi-mortarboard-fill me-1"></i> Étudiant</small>
                                        <small class="text-warning fst-italic"><i class="bi bi-eye-fill me-1"></i> Voir le profil</small>
                                    </div>
                                    <i class="bi bi-chevron-right ms-auto text-muted"></i>
                                </div>
                            </a>
                            <div class="bg-white rounded-3 p-3 mt-3 shadow-sm">
                                <h6 class="fw-bold mb-2 text-purple-primary">Trajet prévu</h6>
                                <p class="mb-1"><i class="bi bi-calendar-event me-2"></i> Le {$trajet.date_heure_depart|date_format:"%d/%m/%Y"}</p>
                                <p class="mb-1 fw-bold"><i class="bi bi-geo-alt-fill me-2"></i> {$trajet.ville_depart} <i class="bi bi-arrow-right mx-1"></i> {$trajet.ville_arrivee}</p>
                                <p class="mb-0 text-success fw-bold"><i class="bi bi-clock-fill me-2"></i> Départ : {$trajet.date_heure_depart|date_format:"%H:%M"}</p>
                            </div>
                        </div>

                        <div class="col-md-8 ps-md-4 d-flex flex-column justify-content-between">
                            <div>
                                <h5 class="fw-bold mb-3 text-purple-dark">Détails du voyage</h5>
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <span class="badge bg-success rounded-pill px-3 py-2 fs-6">
                                        {$trajet.places_proposees} places disponibles
                                    </span>
                                    <span class="text-muted"><i class="bi bi-car-front-fill me-1"></i> {$trajet.marque} {$trajet.modele}</span>
                                </div>

                                <div class="p-3 rounded-3 comment-box">
                                    <p class="text-muted fst-italic mb-0">
                                        <i class="bi bi-chat-quote-fill me-2 text-purple-primary"></i>
                                        "{$trajet.commentaires|default:'Aucune description renseignée par le conducteur.'}"
                                    </p>
                                </div>
                            </div>

                            <div class="d-flex justify-content-end mt-4 gap-3">
                                <button type="button" 
                                        class="btn btn-outline-danger btn-report rounded-pill px-4" 
                                        data-bs-toggle="modal" 
                                        data-bs-target="#modalSignalement" 
                                        data-id-trajet="{$trajet.id_trajet}"
                                        data-id-conducteur="{$trajet.id_conducteur}"> <i class="bi bi-flag-fill me-1"></i> Signaler
                                </button>
                                <a href="/sae-covoiturage/public/trajet/reserver/{$trajet.id_trajet}" class="btn text-white px-5 py-2 fw-bold fs-5 shadow-sm btn-reserve">
                                    Réserver ce trajet
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        {/foreach}
    {else}
        <div class="alert alert-custom-info text-center rounded-4 py-5 mb-5" role="alert">
            <i class="bi bi-emoji-frown fs-1 d-block mb-3"></i>
            <h4 class="fw-bold">Oups ! Vraiment aucun trajet disponible.</h4>
            <p>Même en cherchant des alternatives, nous n'avons rien trouvé pour cette date.</p>
            
            <a href="/sae-covoiturage/public/trajet/nouveau" class="btn text-white mt-3 px-4 fw-bold btn-reserve">
                Soyez le premier à en proposer un !
            </a>
        </div>
    {/if}

</div>

<div class="modal fade" id="modalSignalement" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow-lg">

            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold text-danger">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>Signaler ce trajet
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            
            <form id="formSignalementRecherche"> 
                <div class="modal-body p-4">
                    <p class="text-muted small mb-4">
                        Merci de nous indiquer la raison de ce signalement. Un modérateur examinera la situation rapidement.
                    </p>
                    
                    <input type="hidden" id="signalement_id_trajet">
                    <input type="hidden" id="signalement_id_conducteur"> <div class="mb-3">
                        <label class="form-label-bold">Motif</label>
                        <select class="form-select bg-light border-0 py-2" id="signalement_motif" required>
                            <option value="" selected disabled>Choisir un motif...</option>
                            <option value="Comportement dangereux">Comportement dangereux</option>
                            <option value="Absence / Retard">Absence / Retard</option>
                            <option value="Véhicule non conforme">Véhicule non conforme</option>
                            <option value="Propos inappropriés">Propos inappropriés</option>
                            <option value="Autre">Autre</option>
                        </select>
                    </div>

                    <div class="mb-4">
                        <label class="form-label-bold">Détails supplémentaires</label>
                        <textarea class="custom-textarea" id="signalement_details" rows="4" placeholder="Décrivez la situation ici..."></textarea>
                    </div>
                </div>
                
                <div class="modal-footer border-0 pt-0 pb-4 pe-4">
                    <button type="button" class="btn btn-light rounded-pill text-muted" data-bs-dismiss="modal">Annuler</button>
                    <button type="button" id="btnConfirmSignalement" class="btn btn-danger rounded-pill px-4 fw-bold">
                        Envoyer le signalement
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="/sae-covoiturage/public/assets/javascript/js_resultats_recherche.js"></script>


{include file='includes/footer.tpl'}