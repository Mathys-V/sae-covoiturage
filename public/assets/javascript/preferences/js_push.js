document.addEventListener("DOMContentLoaded", () => {
    /*
     * Restauration des préférences utilisateur au chargement de la page.
     * Le script parcourt un tableau contenant les ID des différentes options de notifications (Trajets, Messages, Promos).
     * Pour chaque option, il vérifie si une valeur 'true' est stockée dans le LocalStorage du navigateur
     * et coche la checkbox correspondante le cas échéant. Cela permet de simuler une persistance des données légère.
     */
    // Chargement (Simulation LocalStorage)
    ["push_trajet", "push_messages", "push_promo"].forEach((id) => {
        if (localStorage.getItem(id) === "true")
            document.getElementById(id).checked = true; // Lecture du stockage local
    });

    /*
     * Gestion de la sauvegarde avec retour visuel immédiat (Feedback UX).
     * Lors de la soumission, on empêche le rechargement de la page pour une expérience fluide (SPA-like).
     * On met à jour le LocalStorage avec l'état actuel des cases.
     * Ensuite, on modifie le style du bouton (texte "Sauvegardé !" et fond vert) pendant 2 secondes
     * pour confirmer la réussite de l'action à l'utilisateur sans utiliser de lourdes fenêtres modales.
     */
    // Sauvegarde avec Feedback visuel
    document.getElementById("pushForm").addEventListener("submit", (e) => {
        e.preventDefault(); // Annulation du comportement par défaut (rechargement)

        ["push_trajet", "push_messages", "push_promo"].forEach((id) => {
            localStorage.setItem(id, document.getElementById(id).checked); // Écriture persistante
        });

        // Feedback simple et natif
        const btn = document.querySelector(".btn-save");
        const originalText = btn.innerText;
        btn.innerText = "Sauvegardé !"; // Modification du DOM
        btn.style.background = "#00e676"; // Manipulation CSS directe (Vert succès)

        // Timer pour rétablir l'état initial du bouton
        setTimeout(() => {
            btn.innerText = originalText;
            btn.style.background = "#8C52FF"; // Retour à la couleur de la charte
        }, 2000);
    });
});
