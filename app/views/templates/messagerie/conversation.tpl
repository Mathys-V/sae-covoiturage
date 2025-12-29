{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/messagerie/chat.css">

<div class="chat-wrapper">
    
    <div class="chat-header">
        <div class="d-flex align-items-center" style="max-width: 70%;">
            <a href="/sae-covoiturage/public/messagerie" class="btn-back">
                <i class="bi bi-arrow-left"></i>
            </a>
            <div class="text-truncate">
                <h2 class="chat-header-title text-truncate">{$trajet.ville_depart} → {$trajet.ville_arrivee}</h2>
                <div class="chat-header-date d-flex align-items-center gap-2">
                    <span class="badge bg-{$trajet.statut_couleur} bg-opacity-10 text-{$trajet.statut_couleur} border border-{$trajet.statut_couleur} rounded-pill px-2">
                        {if $trajet.statut_visuel == 'avenir'}
                            <i class="bi bi-clock"></i>
                        {elseif $trajet.statut_visuel == 'complet'}
                            <i class="bi bi-people-fill"></i> {elseif $trajet.statut_visuel == 'encours'}
                            <i class="bi bi-car-front-fill"></i>
                        {else}
                            <i class="bi bi-check-circle-fill"></i>
                        {/if}
                        {$trajet.statut_libelle}
                    </span>
                    <span>{$trajet.date_fmt}</span>
                </div>
            </div>
        </div>
        
        <button class="btn btn-outline-danger btn-sm rounded-pill px-3" title="Signaler un problème">
            <i class="bi bi-flag"></i> <span class="d-none d-md-inline">Signaler</span>
        </button>
    </div>

    <div class="messages-container" id="messagesArea">
        
        {if empty($messages)}
            <div class="text-center my-auto opacity-50">
                <i class="bi bi-chat-heart display-4 text-purple"></i>
                <p class="mt-3 fw-bold">La conversation commence ici.</p>
                <p class="small">Dites bonjour à votre groupe de covoiturage !</p>
            </div>
        {else}
            {foreach $messages as $msg}
                {if $msg.type == 'separator'}
                    <div class="date-divider">
                        <span>{$msg.date}</span>
                    </div>
                
                {elseif $msg.type == 'system'}
                    <div class="system-msg">
                        <span>{$msg.text_affiche}</span>
                    </div>

                {else}
                    <div class="msg-row {if $msg.type == 'self'}self{else}other{/if}">
                        {if $msg.type != 'self'}
                            <div class="msg-name">{$msg.nom_affiche}</div>
                        {/if}
                        <div class="msg-bubble">
                            {$msg.contenu|escape:'html'|nl2br}
                            <span class="msg-time">{$msg.heure_fmt}</span>
                        </div>
                    </div>
                {/if}
            {/foreach}
        {/if}

    </div>

    <div class="chat-footer">
        <form id="chatForm" class="input-group-chat">
            <input type="text" id="messageInput" class="chat-input" placeholder="Écrivez votre message..." required autocomplete="off">
            <input type="hidden" id="trajetId" value="{$trajet.id_trajet}">
            
            <button type="submit" class="btn-send">
                <i class="bi bi-send-fill"></i>
            </button>
        </form>
    </div>

</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const messagesArea = document.getElementById('messagesArea');
    const chatForm = document.getElementById('chatForm');
    const messageInput = document.getElementById('messageInput');
    const trajetId = document.getElementById('trajetId').value;

    function scrollToBottom() {
        if(messagesArea) {
            messagesArea.scrollTop = messagesArea.scrollHeight;
        }
    }
    scrollToBottom();

    chatForm.addEventListener('submit', function(e) {
        e.preventDefault();
        const text = messageInput.value.trim();
        if(!text) return;

        fetch('/sae-covoiturage/public/api/messagerie/send', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                trajet_id: trajetId,
                message: text
            })
        })
        .then(response => response.json())
        .then(data => {
            if(data.success) {
                location.reload(); 
            } else {
                alert("Erreur lors de l'envoi");
            }
        });
    });
});
</script>

{include file='includes/footer.tpl'}