// --- VARIABLES GLOBALES ---
let departCoords = null; // [long, lat]
let arriveeCoords = null; // [long, lat]

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
  // On ne calcule que si on a les deux coordonnées
  if (departCoords && arriveeCoords) {
    // Format OSRM : long,lat;long,lat
    const url = `https://router.project-osrm.org/route/v1/driving/${departCoords[0]},${departCoords[1]};${arriveeCoords[0]},${arriveeCoords[1]}?overview=false`;

    fetch(url)
      .then((res) => res.json())
      .then((data) => {
        if (data.routes && data.routes.length > 0) {
          const durationSeconds = data.routes[0].duration; // Durée en secondes
          const distanceMeters = data.routes[0].distance; // Distance en mètres

          // 1. Convertir en HH:MM:SS pour MySQL
          const date = new Date(0);
          date.setSeconds(durationSeconds);
          const timeString = date.toISOString().substr(11, 8);

          // 2. Remplir les champs cachés
          const dureeInput = document.getElementById("duree_calc");
          const distanceInput = document.getElementById("distance_calc");

          if (dureeInput) dureeInput.value = timeString;
          if (distanceInput)
            distanceInput.value = Math.round(distanceMeters / 1000); // km

          console.log(
            `Itinéraire calculé : ${timeString} (${Math.round(
              distanceMeters / 1000
            )} km)`
          );

          // 3. Feedback visuel sur le bouton
          const btn = document.querySelector(".btn-submit-trajet");
          const originalText = "Poster le(s) trajet(s)";

          // Convertir en minutes pour l'affichage
          const minutes = Math.round(durationSeconds / 60);
          const heures = Math.floor(minutes / 60);
          const minutesRestantes = minutes % 60;

          let dureeTexte = `${minutes} min`;
          if (heures > 0) dureeTexte = `${heures}h${minutesRestantes}`;

          btn.innerHTML = `<i class="bi bi-check-circle"></i> Durée estimée : ${dureeTexte}`;
          btn.classList.add("btn-success");

          // Remettre le texte normal après 4 secondes
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
function getCoordsFromName(ville, callback) {
  fetch("https://api-adresse.data.gouv.fr/search/?q=" + ville + "&limit=1")
    .then((res) => res.json())
    .then((data) => {
      if (data.features && data.features.length > 0) {
        callback(data.features[0].geometry.coordinates);
        calculateRoute(); // Lancer le calcul une fois les coords obtenues
      }
    });
}

// --- FONCTION AUTOCOMPLETE ---
function setupAutocomplete(inputId, resultsId, type) {
  const input = document.getElementById(inputId);
  const results = document.getElementById(resultsId);

  if (!input || !results) return;

  let timeout = null;

  input.addEventListener("input", function () {
    // Reset validation
    this.setAttribute("data-valid", "false");
    this.classList.remove("is-valid");

    // Si on change le texte, on reset les coordonnées correspondantes
    if (type === "depart") departCoords = null;
    if (type === "arrivee") arriveeCoords = null;

    const query = this.value.toLowerCase().trim();
    results.innerHTML = "";

    if (query.length < 2) return;

    // 1. Lieux Fréquents (Variable globale injectée par Smarty)
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
          let adresseComplete = lieu.nom_lieu; // On affiche le nom du lieu
          input.value = adresseComplete;
          input.setAttribute("data-valid", "true");
          input.classList.remove("input-error");
          results.innerHTML = "";

          // Pour les lieux fréquents, on doit chercher les coordonnées de la ville
          // car elles ne sont pas stockées dans la variable JS locale
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

                  // Sauvegarde des coordonnées [long, lat]
                  const coords = feature.geometry.coordinates;
                  if (type === "depart") departCoords = coords;
                  else arriveeCoords = coords;

                  // Tenter le calcul
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
  // Configurer l'autocomplétion avec le type (depart ou arrivee)
  setupAutocomplete("depart", "suggestions-depart", "depart");
  setupAutocomplete("arrivee", "suggestions-arrivee", "arrivee");

  // Validation formulaire
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
