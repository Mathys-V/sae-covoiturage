{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/style_mes_trajets.css">

<div class="container mt-4 mb-5 flex-grow-1">
    <div class="row">
        <div class="col-12">
            <h1 class="text-white text-center mb-5" style="font-family: 'Garet', sans-serif;">Mes Trajets</h1>
        </div>
    </div>

    {* CAS 1 : Aucun trajet du tout (ni actif, ni passé) *}
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
                    <div class="card border-0 rounded-5 mb-4 card-trajet p-4">
                
                        <div class="d-flex justify-content-between align-items-center mb-3 pb-2 border-bottom border-light-subtle">
                            <div class="d-flex align-items-center gap-3">
                                <span class="badge bg-{$trajet.statut_couleur} bg-opacity-10 text-{$trajet.statut_couleur} border border-{$trajet.statut_couleur} rounded-pill px-3 py-2">
                                    {if $trajet.statut_visuel == 'avenir'}<i class="bi bi-calendar-event me-2"></i>
                                    {elseif $trajet.statut_visuel == 'encours'}<i class="bi bi-car-front-fill me-2"></i>
                                    {elseif $trajet.statut_visuel == 'annule'}<i class="bi bi-x-circle-fill me-2"></i>
                                    {else}<i class="bi bi-check-circle-fill me-2"></i>{/if}
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
                            
                            <div class="col-md-6 pe-md-4 d-flex flex-column border-end-md border-secondary-subtle">
                                
                                <div class="mb-3">
                                    <h3 class="fw-bold mb-3 text-dark">Trajet prévu</h3>
                                    
                                    <p class="fs-5 mb-1 text-dark">le <strong>{$trajet.date_fmt}</strong></p>
                                    
                                    <div class="my-3 text-dark">
                                        <div class="fs-5">
                                            {if $trajet.rue_depart}{$trajet.rue_depart}, {/if}{$trajet.ville_depart}
                                        </div>
                                        
                                        <div class="fs-5 fw-bold text-purple my-1 ps-2">
                                            <i class="bi bi-arrow-down"></i>
                                        </div>
                                        
                                        <div class="fs-5">
                                            {if $trajet.rue_arrivee}{$trajet.rue_arrivee}, {/if}{$trajet.ville_arrivee}
                                        </div>
                                    </div>

                                    <p class="fs-5 mb-1 text-dark">Départ : <strong>{$trajet.heure_fmt}</strong></p>
                                    <p class="mb-0 text-dark">Durée estimée : {$trajet.duree_fmt}</p>
                                </div>

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
                                                <button class="btn btn-sm btn-dark-purple rounded-pill px-3">Signaler</button>
                                            </div>
                                        {/foreach}
                                    {else}
                                        <div class="d-flex align-items-center gap-2 text-muted fst-italic">
                                            <i class="bi bi-info-circle"></i> Aucun passager pour l'instant
                                        </div>
                                    {/if}
                                </div>
                            </div>

                            <div class="col-md-6 ps-md-4 d-flex flex-column justify-content-between mt-4 mt-md-0">
                                
                                <div>
                                    <h3 class="fw-bold mb-3 text-dark">Informations véhicule</h3>
                                    <p class="fs-5 mb-1 text-dark">
                                        <strong>{$trajet.places_restantes}</strong> places disponibles
                                    </p>
                                    <p class="fs-5 text-dark">
                                        {$trajet.marque} {$trajet.modele}
                                    </p>

                                    <h3 class="fw-bold mt-4 mb-2 text-dark">Réservation</h3>
                                    <p class="fs-5 text-dark">
                                        <strong>{$trajet.places_prises}</strong> places réservées
                                    </p>
                                </div>

                                <div class="d-flex flex-column gap-2 mt-4">
                                    <a href="/sae-covoiturage/public/messagerie/conversation/{$trajet.id_trajet}" 
                                       class="btn btn-purple-action fw-bold py-2 w-100 shadow-sm text-decoration-none text-center">
                                        Discussion de groupe
                                    </a>
                                    
<div class="d-flex gap-2 flex-wrap">
    
    <button class="btn btn-purple-action fw-bold py-2 flex-grow-1 shadow-sm" 
        {if $trajet.statut_visuel == 'termine' || $trajet.statut_visuel == 'annule'}
            disabled style="opacity:0.5; cursor:not-allowed;"
        {/if}>
        Modifier
    </button>
    
    {* On affiche le bouton seulement si le trajet n'est ni fini, ni déjà annulé *}
    {if $trajet.statut_visuel != 'termine' && $trajet.statut_visuel != 'annule'}
        <form action="/sae-covoiturage/public/trajet/annuler" method="POST" class="flex-grow-1" onsubmit="return confirm('⚠️ ATTENTION !\n\nÊtes-vous sûr de vouloir ANNULER ce trajet ?\n\n- Les réservations seront annulées.\n- Les passagers seront avertis.\n- Cette action est irréversible.');">
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

        {* SECTION 2 : HISTORIQUE (TERMINÉS & ANNULÉS) *}
        {if !empty($trajets_archives)}
            <div class="mt-5 mb-4">
                <h3 class="text-white-50 mb-4 ps-2 border-start border-4 border-secondary">
                    Historique
                </h3>

                {foreach $trajets_archives as $trajet}
                    <div style="opacity: 0.8;"> <div class="card border-0 rounded-5 mb-4 card-trajet p-4">
                
                            <div class="d-flex justify-content-between align-items-center mb-3 pb-2 border-bottom border-light-subtle">
                                <div class="d-flex align-items-center gap-3">
                                    <span class="badge bg-{$trajet.statut_couleur} bg-opacity-10 text-{$trajet.statut_couleur} border border-{$trajet.statut_couleur} rounded-pill px-3 py-2">
                                        {if $trajet.statut_visuel == 'avenir'}<i class="bi bi-calendar-event me-2"></i>
                                        {elseif $trajet.statut_visuel == 'encours'}<i class="bi bi-car-front-fill me-2"></i>
                                        {elseif $trajet.statut_visuel == 'annule'}<i class="bi bi-x-circle-fill me-2"></i>
                                        {else}<i class="bi bi-check-circle-fill me-2"></i>{/if}
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
                                
                                <div class="col-md-6 pe-md-4 d-flex flex-column border-end-md border-secondary-subtle">
                                    
                                    <div class="mb-3">
                                        <h3 class="fw-bold mb-3 text-dark">Trajet prévu</h3>
                                        
                                        <p class="fs-5 mb-1 text-dark">le <strong>{$trajet.date_fmt}</strong></p>
                                        
                                        <div class="my-3 text-dark">
                                            <div class="fs-5">
                                                {if $trajet.rue_depart}{$trajet.rue_depart}, {/if}{$trajet.ville_depart}
                                            </div>
                                            
                                            <div class="fs-5 fw-bold text-purple my-1 ps-2">
                                                <i class="bi bi-arrow-down"></i>
                                            </div>
                                            
                                            <div class="fs-5">
                                                {if $trajet.rue_arrivee}{$trajet.rue_arrivee}, {/if}{$trajet.ville_arrivee}
                                            </div>
                                        </div>
    
                                        <p class="fs-5 mb-1 text-dark">Départ : <strong>{$trajet.heure_fmt}</strong></p>
                                        <p class="mb-0 text-dark">Durée estimée : {$trajet.duree_fmt}</p>
                                    </div>
    
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
                                                    <button class="btn btn-sm btn-dark-purple rounded-pill px-3">Signaler</button>
                                                </div>
                                            {/foreach}
                                        {else}
                                            <div class="d-flex align-items-center gap-2 text-muted fst-italic">
                                                <i class="bi bi-info-circle"></i> Aucun passager pour l'instant
                                            </div>
                                        {/if}
                                    </div>
                                </div>
    
                                <div class="col-md-6 ps-md-4 d-flex flex-column justify-content-between mt-4 mt-md-0">
                                    
                                    <div>
                                        <h3 class="fw-bold mb-3 text-dark">Informations véhicule</h3>
                                        <p class="fs-5 mb-1 text-dark">
                                            <strong>{$trajet.places_restantes}</strong> places disponibles
                                        </p>
                                        <p class="fs-5 text-dark">
                                            {$trajet.marque} {$trajet.modele}
                                        </p>
    
                                        <h3 class="fw-bold mt-4 mb-2 text-dark">Réservation</h3>
                                        <p class="fs-5 text-dark">
                                            <strong>{$trajet.places_prises}</strong> places réservées
                                        </p>
                                    </div>
    
                                    <div class="d-flex flex-column gap-2 mt-4">
                                        <a href="/sae-covoiturage/public/messagerie/conversation/{$trajet.id_trajet}" 
                                           class="btn btn-purple-action fw-bold py-2 w-100 shadow-sm text-decoration-none text-center">
                                            Discussion de groupe
                                        </a>
                                        
                                        <div class="d-flex gap-2">
                                            
                                            <button class="btn btn-purple-action fw-bold py-2 flex-grow-1 shadow-sm" 
                                                {if $trajet.statut_visuel == 'termine' || $trajet.statut_visuel == 'annule'}
                                                    disabled style="opacity:0.5; cursor:not-allowed;"
                                                {/if}>
                                                Modifier
                                            </button>
                                            
                                            <form action="/sae-covoiturage/public/trajet/supprimer" method="POST" class="flex-grow-1" onsubmit="return confirm('Êtes-vous sûr de vouloir supprimer ce trajet ?');">
                                                <input type="hidden" name="id_trajet" value="{$trajet.id_trajet}">
                                                
                                                <button type="submit" class="btn btn-purple-action fw-bold py-2 w-100 shadow-sm" 
                                                    {if $trajet.statut_visuel == 'termine' || $trajet.statut_visuel == 'annule'}
                                                        disabled style="opacity:0.5; cursor:not-allowed;"
                                                    {/if}>
                                                    Supprimer
                                                </button>
                                            </form>
    
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                {/foreach}
            </div>
        {/if}

    {/if}
</div>

{include file='includes/footer.tpl'}