// --- VARIABLES GLOBALES ---
let departCoords = null; // [long, lat]
let arriveeCoords = null; // [long, lat]

// --- CORRECTION BUG 0KM (Dictionnaire) ---
const KNOWN_LOCATIONS = {
  "IUT d'Amiens": [2.264032, 49.870683],
  "Gare d'Amiens": [2.306739, 49.890583],
  "Gare de Longueau": [2.353159, 49.864238],
  "Mairie de Dury": [2.268248, 49.846271],
  "Centre-ville": [2.3089, 49.8872],
};

// ============================================================
// 1. FONCTIONS GLOBALES (Interface Utilisateur)
// ============================================================

// AFFICHER/MASQUER LE BLOC DATE DE FIN
function toggleDateFin(show) {
  const wrapper = document.getElementById("date_fin_wrapper");
  const input = wrapper.querySelector("input");

  if (show) {
    wrapper.classList.add("visible");
    input.required = true;
    updateSummary(); // Calculer le résumé immédiatement
  } else {
    wrapper.classList.remove("visible");
    input.required = false;
    input.value = "";

    // Cacher le résumé
    const summaryCard = document.getElementById("summary-card");
    if (summaryCard) summaryCard.classList.add("d-none");
  }
}

// METTRE A JOUR LE TEXTE DU RÉSUMÉ
function updateSummary() {
  const dateDepartInput = document.getElementById("date_depart");
  const dateFinInput = document.getElementById("date_fin");
  const heureInput = document.getElementById("heure_depart");
  const summaryCard = document.getElementById("summary-card");
  const summaryText = document.getElementById("summary-text");
  const radioOui = document.getElementById("regulier_oui");

  // Sécurité
  if (
    !dateDepartInput ||
    !dateFinInput ||
    !heureInput ||
    !summaryCard ||
    !radioOui
  )
    return;

  // Si pas en mode régulier, on cache tout
  if (!radioOui.checked) {
    summaryCard.classList.add("d-none");
    return;
  }

  const startStr = dateDepartInput.value;
  const endStr = dateFinInput.value;
  const heureStr = heureInput.value;

  // On affiche seulement si tout est rempli
  if (startStr && endStr && heureStr) {
    const startDate = new Date(startStr);
    const endDate = new Date(endStr);

    // Vérification cohérence
    if (endDate <= startDate) {
      summaryCard.classList.remove("d-none", "alert-info");
      summaryCard.classList.add("alert-danger");
      summaryText.innerHTML = "La date de fin doit être après le départ.";
      return;
    }

    // Calcul du nombre de semaines
    const diffTime = Math.abs(endDate - startDate);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    const nbTrajets = Math.floor(diffDays / 7) + 1;

    // Affichage texte
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
// 2. FONCTIONS TECHNIQUES (Calcul & API)
// ============================================================

function calculateRoute() {
  if (departCoords && arriveeCoords) {
    // Sécurité 0km (même point)
    if (
      departCoords[0] === arriveeCoords[0] &&
      departCoords[1] === arriveeCoords[1]
    ) {
      console.warn("Points identiques.");
      return;
    }

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
          const distanceInput = document.getElementById("distance_calc");

          if (dureeInput) dureeInput.value = timeString;
          if (distanceInput)
            distanceInput.value = Math.round(distanceMeters / 1000);

          console.log(
            `Itinéraire : ${timeString} (${Math.round(
              distanceMeters / 1000
            )} km)`
          );

          const btn = document.querySelector(".btn-submit-trajet");
          const originalText = "Poster le(s) trajet(s)";
          const minutes = Math.round(durationSeconds / 60);
          let dureeTexte = `${minutes} min`;
          if (minutes > 60) {
            const h = Math.floor(minutes / 60);
            const m = minutes % 60;
            dureeTexte = `${h}h${m}`;
          }

          btn.innerHTML = `<i class="bi bi-check-circle"></i> Durée : ${dureeTexte} (${Math.round(
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

function setupAutocomplete(inputId, resultsId, type) {
  const input = document.getElementById(inputId);
  const results = document.getElementById(resultsId);
  if (!input || !results) return;
  let timeout = null;

  input.addEventListener("input", function () {
    this.setAttribute("data-valid", "false");
    this.classList.remove("is-valid");

    if (type === "depart") departCoords = null;
    if (type === "arrivee") arriveeCoords = null;

    const query = this.value.trim().toLowerCase();
    results.innerHTML = "";
    if (query.length < 2) return;

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
          input.setAttribute("data-valid", "true");
          input.classList.remove("input-error");
          results.innerHTML = "";

          // --- FIX 0KM : Utilisation des coordonnées hardcodées ---
          if (KNOWN_LOCATIONS[lieu.nom_lieu]) {
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
            if (data.features) {
              data.features.forEach((feature) => {
                const div = document.createElement("div");
                div.className = "autocomplete-suggestion";
                div.innerHTML =
                  '<i class="bi bi-geo-alt suggestion-icon text-muted"></i> ' +
                  feature.properties.label;

                div.addEventListener("click", function () {
                  input.value = feature.properties.label;
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
