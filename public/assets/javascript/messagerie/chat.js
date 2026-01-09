/*
 * Initialisation de l'interface de messagerie.
 * Dès que le DOM est chargé, on capture les références vers le formulaire et la zone d'affichage.
 * Une fonction utilitaire 'scrollToBottom' est définie et appelée immédiatement :
 * elle force la fenêtre de discussion à descendre tout en bas pour afficher les messages
 * les plus récents, ce qui est le comportement standard attendu sur une application de chat.
 */
document.addEventListener("DOMContentLoaded", function () {
    const chatForm = document.getElementById("chatForm");
    const messageInput = document.getElementById("messageInput");
    const messagesArea = document.getElementById("messagesArea");

    // Force le scroll en bas de la zone de discussion
    function scrollToBottom() {
        messagesArea.scrollTop = messagesArea.scrollHeight;
    }
    scrollToBottom();

    /*
     * Gestion de l'envoi de message (Côté Client).
     * On intercepte la soumission du formulaire pour éviter le rechargement de page.
     * Le script simule une "Optimistic UI" : on affiche le message instantanément pour l'utilisateur
     * sans attendre la confirmation du serveur. On construit dynamiquement le bloc HTML du message
     * avec l'heure actuelle, on l'injecte dans le DOM, puis on réinitialise le champ de saisie.
     */
    chatForm.addEventListener("submit", function (e) {
        e.preventDefault(); // Empêche le rechargement de la page

        const messageText = messageInput.value.trim();
        if (messageText === "") return;

        // Récupération de l'heure actuelle pour l'horodatage local
        const now = new Date();
        const timeString =
            now.getHours() +
            ":" +
            (now.getMinutes() < 10 ? "0" : "") +
            now.getMinutes();

        // Construction du template HTML pour le nouveau message
        // On utilise escapeHtml() pour sécuriser le contenu textuel
        const newMessageHtml = `
            <div class="message-wrapper msg-self">
                <span class="sender-name">Moi</span>
                <div class="message-bubble">
                    ${escapeHtml(messageText)}
                </div>
                <span class="message-time">${timeString}</span>
            </div>
        `;

        // Insertion du HTML juste avant la fin du conteneur (beforeend)
        messagesArea.insertAdjacentHTML("beforeend", newMessageHtml);

        // UX : Nettoyage du champ et scroll automatique vers le nouveau message
        messageInput.value = "";
        scrollToBottom();

        // TODO: Implémenter ici l'appel AJAX (fetch) pour sauvegarder le message en BDD
        // sendToServer(messageText);
    });

    /*
     * Sécurité anti-XSS (Cross-Site Scripting).
     * Avant d'injecter du texte utilisateur dans le HTML (via innerHTML ou template strings),
     * il est impératif de neutraliser les caractères spéciaux (<, >, &, etc.).
     * Cette fonction utilise une astuce du DOM : on place le texte dans un élément 'div' virtuel
     * via 'textContent' (qui échappe automatiquement), puis on récupère le résultat sécurisé.
     */
    function escapeHtml(text) {
        const div = document.createElement("div");
        div.textContent = text;
        return div.innerHTML;
    }
});
