{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/reservation/style_reservation.css">

<div class="container mt-5 mb-5">
    
    {* Bandeau de recherche avec les critères *}
    <div class="card border-0 mb-4 text-white shadow-lg bg-gradient-purple">
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
    <div class="card border-0 shadow-lg bg-gradient-light">
        <div class="card-body p-5">
            <div class="row g-4">
                
                {* COLONNE GAUCHE - Informations Conducteur *}
                <div class="col-lg-5">
                    <h4 class="fw-bold mb-4" style="color: #3b2875;">
                        <i class="bi bi-person-circle me-2"></i>Informations du conducteur
                    </h4>
                    
                    <a href="/sae-covoiturage/public/profil/voir/{$trajet.id_conducteur}" class="text-decoration-none text-dark">
                        <div class="d-flex align-items-center mb-4 p-3 bg-white rounded-4 shadow-sm hover-effect transition">
                            <div class="me-3">
                                {if $trajet.photo_profil && $trajet.photo_profil != ''}
                                    <img src="/sae-covoiturage/public/uploads/{$trajet.photo_profil}" alt="Avatar" class="rounded-circle avatar-img">
                                {else}
                                    <div class="rounded-circle avatar-placeholder">
                                        {$trajet.prenom|substr:0:1}{$trajet.nom|substr:0:1}
                                    </div>
                                {/if}
                            </div>
                            <div>
                                <div class="fw-bold fs-5" style="color: #3b2875;">{$trajet.prenom} {$trajet.nom|upper}</div>
                                <small class="text-muted d-block"><i class="bi bi-mortarboard-fill me-1"></i> Étudiant</small>
                                <small class="text-warning fst-italic"><i class="bi bi-eye-fill me-1"></i> Voir le profil</small>
                            </div>
                        </div>
                    </a>

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
                    <div class="bg-white rounded-4 p-4 shadow-lg border-0 border-purple-start">
                        <h5 class="fw-bold mb-4 text-center" style="color: #3b2875;">
                            <i class="bi bi-bookmark-check-fill me-2"></i>Finaliser ma réservation
                        </h5>
                        
                        <form method="POST" action="/sae-covoiturage/public/trajet/reserver/{$trajet.id_trajet}">
                            
                            <div class="mb-4">
                                <label class="fw-semibold mb-2">Nombre de places à réserver</label>
                                <select name="nb_places" class="form-select form-select-lg border-purple bg-light" required>
                                    {for $i=1 to $trajet.places_disponibles}
                                        <option value="{$i}">{$i} place{if $i > 1}s{/if}</option>
                                    {/for}
                                </select>
                                <div class="form-text mt-2 text-muted">
                                    <i class="bi bi-info-circle me-1"></i> Vous pouvez réserver pour plusieurs personnes.
                                </div>
                            </div>

                            <div class="d-grid gap-3">
                                {if $trajet.places_disponibles > 0}
                                    <button type="submit" class="btn btn-lg text-white fw-bold shadow-lg btn-gradient-primary">
                                        <i class="bi bi-check-circle-fill me-2"></i>Réserver ce trajet
                                    </button>
                                {else}
                                    <button type="button" class="btn btn-lg btn-secondary" disabled>
                                        Plus de places disponibles
                                    </button>
                                {/if}
                                <a href="/sae-covoiturage/public/recherche" class="btn btn-outline-secondary btn-lg fw-semibold" style="border-radius: 15px; border-width: 2px;">
                                    <i class="bi bi-arrow-left me-2"></i>Retour à la recherche
                                </a>
                            </div>
                        </form>
                    </div>

                    {* Bouton signaler *}
                    <div class="text-end mt-3">
                        <button class="btn btn-link text-muted" data-bs-toggle="modal" data-bs-target="#modalSignalement" style="text-decoration: none;">
                            <i class="bi bi-flag-fill me-1"></i> Signaler le conducteur
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    {* Modale de signalement (inchangée) *}
    <div class="modal fade" id="modalSignalement" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content rounded-4 shadow-lg border-0">
                <div class="modal-header bg-danger text-white rounded-top-4">
                    <h5 class="modal-title"><i class="bi bi-flag-fill me-2"></i> Signaler ce conducteur</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <input type="hidden" id="trajetSignalement" value="{$trajet.id_trajet}">
                    <input type="hidden" id="conducteurSignalement" value="{$trajet.id_conducteur}">
                    <div class="mb-3">
                        <label class="fw-semibold">Motif</label>
                        <select id="motifSignalement" class="form-select" required>
                            <option value="" selected disabled>Choisir un motif...</option>
                            <option value="Profil non conforme">Profil non conforme</option>
                            <option value="Comportement inapproprié">Comportement inapproprié</option>
                            <option value="Autre">Autre</option>
                        </select>
                    </div>
                    <div class="mb-4">
                        <label class="fw-semibold">Détails</label>
                        <textarea id="detailsSignalement" class="form-control" rows="4" placeholder="Expliquez la situation..." required></textarea>
                    </div>
                    <div class="d-grid gap-2">
                        <button id="btnEnvoyerSignalement" class="btn btn-danger fw-bold">Envoyer le signalement</button>
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Annuler</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

{literal}
    <script>
    document.addEventListener('DOMContentLoaded', () => {
        const modal = new bootstrap.Modal(document.getElementById('modalSignalement'));
        document.querySelector('[data-bs-target="#modalSignalement"]').addEventListener('click', () => { modal.show(); });
        document.getElementById('btnEnvoyerSignalement').addEventListener('click', () => {
            const t = document.getElementById('trajetSignalement').value;
            const c = document.getElementById('conducteurSignalement').value;
            const m = document.getElementById('motifSignalement').value;
            const d = document.getElementById('detailsSignalement').value;
            if(!m || !d){ alert("Veuillez remplir tous les champs."); return; }
            fetch('/sae-covoiturage/public/api/signalement/nouveau', {
                method: 'POST', headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ id_trajet: t, id_signale: c, motif: m, description: d })
            }).then(r => r.json()).then(data => {
                modal.hide();
                if(data.success){ alert("Signalement envoyé."); } else { alert(data.msg || "Erreur"); }
            });
        });
    });
    </script>
{/literal}

{include file='includes/footer.tpl'}