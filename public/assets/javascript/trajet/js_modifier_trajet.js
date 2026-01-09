// --- VARIABLES GLOBALES ---
// Stockage des coordonnées GPS (Latitude/Longitude) pour le calcul de distance
let departCoords = null;
let arriveeCoords = null;

// --- DICTIONNAIRE LIEUX ---
// Liste de lieux "connus" en dur pour éviter des appels API inutiles
// Utile pour les points de repère récurrents (Faculté, Gare, etc.)
const KNOWN_LOCATIONS = {
    "IUT d'Amiens": [2.264032, 49.870683],
    "Gare d'Amiens": [2.306739, 49.890583],
    "Gare de Longueau": [2.353159, 49.864238],
    "Mairie de Dury": [2.268248, 49.846271],
    "Centre-ville": [2.3089, 49.8872],
};

// --- FONCTIONS UTILITAIRES ---

/**
 * Remplit les champs cachés (<input type="hidden">) nécessaires pour le backend PHP.
 * @param {string} type - 'depart' ou 'arrivee'
 * @param {string} ville - Nom de la ville
 * @param {string} cp - Code postal
 * @param {string} rue - Nom de la rue ou du lieu-dit
 */
function fillHiddenFields(type, ville, cp, rue) {
    const villeInput = document.getElementById(`val_ville_${type}`);
    const cpInput = document.getElementById(`val_cp_${type}`);
    const rueInput = document.getElementById(`val_rue_${type}`);

    if (villeInput) villeInput.value = ville || "";
    if (cpInput) cpInput.value = cp || "";
    if (rueInput) rueInput.value = rue || "";
}

/**
 * Vide les champs cachés (utilisé quand l'utilisateur modifie sa saisie)
 */
function clearHiddenFields(type) {
    fillHiddenFields(type, "", "", "");
}

// --- CALCUL ITINÉRAIRE (API OSRM) ---
/**
 * Calcule la distance et la durée via le service de routing OSRM
 * Se déclenche automatiquement dès que les deux coordonnées sont connues.
 */
function calculateRoute() {
    if (departCoords && arriveeCoords) {
        // Évite le calcul si départ == arrivée
        if (
            departCoords[0] === arriveeCoords[0] &&
            departCoords[1] === arriveeCoords[1]
        )
            return;

        // Appel API OSRM (Open Source Routing Machine) pour le profil "driving" (voiture)
        const url = `https://router.project-osrm.org/route/v1/driving/${departCoords[0]},${departCoords[1]};${arriveeCoords[0]},${arriveeCoords[1]}?overview=false`;

        fetch(url)
            .then((res) => res.json())
            .then((data) => {
                if (data.routes && data.routes.length > 0) {
                    const durationSeconds = data.routes[0].duration;
                    const distanceMeters = data.routes[0].distance;

                    // Conversion de la durée (secondes) en format HH:MM:SS
                    const date = new Date(0);
                    date.setSeconds(durationSeconds);
                    const timeString = date.toISOString().substr(11, 8);

                    // Mise à jour des champs visibles pour l'utilisateur
                    const dureeInput = document.getElementById("duree_calc");
                    const distanceInput =
                        document.getElementById("distance_calc");

                    if (dureeInput) dureeInput.value = timeString;
                    // Conversion mètres -> kilomètres (arrondi)
                    if (distanceInput)
                        distanceInput.value = Math.round(distanceMeters / 1000);
                }
            })
            .catch((err) => console.error("Erreur OSRM", err));
    }
}

/**
 * Récupère les coordonnées d'une ville via l'API Adresse Gouv
 * (Utilisé en fallback si un lieu fréquent n'a pas de coords en mémoire)
 */
function getCoordsFromName(ville, callback) {
    fetch(
        "https://api-adresse.data.gouv.fr/search/?q=" +
            encodeURIComponent(ville) +
            "&limit=1"
    )
        .then((res) => res.json())
        .then((data) => {
            if (data.features && data.features.length > 0) {
                callback(data.features[0].geometry.coordinates);
                calculateRoute();
            }
        });
}

// --- AUTOCOMPLETE ---
/**
 * Gère l'autocomplétion hybride (Lieux fréquents + API Gouv)
 * @param {string} inputId - ID du champ texte visible
 * @param {string} resultsId - ID du conteneur des suggestions
 * @param {string} type - 'depart' ou 'arrivee'
 */
function setupAutocomplete(inputId, resultsId, type) {
    const input = document.getElementById(inputId);
    const results = document.getElementById(resultsId);
    if (!input || !results) return;

    let timeout = null; // Pour le "Debouncing" (limiter les appels API)

    input.addEventListener("input", function () {
        // Dès qu'on tape, on invalide le champ (force l'utilisateur à cliquer sur une suggestion)
        this.setAttribute("data-valid", "false");
        this.classList.remove("is-valid");
        clearHiddenFields(type);

        // Réinitialisation des coordonnées
        if (type === "depart") departCoords = null;
        if (type === "arrivee") arriveeCoords = null;

        const query = this.value.trim().toLowerCase();
        results.innerHTML = "";

        // Pas de recherche en dessous de 2 caractères
        if (query.length < 2) return;

        // 1. RECHERCHE LOCALE (Lieux Fréquents injectés par PHP)
        const localData = window.lieuxFrequents || [];
        const matchesLocal = localData.filter(
            (lieu) =>
                lieu.nom_lieu.toLowerCase().includes(query) ||
                lieu.ville.toLowerCase().includes(query)
        );

        if (matchesLocal.length > 0) {
            matchesLocal.forEach((lieu) => {
                const div = document.createElement("div");
                div.className = "autocomplete-suggestion is-frequent";
                div.innerHTML = `<i class="bi bi-star-fill suggestion-icon text-warning"></i> ${lieu.nom_lieu} <small class="text-muted">(${lieu.ville})</small>`;

                div.addEventListener("click", function () {
                    // Remplissage des champs
                    input.value = lieu.nom_lieu;
                    fillHiddenFields(
                        type,
                        lieu.ville,
                        lieu.code_postal,
                        lieu.rue
                    );

                    // Validation visuelle
                    input.setAttribute("data-valid", "true");
                    input.classList.remove("input-error");
                    results.innerHTML = "";

                    // Gestion des coordonnées pour le calcul d'itinéraire
                    if (KNOWN_LOCATIONS && KNOWN_LOCATIONS[lieu.nom_lieu]) {
                        const coords = KNOWN_LOCATIONS[lieu.nom_lieu];
                        if (type === "depart") departCoords = coords;
                        else arriveeCoords = coords;
                        calculateRoute();
                    } else {
                        // Si on n'a pas les coords, on les cherche
                        const callback = (coords) => {
                            if (type === "depart") departCoords = coords;
                            else arriveeCoords = coords;
                        };
                        getCoordsFromName(lieu.ville, callback);
                    }
                });
                results.appendChild(div);
            });
        }

        // 2. RECHERCHE API GOUV (Adresse)
        if (query.length > 3) {
            clearTimeout(timeout);
            // On attend 300ms après la frappe avant d'appeler l'API
            timeout = setTimeout(() => {
                fetch(
                    "https://api-adresse.data.gouv.fr/search/?q=" +
                        encodeURIComponent(query) +
                        "&limit=5"
                )
                    .then((res) => res.json())
                    .then((data) => {
                        if (data.features && data.features.length > 0) {
                            data.features.forEach((feature) => {
                                const div = document.createElement("div");
                                div.className = "autocomplete-suggestion";
                                div.innerHTML =
                                    '<i class="bi bi-geo-alt suggestion-icon text-muted"></i>' +
                                    feature.properties.label;

                                div.addEventListener("click", function () {
                                    // Remplissage Input + Champs cachés
                                    input.value = feature.properties.label;
                                    fillHiddenFields(
                                        type,
                                        feature.properties.city,
                                        feature.properties.postcode,
                                        feature.properties.name
                                    );

                                    // Validation
                                    input.setAttribute("data-valid", "true");
                                    input.classList.remove("input-error");
                                    results.innerHTML = "";

                                    // Sauvegarde coords + Calcul Itinéraire
                                    const coords = feature.geometry.coordinates;
                                    if (type === "depart")
                                        departCoords = coords;
                                    else arriveeCoords = coords;
                                    calculateRoute();
                                });
                                results.appendChild(div);
                            });
                        }
                    });
            }, 300);
        }
    });

    // Fermeture des suggestions au clic extérieur
    document.addEventListener("click", function (e) {
        if (e.target !== input && e.target !== results) {
            results.innerHTML = "";
        }
    });
}

// --- INITIALISATION ---
document.addEventListener("DOMContentLoaded", function () {
    // 1. Récupération des lieux fréquents depuis l'attribut data-lieux (HTML)
    // Cela permet de passer des données PHP (Smarty) vers JS sans appel AJAX immédiat
    const dataDiv = document.getElementById("trajet-data");
    if (dataDiv) {
        try {
            window.lieuxFrequents = JSON.parse(
                dataDiv.getAttribute("data-lieux")
            );
        } catch (e) {
            window.lieuxFrequents = [];
        }
    } else {
        window.lieuxFrequents = [];
    }

    // 2. Lancement des écouteurs sur les champs Départ et Arrivée
    setupAutocomplete("depart", "suggestions-depart", "depart");
    setupAutocomplete("arrivee", "suggestions-arrivee", "arrivee");

    // 3. Gestion de la soumission du formulaire (Validation finale)
    const form = document.getElementById("trajetForm");
    if (form) {
        form.addEventListener("submit", function (e) {
            const depart = document.getElementById("depart");
            const arrivee = document.getElementById("arrivee");
            const errorMsg = document.getElementById("js-error-message");
            let isValid = true;

            // On empêche l'envoi si l'utilisateur a tapé du texte sans cliquer sur une suggestion
            if (depart.getAttribute("data-valid") !== "true") {
                e.preventDefault();
                depart.classList.add("input-error");
                isValid = false;
            }
            if (arrivee.getAttribute("data-valid") !== "true") {
                e.preventDefault();
                arrivee.classList.add("input-error");
                isValid = false;
            }

            // Gestion de l'affichage du message d'erreur
            if (!isValid) {
                if (errorMsg) errorMsg.classList.remove("d-none");
                window.scrollTo({ top: 0, behavior: "smooth" });
            } else {
                if (errorMsg) errorMsg.classList.add("d-none");
            }
        });
    }
});
