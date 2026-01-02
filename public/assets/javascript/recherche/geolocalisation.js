document.addEventListener('DOMContentLoaded', function() {
    const cookieConsent = document.cookie.match(/(?:^|; )cookie_consent=([^;]*)/);
    const warningText = document.getElementById('cookie-warning');
    if (warningText) {
        let showWarning = true;
        if (cookieConsent) {
            try {
                const consentData = JSON.parse(cookieConsent);
                if (consentData.performance == 1) {
                    showWarning = false;
                }
            } catch (e) { console.error("Erreur lecture cookie", e); }
        }
        if (showWarning) {
            warningText.classList.remove('d-none');
        }
    }

    // --- NOUVEAU : SCRIPT DE GÉOLOCALISATION ---
    const btnGeo = document.getElementById('btn-geo');
    const inputDepart = document.getElementById('depart');
    const iconGeo = btnGeo.querySelector('i');

    if (btnGeo && inputDepart) {
        btnGeo.addEventListener('click', function() {
            if (!navigator.geolocation) {
                alert("La géolocalisation n'est pas supportée par votre navigateur.");
                return;
            }

            // Animation de chargement
            iconGeo.classList.remove('bi-geo-alt-fill');
            iconGeo.classList.add('bi-arrow-repeat', 'geo-loading');

            navigator.geolocation.getCurrentPosition(
                (position) => {
                    const lat = position.coords.latitude;
                    const lon = position.coords.longitude;

                    // Appel API Adresse Gouv (Reverse Geocoding)
                    fetch('https://api-adresse.data.gouv.fr/reverse/?lon=' + lon + '&lat=' + lat)
                        .then(response => response.json())
                        .then(data => {
                            if (data.features && data.features.length > 0) {
                                // On prend la meilleure correspondance
                                const adresseComplete = data.features[0].properties.label;
                                inputDepart.value = adresseComplete;
                            } else {
                                alert("Adresse introuvable.");
                            }
                        })
                        .catch(error => {
                            console.error('Erreur API :', error);
                            alert("Impossible de récupérer l'adresse.");
                        })
                        .finally(() => {
                            // Remettre l'icône normale
                            iconGeo.classList.remove('bi-arrow-repeat', 'geo-loading');
                            iconGeo.classList.add('bi-geo-alt-fill');
                        });
                },
                (error) => {
                    // Gestion des erreurs
                    iconGeo.classList.remove('bi-arrow-repeat', 'geo-loading');
                    iconGeo.classList.add('bi-geo-alt-fill');
                    
                    switch(error.code) {
                        case error.PERMISSION_DENIED:
                            alert("Vous avez refusé la demande de géolocalisation.");
                            break;
                        case error.POSITION_UNAVAILABLE:
                            alert("Les informations de localisation sont indisponibles.");
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