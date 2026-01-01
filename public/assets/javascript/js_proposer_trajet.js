// --- VARIABLES GLOBALES ---
let departCoords = null; // [long, lat]
let arriveeCoords = null; // [long, lat]

// --- 1. FONCTION UTILITAIRE : REMPLIR LES CHAMPS CACHÉS ---
// C'est elle qui fait le lien entre ce qu'on clique et les inputs hidden du HTML
function fillHiddenFields(type, ville, cp, rue) {
    // type vaut soit "depart", soit "arrivee"
    const villeInput = document.getElementById(`val_ville_${type}`);
    const cpInput = document.getElementById(`val_cp_${type}`);
    const rueInput = document.getElementById(`val_rue_${type}`);

    if (villeInput) villeInput.value = ville || "";
    if (cpInput) cpInput.value = cp || "";
    if (rueInput) rueInput.value = rue || "";

    console.log(`Données remplies pour ${type}:`, { ville, cp, rue });
}

// --- 2. FONCTION UTILITAIRE : VIDER LES CHAMPS CACHÉS ---
// Si l'utilisateur efface le texte, on doit vider les données cachées pour éviter les erreurs
function clearHiddenFields(type) {
    fillHiddenFields(type, "", "", "");
}

// --- FONCTION DATE DE FIN ---
function toggleDateFin(show) {
    const wrapper = document.getElementById("date_fin_wrapper");
    const input = wrapper.querySelector("input");
    if (show) {
        wrapper.classList.add("visible");
        input.required = true;
    } else {
        wrapper.classList.remove("visible");
        input.required = false;
        input.value = "";
    }
}

// --- FONCTION CALCUL ITINÉRAIRE (OSRM) ---
function calculateRoute() {
    if (departCoords && arriveeCoords) {
        const url = `https://router.project-osrm.org/route/v1/driving/${departCoords[0]},${departCoords[1]};${arriveeCoords[0]},${arriveeCoords[1]}?overview=false`;

        fetch(url)
            .then((res) => res.json())
            .then((data) => {
                if (data.routes && data.routes.length > 0) {
                    const durationSeconds = data.routes[0].duration;
                    const distanceMeters = data.routes[0].distance;

                    // Convertir en HH:MM:SS
                    const date = new Date(0);
                    date.setSeconds(durationSeconds);
                    const timeString = date.toISOString().substr(11, 8);

                    const dureeInput = document.getElementById("duree_calc");
                    const distanceInput = document.getElementById("distance_calc");

                    if (dureeInput) dureeInput.value = timeString;
                    if (distanceInput) distanceInput.value = Math.round(distanceMeters / 1000);

                    // Feedback visuel bouton
                    const btn = document.querySelector(".btn-submit-trajet");
                    const originalText = "Poster le(s) trajet(s)";
                    
                    const minutes = Math.round(durationSeconds / 60);
                    const heures = Math.floor(minutes / 60);
                    const minutesRestantes = minutes % 60;
                    
                    let dureeTexte = `${minutes} min`;
                    if (heures > 0) dureeTexte = `${heures}h${minutesRestantes}`;

                    btn.innerHTML = `<i class="bi bi-check-circle"></i> Durée estimée : ${dureeTexte}`;
                    btn.classList.add("btn-success");

                    setTimeout(() => {
                        btn.innerHTML = originalText;
                        btn.classList.remove("btn-success");
                    }, 4000);
                }
            })
            .catch((err) => console.error("Erreur OSRM", err));
    }
}

// --- FONCTION RECHERCHE COORDS (Pour Lieux Fréquents) ---
function getCoordsFromName(ville, callback) {
    fetch("https://api-adresse.data.gouv.fr/search/?q=" + ville + "&limit=1")
        .then((res) => res.json())
        .then((data) => {
            if (data.features && data.features.length > 0) {
                callback(data.features[0].geometry.coordinates);
                calculateRoute();
            }
        });
}

// --- FONCTION AUTOCOMPLETE PRINCIPALE ---
function setupAutocomplete(inputId, resultsId, type) {
    const input = document.getElementById(inputId);
    const results = document.getElementById(resultsId);

    if (!input || !results) return;

    let timeout = null;

    input.addEventListener("input", function () {
        // Reset validation et champs cachés quand on tape
        this.setAttribute("data-valid", "false");
        this.classList.remove("is-valid");
        clearHiddenFields(type); // IMPORTANT : On vide si on modifie le texte

        if (type === "depart") departCoords = null;
        if (type === "arrivee") arriveeCoords = null;

        const query = this.value.toLowerCase().trim();
        results.innerHTML = "";

        if (query.length < 2) return;

        // 1. Lieux Fréquents (Variable globale Smarty)
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
                div.innerHTML =
                    '<i class="bi bi-star-fill suggestion-icon text-warning"></i>' +
                    lieu.nom_lieu +
                    ' <small class="text-muted">(' + lieu.ville + ")</small>";

                div.addEventListener("click", function () {
                    input.value = lieu.nom_lieu;
                    
                    // === MODIF ICI : On remplit les hidden avec les données de la BDD ===
                    fillHiddenFields(type, lieu.ville, lieu.code_postal, lieu.rue);

                    input.setAttribute("data-valid", "true");
                    input.classList.remove("input-error");
                    results.innerHTML = "";

                    // Chercher coords ville pour calcul distance
                    const callback = (coords) => {
                        if (type === "depart") departCoords = coords;
                        else arriveeCoords = coords;
                    };
                    getCoordsFromName(lieu.ville, callback);
                });
                results.appendChild(div);
            });
        }

        // 2. API Adresse Gouv
        if (query.length > 3) {
            clearTimeout(timeout);
            timeout = setTimeout(() => {
                fetch("https://api-adresse.data.gouv.fr/search/?q=" + query + "&limit=5")
                    .then((response) => response.json())
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
                                    
                                    // === MODIF ICI : On remplit les hidden avec l'API ===
                                    // L'API renvoie : city (ville), postcode (CP), name (rue/lieu)
                                    fillHiddenFields(
                                        type, 
                                        feature.properties.city, 
                                        feature.properties.postcode, 
                                        feature.properties.name
                                    );

                                    input.setAttribute("data-valid", "true");
                                    input.classList.remove("input-error");
                                    results.innerHTML = "";

                                    // Coordonnées GPS
                                    const coords = feature.geometry.coordinates;
                                    if (type === "depart") departCoords = coords;
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

    // Fermer si clic ailleurs
    document.addEventListener("click", function (e) {
        if (e.target !== input && e.target !== results) {
            results.innerHTML = "";
        }
    });
}

// --- INITIALISATION ---
document.addEventListener("DOMContentLoaded", function () {
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