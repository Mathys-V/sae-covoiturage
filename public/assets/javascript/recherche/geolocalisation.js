document.addEventListener("DOMContentLoaded", function () {
  /*
   * Gestion du consentement aux cookies.
   */
  const cookieConsent = document.cookie.match(/(?:^|; )cookie_consent=([^;]*)/);
  const warningText = document.getElementById("cookie-warning");

  if (warningText) {
    let showWarning = true;
    if (cookieConsent) {
      try {
        const consentData = JSON.parse(cookieConsent);
        if (consentData.performance == 1) {
          showWarning = false;
        }
      } catch (e) {
        console.error("Erreur lecture cookie", e);
      }
    }
    if (showWarning) {
      warningText.classList.remove("d-none");
    }
  }

  /*
   * Initialisation du module de géolocalisation inversée.
   */
  const btnGeo = document.getElementById("btn-geo");
  const inputDepart = document.getElementById("depart");
  const iconGeo = btnGeo ? btnGeo.querySelector("i") : null;

  if (btnGeo && inputDepart) {
    // --- GESTION DU CLIC ---
    btnGeo.addEventListener("click", function () {
      // 1. Vérification du support navigateur
      if (!navigator.geolocation) {
        alert("Désolé, votre navigateur ne supporte pas la géolocalisation.");
        return;
      }

      // 2. Animation de chargement
      iconGeo.classList.remove("bi-geo-alt-fill");
      iconGeo.classList.add("bi-arrow-repeat", "geo-loading");

      // 3. Demande de position
      navigator.geolocation.getCurrentPosition(
        // --- SUCCÈS (Position GPS obtenue) ---
        (position) => {
          const lat = position.coords.latitude;
          const lon = position.coords.longitude;

          // Appel à l'API Adresse (France uniquement)
          fetch(
            "https://api-adresse.data.gouv.fr/reverse/?lon=" +
              lon +
              "&lat=" +
              lat
          )
            .then((response) => response.json())
            .then((data) => {
              if (data.features && data.features.length > 0) {
                // CAS A : Adresse trouvée
                const adresseComplete = data.features[0].properties.label;
                inputDepart.value = adresseComplete;
              } else {
                // CAS B : Position trouvée (GPS OK) mais adresse inconnue (Hors France)
                // C'est ici qu'on guide l'utilisateur
                alert(
                  "📍 Position détectée, mais adresse introuvable.\n\n" +
                    "L'outil de recherche automatique ne fonctionne que pour les lieux situés en France métropolitaine.\n\n" +
                    "👉 Solution : Veuillez saisir le nom de votre ville manuellement."
                );
              }
            })
            .catch((error) => {
              console.error("Erreur API :", error);
              alert(
                "Une erreur technique est survenue lors de la communication avec le service d'adresse."
              );
            })
            .finally(() => {
              // Fin du chargement
              iconGeo.classList.remove("bi-arrow-repeat", "geo-loading");
              iconGeo.classList.add("bi-geo-alt-fill");
            });
        },

        // --- ERREUR (Position GPS échouée ou refusée) ---
        (error) => {
          // Fin du chargement
          iconGeo.classList.remove("bi-arrow-repeat", "geo-loading");
          iconGeo.classList.add("bi-geo-alt-fill");

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
              alert(
                "Votre position est actuellement indisponible (signal GPS trop faible ou désactivé sur l'appareil)."
              );
              break;
            case error.TIMEOUT:
              alert(
                "La demande de localisation a pris trop de temps. Veuillez réessayer."
              );
              break;
            default:
              alert("Une erreur inconnue est survenue.");
              break;
          }
        }
      );
    });
  }
});
