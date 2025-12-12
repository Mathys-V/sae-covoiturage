{include file='includes/header.tpl'}

<div class="container mt-4 mb-5 flex-grow-1">
    <div class="row">
        <div class="col-12">
            <h1 class="text-white text-center mb-5" style="font-family: 'Garet', sans-serif;">Mes Trajets</h1>
        </div>
    </div>

    {if empty($trajets)}
        <div class="text-center text-white">
            <p class="fs-4">Vous n'avez aucun trajet prévu pour le moment.</p>
            <a href="/sae-covoiturage/public/trajet/nouveau" class="btn btn-light fw-bold text-purple mt-3 px-4 py-2 rounded-pill">Proposer un trajet</a>
        </div>
    {else}
        {foreach $trajets as $trajet}
            <div class="card border-0 rounded-5 mb-4 card-trajet p-4">
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
                                {foreach $trajet.passagers as $passager}
                                    <div class="d-flex align-items-center justify-content-between mb-2">
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="rounded-circle bg-secondary-subtle d-flex align-items-center justify-content-center" style="width: 40px; height: 40px; overflow: hidden;">
                                                 <img src="/sae-covoiturage/public/assets/uploads/{$passager.photo_profil|default:'default.png'}" alt="Avatar" style="width: 100%; height: 100%; object-fit: cover;">
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
                            <h3 class="fw-bold mb-3 text-dark">Informations vehicule</h3>
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
                            <button class="btn btn-purple-action fw-bold py-2 w-100 shadow-sm">
                                Discussion de groupe
                            </button>
                            
                            <div class="d-flex gap-2">
                                <button class="btn btn-purple-action fw-bold py-2 flex-grow-1 shadow-sm">
                                    Modifier
                                </button>
                                <button class="btn btn-purple-action fw-bold py-2 flex-grow-1 shadow-sm">
                                    Supprimer
                                </button>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
            {/foreach}
    {/if}
</div>

<style>
    /* Fond de la page */
    body {
        background-color: #452b85;
        min-height: 100vh;
    }

    /* Style de la carte (Violet clair) */
    .card-trajet {
        background-color: #E6E0F8; 
        color: #2c2c2c;
        box-shadow: 0 4px 20px rgba(0,0,0,0.15);
    }

    /* Couleur violette pour les titres et éléments forts */
    .text-purple {
        color: #8c52ff;
    }

    /* Trait de séparation vertical (visible seulement sur PC) */
    @media (min-width: 768px) {
        .border-end-md {
            border-right: 1px solid rgba(0,0,0,0.1); 
        }
    }

    /* BOUTONS VIOLETS CLAIRS (Gros boutons) */
    .btn-purple-action {
        background-color: #8c52ff;
        color: white;
        border: none;
        border-radius: 50px; /* Pill shape */
        font-size: 1.2rem;
        transition: transform 0.2s, background-color 0.2s;
    }

    .btn-purple-action:hover {
        background-color: #6f42c1;
        color: white;
        transform: scale(1.02);
    }

    /* BOUTON SIGNALER (Violet foncé) */
    .btn-dark-purple {
        background-color: #452b85;
        color: white;
        font-size: 0.85rem;
    }
    .btn-dark-purple:hover {
        background-color: #2a1a5e; /* Plus foncé au survol */
        color: white;
    }
</style>

{include file='includes/footer.tpl'}