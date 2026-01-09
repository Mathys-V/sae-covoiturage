// Fonction principale lancée au chargement de la page
document.addEventListener("DOMContentLoaded", function () {
    // --- Initialisation de l'autocomplétion ---
    // On cible les champs 'depart' et 'arrivee' ainsi que leurs conteneurs de suggestions respectifs
    setupAutocomplete("depart", "suggestions-depart");
    setupAutocomplete("arrivee", "suggestions-arrivee");

    // --- Gestion de la soumission du formulaire ---
    const formTrajet = document.getElementById("form-recherche-trajet");

    if (formTrajet) {
        formTrajet.addEventListener("submit", function (e) {
            // On empêche le rechargement par défaut de la page HTML
            e.preventDefault();

            // Récupération et nettoyage des valeurs (suppression des espaces inutiles)
            const depart = document.getElementById("depart").value.trim();
            const arrivee = document.getElementById("arrivee").value.trim();

            // Vérification que les champs ne sont pas vides
            if (depart && arrivee) {
                // Création des paramètres d'URL (ex: ?depart=Paris&arrivee=Lyon)
                const params = new URLSearchParams({
                    depart: depart,
                    arrivee: arrivee,
                });

                // Redirection de l'utilisateur vers la page d'affichage des résultats
                window.location.href = `resultats_trajets.html?${params.toString()}`;
            } else {
                // Alerte simple si un champ est manquant
                alert("Veuillez remplir une ville de départ et d'arrivée.");
            }
        });
    }
});

/**
 * Configure l'autocomplétion sur un champ donné
 * Combine une recherche locale (Lieux fréquents) et une recherche API (Adresse Gouv)
 */
function setupAutocomplete(inputId, resultsId) {
    const input = document.getElementById(inputId);
    const results = document.getElementById(resultsId);

    // Si les éléments n'existent pas dans le DOM, on arrête la fonction
    if (!input || !results) return;

    let timeout = null; // Timer pour limiter les appels API (Debounce)

    input.addEventListener("input", function () {
        const query = this.value.toLowerCase().trim();
        results.innerHTML = ""; // Réinitialise l'affichage des suggestions

        // On ne déclenche rien en dessous de 2 caractères
        if (query.length < 2) return;

        // --- Recherche Locale (Lieux Fréquents) ---
        // Récupère la variable globale injectée par le serveur (ou tableau vide par défaut)
        const localData = window.lieuxFrequents || [];

        // Filtre les lieux qui correspondent à la saisie (nom ou ville)
        const matchesLocal = localData.filter(
            (lieu) =>
                lieu.nom_lieu.toLowerCase().includes(query) ||
                lieu.ville.toLowerCase().includes(query)
        );

        // Affichage des résultats locaux
        if (matchesLocal.length > 0) {
            matchesLocal.forEach((lieu) => {
                const div = document.createElement("div");
                div.className = "autocomplete-suggestion is-frequent";

                div.innerHTML = `
                    <div class="sugg-icon"><i class="bi bi-star-fill text-warning"></i></div>
                    <div class="sugg-text">
                        <span class="sugg-main">${lieu.nom_lieu}</span>
                        <span class="sugg-sub">${lieu.ville}</span>
                    </div>`;

                // Au clic, on remplit l'input et on vide la liste
                div.addEventListener("click", function () {
                    input.value = lieu.nom_lieu;
                    results.innerHTML = "";
                });
                results.appendChild(div);
            });
        }

        // --- Recherche API Gouv (Adresse) ---
        // On attend que l'utilisateur ait tapé au moins 3 caractères
        if (query.length > 3) {
            clearTimeout(timeout);
            // Délai de 300ms après la frappe avant d'appeler l'API
            timeout = setTimeout(() => {
                fetch(
                    "https://api-adresse.data.gouv.fr/search/?q=" +
                        query +
                        "&limit=5"
                )
                    .then((response) => response.json())
                    .then((data) => {
                        if (data.features && data.features.length > 0) {
                            data.features.forEach((feature) => {
                                const div = document.createElement("div");
                                div.className =
                                    "autocomplete-suggestion is-api";

                                div.innerHTML = `
                                    <div class="sugg-icon"><i class="bi bi-geo-alt-fill text-muted"></i></div>
                                    <div class="sugg-text">
                                        <span class="sugg-main">${
                                            feature.properties.name
                                        }</span>
                                        <span class="sugg-sub">${
                                            feature.properties.city || ""
                                        } (${
                                    feature.properties.postcode || ""
                                })</span>
                                    </div>`;

                                div.addEventListener("click", function () {
                                    // Concaténation Nom + Ville pour plus de précision
                                    input.value =
                                        feature.properties.name +
                                        " " +
                                        (feature.properties.city || "");
                                    results.innerHTML = "";
                                });
                                results.appendChild(div);
                            });
                        }
                    });
            }, 300);
        }
    });

    // Fermeture des suggestions si on clique ailleurs sur la page
    document.addEventListener("click", function (e) {
        if (e.target !== input && e.target !== results) {
            results.innerHTML = "";
        }
    });
}
