{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/messagerie/chat.css">

<style>
    /* Zone de texte plus claire et "cliquable" */
    .custom-textarea {
        background-color: #f8f9fa;       /* Fond gris très léger */
        border: 2px solid #e9ecef;       /* Bordure visible mais douce */
        border-radius: 12px;             /* Coins arrondis */
        padding: 15px;                   /* Espace interne confortable */
        font-size: 0.95rem;
        color: #333;
        resize: none;                    /* Empêche de déformer la modale */
        transition: all 0.3s ease;       /* Animation fluide au clic */
        width: 100%;
    }

    /* Quand on clique dedans */
    .custom-textarea:focus {
        background-color: #ffffff;       /* Devient blanc */
        border-color: #8c52ff;           /* Bordure violette */
        box-shadow: 0 0 0 4px rgba(140, 82, 255, 0.15); /* Halo violet */
        outline: none;
    }

    /* Label au-dessus */
    .form-label-bold {
        font-weight: 700;
        color: #2c3e50;
        margin-bottom: 8px;
        display: block;
    }
</style>

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
                        {if $trajet.statut_visuel == 'avenir'}<i class="bi bi-clock"></i>
                        {elseif $trajet.statut_visuel == 'encours'}<i class="bi bi-car-front-fill"></i>
                        {else}<i class="bi bi-check-circle-fill"></i>{/if}
                        {$trajet.statut_libelle}
                    </span>
                    <span>{$trajet.date_fmt}</span>
                </div>
            </div>
        </div>
        
        <button class="btn btn-outline-danger btn-sm rounded-pill px-3 btn-report" title="Signaler un problème">
            <i class="bi bi-flag"></i> <span class="d-none d-md-inline ms-1">Signaler</span>
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
                    <div class="date-divider"><span>{$msg.date}</span></div>
                {elseif $msg.type == 'system'}
                    <div class="system-msg"><span>{$msg.text_affiche}</span></div>
                {else}
                    <div class="msg-row {if $msg.type == 'self'}self{else}other{/if}">
                        {if $msg.type != 'self'}<div class="msg-name">{$msg.nom_affiche}</div>{/if}
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
            <button type="submit" class="btn-send"><i class="bi bi-send-fill"></i></button>
        </form>
    </div>

</div>

<div class="modal fade" id="modalSignalement" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content rounded-4 border-0 shadow-lg">
      
      <div class="modal-header border-0 pb-0">
        <h5 class="modal-title fw-bold text-danger">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>Signaler ce trajet
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      
      <div class="modal-body p-4">
        <p class="text-muted small mb-4">Merci de nous indiquer la raison de ce signalement. Un modérateur examinera la situation rapidement.</p>
        
        <form id="formSignalement">
            
            <div class="mb-3">
                <label class="form-label-bold">Qui concerne ce signalement ?</label>
                <select class="form-select bg-light border-0 py-2" id="userSignalement" required>
                    <option value="" selected disabled>Choisir un utilisateur...</option>
                    {foreach $participants as $p}
                        <option value="{$p.id}">{$p.nom} ({$p.role})</option>
                    {/foreach}
                </select>
            </div>

            <div class="mb-3">
                <label class="form-label-bold">Motif</label>
                <select class="form-select bg-light border-0 py-2" id="motifSignalement" required>
                    <option value="" selected disabled>Choisir un motif...</option>
                    <option value="Comportement dangereux">Comportement dangereux</option>
                    <option value="Absence au rendez-vous">Absence au rendez-vous</option>
                    <option value="Véhicule non conforme">Véhicule non conforme</option>
                    <option value="Propos inappropriés">Propos inappropriés (Chat)</option>
                    <option value="Autre">Autre</option>
                </select>
            </div>

            <div class="mb-4">
                <label class="form-label-bold">Détails supplémentaires</label>
                <textarea class="custom-textarea" id="detailsSignalement" rows="4" placeholder="Décrivez la situation ici..."></textarea>
            </div>

            <div class="d-grid gap-2">
                <button type="submit" class="btn btn-danger rounded-pill fw-bold py-2">Envoyer le signalement</button>
                <button type="button" class="btn btn-light rounded-pill text-muted" data-bs-dismiss="modal">Annuler</button>
            </div>
        </form>
      </div>

    </div>
  </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const messagesArea = document.getElementById('messagesArea');
    const chatForm = document.getElementById('chatForm');
    const messageInput = document.getElementById('messageInput');
    const trajetId = document.getElementById('trajetId').value;

    function scrollToBottom() {
        if(messagesArea) messagesArea.scrollTop = messagesArea.scrollHeight;
    }
    scrollToBottom();

    // ENVOI MESSAGE
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
            if(data.success) location.reload();
            else alert("Erreur lors de l'envoi");
        });
    });

    // GESTION SIGNALEMENT
    const btnSignaler = document.querySelector('.btn-report');
    const modalEl = document.getElementById('modalSignalement');
    const modal = new bootstrap.Modal(modalEl);
    const formSignalement = document.getElementById('formSignalement');

    if(btnSignaler){
        btnSignaler.addEventListener('click', function() {
            modal.show();
        });
    }

    formSignalement.addEventListener('submit', function(e) {
        e.preventDefault();
        const user = document.getElementById('userSignalement').value;
        const motif = document.getElementById('motifSignalement').value;
        const details = document.getElementById('detailsSignalement').value;

        if(!user || !motif) {
            alert("Veuillez remplir tous les champs obligatoires.");
            return;
        }

        fetch('/sae-covoiturage/public/api/signalement/nouveau', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                id_trajet: trajetId,
                id_signale: user,
                motif: motif,
                description: details
            })
        })
        .then(response => response.json())
        .then(data => {
            modal.hide();
            if(data.success) {
                alert("Signalement envoyé. Merci de votre vigilance.");
                formSignalement.reset();
            } else {
                alert("Erreur : " + (data.msg || "Impossible d'envoyer"));
            }
        });
    });
});
</script>

{include file='includes/footer.tpl'}