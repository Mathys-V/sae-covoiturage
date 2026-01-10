{include file='includes/header.tpl'}

{* Inclusion de la feuille de style spécifique à la gestion des trajets *}
<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/trajet/style_mes_trajets.css">

{* Styles spécifiques pour la fenêtre modale de signalement *}
<style>
    .modal-content { border-radius: 20px; border: none; overflow: hidden; }
    .modal-header { background-color: #452b85; color: white; border-bottom: none; }
    .btn-close-white { filter: invert(1); }
    .form-label { color: #452b85; font-weight: bold; }
</style>

<div class="container mt-4 mb-5 flex-grow-1">
    <div class="row">
        <div class="col-12">
            <h1 class="text-white text-center mb-5" style="font-family: 'Garet', sans-serif;">Mes Trajets</h1>
        </div>
    </div>

    {* CAS 1 : Aucun trajet (ni actif, ni archivé) *}
    {if empty($trajets_actifs) && empty($trajets_archives)}
        <div class="text-center text-white mt-5">
            <div class="mb-3">
                <i class="bi bi-car-front fs-1 text-white-50"></i>
            </div>
            <p class="fs-4">Vous n'avez aucun trajet pour le moment.</p>
            <a href="/sae-covoiturage/public/trajet/nouveau" class="btn btn-light fw-bold text-purple mt-3 px-4 py-2 rounded-pill shadow">
                Proposer un trajet
            </a>
        </div>

    {else}
        
        {* SECTION 1 : TRAJETS À VENIR & EN COURS *}
        {if !empty($trajets_actifs)}
            <div class="mb-4">
                <h3 class="text-white mb-4 ps-2 border-start border-4 border-warning">
                    Prochains départs
                </h3>
                
                {foreach $trajets_actifs as $trajet}
                    {* ID utilisé pour le défilement automatique depuis la carte *}
                    <div class="card border-0 rounded-5 mb-4 card-trajet p-4" id="trajet-{$trajet.id_trajet}">
                        
                        {* En-tête de la carte : Statut et Temps restant *}
                        <div class="d-flex justify-content-between align-items-center mb-3 pb-2 border-bottom border-light-subtle">
                            <div class="d-flex align-items-center gap-3">
                                <span class="badge bg-{$trajet.statut_couleur} bg-opacity-10 text-{$trajet.statut_couleur} border border-{$trajet.statut_couleur} rounded-pill px-3 py-2">
                                    {$trajet.statut_libelle}
                                </span>
                                {if $trajet.statut_visuel == 'encours' && isset($trajet.temps_restant)}
                                    <span class="text-success fw-bold small">
                                        <i class="bi bi-hourglass-split"></i> Arrivée dans {$trajet.temps_restant}
                                    </span>
                                {/if}
                            </div>
                        </div>

                        <div class="row g-0">
                            {* Colonne Gauche : Détails de l'itinéraire *}
                            <div class="col-md-6 pe-md-4 d-flex flex-column border-end-md border-secondary-subtle">
                                <div class="mb-3">
                                    <h3 class="fw-bold mb-3 text-dark">Trajet prévu</h3>
                                    <p class="fs-5 mb-1 text-dark">le <strong>{$trajet.date_fmt}</strong></p>
                                    <div class="my-3 text-dark">
                                        <div class="fs-5">{if $trajet.rue_depart}{$trajet.rue_depart}, {/if}{$trajet.ville_depart}</div>
                                        <div class="fs-5 fw-bold text-purple my-1 ps-2"><i class="bi bi-arrow-down"></i></div>
                                        <div class="fs-5">{if $trajet.rue_arrivee}{$trajet.rue_arrivee}, {/if}{$trajet.ville_arrivee}</div>
                                    </div>
                                    <p class="fs-5 mb-1 text-dark">Départ : <strong>{$trajet.heure_fmt}</strong></p>
                                </div>

                                {* Liste des passagers inscrits *}
                                <div class="mt-auto pt-3">
                                    {if $trajet.passagers|count > 0}
                                        <div class="mb-2 fw-bold text-dark">Passagers :</div>
                                        {foreach $trajet.passagers as $passager}
                                            <div class="d-flex align-items-center justify-content-between mb-2">
                                                <div class="d-flex align-items-center gap-2">
                                                    <div class="rounded-circle bg-secondary-subtle d-flex align-items-center justify-content-center" style="width: 40px; height: 40px; overflow: hidden;">
                                                        <img src="/sae-covoiturage/public/uploads/{$passager.photo_profil|default:'default.png'}" alt="Avatar" style="width: 100%; height: 100%; object-fit: cover;">
                                                    </div>
                                                    <span class="fw-bold fs-5 text-dark">{$passager.prenom} {$passager.nom|substr:0:1}.</span>
                                                </div>
                                                {* Bouton pour signaler ce passager spécifique *}
                                                <button class="btn btn-sm btn-dark-purple rounded-pill px-3" 
                                                        onclick="ouvrirSignalement({$trajet.id_trajet}, {$passager.id_utilisateur}, '{$passager.prenom|escape:'javascript'} {$passager.nom|escape:'javascript'}')">
                                                    Signaler
                                                </button>
                                            </div>
                                        {/foreach}
                                    {else}
                                        <div class="d-flex align-items-center gap-2 text-muted fst-italic">
                                            <i class="bi bi-info-circle"></i> Aucun passager pour l'instant
                                        </div>
                                    {/if}
                                </div>
                            </div>

                            {* Colonne Droite : Infos véhicule et Boutons d'action *}
                            <div class="col-md-6 ps-md-4 d-flex flex-column justify-content-between mt-4 mt-md-0">
                                <div>
                                    <h3 class="fw-bold mb-3 text-dark">Informations véhicule</h3>
                                    <p class="fs-5 mb-1 text-dark"><strong>{$trajet.places_restantes}</strong> places disponibles</p>
                                    <p class="fs-5 text-dark">{$trajet.marque} {$trajet.modele}</p>
                                    <h3 class="fw-bold mt-4 mb-2 text-dark">Réservation</h3>
                                    <p class="fs-5 text-dark"><strong>{$trajet.places_prises}</strong> places réservées</p>
                                </div>

                                <div class="d-flex flex-column gap-2 mt-4">
                                    {* Bouton Discussion de groupe *}
                                    <a href="/sae-covoiturage/public/messagerie/conversation/{$trajet.id_trajet}" 
                                       class="btn btn-purple-action fw-bold py-2 w-100 shadow-sm text-decoration-none text-center">
                                        Discussion de groupe
                                    </a>
                                    
                                    <div class="d-flex gap-2 flex-wrap">
                                        {* Bouton Modifier (Désactivé si terminé/annulé) *}
                                        <a href="/sae-covoiturage/public/trajet/modifier/{$trajet.id_trajet}" 
                                           class="btn btn-purple-action fw-bold py-2 flex-grow-1 shadow-sm text-decoration-none text-center d-flex align-items-center justify-content-center
                                           {if $trajet.statut_visuel == 'termine' || $trajet.statut_visuel == 'annule'}disabled{/if}"
                                           {if $trajet.statut_visuel == 'termine' || $trajet.statut_visuel == 'annule'}
                                               aria-disabled="true" tabindex="-1" style="pointer-events: none; opacity: 0.65;"
                                           {/if}>
                                            Modifier
                                        </a>
                                        
                                        {* Bouton Annuler le trajet (Avec confirmation) *}
                                        {if $trajet.statut_visuel != 'termine' && $trajet.statut_visuel != 'annule'}
                                            <form action="/sae-covoiturage/public/trajet/annuler" method="POST" class="flex-grow-1" onsubmit="return confirm('⚠️ Êtes-vous sûr de vouloir ANNULER ce trajet ?');">
                                                <input type="hidden" name="id_trajet" value="{$trajet.id_trajet}">
                                                <button type="submit" class="btn btn-outline-danger fw-bold py-2 w-100 shadow-sm">
                                                    Annuler
                                                </button>
                                            </form>
                                        {/if}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                {/foreach}
            </div>
        {/if}

        {* SECTION 2 : HISTORIQUE (Trajets passés) *}
        {if !empty($trajets_archives)}
            <div class="mt-5 mb-4">
                <h3 class="text-white-50 mb-4 ps-2 border-start border-4 border-secondary">Historique</h3>
                {foreach $trajets_archives as $trajet}
                    <div style="opacity: 0.8;"> 
                        <div class="card border-0 rounded-5 mb-4 card-trajet p-4" id="trajet-{$trajet.id_trajet}">
                            <div class="d-flex justify-content-between align-items-center mb-3 pb-2 border-bottom border-light-subtle">
                                <span class="badge bg-{$trajet.statut_couleur} bg-opacity-10 text-{$trajet.statut_couleur} border border-{$trajet.statut_couleur} rounded-pill px-3 py-2">
                                    {$trajet.statut_libelle}
                                </span>
                            </div>
                            <div class="row g-0">
                                <div class="col-md-6 pe-md-4 border-end-md border-secondary-subtle">
                                    <h3 class="fw-bold mb-3 text-dark">Trajet du {$trajet.date_fmt}</h3>
                                    <div class="my-3 text-dark">
                                        <div class="fs-5">{$trajet.ville_depart} -> {$trajet.ville_arrivee}</div>
                                    </div>
                                    <div class="mt-3">
                                        {if $trajet.passagers|count > 0}
                                            <div class="mb-2 fw-bold text-dark">Passagers :</div>
                                            {foreach $trajet.passagers as $passager}
                                                <div class="d-flex align-items-center justify-content-between mb-2">
                                                    <span class="text-dark">{$passager.prenom} {$passager.nom|substr:0:1}.</span>
                                                    {* Signalement toujours possible dans l'historique *}
                                                    <button class="btn btn-sm btn-dark-purple rounded-pill px-3"
                                                            onclick="ouvrirSignalement({$trajet.id_trajet}, {$passager.id_utilisateur}, '{$passager.prenom|escape:'javascript'} {$passager.nom|escape:'javascript'}')">
                                                        Signaler
                                                    </button>
                                                </div>
                                            {/foreach}
                                        {else}
                                            <div class="text-muted small">Aucun passager</div>
                                        {/if}
                                    </div>
                                </div>
                                <div class="col-md-6 ps-md-4 mt-3 mt-md-0">
                                    <a href="#" class="btn btn-purple-action w-100 disabled" style="opacity:0.5;">Archivé</a>
                                </div>
                            </div>
                        </div>
                    </div>
                {/foreach}
            </div>
        {/if}
    {/if}
</div>

{* --- MODAL SIGNALEMENT (Masqué par défaut) --- *}
<div class="modal fade" id="signalementModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content shadow-lg">
            <div class="modal-header">
                <h5 class="modal-title"><i class="bi bi-exclamation-triangle-fill me-2"></i>Signaler</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Signaler <strong id="modal-passager-nom" class="text-purple"></strong>.</p>
                <form id="form-signalement">
                    <input type="hidden" id="sig-id-trajet">
                    <input type="hidden" id="sig-id-passager">
                    <div class="mb-3">
                        <label for="sig-motif" class="form-label">Motif *</label>
                        <select class="form-select" id="sig-motif" required>
                            <option value="" selected disabled>Choisir...</option>
                            <option value="Absence">Absence au rendez-vous</option>
                            <option value="Retard">Retard</option>
                            <option value="Comportement">Comportement</option>
                            <option value="Autre">Autre</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <textarea class="form-control" id="sig-desc" rows="3" placeholder="Détails..."></textarea>
                    </div>
                    <div class="d-grid"><button type="submit" class="btn btn-danger rounded-pill">Envoyer</button></div>
                </form>
            </div>
        </div>
    </div>
</div>

{* Script JS pour gérer l'ouverture du modal et l'envoi du signalement *}
<script src="/sae-covoiturage/public/assets/javascript/trajet/js_mes_trajets.js"></script>

{include file='includes/footer.tpl'}