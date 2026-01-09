document.addEventListener("DOMContentLoaded", function () {
    // --- Configuration globale ---
    const MIN_LENGTH = 2; // Nombre minimum de caractères pour déclencher la recherche

    /**
     * Fonction principale d'autocomplétion
     * Gère à la fois les lieux fréquents (variable JS) et l'API Gouv
     */
    function setupAutocomplete(inputId, listId) {
        const input = document.getElementById(inputId);
        const list = document.getElementById(listId);

        // Sécurité : arrêt si les éléments n'existent pas dans le DOM
        if (!input || !list) return;

        input.addEventListener("input", function (e) {
            let val = this.value;
            list.innerHTML = ""; // Réinitialisation de l'affichage

            // On ne lance rien si la saisie est trop courte
            if (!val || val.length < MIN_LENGTH) return false;

            // --- RECHERCHE LOCALE (Lieux Fréquents / BDD) ---
            // On filtre le tableau global window.lieuxFrequents injecté par le serveur
            let matchesDb = [];
            if (window.lieuxFrequents) {
                matchesDb = window.lieuxFrequents.filter(
                    (lieu) =>
                        lieu.nom_lieu
                            .toLowerCase()
                            .includes(val.toLowerCase()) ||
                        lieu.ville.toLowerCase().includes(val.toLowerCase())
                );
            }

            // Affichage des résultats locaux (prioritaires)
            matchesDb.forEach((lieu) => {
                const div = document.createElement("div");
                div.className = "autocomplete-suggestion is-frequent";

                // Construction du HTML (Icône étoile pour les favoris)
                div.innerHTML = `
                    <div class="sugg-icon"><i class="bi bi-star-fill"></i></div>
                    <div class="sugg-text">
                        <span class="sugg-main">${lieu.nom_lieu}</span>
                        <span class="sugg-sub">${lieu.ville}</span>
                    </div>
                `;

                // Au clic : remplissage du champ et fermeture de la liste
                div.addEventListener("click", function () {
                    input.value = lieu.nom_lieu;
                    list.innerHTML = "";
                });
                list.appendChild(div);
            });

            // --- RECHERCHE DISTANTE (API Adresse Gouv) ---
            // Appel asynchrone pour compléter les résultats locaux
            fetch(
                `https://api-adresse.data.gouv.fr/search/?q=${encodeURIComponent(
                    val
                )}&limit=5`
            )
                .then((response) => response.json())
                .then((data) => {
                    // Les résultats de l'API s'ajoutent à la suite des favoris existants

                    data.features.forEach((feature) => {
                        let label = feature.properties.label;
                        let context = feature.properties.context || "";

                        const div = document.createElement("div");
                        div.className = "autocomplete-suggestion is-api"; // Style standard API

                        // Construction du HTML (Icône localisation pour l'API)
                        div.innerHTML = `
                            <div class="sugg-icon"><i class="bi bi-geo-alt-fill"></i></div>
                            <div class="sugg-text">
                                <span class="sugg-main">${label}</span>
                                <span class="sugg-sub">${context}</span>
                            </div>
                        `;

                        div.addEventListener("click", function () {
                            input.value = label;
                            list.innerHTML = "";
                        });

                        list.appendChild(div);
                    });
                })
                .catch((err) => console.error("Erreur API:", err));
        });

        // --- Gestion de la fermeture ---
        // Masque la liste si l'utilisateur clique ailleurs sur la page
        document.addEventListener("click", function (e) {
            if (e.target !== input) {
                list.innerHTML = "";
            }
        });
    }

    // Lancement de l'autocomplétion sur les champs Départ et Arrivée
    setupAutocomplete("depart", "depart-list");
    setupAutocomplete("arrivee", "arrivee-list");
});
