document.addEventListener("DOMContentLoaded", function () {
  const chatForm = document.getElementById("chatForm");
  const messageInput = document.getElementById("messageInput");
  const messagesArea = document.getElementById("messagesArea");

  // 1. Scroll automatique vers le bas au chargement
  function scrollToBottom() {
    messagesArea.scrollTop = messagesArea.scrollHeight;
  }
  scrollToBottom();

  // 2. Gestion de l'envoi
  chatForm.addEventListener("submit", function (e) {
    e.preventDefault();

    const messageText = messageInput.value.trim();
    if (messageText === "") return;

    // --- Simulation de l'ajout du message (En production, utiliser fetch/AJAX) ---

    // Création du HTML pour le nouveau message
    const now = new Date();
    const timeString =
      now.getHours() +
      ":" +
      (now.getMinutes() < 10 ? "0" : "") +
      now.getMinutes();

    const newMessageHtml = `
            <div class="message-wrapper msg-self">
                <span class="sender-name">Moi</span>
                <div class="message-bubble">
                    ${escapeHtml(messageText)}
                </div>
                <span class="message-time">${timeString}</span>
            </div>
        `;

    // Insertion dans le DOM
    messagesArea.insertAdjacentHTML("beforeend", newMessageHtml);

    // Reset input et scroll
    messageInput.value = "";
    scrollToBottom();

    // TODO: Envoyer les données au serveur ici
    // sendToServer(messageText);
  });

  // Sécurité XSS simple
  function escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }
});
