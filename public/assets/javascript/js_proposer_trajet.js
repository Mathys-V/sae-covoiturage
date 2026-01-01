// --- VARIABLES GLOBALES ---
let departCoords = null; // [long, lat]
let arriveeCoords = null; // [long, lat]

// --- FONCTION DATE DE FIN (Mise à jour pour le résumé) ---
function toggleDateFin(show) {
  const wrapper = document.getElementById("date_fin_wrapper");
  const input = wrapper.querySelector("input");

  if (show) {
    // Utilisation de la classe CSS pour l'animation
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

// --- FONCTION RÉSUMÉ DYNAMIQUE (Nouvelle fonction) ---
function updateSummary() {
  const dateDepartInput = document.getElementById("date_depart");
  const dateFinInput = document.getElementById("date_fin");
  const heureInput = document.getElementById("heure_depart");
  const summaryCard = document.getElementById("summary-card");
  const summaryText = document.getElementById("summary-text");
  const radioOui = document.getElementById("regulier_oui");

  // Sécurité anti-bug
  if (
    !dateDepartInput ||
    !dateFinInput ||
    !heureInput ||
    !summaryCard ||
    !radioOui
  )
    return;

  // Si pas régulier, on cache
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

    // Vérification cohérence
    if (endDate <= startDate) {
      summaryCard.classList.remove("d-none", "alert-info");
      summaryCard.classList.add("alert-danger");
      summaryText.innerHTML = "La date de fin doit être après le début.";
      return;
    }

    // Calcul du nombre de trajets (1 par semaine)
    const diffTime = Math.abs(endDate - startDate);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    const nbTrajets = Math.floor(diffDays / 7) + 1;

    // Formatage Date
    const options = { weekday: "long" };
    const jourSemaine = new Intl.DateTimeFormat("fr-FR", options).format(
      startDate
    );
    const optionsDate = { day: "2-digit", month: "2-digit", year: "numeric" };
    const startDisplay = startDate.toLocaleDateString("fr-FR", optionsDate);
    const endDisplay = endDate.toLocaleDateString("fr-FR", optionsDate);

    // Message
    const message = `Il y aura <strong>${nbTrajets} trajets</strong> du ${startDisplay} au ${endDisplay}, chaque <strong>${jourSemaine} à ${heureStr}</strong>.`;

    summaryCard.classList.remove("d-none", "alert-danger");
    summaryCard.classList.add("alert-info");
    summaryText.innerHTML = message;
  } else {
    // Données incomplètes
    summaryCard.classList.add("d-none");
  }
}

// --- FONCTION CALCUL ITINÉRAIRE (OSRM) ---
// (Inchangée par rapport à ta version fonctionnelle)
function calculateRoute() {
  if (departCoords && arriveeCoords) {
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
      .catch((err) => {
        console.error("Erreur calcul OSRM", err);
      });
  }
}

// --- FONCTION POUR RÉCUPÉRER COORDS SI LIEU FRÉQUENT ---
// (Inchangée)
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

// --- FONCTION AUTOCOMPLETE ---
// (Inchangée)
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

    const query = this.value.toLowerCase().trim();
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
        div.innerHTML =
          '<i class="bi bi-star-fill suggestion-icon text-warning"></i>' +
          lieu.nom_lieu +
          ' <small class="text-muted">(' +
          lieu.ville +
          ")</small>";

        div.addEventListener("click", function () {
          let adresseComplete = lieu.nom_lieu;
          input.value = adresseComplete;
          input.setAttribute("data-valid", "true");
          input.classList.remove("input-error");
          results.innerHTML = "";

          const callback = (coords) => {
            if (type === "depart") departCoords = coords;
            else arriveeCoords = coords;
          };
          getCoordsFromName(lieu.ville, callback);
        });
        results.appendChild(div);
      });
    }

    if (query.length > 3) {
      clearTimeout(timeout);
      timeout = setTimeout(() => {
        fetch(
          "https://api-adresse.data.gouv.fr/search/?q=" + query + "&limit=5"
        )
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
