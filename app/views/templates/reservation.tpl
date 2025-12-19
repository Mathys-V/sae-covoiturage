{include file='includes/header.tpl'}

<div class="container mt-5 mb-5">
    
    {* Bandeau de recherche avec les critères *}
    <div class="card border-0 mb-4 text-white shadow-lg" style="background: linear-gradient(135deg, #5e3a8f 0%, #3b2875 100%); border-radius: 25px;">
        <div class="card-body text-center py-4">
            <h2 class="fw-bold mb-4">Résultat de la recherche</h2>
            
            <div class="d-flex justify-content-center flex-wrap gap-3 align-items-center">
                <div class="bg-white text-dark rounded-pill px-4 py-2 fw-semibold" style="min-width: 250px;">
                    <i class="bi bi-geo-alt-fill text-primary me-2"></i>{$trajet.ville_depart}
                </div>
                <div class="bg-white text-dark rounded-pill px-4 py-2 fw-semibold" style="min-width: 250px;">
                    <i class="bi bi-geo-fill text-danger me-2"></i>{$trajet.ville_arrivee}
                </div>
                <div class="bg-white text-dark rounded-pill px-4 py-2 fw-semibold">
                    <i class="bi bi-calendar-check me-2"></i>{$trajet.date_fmt}
                </div>
            </div>
        </div>
    </div>

    {* Carte de réservation *}
    <div class="card border-0 shadow-lg" style="background: linear-gradient(135deg, #f0ebf8 0%, #e8e0f5 100%); border-radius: 25px;">
        <div class="card-body p-5">
            <div class="row g-4">
                
                {* COLONNE GAUCHE - Informations Conducteur *}
                <div class="col-lg-5">
                    <h4 class="fw-bold mb-4" style="color: #3b2875;">
                        <i class="bi bi-person-circle me-2"></i>Informations du conducteur
                    </h4>
                    
                    <div class="d-flex align-items-center mb-4 p-3 bg-white rounded-4 shadow-sm">
                        <div class="me-3">
                            {if $trajet.photo_profil && $trajet.photo_profil != ''}
                                <img src="/sae-covoiturage/public/uploads/{$trajet.photo_profil}" alt="Avatar" class="rounded-circle" width="70" height="70" style="object-fit: cover; border: 3px solid #8c52ff;">
                            {else}
                                <div class="rounded-circle d-flex align-items-center justify-content-center" style="width: 70px; height: 70px; background: linear-gradient(135deg, #8c52ff, #5e3a8f); color: white; font-size: 28px; font-weight: bold;">
                                    {$trajet.prenom|substr:0:1}{$trajet.nom|substr:0:1}
                                </div>
                            {/if}
                        </div>
                        <div>
                            <div class="fw-bold fs-5" style="color: #3b2875;">{$trajet.prenom} {$trajet.nom|upper}</div>
                            <small class="text-muted"><i class="bi bi-mortarboard-fill me-1"></i> Étudiant</small>
                        </div>
                    </div>

                    {* Trajet prévu *}
                    <div class="bg-white rounded-4 p-4 shadow-sm">
                        <h5 class="fw-bold mb-3" style="color: #8c52ff;">
                            <i class="bi bi-sign-turn-right me-2"></i>Trajet prévu
                        </h5>
                        
                        <div class="mb-3">
                            <div class="d-flex align-items-center mb-2">
                                <i class="bi bi-calendar-event-fill me-2 text-primary"></i>
                                <span class="fw-semibold">Le {$trajet.date_fmt}</span>
                            </div>
                        </div>

                        <div class="mb-3 p-3 rounded-3" style="background-color: #f8f9fa; border-left: 4px solid #8c52ff;">
                            <div class="d-flex align-items-start mb-2">
                                <i class="bi bi-geo-alt-fill text-success me-2 mt-1"></i>
                                <div>
                                    <strong>Départ:</strong><br>
                                    <span>{$trajet.ville_depart}</span>
                                </div>
                            </div>
                            <div class="text-center my-2">
                                <i class="bi bi-arrow-down fs-4" style="color: #8c52ff;"></i>
                            </div>
                            <div class="d-flex align-items-start">
                                <i class="bi bi-geo-fill text-danger me-2 mt-1"></i>
                                <div>
                                    <strong>Arrivée:</strong><br>
                                    <span>{$trajet.ville_arrivee}</span>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex align-items-center justify-content-between p-3 rounded-3" style="background-color: #e8f5e9;">
                            <span><i class="bi bi-clock-fill me-2 text-success"></i><strong>Départ:</strong></span>
                            <span class="badge bg-success px-3 py-2 fs-6">{$trajet.heure_fmt}</span>
                        </div>
                    </div>
                </div>

                {* COLONNE DROITE - Détails voyage + Réservation *}
                <div class="col-lg-7">
                    <h4 class="fw-bold mb-4" style="color: #3b2875;">
                        <i class="bi bi-info-circle me-2"></i>Détails du voyage
                    </h4>

                    <div class="row g-3 mb-4">
                        <div class="col-6">
                            <div class="bg-white rounded-4 p-3 shadow-sm text-center h-100">
                                <div class="text-success fw-bold fs-3">{$trajet.places_disponibles}</div>
                                <small class="text-muted">place{if $trajet.places_disponibles > 1}s{/if} disponible{if $trajet.places_disponibles > 1}s{/if}</small>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="bg-white rounded-4 p-3 shadow-sm text-center h-100">
                                <div class="fw-bold fs-5" style="color: #3b2875;">
                                    <i class="bi bi-car-front-fill me-1"></i>{$trajet.marque}
                                </div>
                                <small class="text-muted">{$trajet.modele}</small>
                            </div>
                        </div>
                    </div>

                    {* Description *}
                    <div class="bg-white rounded-4 p-4 mb-4 shadow-sm">
                        <h6 class="fw-bold mb-3" style="color: #8c52ff;">
                            <i class="bi bi-chat-quote-fill me-2"></i>Commentaire du conducteur
                        </h6>
                        <p class="text-muted fst-italic mb-0" style="line-height: 1.6;">
                            {$trajet.commentaires|default:'Aucune description renseignée par le conducteur.'}
                        </p>
                    </div>

                    {* FORMULAIRE DE RÉSERVATION *}
                    <div class="bg-white rounded-4 p-4 shadow-lg border-0" style="border-left: 5px solid #8c52ff !important;">
                        <h5 class="fw-bold mb-4 text-center" style="color: #3b2875;">
                            <i class="bi bi-bookmark-check-fill me-2"></i>Finaliser ma réservation
                        </h5>
                        
                        <form method="POST" action="/sae-covoiturage/public/trajet/reserver/{$trajet.id_trajet}">
                            <div class="mb-4">
                                <label class="fw-semibold">
                                    Prêt(e) à monter à bord ? Confirmez votre réservation.
                                </label>
                            </div>

                            <div class="d-grid gap-3">
                                <button type="submit" class="btn btn-lg text-white fw-bold shadow-lg" style="background: linear-gradient(135deg, #8c52ff 0%, #6a3fd9 100%); border-radius: 15px; padding: 15px; transition: all 0.3s;">
                                    <i class="bi bi-check-circle-fill me-2"></i>Réserver ce trajet
                                </button>
                                <a href="/sae-covoiturage/public/recherche" class="btn btn-outline-secondary btn-lg fw-semibold" style="border-radius: 15px; border-width: 2px;">
                                    <i class="bi bi-arrow-left me-2"></i>Retour à la recherche
                                </a>
                            </div>
                        </form>
                    </div>

                    {* Bouton signaler *}
                    <div class="text-end mt-3">
                        <button class="btn btn-link text-muted" style="text-decoration: none;">
                            <i class="bi bi-flag-fill me-1"></i> Signaler ce trajet
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(140, 82, 255, 0.3) !important;
}

.card {
    transition: all 0.3s ease;
}
</style>

{include file='includes/footer.tpl'}