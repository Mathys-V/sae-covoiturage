document.addEventListener("DOMContentLoaded", function () {
    /*
     * Gestion du consentement aux cookies.
     * On tente de lire un cookie nommé 'cookie_consent' via une Expression Régulière (Regex).
     * Si le cookie existe et contient l'autorisation pour les cookies de "performance",
     * on masque le bandeau d'avertissement. Sinon, on l'affiche par défaut.
     */
    const cookieConsent = document.cookie.match(
        /(?:^|; )cookie_consent=([^;]*)/
    ); // Extraction via groupe capturant
    const warningText = document.getElementById("cookie-warning");

    if (warningText) {
        let showWarning = true;
        if (cookieConsent) {
            try {
                const consentData = JSON.parse(cookieConsent); // Désérialisation du JSON stocké
                if (consentData.performance == 1) {
                    showWarning = false;
                }
            } catch (e) {
                console.error("Erreur lecture cookie", e);
            } // Gestion silencieuse des erreurs de parsing
        }
        if (showWarning) {
            warningText.classList.remove("d-none"); // Manipulation de classe utilitaire Bootstrap
        }
    }

    /*
     * Initialisation du module de géolocalisation inversée.
     * On récupère les références du bouton déclencheur et du champ input cible
     * qui recevra l'adresse postale une fois trouvée.
     */
    // --- NOUVEAU : SCRIPT DE GÉOLOCALISATION ---
    const btnGeo = document.getElementById("btn-geo");
    const inputDepart = document.getElementById("depart");
    const iconGeo = btnGeo ? btnGeo.querySelector("i") : null; // Sécurité si le bouton n'existe pas

    if (btnGeo && inputDepart) {
        /*
         * Gestionnaire d'événement au clic.
         * Vérifie d'abord si le navigateur supporte l'API Geolocation HTML5.
         * Si oui, modifie l'icône pour indiquer un chargement (Feedback UX) et lance la demande de position.
         */
        btnGeo.addEventListener("click", function () {
            if (!navigator.geolocation) {
                // Feature detection
                alert(
                    "La géolocalisation n'est pas supportée par votre navigateur."
                );
                return;
            }

            // Animation de chargement (UX)
            iconGeo.classList.remove("bi-geo-alt-fill");
            iconGeo.classList.add("bi-arrow-repeat", "geo-loading"); // Ajout classe animation CSS

            /*
             * Cœur de la logique : Récupération des coordonnées et Appel API.
             * 1. getCurrentPosition récupère la latitude/longitude (nécessite l'accord utilisateur).
             * 2. On appelle l'API Adresse du gouvernement (Reverse Geocoding) via Fetch.
             * 3. On traite la réponse JSON pour extraire l'adresse la plus pertinente (label).
             */
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    const lat = position.coords.latitude;
                    const lon = position.coords.longitude;

                    // Appel API Adresse Gouv (Reverse Geocoding)
                    fetch(
                        "https://api-adresse.data.gouv.fr/reverse/?lon=" +
                            lon +
                            "&lat=" +
                            lat
                    ) // Requête HTTP GET
                        .then((response) => response.json()) // Parsing du flux de réponse
                        .then((data) => {
                            if (data.features && data.features.length > 0) {
                                // On prend la meilleure correspondance (Feature 0 du GeoJSON)
                                const adresseComplete =
                                    data.features[0].properties.label;
                                inputDepart.value = adresseComplete; // Injection dans le DOM
                            } else {
                                alert("Adresse introuvable.");
                            }
                        })
                        .catch((error) => {
                            console.error("Erreur API :", error);
                            alert("Impossible de récupérer l'adresse.");
                        })
                        .finally(() => {
                            // Nettoyage de l'interface quel que soit le résultat (Succès ou Erreur)
                            iconGeo.classList.remove(
                                "bi-arrow-repeat",
                                "geo-loading"
                            );
                            iconGeo.classList.add("bi-geo-alt-fill");
                        });
                },
                /*
                 * Gestion des erreurs natives de géolocalisation.
                 * Le navigateur renvoie un code d'erreur spécifique (refus, timeout, etc.)
                 * qu'il faut traiter pour informer correctement l'utilisateur.
                 */
                (error) => {
                    // Reset de l'icône
                    iconGeo.classList.remove("bi-arrow-repeat", "geo-loading");
                    iconGeo.classList.add("bi-geo-alt-fill");

                    switch (
                        error.code // Structure de contrôle sur code erreur
                    ) {
                        case error.PERMISSION_DENIED:
                            alert(
                                "Vous avez refusé la demande de géolocalisation."
                            );
                            break;
                        case error.POSITION_UNAVAILABLE:
                            alert(
                                "Les informations de localisation sont indisponibles."
                            );
                            break;
                        case error.TIMEOUT:
                            alert("La demande de localisation a expiré.");
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
