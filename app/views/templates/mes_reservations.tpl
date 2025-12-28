{include file='includes/header.tpl'}

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

                        <div class="d-flex align-items-center mb-4">
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
                                <small class="text-muted"><i class="bi bi-mortarboard-fill me-1"></i> Étudiant</small>
                            </div>
                        </div>

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

                        <div class="d-flex justify-content-end gap-3 mt-4"> {* Boutton signaler *}
                            <button class="btn btn-outline-secondary rounded-pill px-4">
                                <i class="bi bi-flag-fill me-1"></i> Signaler
                            </button>

                            <a href="/sae-covoiturage/public/messagerie/conversation/{$reservation.id_trajet}" class="btn btn-custom rounded-pill px-4" style="background-color:#8c52ff; color: white;">
                                <i class="bi bi-chat-text"></i>
                            </a>

                            <form method="POST"
                                  action="/sae-covoiturage/public/reservation/annuler/{$reservation.id_reservation}"
                                  onsubmit="return confirm('Voulez-vous vraiment annuler cette réservation ?');">
                                <button type="submit"
                                        class="btn btn-purple rounded-pill px-4">
                                    <i class="bi bi-x-circle-fill me-1"></i> Annuler
                                </button>
                            </form>
                        </div>

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

</div>

{include file='includes/footer.tpl'}