{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/messagerie/style_liste.css">

<div class="container my-4" style="max-width: 800px;">
    <h2 class="fw-bold text-center text-purple mb-4">Mes Discussions</h2>

    <ul class="nav nav-pills nav-fill mb-4 p-1 bg-light rounded-pill shadow-sm" id="msgTabs" role="tablist">
        
        <li class="nav-item" role="presentation">
            <button class="nav-link rounded-pill active fw-bold position-relative" id="encours-tab" data-bs-toggle="pill" data-bs-target="#encours" type="button">
                En cours
                {if $notifs.encours > 0}
                    <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                        {$notifs.encours}
                    </span>
                {/if}
            </button>
        </li>

        <li class="nav-item" role="presentation">
            <button class="nav-link rounded-pill fw-bold position-relative" id="avenir-tab" data-bs-toggle="pill" data-bs-target="#avenir" type="button">
                À venir
                {if $notifs.avenir > 0}
                    <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                        {$notifs.avenir}
                    </span>
                {/if}
            </button>
        </li>

        <li class="nav-item" role="presentation">
            <button class="nav-link rounded-pill fw-bold position-relative" id="termine-tab" data-bs-toggle="pill" data-bs-target="#termine" type="button">
                Terminé
                {if $notifs.termine > 0}
                    <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                        {$notifs.termine}
                    </span>
                {/if}
            </button>
        </li>
    </ul>

    <div class="tab-content" id="msgTabsContent">
        
        <div class="tab-pane fade show active" id="encours" role="tabpanel">
            {call name=displayList list=$groupes.encours emptyMsg="Aucun trajet en cours."}
        </div>

        <div class="tab-pane fade" id="avenir" role="tabpanel">
            {call name=displayList list=$groupes.avenir emptyMsg="Aucun trajet à venir."}
        </div>

        <div class="tab-pane fade" id="termine" role="tabpanel">
            {call name=displayList list=$groupes.termine emptyMsg="Historique vide."}
        </div>

    </div>
</div>

{* --- FONCTION SMARTY POUR AFFICHER UNE LISTE --- *}
{function name=displayList}
    <div class="d-flex flex-column gap-3">
        {if empty($list)}
            <div class="text-center py-5 text-muted">
                <i class="bi bi-chat-square-dots display-1 d-block mb-3 opacity-25"></i>
                <p class="fs-5">{$emptyMsg}</p>
                <a href="/sae-covoiturage/public/recherche" class="btn btn-sm btn-outline-purple rounded-pill mt-2">Rechercher un trajet</a>
            </div>
        {else}
            {foreach $list as $conv}
            <a href="/sae-covoiturage/public/messagerie/conversation/{$conv.id_trajet}" class="text-decoration-none text-dark">
                <div class="card border-0 shadow-sm hover-shadow transition-all">
                    <div class="card-body d-flex align-items-center p-3">
                        
                        <div class="rounded-circle p-3 me-3 d-flex align-items-center justify-content-center flex-shrink-0" 
                             style="width: 50px; height: 50px; background-color: #f3f0ff;">
                            <i class="bi bi-car-front-fill text-purple fs-4"></i>
                        </div>

                        <div class="flex-grow-1 overflow-hidden">
                            <div class="d-flex justify-content-between align-items-start">
                                <h6 class="fw-bold mb-1 text-truncate pe-2">
                                    {$conv.ville_depart} <i class="bi bi-arrow-right-short text-muted"></i> {$conv.ville_arrivee}
                                </h6>
                                {if $conv.nb_non_lus > 0}
                                    <span class="badge bg-danger rounded-pill">{$conv.nb_non_lus}</span>
                                {else}
                                    <i class="bi bi-chevron-right text-muted small"></i>
                                {/if}
                            </div>

                            <div class="mb-1 d-flex align-items-center">
                                <span class="badge bg-{$conv.statut_couleur} bg-opacity-10 text-{$conv.statut_couleur} border border-{$conv.statut_couleur} rounded-pill px-2 py-0 small">
                                    {if $conv.statut_visuel == 'avenir'}<i class="bi bi-clock me-1"></i>
                                    {elseif $conv.statut_visuel == 'encours'}<i class="bi bi-car-front-fill me-1"></i>
                                    {else}<i class="bi bi-check-circle-fill me-1"></i>{/if}
                                    {$conv.statut_libelle}
                                </span>

                                {if $conv.statut_visuel == 'encours' && isset($conv.temps_restant)}
                                    <span class="ms-2 text-success small fw-bold">
                                        <i class="bi bi-hourglass-split"></i> Arrivée dans {$conv.temps_restant}
                                    </span>
                                {/if}
                            </div>

                            <div class="small text-muted text-truncate">
                                
                                {if $conv.dernier_message}
                                    {* --- GESTION DES MESSAGES SYSTÈME --- *}
                                    
                                    {* 1. Trajet Rejoint *}
                                    {if $conv.dernier_message == '::sys_join::'}
                                        <em class="fst-italic"><i class="bi bi-person-plus"></i> Un utilisateur a rejoint le trajet</em>
                                    
                                    {* 2. Trajet Quitté *}
                                    {elseif $conv.dernier_message == '::sys_leave::'}
                                        <em class="fst-italic"><i class="bi bi-person-dash"></i> Un utilisateur a quitté le trajet</em>
                                    
                                    {* 3. Trajet Terminé *}
                                    {elseif $conv.dernier_message == '::sys_end::'}
                                        <strong class="text-purple"><i class="bi bi-flag-fill"></i> Trajet terminé</strong>
                                    
                                    {* 4. Trajet Annulé (Correction : syntaxe modifier Smarty) *}
                                    {elseif $conv.dernier_message|replace:'::sys_cancel::':'' != $conv.dernier_message}
                                        <strong class="text-danger"><i class="bi bi-x-circle-fill"></i> Le trajet a été annulé</strong>

                                    {* 5. Message Classique (Texte Utilisateur) *}
                                    {else}
                                        {if $conv.conducteur_prenom}
                                            <span class="fw-semibold">{$conv.conducteur_prenom}</span> : 
                                        {/if}
                                        {$conv.dernier_message|replace:'::sys_create::':''|truncate:50:"..."}
                                    {/if}
                                    
                                    <span class="text-muted ms-1 small">• {$conv.date_tri|date_format:"%d/%m %H:%M"}</span>
                                
                                {else}
                                    <em class="text-muted fst-italic">Nouvelle discussion</em>
                                {/if}
                                
                            </div>
                        </div>

                    </div>
                </div>
            </a>
            {/foreach}
        {/if}
    </div>
{/function}



{* --- SCRIPT POUR ACTIVER LE BON ONGLET AU RETOUR --- *}
<script>
document.addEventListener("DOMContentLoaded", function() {
    // Si l'URL contient une ancre (ex: #avenir)
    if(window.location.hash) {
        // On cherche le bouton qui cible cet ID (ex: data-bs-target="#avenir")
        var trigger = document.querySelector('button[data-bs-target="' + window.location.hash + '"]');
        // Si on le trouve, on simule un clic dessus pour changer l'onglet
        if(trigger) {
            trigger.click();
        }
    }
});
</script>

{include file='includes/footer.tpl'}