{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/reservation/style_mes_reservations.css">

<div class="container my-5 flex-grow-1">

    <h1 class="fw-bold text-center mb-5" style="color:#3b2875;">
        {$titre}
    </h1>

    {if isset($reservations) && $reservations|@count > 0}
        {foreach from=$reservations item=reservation}
        <div class="card border-0 shadow-sm mb-3" style="background-color: #f0ebf8; border-radius: 20px; transition: transform 0.2s;">
            <div class="card-body p-4">
                <div class="row">

                    {* COLONNE GAUCHE — Conducteur & trajet *}
                    <div class="col-md-5 border-end border-secondary border-opacity-25">

                        <h5 class="fw-bold mb-3" style="color: #452b85;">
                            Conducteur
                        </h5>

                        <a href="/sae-covoiturage/public/profil/voir/{$reservation.id_conducteur}" class="text-decoration-none text-dark">
                            <div class="d-flex align-items-center mb-4 p-2 rounded hover-bg-light transition">
                                <div class="me-3">
                                    {if $reservation.conducteur_photo}
                                        <img src="/sae-covoiturage/public/uploads/{$reservation.conducteur_photo}"
                                             class="rounded-circle shadow-sm"
                                             width="60" height="60"
                                             style="object-fit:cover;">
                                    {else}
                                        <div class="avatar-fallback">
                                            {$reservation.conducteur_prenom|substr:0:1}{$reservation.conducteur_nom|substr:0:1}
                                        </div>
                                    {/if}
                                </div>
                                <div>
                                    <div class="fw-bold">
                                        {$reservation.conducteur_prenom} {$reservation.conducteur_nom|upper}
                                    </div>
                                    <small class="text-muted d-block"><i class="bi bi-mortarboard-fill me-1"></i> Étudiant</small>
                                    <small class="text-warning fst-italic"><i class="bi bi-eye-fill"></i> Voir le profil</small>
                                </div>
                            </div>
                        </a>

                        <div class="bg-light rounded-3 p-3">
                            <label class="pb-3 fw-bold" style="color: #8c52ff;">Information du trajet</label>
                            <p class="mb-2">
                                <i class="bi bi-calendar-event me-2"></i>
                                {$reservation.date_fmt}
                            </p>

                            <p class="fw-semibold mb-2">
                                <i class="bi bi-geo-alt-fill me-2"></i>
                                {$reservation.ville_depart}
                                <i class="bi bi-arrow-right mx-1"></i>
                                {$reservation.ville_arrivee}
                            </p>

                            <p class="mb-0 text-success fw-bold">
                                <i class="bi bi-clock-fill me-2"></i>
                                Départ : {$reservation.heure_fmt}
                            </p>

                            <p class="mt-2">
                                <span class="badge bg-{$reservation.statut_couleur} bg-opacity-10 text-{$reservation.statut_couleur} border border-{$reservation.statut_couleur} rounded-pill px-2 py-1 fw-bold">
                                    {if $reservation.statut_visuel == 'avenir'}<i class="bi bi-clock me-1"></i>
                                    {elseif $reservation.statut_visuel == 'encours'}<i class="bi bi-car-front-fill me-1"></i>
                                    {else}<i class="bi bi-check-circle-fill me-1"></i>{/if}
                                    {$reservation.statut_libelle}
                                </span>

                                {if $reservation.statut_visuel == 'encours' && isset($reservation.temps_restant)}
                                    <span class="ms-2 text-success fw-semibold">
                                        <i class="bi bi-hourglass-split"></i> Arrivée dans {$reservation.temps_restant}
                                    </span>
                                {/if}
                            </p>
                        </div>
                    </div>

                    {* COLONNE DROITE — Véhicule & actions *}
                    <div class="col-md-7 d-flex flex-column justify-content-between">

                        <div>
                            <h5 class="fw-bold mb-3" style="color: #452b85;">
                                <i class="bi bi-car-front-fill me-2"></i>Véhicule
                            </h5>

                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="text-muted">
                                    {$reservation.marque} {$reservation.modele}
                                </span>
                            </div>

                            <div class="p-3 rounded-3" style="background-color: rgba(140, 82, 255, 0.1);">
                                <p class="text-muted fst-italic mb-0">
                                    <i class="bi bi-chat-quote-fill me-2 text-purple"></i>
                                    {$reservation.commentaires|default:'Aucun commentaire.'}
                                </p>
                            </div>
                        </div>

                        <div class="d-flex justify-content-end gap-3 mt-4"> {* Boutons action *}
                        <button class="btn btn-outline-danger btn-report rounded-pill px-4"
                        data-trajet="{$reservation.id_trajet}">                
                                <i class="bi bi-flag-fill me-1"></i> Signaler
                            </button>
                    
                            {* Bouton Message - Masqué pour les trajets terminés *}
                            {if $reservation.statut_visuel != 'termine'}
                            <a href="/sae-covoiturage/public/messagerie/conversation/{$reservation.id_trajet}" class="btn btn-custom rounded-pill px-4" style="background-color:#8c52ff; color: white;">
                                <i class="bi bi-chat-text"></i>
                            </a>
                            {/if}

                            {* Bouton Annuler - Masqué pour les trajets terminés *}
                            {if $reservation.statut_visuel != 'termine'}
                            <form method="POST"
                                  action="/sae-covoiturage/public/reservation/annuler/{$reservation.id_reservation}"
                                  onsubmit="return confirm('Voulez-vous vraiment annuler cette réservation ?');">
                                <button type="submit"
                                        class="btn btn-purple rounded-pill px-4">
                                    <i class="bi bi-x-circle-fill me-1"></i> Annuler
                                </button>
                            </form>
                            {/if}
                        </div>

                    </div>
                </div>
            </div>
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

                    <div class="modal-body p-4">
                        <p class="text-muted small mb-4">Merci de nous indiquer la raison de ce signalement. Un
                            modérateur examinera la situation rapidement.</p>

                        <form id="formSignalement">

                            <input type="hidden" id="trajetSignalement">

                            <div class="mb-3">
                                <label class="form-label-bold">Qui concerne ce signalement ?</label>
                                <select class="form-select bg-light border-0 py-2" id="userSignalement" required>
                                    <option value="" selected disabled>Choisir un utilisateur...</option>
                                    {if isset($participants[$reservation.id_trajet])}
                                        {foreach $participants[$reservation.id_trajet] as $p}
                                            <option value="{$p.id}">{$p.nom} ({$p.role})</option>
                                        {/foreach}
                                    {/if}
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label-bold">Motif</label>
                                <select class="form-select bg-light border-0 py-2" id="motifSignalement" required>
                                    <option value="" selected disabled>Choisir un motif...</option>
                                    <option value="Comportement dangereux">Comportement dangereux</option>
                                    <option value="Absence au rendez-vous">Absence au rendez-vous</option>
                                    <option value="Véhicule non conforme">Véhicule non conforme</option>
                                    <option value="Propos inappropriés">Propos inappropriés</option>
                                    <option value="Autre">Autre</option>
                                </select>
                            </div>

                            <div class="mb-4">
                                <label class="form-label-bold">Détails supplémentaires</label>
                                <textarea class="custom-textarea" id="detailsSignalement" rows="4"
                                    placeholder="Décrivez la situation ici..."></textarea>
                            </div>

                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-danger rounded-pill fw-bold py-2">Envoyer le
                                    signalement</button>
                                <button type="button" class="btn btn-light rounded-pill text-muted"
                                    data-bs-dismiss="modal">Annuler</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        {/foreach}

    {else}
        <div class="alert alert-info text-center rounded-4 py-5">
            <i class="bi bi-calendar-x fs-1 d-block mb-3"></i>
            <h4 class="fw-bold">Aucune réservation</h4>
            <p class="mb-4">Vous n’avez pas encore réservé de trajet.</p>
            <a href="/sae-covoiturage/public/recherche"
               class="btn btn-purple rounded-pill px-5">
                <i class="bi bi-search me-2"></i>Rechercher un trajet
            </a>
        </div>
    {/if}

<script src="/sae-covoiturage/public/assets/javascript/reservation/js_mes_reservations.js"></script>

</div>
{include file='includes/footer.tpl'}
