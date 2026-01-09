/*
 * Gestion de la persistance des onglets au chargement (Deep Linking).
 * Par défaut, les onglets Bootstrap se réinitialisent sur le premier onglet lors d'un rafraîchissement.
 * Ce script permet d'activer automatiquement l'onglet spécifique demandé via l'URL (ex: page.php#historique).
 * Il améliore l'UX en permettant de partager ou de mettre en favori un lien pointant vers un onglet précis.
 */
document.addEventListener("DOMContentLoaded", function () {
    // On vérifie si l'URL courante contient une ancre (ex: #avenir)
    if (window.location.hash) {
        // Propriété du BOM (Browser Object Model)

        // On cherche dans le DOM le bouton qui contrôle l'onglet correspondant à cette ancre.
        // On utilise un sélecteur d'attribut CSS complexe pour cibler le 'data-bs-target' exact.
        var trigger = document.querySelector(
            'button[data-bs-target="' + window.location.hash + '"]'
        );

        // Si un bouton correspondant est trouvé, on force son activation
        if (trigger) {
            trigger.click(); // Simulation programmatique de l'événement clic
        }
    }
});
