/*
 * Script de gestion du formulaire de modification d'adresse.
 * Ce script implémente une autocomplétion intelligente via l'API Adresse du gouvernement
 * et une validation côté client avant d'afficher une modale de confirmation.
 * L'objectif est de garantir que les données envoyées au serveur sont normalisées et complètes.
 */
document.addEventListener("DOMContentLoaded", () => {
    console.log("✅ CHARGEMENT: js_modif_adresse.js"); // Trace de débogage

    // Récupération des références aux éléments du DOM pour éviter de requêter le document à chaque fois
    const rueInput = document.getElementById("rue");
    const suggestionsContainer = document.querySelector(
        ".autocomplete-suggestions"
    ); // La DIV conteneur des résultats
    const villeInput = document.getElementById("ville");
    const cpInput = document.getElementById("cp");
    const form = document.getElementById("addressForm");
    const confirmModal = document.getElementById("confirmModal");

    let timeout = null; // Variable pour stocker le timer du Debounce

    // Vérification d'intégrité : on arrête tout si les éléments critiques sont absents
    if (!rueInput || !suggestionsContainer) {
        console.error("❌ ERREUR: Champs introuvables"); // Log d'erreur console
        return; // Arrêt de l'exécution
    }

    /*
     * Gestion de l'autocomplétion sur le champ adresse.
     * Pour optimiser les performances et limiter les requêtes réseau vers l'API Gouv,
     * on utilise un mécanisme de 'Debounce' : la requête n'est envoyée que si l'utilisateur
     * arrête de taper pendant 300ms.
     */
    // --- 1. AUTOCOMPLÉTION ---
    rueInput.addEventListener("input", function () {
        const query = this.value.trim(); // Nettoyage des espaces

        // Si le champ est vide, on masque immédiatement la liste de suggestions
        if (query.length === 0) {
            suggestionsContainer.style.display = "none"; // Manipulation CSS
            return;
        }

        // Annulation de l'appel précédent s'il y a une nouvelle frappe (Debounce)
        clearTimeout(timeout);

        timeout = setTimeout(() => {
            console.log("🔎 Recherche API : " + query);

            // Appel asynchrone à l'API Adresse (GET)
            // encodeURIComponent est crucial pour gérer les espaces et caractères spéciaux dans l'URL
            fetch(
                "https://api-adresse.data.gouv.fr/search/?q=" +
                    encodeURIComponent(query) +
                    "&limit=5"
            )
                .then((response) => response.json()) // Parsing du flux JSON
                .then((data) => {
                    suggestionsContainer.innerHTML = ""; // Nettoyage de la liste précédente

                    if (data.features && data.features.length > 0) {
                        suggestionsContainer.style.display = "block"; // Affichage du conteneur

                        // Itération sur les résultats (features) renvoyés par l'API GeoJSON
                        data.features.forEach((feature) => {
                            const props = feature.properties;

                            // Création dynamique d'un élément de suggestion
                            const div = document.createElement("div"); // Création de nœud DOM
                            div.className = "autocomplete-suggestion";
                            div.innerHTML = `<i class="bi bi-geo-alt-fill"></i> <strong>${props.name}</strong> <span style="font-size:0.85em; color:#666; margin-left:5px;">(${props.postcode} ${props.city})</span>`;

                            /*
                             * Gestion du clic sur une suggestion.
                             * On remplit automatiquement les inputs (Rue, Ville, CP) avec les données normalisées
                             * renvoyées par l'API, puis on applique un feedback visuel (fond vert) temporaire.
                             */
                            div.addEventListener("click", function () {
                                // Remplissage des champs
                                rueInput.value = props.name;
                                villeInput.value = props.city;
                                cpInput.value = props.postcode;

                                // Feedback visuel (UX)
                                villeInput.style.backgroundColor = "#d4edda";
                                cpInput.style.backgroundColor = "#d4edda";
                                setTimeout(() => {
                                    villeInput.style.backgroundColor = ""; // Reset du style
                                    cpInput.style.backgroundColor = "";
                                }, 500);

                                suggestionsContainer.style.display = "none";

                                // Suppression des messages d'erreur potentiels car le champ est maintenant valide
                                document
                                    .querySelectorAll(".error-message")
                                    .forEach(
                                        (el) => (el.style.display = "none")
                                    );
                            });

                            suggestionsContainer.appendChild(div); // Injection dans le DOM
                        });
                    } else {
                        suggestionsContainer.style.display = "none"; // Aucun résultat
                    }
                })
                .catch((err) => console.error("❌ Erreur API", err)); // Gestion des erreurs réseau
        }, 300); // Délai du debounce
    });

    // UX : Fermeture de la liste de suggestions si on clique ailleurs sur la page
    document.addEventListener("click", function (e) {
        if (e.target !== rueInput && e.target !== suggestionsContainer) {
            suggestionsContainer.style.display = "none";
        }
    });

    /*
     * Interception de la soumission du formulaire.
     * On empêche l'envoi natif (e.preventDefault()) pour lancer une validation côté client.
     * Si les données sont valides, on affiche la modale de confirmation au lieu d'envoyer directement.
     */
    // --- 2. VALIDATION ---
    if (form) {
        form.addEventListener("submit", function (e) {
            e.preventDefault(); // Bloque le submit standard
            if (validateForm()) {
                confirmModal.style.display = "flex"; // Affiche la modale custom
            }
        });
    }

    // Fonction de validation simple : vérifie que les champs requis ne sont pas vides
    function validateForm() {
        let isValid = true;
        // Reset de l'affichage des erreurs
        document
            .querySelectorAll(".error-message")
            .forEach((el) => (el.style.display = "none"));

        if (rueInput.value.trim() === "") {
            document.getElementById("errorRue").style.display = "block";
            isValid = false;
        }
        if (villeInput.value.trim() === "") {
            document.getElementById("errorVille").style.display = "block";
            isValid = false;
        }
        // Vérification basique du code postal (doit faire 5 caractères)
        if (cpInput.value.trim().length !== 5) {
            document.getElementById("errorCp").style.display = "block";
            isValid = false;
        }
        return isValid;
    }
});

/*
 * Fonctions utilitaires exposées dans le scope global (window).
 * Elles sont nécessaires car les boutons de la modale utilisent des attributs 'onclick' dans le HTML.
 * Si elles étaient dans le 'DOMContentLoaded', elles seraient inaccessibles (encapsulées).
 */
function closeConfirm() {
    document.getElementById("confirmModal").style.display = "none";
}

function submitRealForm() {
    document.getElementById("addressForm").submit(); // Déclenche l'envoi réel au serveur
}
