{include file='includes/header.tpl'}

{* Inclusion de la feuille de style spécifique à la page des avis *}
<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/avis/style_avis.css">

<div class="page-wrapper">

    <main class="container my-5" style="max-width: 900px;">

        {* En-tête : Bouton retour vers le profil et titre *}
        <div class="d-flex align-items-center mb-4">
            <a href="/sae-covoiturage/public/profil" class="btn btn-outline-secondary me-3">
                <i class="bi bi-arrow-left"></i> Retour
            </a>
            <h2 class="fw-bold mb-0">Avis reçus</h2>
        </div>

        {* Système d'onglets personnalisés pour basculer entre avis Conducteur et Passager *}
        <div class="custom-tabs">
            <button class="tab-btn active" onclick="switchTab('cond')" id="btn-cond">
                <i class="bi bi-person-badge-fill d-block fs-3 mb-1"></i>
                Conducteur
            </button>
            <button class="tab-btn" onclick="switchTab('pass')" id="btn-pass">
                <i class="bi bi-person-fill d-block fs-3 mb-1"></i>
                Passager
            </button>
        </div>

        <div class="content-box">

            {* --- ONGLET CONDUCTEUR --- *}
            <div id="view-cond">
                {* Affichage de la note moyenne et du nombre total d'avis *}
                <div class="text-center mb-5">
                    <div class="display-4 fw-bold text-primary">{$moy_cond}<span class="fs-4 text-muted">/5</span></div>
                    <div class="text-warning fs-3 mb-2">
                        {* Boucle pour afficher les étoiles pleines ou vides selon la note *}
                        {section name=i loop=5}
                            {if $smarty.section.i.index < $moy_cond}<i class="bi bi-star-fill"></i>{else}<i class="bi bi-star"></i>{/if}
                        {/section}
                    </div>
                    <div class="text-muted">Basé sur {$nb_cond} avis conducteur</div>
                </div>

                {* Liste des avis conducteur *}
                <div class="row g-3">
                    {if $nb_cond > 0}
                        {foreach from=$avis_cond item=avis}
                            <div class="col-12 col-md-6">
                                <div class="card p-3 border-0 shadow-sm h-100 bg-light">
                                    <div class="d-flex">
                                        <div class="me-3">
                                            {* Affichage de la photo de profil ou d'une image par défaut *}
                                            {if !empty($avis.photo_profil)}
                                                <img src="/sae-covoiturage/public/uploads/{$avis.photo_profil}"
                                                    class="rounded-circle"
                                                    style="width: 50px; height: 50px; object-fit: cover;">
                                            {else}
                                                <img src="/sae-covoiturage/public/assets/img/default.png" class="rounded-circle"
                                                    style="width: 50px; height: 50px; object-fit: cover;">
                                            {/if}
                                        </div>
                                        <div class="flex-grow-1">
                                            <div class="d-flex justify-content-between align-items-start">
                                                <h6 class="fw-bold mb-1">{$avis.prenom} {$avis.nom}</h6>
                                                <small class="text-muted">{$avis.date_avis|date_format:"%d/%m/%Y"}</small>
                                            </div>
                                            {* Affichage de la note individuelle en étoiles *}
                                            <div class="text-warning mb-2" style="font-size: 0.8rem;">
                                                {section name=star loop=5}
                                                    {if $smarty.section.star.index < $avis.note}<i class="bi bi-star-fill"></i>{else}<i class="bi bi-star"></i>{/if}
                                                {/section}
                                            </div>
                                            <p class="mb-0 text-secondary small">{$avis.commentaire|nl2br}</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        {/foreach}
                    {else}
                        {* Message si aucun avis conducteur *}
                        <div class="col-12">
                            <div class="alert alert-light text-center border">
                                <i class="bi bi-car-front d-block fs-2 mb-2 text-muted"></i>
                                Aucun avis en tant que conducteur.
                            </div>
                        </div>
                    {/if}
                </div>
            </div>

            {* --- ONGLET PASSAGER (Masqué par défaut) --- *}
            <div id="view-pass" style="display: none;">
                {* Affichage de la note moyenne passager *}
                <div class="text-center mb-5">
                    <div class="display-4 fw-bold text-primary">{$moy_pass}<span class="fs-4 text-muted">/5</span></div>
                    <div class="text-warning fs-3 mb-2">
                        {section name=i loop=5}
                            {if $smarty.section.i.index < $moy_pass}<i class="bi bi-star-fill"></i>{else}<i class="bi bi-star"></i>{/if}
                        {/section}
                    </div>
                    <div class="text-muted">Basé sur {$nb_pass} avis passager</div>
                </div>

                {* Liste des avis passager *}
                <div class="row g-3">
                    {if $nb_pass > 0}
                        {foreach from=$avis_pass item=avis}
                            <div class="col-12 col-md-6">
                                <div class="card p-3 border-0 shadow-sm h-100 bg-light">
                                    <div class="d-flex">
                                        <div class="me-3">
                                            {if !empty($avis.photo_profil)}
                                                <img src="/sae-covoiturage/public/uploads/{$avis.photo_profil}"
                                                    class="rounded-circle"
                                                    style="width: 50px; height: 50px; object-fit: cover;">
                                            {else}
                                                <img src="/sae-covoiturage/public/assets/img/default.png" class="rounded-circle"
                                                    style="width: 50px; height: 50px; object-fit: cover;">
                                            {/if}
                                        </div>
                                        <div class="flex-grow-1">
                                            <div class="d-flex justify-content-between align-items-start">
                                                <h6 class="fw-bold mb-1">{$avis.prenom} {$avis.nom}</h6>
                                                <small class="text-muted">{$avis.date_avis|date_format:"%d/%m/%Y"}</small>
                                            </div>
                                            <div class="text-warning mb-2" style="font-size: 0.8rem;">
                                                {section name=star loop=5}
                                                    {if $smarty.section.star.index < $avis.note}<i class="bi bi-star-fill"></i>{else}<i class="bi bi-star"></i>{/if}
                                                {/section}
                                            </div>
                                            <p class="mb-0 text-secondary small">{$avis.commentaire|nl2br}</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        {/foreach}
                    {else}
                        {* Message si aucun avis passager *}
                        <div class="col-12">
                            <div class="alert alert-light text-center border">
                                <i class="bi bi-person-fill d-block fs-1 mb-3 text-secondary"></i>
                                Aucun avis en tant que passager.
                            </div>
                        </div>
                    {/if}
                </div>
            </div>

        </div>

    </main>
</div>

{include file='includes/footer.tpl'}

{* Inclusion du script JS pour gérer le basculement des onglets *}
<script src="/sae-covoiturage/public/assets/javascript/avis/js_avis.js"></script>