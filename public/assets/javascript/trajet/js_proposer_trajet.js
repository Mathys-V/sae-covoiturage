// Stockage des coordonnées GPS pour le calcul de distance via l'API OSRM
let departCoords = null; // Format : [longitude, latitude]
let arriveeCoords = null; // Format : [longitude, latitude]

// Dictionnaire de coordonnées fixes ("Hardcoded")
// Permet d'avoir une précision parfaite sur les lieux clés de l'application
// et d'éviter des calculs de distance erronés (0km) si l'API ne trouve pas le point exact.
const KNOWN_LOCATIONS = {
    "IUT d'Amiens": [2.264032, 49.870683],
    "Gare d'Amiens": [2.306739, 49.890583],
    "Gare de Longueau": [2.353159, 49.864238],
    "Mairie de Dury": [2.268248, 49.846271],
    "Centre-ville": [2.3089, 49.8872],
};

/**
 * Remplit les champs cachés (<input type="hidden">) nécessaires à l'insertion en BDD PHP
 * @param {string} type - 'depart' ou 'arrivee'
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
 * Vide les champs cachés (utilisé si l'utilisateur efface sa saisie)
 */
function clearHiddenFields(type) {
    fillHiddenFields(type, "", "", "");
}

/**
 * Affiche ou masque le champ "Date de fin" selon si le trajet est régulier ou non.
 * Gère aussi l'attribut 'required' pour la validation HTML5.
 * @param {boolean} show - true pour afficher, false pour masquer
 */
function toggleDateFin(show) {
    const wrapper = document.getElementById("date_fin_wrapper");
    const input = wrapper.querySelector("input");

    if (show) {
        wrapper.classList.add("visible");
        input.required = true; // Devient obligatoire
        updateSummary(); // On met à jour le texte récapitulatif
    } else {
        wrapper.classList.remove("visible");
        input.required = false; // N'est plus obligatoire
        input.value = ""; // On vide la valeur

        const summaryCard = document.getElementById("summary-card");
        if (summaryCard) summaryCard.classList.add("d-none");
    }
}

/**
 * Génère un résumé textuel pour les trajets réguliers.
 * Ex: "Il y aura 5 trajets les lundis du 01/01 au 01/02..."
 */
function updateSummary() {
    const dateDepartInput = document.getElementById("date_depart");
    const dateFinInput = document.getElementById("date_fin");
    const heureInput = document.getElementById("heure_depart");
    const summaryCard = document.getElementById("summary-card");
    const summaryText = document.getElementById("summary-text");
    const radioOui = document.getElementById("regulier_oui");

    // Sécurité : si un élément manque, on sort
    if (
        !dateDepartInput ||
        !dateFinInput ||
        !heureInput ||
        !summaryCard ||
        !radioOui
    )
        return;

    // Si l'utilisateur n'a pas coché "Trajet régulier", on cache le résumé
    if (!radioOui.checked) {
        summaryCard.classList.add("d-none");
        return;
    }

    const startStr = dateDepartInput.value;
    const endStr = dateFinInput.value;
    const heureStr = heureInput.value;

    if (startStr && endStr && heureStr) {
        const startDate = new Date(startStr);
        const endDate = new Date(endStr);

        // Validation logique : Fin doit être après Début
        if (endDate <= startDate) {
            summaryCard.classList.remove("d-none", "alert-info");
            summaryCard.classList.add("alert-danger");
            summaryText.innerHTML = "La date de fin doit être après le départ.";
            return;
        }

        // Calcul du nombre de semaines (donc de trajets)
        const diffTime = Math.abs(endDate - startDate);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        const nbTrajets = Math.floor(diffDays / 7) + 1;

        // Formatage des dates pour l'affichage (fr-FR)
        const options = { weekday: "long" };
        const jourSemaine = new Intl.DateTimeFormat("fr-FR", options).format(
            startDate
        );
        const optionsDate = {
            day: "2-digit",
            month: "2-digit",
            year: "numeric",
        };
        const startDisplay = startDate.toLocaleDateString("fr-FR", optionsDate);
        const endDisplay = endDate.toLocaleDateString("fr-FR", optionsDate);

        // Construction du message final
        const message = `Il y aura <strong>${nbTrajets} trajets</strong> du ${startDisplay} au ${endDisplay}, chaque <strong>${jourSemaine} à ${heureStr}</strong>.`;

        summaryCard.classList.remove("d-none", "alert-danger");
        summaryCard.classList.add("alert-info");
        summaryText.innerHTML = message;
    } else {
        summaryCard.classList.add("d-none");
    }
}

/**
 * Calcule l'itinéraire via l'API OSRM (Open Source Routing Machine).
 * Met à jour les champs Durée et Distance et donne un feedback sur le bouton.
 */
function calculateRoute() {
    if (departCoords && arriveeCoords) {
        // Sécurité pour éviter le bug si les points sont identiques
        if (
            departCoords[0] === arriveeCoords[0] &&
            departCoords[1] === arriveeCoords[1]
        ) {
            console.warn("Points de départ et d'arrivée identiques.");
            return;
        }

        // Appel API OSRM (profil 'driving')
        const url = `https://router.project-osrm.org/route/v1/driving/${departCoords[0]},${departCoords[1]};${arriveeCoords[0]},${arriveeCoords[1]}?overview=false`;

        fetch(url)
            .then((res) => res.json())
            .then((data) => {
                if (data.routes && data.routes.length > 0) {
                    const durationSeconds = data.routes[0].duration;
                    const distanceMeters = data.routes[0].distance;

                    // Conversion durée (secondes) -> Format Time Input (HH:MM:SS)
                    const date = new Date(0);
                    date.setSeconds(durationSeconds);
                    const timeString = date.toISOString().substr(11, 8);

                    const dureeInput = document.getElementById("duree_calc");
                    const distanceInput =
                        document.getElementById("distance_calc");

                    if (dureeInput) dureeInput.value = timeString;
                    if (distanceInput)
                        distanceInput.value = Math.round(distanceMeters / 1000); // En km

                    // --- Feedback UX sur le bouton Submit ---
                    // Change le texte du bouton pour montrer que le calcul est fait
                    const btn = document.querySelector(".btn-submit-trajet");
                    const originalText = "Poster le(s) trajet(s)";

                    // Calcul format texte "1h30" ou "45 min"
                    const minutes = Math.round(durationSeconds / 60);
                    const heures = Math.floor(minutes / 60);
                    const minutesRestantes = minutes % 60;

                    let dureeTexte = `${minutes} min`;
                    if (heures > 0)
                        dureeTexte = `${heures}h${minutesRestantes}`;

                    btn.innerHTML = `<i class="bi bi-check-circle"></i> Durée estimée : ${dureeTexte} (${Math.round(
                        distanceMeters / 1000
                    )}km)`;
                    btn.classList.add("btn-success");

                    // Remet le bouton normal après 4 secondes
                    setTimeout(() => {
                        btn.innerHTML = originalText;
                        btn.classList.remove("btn-success");
                    }, 4000);
                }
            })
            .catch((err) => console.error("Erreur OSRM", err));
    }
}

/**
 * Récupère les coordonnées d'une ville via l'API Adresse Gouv.
 * Fonction de fallback si le lieu n'est pas dans KNOWN_LOCATIONS.
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
                calculateRoute(); // Une fois les coords reçues, on lance le calcul
            }
        });
}

/**
 * Initialise l'autocomplétion sur un champ donné (Départ ou Arrivée).
 * Gère la recherche locale (Lieux Fréquents) ET la recherche API.
 */
function setupAutocomplete(inputId, resultsId, type) {
    const input = document.getElementById(inputId);
    const results = document.getElementById(resultsId);
    if (!input || !results) return;
    let timeout = null;

    input.addEventListener("input", function () {
        // 1. Invalidation du champ dès qu'on tape (force le clic sur une suggestion)
        this.setAttribute("data-valid", "false");
        this.classList.remove("is-valid");
        clearHiddenFields(type);

        // Reset des coordonnées
        if (type === "depart") departCoords = null;
        if (type === "arrivee") arriveeCoords = null;

        const query = this.value.trim().toLowerCase();
        results.innerHTML = "";

        // On attend au moins 2 caractères pour chercher
        if (query.length < 2) return;

        // --- A. RECHERCHE DANS LES LIEUX FRÉQUENTS (Globaux / Local) ---
        // On récupère la variable globale définie dans le Template Smarty
        const localData = window.lieuxFrequents || [];

        // Filtre : Recherche dans le "label" (ex: IUT) OU l'adresse complète
        const matchesLocal = localData.filter((lieu) => {
            const label = lieu.label ? lieu.label.toLowerCase() : "";
            const fullAddr = lieu.full_address
                ? lieu.full_address.toLowerCase()
                : "";

            return label.includes(query) || fullAddr.includes(query);
        });

        // Affichage des résultats locaux
        if (matchesLocal.length > 0) {
            matchesLocal.forEach((lieu) => {
                const div = document.createElement("div");
                div.className = "autocomplete-suggestion is-frequent";
                // Affichage propre : Icône Etoile + Label + Ville
                div.innerHTML = `<i class="bi bi-star-fill suggestion-icon text-warning"></i> <strong>${lieu.label}</strong> <small class="text-muted">(${lieu.ville})</small>`;

                div.addEventListener("click", function () {
                    input.value = lieu.label; // On remplit le champ visible

                    // On remplit les champs cachés pour le PHP
                    fillHiddenFields(
                        type,
                        lieu.ville,
                        lieu.code_postal,
                        lieu.rue
                    );

                    // On valide le champ
                    input.setAttribute("data-valid", "true");
                    input.classList.remove("input-error");
                    results.innerHTML = "";

                    // Gestion des coordonnées pour le calcul
                    if (KNOWN_LOCATIONS && KNOWN_LOCATIONS[lieu.label]) {
                        // Si c'est un lieu connu, on prend les coords fixes
                        const coords = KNOWN_LOCATIONS[lieu.label];
                        if (type === "depart") departCoords = coords;
                        else arriveeCoords = coords;
                        calculateRoute();
                    } else {
                        // Sinon, on demande à l'API via la ville
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

        // --- B. RECHERCHE API ADRESSE GOUV (Si > 3 caractères) ---
        if (query.length > 3) {
            clearTimeout(timeout);
            // Debounce : on attend 300ms après la frappe
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
                                // Affichage propre : Icône Pin + Label Adresse
                                div.innerHTML =
                                    '<i class="bi bi-geo-alt suggestion-icon text-muted"></i> ' +
                                    feature.properties.label;

                                div.addEventListener("click", function () {
                                    // Remplissage Input visible
                                    input.value = feature.properties.label;

                                    // Remplissage champs cachés
                                    fillHiddenFields(
                                        type,
                                        feature.properties.city,
                                        feature.properties.postcode,
                                        feature.properties.name // Nom de la rue
                                    );

                                    // Validation
                                    input.setAttribute("data-valid", "true");
                                    input.classList.remove("input-error");
                                    results.innerHTML = "";

                                    // Stockage coordonnées + Calcul
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

    // Fermer la liste si on clique ailleurs sur la page
    document.addEventListener("click", function (e) {
        if (e.target !== input && e.target !== results) {
            results.innerHTML = "";
        }
    });
}

document.addEventListener("DOMContentLoaded", function () {
    // 1. Initialiser l'autocomplétion sur Départ et Arrivée
    setupAutocomplete("depart", "suggestions-depart", "depart");
    setupAutocomplete("arrivee", "suggestions-arrivee", "arrivee");

    // 2. Gestion de la soumission du formulaire (Validation finale)
    const form = document.getElementById("trajetForm");
    if (form) {
        form.addEventListener("submit", function (e) {
            const depart = document.getElementById("depart");
            const arrivee = document.getElementById("arrivee");
            const errorMsg = document.getElementById("js-error-message");
            let isValid = true;

            // Vérifie si l'utilisateur a bien cliqué sur une suggestion (data-valid="true")
            // Cela empêche l'envoi de texte libre non géolocalisé
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
                window.scrollTo({ top: 0, behavior: "smooth" }); // Remonte en haut
            } else {
                if (errorMsg) errorMsg.classList.add("d-none");
            }
        });
    }

    // --- 3. VERIFICATION DE L'HORAIRE (Logique Temporelle) ---
    // Empêche de choisir une heure passée si la date est "aujourd'hui"
    const dateInput = document.getElementById("date_depart");
    const timeInput = document.getElementById("heure_depart");

    function verifierHoraire() {
        if (!dateInput || !timeInput) return;

        const now = new Date();
        // Formatage date locale YYYY-MM-DD
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, "0");
        const day = String(now.getDate()).padStart(2, "0");
        const todayStr = `${year}-${month}-${day}`;

        const currentHour = String(now.getHours()).padStart(2, "0");
        const currentMinute = String(now.getMinutes()).padStart(2, "0");
        const currentTimeStr = `${currentHour}:${currentMinute}`;

        // Si la date choisie est AUJOURD'HUI
        if (dateInput.value === todayStr) {
            // On définit l'heure min comme l'heure actuelle
            timeInput.min = currentTimeStr;

            // Si l'utilisateur a déjà mis une heure passée, on reset
            if (timeInput.value && timeInput.value < currentTimeStr) {
                timeInput.value = "";
            }
        } else {
            // Sinon (demain ou plus tard), pas de limite d'heure
            timeInput.removeAttribute("min");
        }
    }

    if (dateInput && timeInput) {
        // Vérifier au changement de date et d'heure
        dateInput.addEventListener("change", verifierHoraire);
        timeInput.addEventListener("change", verifierHoraire);
        // Vérifier dès le chargement de la page
        verifierHoraire();
    }
});
