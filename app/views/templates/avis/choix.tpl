{include file='includes/header.tpl'}

{* Conteneur principal centré pour la sélection de la personne à noter *}
<div class="container mt-5" style="max-width: 600px;">
    
    <h2 class="fw-bold mb-4 text-center">Qui voulez-vous noter ?</h2>
    
    {* Liste des participants (Conducteur + Passagers) *}
    <div class="list-group shadow-sm rounded-4">
        {foreach $participants as $p}
        {* Lien cliquable vers le formulaire d'avis pour ce participant spécifique *}
        <a href="/sae-covoiturage/public/avis/laisser/{$id_trajet}/{$p.id}" class="list-group-item list-group-item-action p-3 d-flex align-items-center justify-content-between">
            
            <div class="d-flex align-items-center gap-3">
                {* Affichage de la photo de profil *}
                <img src="/sae-covoiturage/public/uploads/{$p.photo}" class="rounded-circle" width="50" height="50" style="object-fit:cover;">
                
                {* Informations de l'utilisateur (Nom + Badge de rôle) *}
                <div>
                    <h5 class="mb-0 fw-bold">{$p.nom}</h5>
                    {* Badge dynamique indiquant si c'est le conducteur ou un passager *}
                    <span class="badge bg-{$p.role_color}">{$p.role_badge}</span>
                </div>
            </div>
            
            {* Icône indiquant la navigation *}
            <i class="bi bi-chevron-right text-muted"></i>
        </a>
        {/foreach}
    </div>
    
    {* Option secondaire pour ignorer l'étape de notation et retourner à la messagerie *}
    <div class="text-center mt-4">
        <a href="/sae-covoiturage/public/messagerie" class="text-muted text-decoration-none">Passer pour le moment</a>
    </div>
</div>

{include file='includes/footer.tpl'}