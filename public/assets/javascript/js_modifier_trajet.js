// --- VARIABLES GLOBALES ---
let departCoords = null;
let arriveeCoords = null;

// --- DICTIONNAIRE LIEUX ---
const KNOWN_LOCATIONS = {
    "IUT d'Amiens": [2.264032, 49.870683],
    "Gare d'Amiens": [2.306739, 49.890583],
    "Gare de Longueau": [2.353159, 49.864238],
    "Mairie de Dury": [2.268248, 49.846271],
    "Centre-ville": [2.3089, 49.8872],
};

// --- FONCTIONS UTILITAIRES ---
function fillHiddenFields(type, ville, cp, rue) {
    const villeInput = document.getElementById(`val_ville_${type}`);
    const cpInput = document.getElementById(`val_cp_${type}`);
    const rueInput = document.getElementById(`val_rue_${type}`);

    if (villeInput) villeInput.value = ville || "";
    if (cpInput) cpInput.value = cp || "";
    if (rueInput) rueInput.value = rue || "";
}

function clearHiddenFields(type) {
    fillHiddenFields(type, "", "", "");
}

// --- CALCUL ITINÉRAIRE ---
function calculateRoute() {
    if (departCoords && arriveeCoords) {
        if (
            departCoords[0] === arriveeCoords[0] &&
            departCoords[1] === arriveeCoords[1]
        )
            return;

        const url = `https://router.project-osrm.org/route/v1/driving/${departCoords[0]},${departCoords[1]};${arriveeCoords[0]},${arriveeCoords[1]}?overview=false`;

        fetch(url)
            .then((res) => res.json())
            .then((data) => {
                if (data.routes && data.routes.length > 0) {
                    const durationSeconds = data.routes[0].duration;
                    const distanceMeters = data.routes[0].distance;

                    const date = new Date(0);
                    date.setSeconds(durationSeconds);
                    const timeString = date.toISOString().substr(11, 8);

                    const dureeInput = document.getElementById("duree_calc");
                    const distanceInput =
                        document.getElementById("distance_calc");

                    if (dureeInput) dureeInput.value = timeString;
                    if (distanceInput)
                        distanceInput.value = Math.round(distanceMeters / 1000);
                }
            })
            .catch((err) => console.error("Erreur OSRM", err));
    }
}

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
function setupAutocomplete(inputId, resultsId, type) {
    const input = document.getElementById(inputId);
    const results = document.getElementById(resultsId);
    if (!input || !results) return;
    let timeout = null;

    input.addEventListener("input", function () {
        this.setAttribute("data-valid", "false");
        this.classList.remove("is-valid");
        clearHiddenFields(type);

        if (type === "depart") departCoords = null;
        if (type === "arrivee") arriveeCoords = null;

        const query = this.value.trim().toLowerCase();
        results.innerHTML = "";
        if (query.length < 2) return;

        // Lieux Fréquents
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
                    input.value = lieu.nom_lieu;
                    fillHiddenFields(
                        type,
                        lieu.ville,
                        lieu.code_postal,
                        lieu.rue
                    );
                    input.setAttribute("data-valid", "true");
                    input.classList.remove("input-error");
                    results.innerHTML = "";

                    if (KNOWN_LOCATIONS && KNOWN_LOCATIONS[lieu.nom_lieu]) {
                        const coords = KNOWN_LOCATIONS[lieu.nom_lieu];
                        if (type === "depart") departCoords = coords;
                        else arriveeCoords = coords;
                        calculateRoute();
                    } else {
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

        // API Adresse
        if (query.length > 3) {
            clearTimeout(timeout);
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
                                    input.value = feature.properties.label;
                                    fillHiddenFields(
                                        type,
                                        feature.properties.city,
                                        feature.properties.postcode,
                                        feature.properties.name
                                    );
                                    input.setAttribute("data-valid", "true");
                                    input.classList.remove("input-error");
                                    results.innerHTML = "";

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

    document.addEventListener("click", function (e) {
        if (e.target !== input && e.target !== results) {
            results.innerHTML = "";
        }
    });
}

// --- INITIALISATION ---
document.addEventListener("DOMContentLoaded", function () {
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

    setupAutocomplete("depart", "suggestions-depart", "depart");
    setupAutocomplete("arrivee", "suggestions-arrivee", "arrivee");

    const form = document.getElementById("trajetForm");
    if (form) {
        form.addEventListener("submit", function (e) {
            const depart = document.getElementById("depart");
            const arrivee = document.getElementById("arrivee");
            const errorMsg = document.getElementById("js-error-message");
            let isValid = true;

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

            if (!isValid) {
                if (errorMsg) errorMsg.classList.remove("d-none");
                window.scrollTo({ top: 0, behavior: "smooth" });
            } else {
                if (errorMsg) errorMsg.classList.add("d-none");
            }
        });
    }
});
