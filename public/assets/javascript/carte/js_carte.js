// ============================================================
// 1. INITIALISATION
// ============================================================
var map = L.map("map").setView([49.89407, 2.29575], 12);

L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution: "&copy; OpenStreetMap",
}).addTo(map);

var frequentLayer = L.layerGroup().addTo(map);
var routeMarkersLayer = L.layerGroup().addTo(map);
var currentRoutingControl = null;

// Variable cache pour stocker les résultats de l'API
var mesTrajetsCache = null;

function createCustomMarker(color, icon = "fa-location-dot") {
    return L.divIcon({
        className: "custom-div-icon",
        html: `<div class='marker-pin ${color}'><i class='fa-solid ${icon}'></i></div><div class='marker-shadow'></div>`,
        iconSize: [30, 42],
        iconAnchor: [15, 42],
        popupAnchor: [0, -35],
    });
}

var goldIcon = createCustomMarker("marker-gold", "fa-star");
var greenIcon = createCustomMarker("marker-green", "fa-car");
var redIcon = createCustomMarker("marker-red", "fa-flag-checkered");

// ============================================================
// 2. AUTOCOMPLÉTION
// ============================================================
function setupMapAutocomplete(inputId, resultsId) {
    const input = document.getElementById(inputId);
    const results = document.getElementById(resultsId);
    let timeout = null;

    input.addEventListener("input", function() {
        const query = this.value.toLowerCase().trim();
        results.innerHTML = "";
        
        if (query.length < 2) {
            return;
        }

        const matchesLocal = lieuxFrequents.filter(
            (lieu) =>
            lieu.nom_lieu.toLowerCase().includes(query) ||
            lieu.ville.toLowerCase().includes(query)
        );

        if (matchesLocal.length > 0) {
            matchesLocal.forEach((lieu) => {
                const div = document.createElement("div");
                div.className = "autocomplete-suggestion is-frequent";
                div.innerHTML = `<div class="sugg-icon"><i class="bi bi-star-fill"></i></div>
                                 <div class="sugg-text"><span class="sugg-main">${lieu.nom_lieu}</span><span class="sugg-sub">${lieu.ville}</span></div>`;
                
                div.addEventListener("click", function() {
                    input.value = lieu.nom_lieu;
                    results.innerHTML = "";
                });
                results.appendChild(div);
            });
        }

        if (query.length > 3) {
            clearTimeout(timeout);
            timeout = setTimeout(() => {
                fetch(
                    "https://api-adresse.data.gouv.fr/search/?q=" + query + "&limit=3"
                )
                .then((response) => response.json())
                .then((data) => {
                    if (data.features && data.features.length > 0) {
                        data.features.forEach((feature) => {
                            const div = document.createElement("div");
                            div.className = "autocomplete-suggestion is-api";
                            div.innerHTML = `<div class="sugg-icon"><i class="bi bi-geo-alt-fill"></i></div>
                                             <div class="sugg-text"><span class="sugg-main">${feature.properties.name}</span><span class="sugg-sub">${feature.properties.city || ""}</span></div>`;
                            
                            div.addEventListener("click", function() {
                                input.value = feature.properties.label;
                                results.innerHTML = "";
                            });
                            results.appendChild(div);
                        });
                    }
                });
            }, 300);
        }
    });

    document.addEventListener("click", function(e) {
        if (e.target !== input && e.target !== results) {
            results.innerHTML = "";
        }
    });
}

setupMapAutocomplete("departInput", "suggestions-depart");
setupMapAutocomplete("arriveeInput", "suggestions-arrivee");

// ============================================================
// 3. LIEUX FRÉQUENTS & GÉOCODAGE
// ============================================================
function afficherLieuxFrequents() {
    lieuxFrequents.forEach(function(lieu) {
        if (lieu.latitude && lieu.longitude) {
            L.marker([lieu.latitude, lieu.longitude], { icon: goldIcon })
                .bindPopup(
                    "<b>" +
                    lieu.nom_lieu +
                    '</b><br><span class="text-muted">Lieu fréquent</span>'
                )
                .addTo(frequentLayer);
        }
    });
}
afficherLieuxFrequents();

async function geocodeVille(nomVille) {
    const lieuConnu = lieuxFrequents.find((l) => {
        let dbName = l.nom_lieu.toLowerCase().trim();
        let searchName = nomVille.toLowerCase().trim();
        return dbName.includes(searchName) || searchName.includes(dbName);
    });

    if (lieuConnu && lieuConnu.latitude && lieuConnu.longitude) {
        return L.latLng(lieuConnu.latitude, lieuConnu.longitude);
    }

    let cleanQuery = nomVille.split("(")[0].trim();
    try {
        const url = `https://api-adresse.data.gouv.fr/search/?q=${encodeURIComponent(cleanQuery)}&limit=1`;
        const response = await fetch(url);
        const data = await response.json();
        
        if (data.features && data.features.length > 0) {
            const coords = data.features[0].geometry.coordinates;
            return L.latLng(coords[1], coords[0]);
        }
    } catch (error) {
        return null;
    }
    return null;
}

// ============================================================
// 4. RECHERCHE INTELLIGENTE
// ============================================================
function filtrerTrajetsFuturs(trajets) {
    const maintenant = new Date();
    return trajets.filter(t => {
        const dateTrajet = new Date(t.date_heure_depart.replace(" ", "T"));
        return dateTrajet >= maintenant;
    });
}

function rechercherTrajet() {
    var departTxt = document.getElementById("departInput").value.toLowerCase().trim();
    var arriveeTxt = document.getElementById("arriveeInput").value.toLowerCase().trim();
    var statusDiv = document.getElementById("searchStatus");

    // --- SÉCURITÉ : Blocage si Départ == Arrivée ---
    if (departTxt !== "" && arriveeTxt !== "" && departTxt === arriveeTxt) {
        statusDiv.innerHTML = '<span class="text-danger fw-bold"><i class="bi bi-exclamation-triangle-fill"></i> Le départ et l\'arrivée ne peuvent pas être identiques.</span>';
        return;
    }

    if (departTxt === "" && arriveeTxt === "") {
        statusDiv.innerHTML = "Saisissez un lieu.";
        return;
    }

    statusDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Recherche...';

    var resultats = tousLesTrajets.filter(function(trajet) {
        if (typeof userId !== 'undefined' && userId > 0 && trajet.id_conducteur == userId) {
            return false;
        }

        var dbDepart = trajet.ville_depart.toLowerCase();
        var dbArrivee = trajet.ville_arrivee.toLowerCase();
        var matchDepart = true;
        var matchArrivee = true;

        if (departTxt !== "") {
            matchDepart = dbDepart.includes(departTxt) || departTxt.includes(dbDepart);
        }
        if (arriveeTxt !== "") {
            matchArrivee = dbArrivee.includes(arriveeTxt) || arriveeTxt.includes(dbArrivee);
        }
        return matchDepart && matchArrivee;
    });

    resultats = filtrerTrajetsFuturs(resultats);

    var modeAlternatif = false;

    // Recherche alternative (Arrivée seule)
    if (resultats.length === 0 && arriveeTxt !== "") {
        modeAlternatif = true;
        resultats = tousLesTrajets.filter((t) => {
            if (typeof userId !== 'undefined' && userId > 0 && t.id_conducteur == userId) {
                return false;
            }
            var dbArrivee = t.ville_arrivee.toLowerCase();
            return dbArrivee.includes(arriveeTxt) || arriveeTxt.includes(dbArrivee);
        });
        resultats = filtrerTrajetsFuturs(resultats);
    }

    // Recherche alternative (Départ seul)
    if (resultats.length === 0 && departTxt !== "") {
        modeAlternatif = true;
        resultats = tousLesTrajets.filter((t) => {
            if (typeof userId !== 'undefined' && userId > 0 && t.id_conducteur == userId) {
                return false;
            }
            var dbDepart = t.ville_depart.toLowerCase();
            return dbDepart.includes(departTxt) || departTxt.includes(dbDepart);
        });
        resultats = filtrerTrajetsFuturs(resultats);
    }

    // Défaut (Suggestions)
    if (resultats.length === 0) {
        modeAlternatif = true;
        resultats = filtrerTrajetsFuturs(tousLesTrajets).filter((t) => {
            if (typeof userId !== 'undefined' && userId > 0 && t.id_conducteur == userId) {
                return false;
            }
            return true;
        }).slice(0, 10);
    }

    if (currentRoutingControl) {
        map.removeControl(currentRoutingControl);
        currentRoutingControl = null;
    }
    routeMarkersLayer.clearLayers();

    if (resultats.length > 0) {
        if (modeAlternatif) {
            statusDiv.innerHTML = '<span class="text-warning fw-bold"><i class="bi bi-exclamation-triangle"></i> Trajet exact introuvable. <br>Voici des alternatives :</span>';
        } else {
            statusDiv.innerHTML = '<span class="text-success fw-bold">' + resultats.length + " trajet(s) trouvé(s).</span>";
        }
        afficherResultatsSidebar(resultats, modeAlternatif, false, "Résultats");
    } else {
        statusDiv.innerHTML = '<span class="text-danger">Aucun trajet trouvé.</span>';
        document.getElementById("infoSidebar").classList.remove("active");
    }
}

// ============================================================
// 5. CHARGEMENT API (DONNÉES PERSO)
// ============================================================
async function chargerDonneesPerso() {
    if (mesTrajetsCache) {
        return mesTrajetsCache;
    }

    try {
        const response = await fetch('/sae-covoiturage/public/api/mes-trajets-carte');
        const data = await response.json();
        
        if (data.success) {
            mesTrajetsCache = data;
            return data;
        }
    } catch (error) {
        console.error("Erreur API :", error);
    }
    
    return { annonces: [], reservations: [] };
}

// ============================================================
// 6. AFFICHAGE ITINÉRAIRE
// ============================================================
async function afficherItineraire(idTrajet) {
    var trajet = tousLesTrajets.find((t) => t.id_trajet == idTrajet);

    if (!trajet && mesTrajetsCache) {
        trajet = mesTrajetsCache.annonces.find(t => t.id_trajet == idTrajet) ||
                 mesTrajetsCache.reservations.find(t => t.id_trajet == idTrajet);
    }

    if (!trajet) {
        return;
    }

    var statusDiv = document.getElementById("searchStatus");
    statusDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Calcul itinéraire...';

    try {
        if (currentRoutingControl) {
            map.removeControl(currentRoutingControl);
        }
        routeMarkersLayer.clearLayers();

        const [departLatLng, arriveeLatLng] = await Promise.all([
            geocodeVille(trajet.ville_depart),
            geocodeVille(trajet.ville_arrivee),
        ]);

        if (!departLatLng || !arriveeLatLng) {
            statusDiv.innerHTML = '<span class="text-danger">Localisation impossible.</span>';
            return;
        }

        L.marker(departLatLng, { icon: greenIcon })
            .addTo(routeMarkersLayer)
            .bindPopup("<b>Départ</b><br>" + trajet.ville_depart);
            
        L.marker(arriveeLatLng, { icon: redIcon })
            .addTo(routeMarkersLayer)
            .bindPopup("<b>Arrivée</b><br>" + trajet.ville_arrivee);

        currentRoutingControl = L.Routing.control({
            waypoints: [departLatLng, arriveeLatLng],
            routeWhileDragging: false,
            show: false,
            fitSelectedRoutes: true,
            lineOptions: { styles: [{ color: "#007bff", opacity: 0.7, weight: 5 }] },
            createMarker: function() {
                return null;
            },
        }).addTo(map);

        statusDiv.innerHTML = '<span class="text-success">Itinéraire affiché !</span>';
        highlightSelectedCard(idTrajet);

    } catch (error) {
        statusDiv.innerHTML = '<span class="text-warning">Erreur calcul.</span>';
    }
}

// ============================================================
// 7. AFFICHAGE SIDEBAR
// ============================================================
function afficherResultatsSidebar(resultats, isAlternative, isPerso = false, titrePersonnalise = null) {
    var container = document.getElementById("listeTrajetsContainer");
    var html = "";

    var titre = titrePersonnalise || (isPerso ? "Mes Trajets" : (isAlternative ? "Suggestions" : "Résultats"));

    if (isAlternative) {
        html += '<div class="alert alert-warning small mb-3"><i class="bi bi-exclamation-triangle"></i> Trajet exact introuvable. <br>Voici des alternatives :</div>';
    }

    if (!resultats || resultats.length === 0) {
        html += '<div class="text-center text-muted mt-4">Aucun trajet à afficher.</div>';
    } else {
        resultats.forEach(function(t) {
            var dateObj = new Date(t.date_heure_depart.replace(" ", "T"));
            var heure = ("0" + dateObj.getHours()).slice(-2) + ":" + ("0" + dateObj.getMinutes()).slice(-2);
            var date = ("0" + dateObj.getDate()).slice(-2) + "/" + ("0" + (dateObj.getMonth() + 1)).slice(-2);

            var cardClass = isAlternative ? "trip-card alternative" : "trip-card";
            var badgeClass = "badge bg-success rounded-pill px-3";
            var badgeText = t.places_proposees + " pl.";

            // URL et Texte par défaut
            var btnUrl = "/sae-covoiturage/public/trajet/reserver/" + t.id_trajet;
            var btnText = 'Réserver <i class="bi bi-chevron-right"></i>';

            if (isPerso) {
                btnText = 'Voir détails';

                if (t.mon_role === "conducteur") {
                    // SI CONDUCTEUR -> Modifier
                    btnUrl = "/sae-covoiturage/public/trajet/modifier/" + t.id_trajet;
                    badgeClass = "badge bg-primary rounded-pill px-3";
                    badgeText = "Mon Annonce";
                } else {
                    // SI PASSAGER -> Messagerie (Pour éviter l'erreur "Déjà réservé")
                    // MODIFICATION ICI : On redirige vers la conversation
                    btnUrl = "/sae-covoiturage/public/messagerie/conversation/" + t.id_trajet;
                    badgeClass = "badge bg-info text-dark rounded-pill px-3";
                    badgeText = "Ma Réservation";
                }
            } else if (isAlternative) {
                badgeClass = "badge badge-alternative rounded-pill px-3";
            }

            html += `
                <div class="${cardClass}" id="card-${t.id_trajet}">
                    <div style="cursor:pointer;" onclick="afficherItineraire(${t.id_trajet})">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <div>
                                <span class="trip-time">${heure}</span>
                                <span class="text-muted small ms-1">(${date})</span>
                            </div>
                            <span class="${badgeClass}">${badgeText}</span>
                        </div>
                        <div class="mb-2">
                            <strong>${t.ville_depart.split(",")[0]}</strong> 
                            <i class="bi bi-arrow-right text-muted mx-1"></i> 
                            <strong>${t.ville_arrivee.split(",")[0]}</strong>
                        </div>
                    </div>
                    
                    <div class="mt-2 pt-2 border-top d-flex justify-content-end">
                        <a href="${btnUrl}" class="btn btn-sm btn-purple rounded-pill text-white fw-bold px-3">
                            ${btnText}
                        </a>
                    </div>
                </div>`;
        });
    }

    container.innerHTML = html;
    document.getElementById("sidebarTitle").innerText = titre;
    document.getElementById("sidebarSubtitle").innerText = (resultats ? resultats.length : 0) + " trajet(s)";
    document.getElementById("infoSidebar").classList.add("active");
}

// ============================================================
// 8. BOUTONS (Avec Titres)
// ============================================================
async function afficherMesAnnonces() {
    var statusDiv = document.getElementById("searchStatus");
    statusDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Chargement...';

    if (currentRoutingControl) {
        map.removeControl(currentRoutingControl);
        currentRoutingControl = null;
    }
    routeMarkersLayer.clearLayers();

    const data = await chargerDonneesPerso();
    const annonces = data.annonces || [];

    if (annonces.length === 0) {
        statusDiv.innerHTML = '<span class="text-muted">Aucune annonce trouvée.</span>';
    } else {
        statusDiv.innerHTML = `<span class="text-primary fw-bold">Vos ${annonces.length} annonces.</span>`;
    }

    afficherResultatsSidebar(annonces, false, true, "Mes Annonces");
}

async function afficherMesReservations() {
    var statusDiv = document.getElementById("searchStatus");
    statusDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Chargement...';

    if (currentRoutingControl) {
        map.removeControl(currentRoutingControl);
        currentRoutingControl = null;
    }
    routeMarkersLayer.clearLayers();

    const data = await chargerDonneesPerso();
    const reservations = data.reservations || [];

    if (reservations.length === 0) {
        statusDiv.innerHTML = '<span class="text-muted">Aucune réservation trouvée.</span>';
    } else {
        statusDiv.innerHTML = `<span class="text-info fw-bold">Vos ${reservations.length} réservations.</span>`;
    }

    afficherResultatsSidebar(reservations, false, true, "Mes Réservations");
}

// ============================================================
// 9. UTILITAIRES
// ============================================================
function highlightSelectedCard(id) {
    document
        .querySelectorAll(".trip-card")
        .forEach((c) => c.classList.remove("selected"));
        
    const card = document.getElementById("card-" + id);
    if (card) {
        card.classList.add("selected");
        card.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
}

function closeSidebar() {
    document.getElementById("infoSidebar").classList.remove("active");
    if (currentRoutingControl) {
        map.removeControl(currentRoutingControl);
        currentRoutingControl = null;
    }
    routeMarkersLayer.clearLayers();
}

function handleEnter(e) {
    if (e.key === "Enter") {
        rechercherTrajet();
    }
}