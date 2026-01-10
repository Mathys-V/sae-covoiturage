{include file='includes/header.tpl'}

<div class="container my-5" style="max-width: 900px;">
    
    {* Bouton de retour (JavaScript) pour revenir à la page précédente (recherche ou trajet) *}
    <a href="javascript:history.back()" class="btn btn-sm btn-outline-secondary rounded-pill mb-4">
        <i class="bi bi-arrow-left"></i> Retour
    </a>

    <div class="row g-4">
        
        {* COLONNE GAUCHE : Carte d'identité du membre *}
        <div class="col-md-4">
            <div class="card border-0 shadow-sm text-center h-100">
                <div class="card-body p-4">
                    
                    {* Photo de profil (ou image par défaut) *}
                    <img src="/sae-covoiturage/public/uploads/{$membre.photo_profil|default:'default.png'}" 
                         alt="{$membre.prenom|default:'Membre'}" 
                         class="rounded-circle mb-3 shadow-sm object-fit-cover" 
                         style="width: 120px; height: 120px;">
                    
                    {* Nom et Prénom (Nom tronqué à l'initiale pour la confidentialité) *}
                    <h3 class="fw-bold text-purple mb-1">
                        {$membre.prenom|default:'Utilisateur'} {$membre.nom|default:''|substr:0:1}.
                    </h3>
                    <p class="text-muted small">Membre depuis {$membre.membre_depuis|default:'-'}</p>

                    <hr class="my-4 opacity-10">

                    {* Statistiques : Note en tant que Conducteur *}
                    <div class="d-flex justify-content-between text-start mb-2">
                        <span><i class="bi bi-steering-wheel text-purple"></i> Conducteur</span>
                        <span class="fw-bold">
                            {if isset($stats.conducteur.moyenne) && $stats.conducteur.moyenne}
                                <i class="bi bi-star-fill text-warning"></i> {$stats.conducteur.moyenne}/5
                                <small class="text-muted fw-normal">({$stats.conducteur.count})</small>
                            {else}
                                <span class="text-muted small">-</span>
                            {/if}
                        </span>
                    </div>

                    {* Statistiques : Note en tant que Passager *}
                    <div class="d-flex justify-content-between text-start">
                        <span><i class="bi bi-backpack text-purple"></i> Passager</span>
                        <span class="fw-bold">
                            {if isset($stats.passager.moyenne) && $stats.passager.moyenne}
                                <i class="bi bi-star-fill text-warning"></i> {$stats.passager.moyenne}/5
                                <small class="text-muted fw-normal">({$stats.passager.count})</small>
                            {else}
                                <span class="text-muted small">-</span>
                            {/if}
                        </span>
                    </div>
                </div>
            </div>
        </div>

        {* COLONNE DROITE : Biographie et Liste des avis *}
        <div class="col-md-8">
            
            {* Section Biographie *}
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-body p-4">
                    <h5 class="fw-bold mb-3">À propos de {$membre.prenom|default:'ce membre'}</h5>
                    {if isset($membre.bio) && $membre.bio}
                        {* nl2br permet de conserver les sauts de ligne saisis par l'utilisateur *}
                        <p class="text-muted mb-0">{$membre.bio|nl2br}</p>
                    {else}
                        <p class="text-muted fst-italic mb-0">Aucune description renseignée.</p>
                    {/if}
                </div>
            </div>

            <h5 class="fw-bold mb-3">Avis reçus ({$avis_list|count})</h5>
            
            {* Liste des avis *}
            {if $avis_list && $avis_list|count > 0}
                <div class="d-flex flex-column gap-3">
                    {foreach from=$avis_list item=avis}
                        <div class="card border-0 shadow-sm">
                            <div class="card-body p-3">
                                <div class="d-flex justify-content-between align-items-start">
                                    
                                    {* Auteur de l'avis *}
                                    <div class="d-flex align-items-center">
                                        <img src="/sae-covoiturage/public/uploads/{$avis.auteur_photo|default:'default.png'}" 
                                             class="rounded-circle me-3 object-fit-cover" 
                                             style="width: 40px; height: 40px;" alt="Auteur">
                                        <div>
                                            <h6 class="mb-0 fw-bold">
                                                {$avis.auteur_prenom|default:'Anonyme'} {$avis.auteur_nom|default:''|substr:0:1}.
                                            </h6>
                                            <small class="text-muted">{$avis.date_avis|date_format:"%d/%m/%Y"}</small>
                                        </div>
                                    </div>
                                    
                                    {* Affichage des étoiles (Boucle basée sur la note) *}
                                    <div class="text-warning">
                                        {section name=star loop=$avis.note}
                                            <i class="bi bi-star-fill"></i>
                                        {/section}
                                    </div>
                                </div>
                                
                                {* Commentaire *}
                                <p class="mt-2 mb-0 text-dark">{$avis.commentaire|default:''}</p>
                                
                                {* Badge indiquant le rôle lors du trajet (Conducteur ou Passager) *}
                                <span class="badge bg-light text-muted mt-2 border">
                                    {if isset($avis.id_conducteur) && $avis.id_conducteur == $membre.id_utilisateur}
                                        En tant que Conducteur
                                    {else}
                                        En tant que Passager
                                    {/if}
                                </span>
                            </div>
                        </div>
                    {/foreach}
                </div>
            {else}
                {* Message si aucun avis *}
                <div class="alert alert-light text-center text-muted border-0 shadow-sm">
                    Aucun avis pour le moment.
                </div>
            {/if}
        </div>
    </div>
</div>

{* Styles spécifiques minimalistes pour cette page *}
<style>
.text-purple { color: #6f42c1; }
</style>

{include file='includes/footer.tpl'}