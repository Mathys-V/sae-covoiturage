{include file='includes/header.tpl'}

<div class="container mt-5 mb-5 flex-grow-1">
    <div class="row justify-content-center">
        <div class="col-md-8">
            
            {* En-tête de la page avec bouton retour vers le profil *}
            <div class="d-flex align-items-center mb-4">
                <a href="/sae-covoiturage/public/profil" class="text-decoration-none text-secondary me-3">
                    <i class="bi bi-arrow-left fs-4"></i>
                </a>
                <h2 class="fw-bold mb-0 text-dark">Mes signalements</h2>
            </div>

            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div class="card-body p-0">
                    
                    {* Cas : Aucun signalement effectué par l'utilisateur *}
                    {if empty($signalements)}
                        <div class="text-center py-5">
                            <i class="bi bi-shield-check display-1 text-success opacity-50 mb-3"></i>
                            <h4 class="fw-bold">Aucun signalement</h4>
                            <p class="text-muted">Vous n'avez effectué aucun signalement pour le moment.</p>
                        </div>
                    
                    {* Cas : Affichage de la liste des signalements *}
                    {else}
                        <div class="list-group list-group-flush">
                            {foreach $signalements as $sig}
                                <div class="list-group-item p-4 border-bottom">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <div>
                                            {* Badge de statut du signalement (En attente, Traité, Clôturé) *}
                                            <span class="badge {if $sig.statut_code == 'E'}bg-warning text-dark{elseif $sig.statut_code == 'T'}bg-success{else}bg-secondary{/if} mb-2">
                                                {if $sig.statut_code == 'E'}En attente{elseif $sig.statut_code == 'T'}Traité{else}Clôturé{/if}
                                            </span>
                                            <h5 class="fw-bold mb-1">Signalement #{$sig.id_signalement}</h5>
                                            <small class="text-muted">Le {$sig.date_signalement|date_format:"%d/%m/%Y à %Hh%M"}</small>
                                        </div>
                                        <div class="text-end">
                                            <div class="fw-bold text-danger">{$sig.motif}</div>
                                        </div>
                                    </div>
                                    
                                    {* Détails du signalement (Utilisateur concerné, Trajet, Commentaire) *}
                                    <div class="bg-light p-3 rounded-3 mt-3">
                                        <div class="d-flex align-items-center mb-2">
                                            <i class="bi bi-person-exclamation me-2 text-secondary"></i>
                                            <strong>Utilisateur signalé :</strong> 
                                            <span class="ms-2">{$sig.nom_signale} {$sig.prenom_signale}</span>
                                        </div>
                                        
                                        {if $sig.ville_depart}
                                        <div class="d-flex align-items-center mb-2">
                                            <i class="bi bi-car-front me-2 text-secondary"></i>
                                            <strong>Trajet concerné :</strong> 
                                            <span class="ms-2">{$sig.ville_depart} → {$sig.ville_arrivee}</span>
                                        </div>
                                        {/if}
                                        
                                        <div class="mt-3 pt-3 border-top border-white">
                                            <p class="mb-0 text-secondary fst-italic">"{$sig.description}"</p>
                                        </div>
                                    </div>
                                </div>
                            {/foreach}
                        </div>
                    {/if}
                </div>
            </div>

        </div>
    </div>
</div>

{include file='includes/footer.tpl'}