/*
 * Gestion de la fonctionnalité "Afficher/Masquer le mot de passe".
 * Ce script améliore l'expérience utilisateur (UX) en permettant de vérifier la saisie.
 * Il repose sur une écoute d'événement 'click' qui modifie dynamiquement l'attribut HTML 'type'
 * de l'input (passant de 'password' à 'text' et inversement) et met à jour l'icône visuelle via les classes CSS.
 */
const togglePassword = document.querySelector("#togglePassword");
const password = document.querySelector("#passwordInput");

// Clause de garde : on ne pose l'écouteur que si l'icône existe sur la page
if (togglePassword) {
    togglePassword.addEventListener("click", function (e) {
        // Logique de bascule : si c'est caché, on montre, sinon on cache (Opérateur ternaire)
        const type =
            password.getAttribute("type") === "password" ? "text" : "password";

        // Application du changement de type sur l'input
        password.setAttribute("type", type); // Manipulation directe du DOM

        // Bascule des classes CSS pour changer l'icône (Œil ouvert <-> Œil barré)
        // 'this' fait référence ici à l'élément cliqué (l'icône elle-même)
        this.classList.toggle("bi-eye");
        this.classList.toggle("bi-eye-slash");
    });
}
