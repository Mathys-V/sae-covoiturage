{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/messagerie/liste.css">

<div class="container mt-5 mb-5 flex-grow-1">
    
    <div class="messagerie-container">
        <h1 class="page-title">Mes Discussions</h1>

        {if empty($conversations)}
            <div class="empty-state-box">
                <i class="bi bi-chat-square-dots text-muted display-1 mb-3"></i>
                <h4 class="text-dark">Aucune conversation</h4>
                <p class="text-muted mb-4">Rejoignez un trajet pour commencer à discuter !</p>
                <a href="/sae-covoiturage/public/recherche" class="btn btn-purple rounded-pill px-4">Rechercher un trajet</a>
            </div>
        {else}
            {foreach $conversations as $conv}
                <a href="/sae-covoiturage/public/messagerie/conversation/{$conv.id_trajet}" 
                   class="conversation-card {if $conv.nb_non_lus > 0}unread{/if}">
                    
                    <div class="conv-icon-box">
                        <i class="bi bi-car-front-fill"></i>
                    </div>
                    
                    <div class="conv-content">
                        <div class="conv-trajet-title">
                            {$conv.ville_depart} <i class="bi bi-arrow-right-short text-muted"></i> {$conv.ville_arrivee}
                        </div>
                        
                        <div class="conv-info">
                            <i class="bi bi-person"></i> {$conv.conducteur_prenom} {$conv.conducteur_nom} • 
                            {$conv.date_heure_depart|date_format:"%d/%m à %Hh%M"}
                        </div>

                        <div class="conv-last-msg {if $conv.nb_non_lus > 0}new{/if}">
                            {if $conv.dernier_message}
                                {if $conv.nb_non_lus > 0}<span class="text-danger me-1">●</span>{/if}
                                {$conv.dernier_message}
                            {else}
                                <em>Nouvelle conversation créée</em>
                            {/if}
                        </div>
                    </div>

                    {if $conv.nb_non_lus > 0}
                        <span class="badge-unread">{$conv.nb_non_lus}</span>
                    {/if}
                    <i class="bi bi-chevron-right chevron"></i>

                </a>
            {/foreach}
        {/if}
    </div>
</div>

{include file='includes/footer.tpl'}