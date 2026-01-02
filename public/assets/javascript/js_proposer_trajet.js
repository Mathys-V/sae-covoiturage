// ============================================================
// 1. VARIABLES GLOBALES & CONSTANTES
// ============================================================
let departCoords = null; // [long, lat]
let arriveeCoords = null; // [long, lat]

// Dictionnaire de coordonnées fixes pour éviter les erreurs "0km" sur les lieux très connus
const KNOWN_LOCATIONS = {
  "IUT d'Amiens": [2.264032, 49.870683],
  "Gare d'Amiens": [2.306739, 49.890583],
  "Gare de Longueau": [2.353159, 49.864238],
  "Mairie de Dury": [2.268248, 49.846271],
  "Centre-ville": [2.3089, 49.8872],
};

// ============================================================
// 2. FONCTIONS UTILITAIRES (DOM)
// ============================================================

// Remplir les champs cachés (Ville, CP, Rue) pour la BDD
function fillHiddenFields(type, ville, cp, rue) {
  const villeInput = document.getElementById(`val_ville_${type}`);
  const cpInput = document.getElementById(`val_cp_${type}`);
  const rueInput = document.getElementById(`val_rue_${type}`);

  if (villeInput) villeInput.value = ville || "";
  if (cpInput) cpInput.value = cp || "";
  if (rueInput) rueInput.value = rue || "";
}

// Vider les champs cachés
function clearHiddenFields(type) {
  fillHiddenFields(type, "", "", "");
}

// Afficher/Masquer la date de fin (Trajet régulier)
function toggleDateFin(show) {
  const wrapper = document.getElementById("date_fin_wrapper");
  const input = wrapper.querySelector("input");

  if (show) {
    wrapper.classList.add("visible");
    input.required = true;
    updateSummary();
  } else {
    wrapper.classList.remove("visible");
    input.required = false;
    input.value = "";

    const summaryCard = document.getElementById("summary-card");
    if (summaryCard) summaryCard.classList.add("d-none");
  }
}

// Mettre à jour le résumé textuel (ex: "5 trajets les lundis...")
function updateSummary() {
  const dateDepartInput = document.getElementById("date_depart");
  const dateFinInput = document.getElementById("date_fin");
  const heureInput = document.getElementById("heure_depart");
  const summaryCard = document.getElementById("summary-card");
  const summaryText = document.getElementById("summary-text");
  const radioOui = document.getElementById("regulier_oui");

  if (
    !dateDepartInput ||
    !dateFinInput ||
    !heureInput ||
    !summaryCard ||
    !radioOui
  )
    return;

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

    if (endDate <= startDate) {
      summaryCard.classList.remove("d-none", "alert-info");
      summaryCard.classList.add("alert-danger");
      summaryText.innerHTML = "La date de fin doit être après le départ.";
      return;
    }

    const diffTime = Math.abs(endDate - startDate);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    const nbTrajets = Math.floor(diffDays / 7) + 1;

    const options = { weekday: "long" };
    const jourSemaine = new Intl.DateTimeFormat("fr-FR", options).format(
      startDate
    );
    const optionsDate = { day: "2-digit", month: "2-digit", year: "numeric" };
    const startDisplay = startDate.toLocaleDateString("fr-FR", optionsDate);
    const endDisplay = endDate.toLocaleDateString("fr-FR", optionsDate);

    const message = `Il y aura <strong>${nbTrajets} trajets</strong> du ${startDisplay} au ${endDisplay}, chaque <strong>${jourSemaine} à ${heureStr}</strong>.`;

    summaryCard.classList.remove("d-none", "alert-danger");
    summaryCard.classList.add("alert-info");
    summaryText.innerHTML = message;
  } else {
    summaryCard.classList.add("d-none");
  }
}

// ============================================================
// 3. FONCTIONS TECHNIQUES (Calcul Itinéraire & API)
// ============================================================

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

    const url = `https://router.project-osrm.org/route/v1/driving/${departCoords[0]},${departCoords[1]};${arriveeCoords[0]},${arriveeCoords[1]}?overview=false`;

    fetch(url)
      .then((res) => res.json())
      .then((data) => {
        if (data.routes && data.routes.length > 0) {
          const durationSeconds = data.routes[0].duration;
          const distanceMeters = data.routes[0].distance;

          // Conversion durée pour input time (01:30:00)
          const date = new Date(0);
          date.setSeconds(durationSeconds);
          const timeString = date.toISOString().substr(11, 8);

          const dureeInput = document.getElementById("duree_calc");
          const distanceInput = document.getElementById("distance_calc");

          if (dureeInput) dureeInput.value = timeString;
          if (distanceInput)
            distanceInput.value = Math.round(distanceMeters / 1000);

          // Feedback visuel sur le bouton
          const btn = document.querySelector(".btn-submit-trajet");
          const originalText = "Poster le(s) trajet(s)";
          const minutes = Math.round(durationSeconds / 60);
          const heures = Math.floor(minutes / 60);
          const minutesRestantes = minutes % 60;

          let dureeTexte = `${minutes} min`;
          if (heures > 0) dureeTexte = `${heures}h${minutesRestantes}`;

          btn.innerHTML = `<i class="bi bi-check-circle"></i> Durée estimée : ${dureeTexte} (${Math.round(
            distanceMeters / 1000
          )}km)`;
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

// Récupère les coordonnées d'une ville (fallback si pas de coordonnées dans les favoris)
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

// ============================================================
// 4. LOGIQUE D'AUTOCOMPLÉTION (Le cœur du système)
// ============================================================

function setupAutocomplete(inputId, resultsId, type) {
  const input = document.getElementById(inputId);
  const results = document.getElementById(resultsId);
  if (!input || !results) return;
  let timeout = null;

  input.addEventListener("input", function () {
    // Reset validation et champs cachés
    this.setAttribute("data-valid", "false");
    this.classList.remove("is-valid");
    clearHiddenFields(type);

    if (type === "depart") departCoords = null;
    if (type === "arrivee") arriveeCoords = null;

    const query = this.value.trim().toLowerCase();
    results.innerHTML = "";

    // On attend au moins 2 caractères
    if (query.length < 2) return;

    // --- A. RECHERCHE DANS LES LIEUX FRÉQUENTS (Globaux) ---
    // On récupère la variable globale définie dans le TPL
    const localData = window.lieuxFrequents || [];

    // CORRECTION ICI : Recherche dans le label OU l'adresse complète
    const matchesLocal = localData.filter((lieu) => {
      const label = lieu.label ? lieu.label.toLowerCase() : "";
      const fullAddr = lieu.full_address ? lieu.full_address.toLowerCase() : "";

      return label.includes(query) || fullAddr.includes(query);
    });

    if (matchesLocal.length > 0) {
      matchesLocal.forEach((lieu) => {
        const div = document.createElement("div");
        div.className = "autocomplete-suggestion is-frequent";
        // Affichage propre : Label + Ville
        div.innerHTML = `<i class="bi bi-star-fill suggestion-icon text-warning"></i> <strong>${lieu.label}</strong> <small class="text-muted">(${lieu.ville})</small>`;

        div.addEventListener("click", function () {
          input.value = lieu.label; // On met le nom du lieu dans le champ

          // On remplit les champs cachés
          fillHiddenFields(type, lieu.ville, lieu.code_postal, lieu.rue);

          input.setAttribute("data-valid", "true");
          input.classList.remove("input-error");
          results.innerHTML = "";

          // Gestion des coordonnées pour le calcul
          if (KNOWN_LOCATIONS && KNOWN_LOCATIONS[lieu.label]) {
            const coords = KNOWN_LOCATIONS[lieu.label];
            if (type === "depart") departCoords = coords;
            else arriveeCoords = coords;
            calculateRoute();
          } else {
            // Si on n'a pas les coords en dur, on demande à l'API via la ville
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

    // --- B. RECHERCHE API ADRESSE GOUV ---
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
                  '<i class="bi bi-geo-alt suggestion-icon text-muted"></i> ' +
                  feature.properties.label;

                div.addEventListener("click", function () {
                  input.value = feature.properties.label;

                  fillHiddenFields(
                    type,
                    feature.properties.city,
                    feature.properties.postcode,
                    feature.properties.name // Nom de la rue
                  );

                  input.setAttribute("data-valid", "true");
                  input.classList.remove("input-error");
                  results.innerHTML = "";

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

// ============================================================
// 5. INITIALISATION
// ============================================================

document.addEventListener("DOMContentLoaded", function () {
  // 1. Initialiser l'autocomplétion
  setupAutocomplete("depart", "suggestions-depart", "depart");
  setupAutocomplete("arrivee", "suggestions-arrivee", "arrivee");

  // 2. Gestion de la soumission du formulaire (Validation)
  const form = document.getElementById("trajetForm");
  if (form) {
    form.addEventListener("submit", function (e) {
      const depart = document.getElementById("depart");
      const arrivee = document.getElementById("arrivee");
      const errorMsg = document.getElementById("js-error-message");
      let isValid = true;

      // Vérifie si l'utilisateur a bien cliqué sur une suggestion
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
