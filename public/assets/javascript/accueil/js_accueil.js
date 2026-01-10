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

    /**
     * GESTION DE LA GÉOLOCALISATION
     * Récupère la position GPS et trouve l'adresse correspondante via l'API Gouv
     */
function setupGeolocation() {
        // On récupère l'icône (qui sert de bouton) et le champ input
        const btnGeoloc = document.getElementById("btn-geoloc");
        const inputDepart = document.getElementById("depart");

        if (!btnGeoloc || !inputDepart) return;

        btnGeoloc.addEventListener("click", function () {
            
            // 1. Vérification du support navigateur
            if (!navigator.geolocation) {
                alert("Désolé, votre navigateur ne supporte pas la géolocalisation.");
                return;
            }

            // 2. Animation de chargement
            // (Note : btnGeoloc est la balise <i>, donc on modifie ses classes directement)
            btnGeoloc.classList.remove("bi-geo-alt-fill");
            btnGeoloc.classList.add("bi-arrow-repeat", "geo-loading");
            
            // On change le placeholder pour indiquer la recherche
            const originalPlace = inputDepart.placeholder;
            inputDepart.placeholder = "Recherche position...";

            // 3. Demande de position
            navigator.geolocation.getCurrentPosition(
                // --- SUCCÈS (Position GPS obtenue) ---
                (position) => {
                    const lat = position.coords.latitude;
                    const lon = position.coords.longitude;

                    // Appel à l'API Adresse (France uniquement)
                    fetch(`https://api-adresse.data.gouv.fr/reverse/?lon=${lon}&lat=${lat}`)
                        .then((response) => response.json())
                        .then((data) => {
                            if (data.features && data.features.length > 0) {
                                // CAS A : Adresse trouvée
                                const adresseComplete = data.features[0].properties.label;
                                inputDepart.value = adresseComplete;
                            } else {
                                // CAS B : Position trouvée mais adresse inconnue (Hors France ou zone vide)
                                alert(
                                    "📍 Position détectée, mais adresse introuvable.\n\n" +
                                    "L'outil de recherche automatique ne fonctionne que pour les lieux situés en France métropolitaine.\n\n" +
                                    "👉 Solution : Veuillez saisir le nom de votre ville manuellement."
                                );
                            }
                        })
                        .catch((error) => {
                            console.error("Erreur API :", error);
                            alert("Une erreur technique est survenue lors de la communication avec le service d'adresse.");
                        })
                        .finally(() => {
                            // Fin du chargement (Succès ou Erreur API)
                            btnGeoloc.classList.remove("bi-arrow-repeat", "geo-loading");
                            btnGeoloc.classList.add("bi-geo-alt-fill");
                            inputDepart.placeholder = originalPlace;
                        });
                },

                // --- ERREUR (Position GPS échouée ou refusée) ---
                (error) => {
                    // Fin du chargement
                    btnGeoloc.classList.remove("bi-arrow-repeat", "geo-loading");
                    btnGeoloc.classList.add("bi-geo-alt-fill");
                    inputDepart.placeholder = originalPlace;

                    switch (error.code) {
                        case error.PERMISSION_DENIED:
                            alert(
                                "⚠️ Géolocalisation bloquée.\n\n" +
                                "Pour utiliser cette fonction, vous devez l'autoriser :\n" +
                                "1. Cliquez sur l'icône (cadenas 🔒) à gauche de l'adresse URL.\n" +
                                "2. Activez l'option 'Position' ou 'Localisation'.\n" +
                                "3. Réessayez."
                            );
                            break;
                        case error.POSITION_UNAVAILABLE:
                            alert("Votre position est actuellement indisponible (signal GPS trop faible ou désactivé).");
                            break;
                        case error.TIMEOUT:
                            alert("La demande de localisation a pris trop de temps. Veuillez réessayer.");
                            break;
                        default:
                            alert("Une erreur inconnue est survenue.");
                            break;
                    }
                }
            );
        });
    }

    // Lancer la configuration de la géolocalisation
    setupGeolocation();

    // Lancement de l'autocomplétion sur les champs Départ et Arrivée
    setupAutocomplete("depart", "depart-list");
    setupAutocomplete("arrivee", "arrivee-list");

    // --- Validation Client ---
    // On sélectionne le formulaire qui contient à la fois "depart" et "arrivee"
    const searchForm = document.querySelector('form[action*="/recherche/resultats"]');
    if (searchForm) {
        searchForm.addEventListener("submit", function (e) {
            const departInput = document.getElementById("depart");
            const arriveeInput = document.getElementById("arrivee");

            if (departInput && arriveeInput) {
                const depart = departInput.value.trim().toLowerCase();
                const arrivee = arriveeInput.value.trim().toLowerCase();

                if (depart && arrivee && depart === arrivee) {
                    e.preventDefault(); // On bloque l'envoi
                    alert("Attention : Le lieu de départ et la destination ne peuvent pas être identiques.");
                }
            }
        });
    }
});
