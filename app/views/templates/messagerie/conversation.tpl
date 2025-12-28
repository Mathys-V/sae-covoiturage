{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/messagerie/style.css">

<div class="container mt-4 mb-5">
    
    <h1 class="page-title">Message</h1>

    <div class="chat-container">
        
        <div class="chat-header">
            <div class="trajet-info">
                <div class="trajet-icon shadow-sm">
                    <img src="/sae-covoiturage/public/assets/img/icons/group-icon.png" alt="Groupe" style="width:30px;"> 
                    </div>
                <div>
                    <h4 class="m-0 fw-bold text-dark">Trajet {$trajet.ville_depart} - {$trajet.ville_arrivee}</h4>
                    <small class="text-muted">{$trajet.date_fmt}</small>
                </div>
            </div>
            <button class="btn-signaler">Signaler</button>
        </div>

        <div class="messages-area" id="messagesArea">

            <div class="message-wrapper msg-other">
                <span class="sender-name">Julien LEGER</span>
                <div class="message-bubble">
                    Bonjour c'est toujours bon pour jeudi ?
                </div>
                <span class="message-time">le 23/11/2025 à 20:45</span>
            </div>

            <div class="message-wrapper msg-self">
                <span class="sender-name">Jules tambour - Conducteur</span>
                <div class="message-bubble">
                    Oui, tout est bon pour jeudi
                </div>
                <span class="message-time">le 23/11/2025 à 20:47</span>
            </div>

            <div class="date-separator">
                <span>24/11/2025</span>
            </div>

            <div class="message-wrapper msg-other">
                <span class="sender-name">Julien LEGER</span>
                <div class="message-bubble">
                    Je ne vous vois pas. Vous êtes arrivé ?
                </div>
                <span class="message-time">12:30</span>
            </div>

            <div class="message-wrapper msg-self">
                <span class="sender-name">Jules tambour - Conducteur</span>
                <div class="message-bubble">
                    Oui je suis sur le parking de droite
                </div>
                <span class="message-time">12:33</span>
            </div>
            
            <div class="message-wrapper msg-other">
                <span class="sender-name">Alice Raux</span>
                <div class="message-bubble">
                    J'arrive
                </div>
                <span class="message-time">12:34</span>
            </div>

             <div class="message-wrapper msg-self">
                <span class="sender-name">Jules tambour - Conducteur</span>
                <div class="message-bubble">
                    Je vous vois au loin, je suis sur votre gauche
                </div>
                <span class="message-time">12:34</span>
            </div>

        </div>

        <form id="chatForm" class="mt-auto">
            <div class="input-area">
                <input type="text" id="messageInput" placeholder="Écrivez votre message..." required autocomplete="off">
                <input type="hidden" id="trajetId" value="{$trajet.id_trajet}">
                <button type="submit" class="btn-send">Envoyer</button>
            </div>
        </form>

    </div>
</div>

<script src="/sae-covoiturage/public/assets/js/messagerie/chat.js"></script>

{include file='includes/footer.tpl'}