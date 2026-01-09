/*
 * Script de gestion de la messagerie instantanée et des signalements.
 * Ce script assure deux fonctions principales :
 * 1. L'envoi de messages via une requête AJAX (Fetch) pour éviter le rechargement brutal du formulaire,
 * bien que la page soit rechargée ensuite pour afficher le nouveau message (stratégie simple de synchro).
 * 2. La gestion d'une modale Bootstrap pour signaler un utilisateur abusif au sein de la conversation.
 */
document.addEventListener("DOMContentLoaded", function () {
    const messagesArea = document.getElementById("messagesArea");
    const chatForm = document.getElementById("chatForm");
    const messageInput = document.getElementById("messageInput");
    const trajetId = document.getElementById("trajetId").value; // ID caché nécessaire pour l'API

    /*
     * Fonction utilitaire d'UX pour la messagerie.
     * Elle force la zone de discussion à scroller vers le bas.
     * C'est indispensable pour que l'utilisateur voie immédiatement les derniers messages reçus ou envoyés
     * sans avoir à faire défiler manuellement la page à chaque chargement.
     */
    function scrollToBottom() {
        if (messagesArea) messagesArea.scrollTop = messagesArea.scrollHeight; // Scroll au max de la hauteur totale
    }
    scrollToBottom(); // Appel immédiat au chargement

    /*
     * Gestionnaire d'événement pour l'envoi d'un nouveau message.
     * On intercepte la soumission classique du formulaire pour traiter les données en JavaScript.
     * Le bouton est désactivé temporairement pour éviter les doubles soumissions (double-click).
     * Une fois le message enregistré en base via l'API, on recharge la page pour mettre à jour la vue.
     */
    // 1. ENVOI DE MESSAGE
    chatForm.addEventListener("submit", function (e) {
        e.preventDefault(); // Bloque le rechargement natif du navigateur
        const text = messageInput.value.trim(); // Nettoyage des espaces vides
        if (!text) return; // Clause de garde : pas de message vide

        // Désactiver le bouton pour éviter le double clic (UX/Sécurité)
        const btn = chatForm.querySelector('button[type="submit"]');
        btn.disabled = true;

        fetch("/sae-covoiturage/public/api/messagerie/send", {
            // Appel API interne
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                trajet_id: trajetId,
                message: text,
            }),
        })
            .then((response) => response.json()) // Parsing de la réponse JSON
            .then((data) => {
                if (data.success) {
                    messageInput.value = ""; // Reset visuel du champ
                    location.reload(); // Rechargement complet pour récupérer l'historique à jour
                } else {
                    alert("Erreur lors de l'envoi");
                    btn.disabled = false; // Réactivation du bouton en cas d'échec
                }
            })
            .catch((err) => {
                console.error(err);
                btn.disabled = false;
            });
    });

    /*
     * Gestion du module de signalement d'utilisateur.
     * Ce bloc vérifie d'abord l'existence des éléments (bouton et modale) pour éviter des erreurs JS
     * si l'utilisateur est seul dans la conversation (pas de bouton de signalement).
     * Il utilise l'API JavaScript de Bootstrap 5 pour manipuler la fenêtre modale (ouverture/fermeture).
     */
    // 2. GESTION SIGNALEMENT
    const btnSignaler = document.querySelector(".btn-report");
    const modalEl = document.getElementById("modalSignalement");

    // Vérification de sécurité : on n'exécute le code que si le bouton existe dans le DOM
    if (btnSignaler && modalEl) {
        const modal = new bootstrap.Modal(modalEl); // Instanciation de l'objet Modal Bootstrap
        const formSignalement = document.getElementById("formSignalement");

        // Ouverture de la modale au clic
        btnSignaler.addEventListener("click", function () {
            modal.show(); // Méthode Bootstrap pour afficher la popup
        });

        // Traitement du formulaire de signalement
        formSignalement.addEventListener("submit", function (e) {
            e.preventDefault();
            const user = document.getElementById("userSignalement").value;
            const motif = document.getElementById("motifSignalement").value;
            const details = document.getElementById("detailsSignalement").value;

            // Validation simple côté client
            if (!user || !motif) {
                alert("Veuillez remplir tous les champs obligatoires.");
                return;
            }

            // Envoi asynchrone du signalement
            fetch("/sae-covoiturage/public/api/signalement/nouveau", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    id_trajet: trajetId,
                    id_signale: user,
                    motif: motif,
                    description: details,
                }),
            })
                .then((response) => response.json())
                .then((data) => {
                    modal.hide(); // Fermeture automatique de la modale
                    if (data.success) {
                        alert("Signalement envoyé. Merci de votre vigilance.");
                        formSignalement.reset(); // Remise à zéro des champs du formulaire
                    } else {
                        alert(
                            "Erreur : " + (data.msg || "Impossible d'envoyer")
                        );
                    }
                });
        });
    }
});
