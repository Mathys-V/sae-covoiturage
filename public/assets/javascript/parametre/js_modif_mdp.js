/*
 * Script de gestion du formulaire de modification de mot de passe.
 * Ce fichier assure trois fonctions principales :
 * 1. L'amélioration de l'UX via l'affichage/masquage du mot de passe (toggle).
 * 2. La validation en temps réel (feedback immédiat) de la complexité et de la correspondance des mots de passe.
 * 3. L'interception de la soumission pour afficher une modale de confirmation avant l'envoi au serveur.
 */
document.addEventListener("DOMContentLoaded", () => {
    /*
     * Fonction de bascule de visibilité des mots de passe.
     * Elle est attachée à l'objet global 'window' pour être accessible depuis les attributs 'onclick' du HTML,
     * même si elle est définie à l'intérieur de notre écouteur d'événement (problème de portée/scope).
     * Elle modifie dynamiquement l'attribut 'type' de l'input ciblé.
     */
    // --- 1. Gestion de l'affichage des mots de passe (Oeil) ---
    window.togglePwd = function (id) {
        const input = document.getElementById(id);
        // Opérateur ternaire pour basculer entre texte clair et masqué
        input.type = input.type === "password" ? "text" : "password";
    };

    /*
     * Initialisation des références DOM et de la Regex de sécurité.
     * La Regex impose une complexité forte : au moins 8 caractères, 1 lettre, 1 chiffre et 1 caractère spécial.
     * Les 'Lookaheads' (?=...) permettent de vérifier la présence de ces éléments n'importe où dans la chaîne.
     */
    // --- 2. Validation et Modale ---
    const form = document.getElementById("mdpForm");
    const confirmModal = document.getElementById("confirmModal");
    const currentInput = document.getElementById("current_password");
    const newInput = document.getElementById("new_password");
    const confirmInput = document.getElementById("confirm_password");

    // Regex : Min 8 car, 1 lettre, 1 chiffre, 1 car. spécial
    const regex =
        /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/;

    /*
     * Gestionnaires d'événements pour le feedback en temps réel.
     * L'événement 'input' est déclenché à chaque frappe de clavier.
     * 1. Sur l'ancien mot de passe : on efface le message d'erreur PHP dès que l'utilisateur commence à corriger.
     * 2. Sur le nouveau mot de passe : on vérifie la complexité via la méthode .test() de la Regex.
     * 3. Sur la confirmation : on vérifie l'égalité stricte avec le nouveau mot de passe.
     */
    // Reset erreur PHP au typage
    currentInput.addEventListener("input", function () {
        const errCurrent = document.getElementById("msg-error-current");
        if (errCurrent) errCurrent.classList.remove("show-error-php"); // Masque l'erreur serveur
    });

    // Validation temps réel (Format)
    newInput.addEventListener("input", function () {
        const val = this.value;
        const errorMsg = document.getElementById("msg-error-format");

        // Affiche l'erreur si le champ n'est pas vide ET ne respecte pas la regex
        if (val.length > 0 && !regex.test(val)) {
            errorMsg.style.display = "block";
        } else {
            errorMsg.style.display = "none";
        }
    });

    // Validation temps réel (Correspondance)
    confirmInput.addEventListener("input", function () {
        const errorMsg = document.getElementById("msg-error-confirm");
        // Vérifie si la valeur actuelle diffère du champ "nouveau mot de passe"
        if (this.value !== newInput.value) {
            errorMsg.style.display = "block";
        } else {
            errorMsg.style.display = "none";
        }
    });

    /*
     * Interception de la soumission du formulaire.
     * On utilise preventDefault() pour bloquer l'envoi HTTP classique.
     * On relance une validation complète (au cas où l'utilisateur aurait forcé ou copié-collé).
     * Si tout est valide, on affiche la modale de confirmation personnalisée au lieu d'envoyer directement.
     */
    // --- INTERCEPTION DU SUBMIT ---
    form.addEventListener("submit", function (e) {
        e.preventDefault(); // Bloque l'envoi immédiat du formulaire

        let isValid = true;

        // Vérification finale de la complexité
        if (!regex.test(newInput.value)) {
            document.getElementById("msg-error-format").style.display = "block";
            isValid = false;
        }
        // Vérification finale de la correspondance
        if (newInput.value !== confirmInput.value) {
            document.getElementById("msg-error-confirm").style.display =
                "block";
            isValid = false;
        }

        // Si aucune erreur, on ouvre la modale
        if (isValid) {
            confirmModal.style.display = "flex"; // Affiche la popup
        }
    });
});

/*
 * Fonctions utilitaires globales.
 * Elles sont placées hors du 'DOMContentLoaded' pour être accessibles globalement.
 * 'submitRealForm' est appelée par le bouton "Oui" de la modale pour déclencher
 * l'envoi réel des données au serveur via la méthode .submit() du formulaire DOM.
 */
function closeConfirm() {
    document.getElementById("confirmModal").style.display = "none";
}

function submitRealForm() {
    document.getElementById("mdpForm").submit(); // Force l'envoi du formulaire
}
