document.addEventListener('DOMContentLoaded', function() {
    const messagesArea = document.getElementById('messagesArea');
    const chatForm = document.getElementById('chatForm');
    const messageInput = document.getElementById('messageInput');
    const trajetId = document.getElementById('trajetId').value;

    // Scroll automatique en bas
    function scrollToBottom() {
        if(messagesArea) messagesArea.scrollTop = messagesArea.scrollHeight;
    }
    scrollToBottom();

    // 1. ENVOI DE MESSAGE
    chatForm.addEventListener('submit', function(e) {
        e.preventDefault();
        const text = messageInput.value.trim();
        if(!text) return;

        // Désactiver le bouton pour éviter le double clic
        const btn = chatForm.querySelector('button[type="submit"]');
        btn.disabled = true;

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
                messageInput.value = ''; // Vider l'input
                location.reload();       // Recharger pour afficher le message
            } else {
                alert("Erreur lors de l'envoi");
                btn.disabled = false;
            }
        })
        .catch(err => {
            console.error(err);
            btn.disabled = false;
        });
    });

    // 2. GESTION SIGNALEMENT
    const btnSignaler = document.querySelector('.btn-report');
    const modalEl = document.getElementById('modalSignalement');
    
    // On vérifie si le bouton existe (il n'existe pas si pas de participants)
    if(btnSignaler && modalEl){
        const modal = new bootstrap.Modal(modalEl);
        const formSignalement = document.getElementById('formSignalement');

        btnSignaler.addEventListener('click', function() {
            modal.show();
        });

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
    }
});