<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carte - MonCovoitJV</title>

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
    <link rel="stylesheet" href="https://unpkg.com/leaflet-routing-machine@latest/dist/leaflet-routing-machine.css" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <link rel="stylesheet" href="/sae-covoiturage/public/assets/css/carte/style_carte.css">

</head>
<body>

    {include file='includes/header.tpl'} 

    <div class="container-fluid p-0 position-relative d-flex flex-column h-100">
        
        <div class="search-card">
            <div class="search-title"><i class="bi bi-map-fill"></i> Trouver un trajet</div>
            
            <div class="input-group-modern">
                <div class="input-icon-box"><i class="bi bi-geo-alt-fill"></i></div>
                <input type="text" id="departInput" class="form-control-map" placeholder="Départ (ex: Amiens)" autocomplete="off">
                <div id="suggestions-depart" class="autocomplete-suggestions"></div>
            </div>

            <div class="input-group-modern">
                <div class="input-icon-box"><i class="bi bi-flag-fill"></i></div>
                <input type="text" id="arriveeInput" class="form-control-map" placeholder="Arrivée (ex: IUT)" autocomplete="off">
                <div id="suggestions-arrivee" class="autocomplete-suggestions"></div>
            </div>

            <button class="btn-search-map" onclick="rechercherTrajet()">
                Rechercher
            </button>

            <div id="searchStatus" class="mt-3 text-center small text-muted"></div>
        </div>

        <div class="legend-card">
            <div class="legend-item"><span class="dot" style="background: #FFD700;"></span> Lieux Fréquents</div>
            <div class="legend-item"><span class="dot" style="background: #28a745;"></span> Départ</div>
            <div class="legend-item"><span class="dot" style="background: #dc3545;"></span> Arrivée</div>
        </div>

        <div id="map-container">
            <div id="map"></div>
            <div id="infoSidebar" class="info-sidebar">
                <div class="sidebar-header">
                    <button class="close-sidebar-btn" onclick="closeSidebar()"><i class="fa-solid fa-xmark"></i></button>
                    <h4 class="m-0 fw-bold" id="sidebarTitle">Résultats</h4>
                    <small id="sidebarSubtitle" class="opacity-75">Trajets disponibles</small>
                </div>
                <div id="listeTrajetsContainer" class="p-3" style="background-color: #f8f9fa; flex-grow: 1; overflow-y: auto;"></div>
            </div>
        </div>
    </div>

    {include file='includes/footer.tpl'}

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
    <script src="https://unpkg.com/leaflet-routing-machine@latest/dist/leaflet-routing-machine.js"></script>

    <script>
        var lieuxFrequents = [];
        var tousLesTrajets = [];
        try {
            lieuxFrequents = JSON.parse('{$lieux_frequents|json_encode|escape:"javascript"}');
            tousLesTrajets = JSON.parse('{$trajets|json_encode|escape:"javascript"}');
        } catch(e) { console.warn("Erreur data", e); }
    </script>

    {literal}
    <script>
        // --- 1. INITIALISATION ---
        var map = L.map('map').setView([49.89407, 2.29575], 12);
        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19, attribution: '&copy; OpenStreetMap' }).addTo(map);

        var frequentLayer = L.layerGroup().addTo(map); 
        var routeMarkersLayer = L.layerGroup().addTo(map);
        var currentRoutingControl = null; 

        function createCustomMarker(color, icon = 'fa-location-dot') {
            return L.divIcon({
                className: 'custom-div-icon',
                html: `<div class='marker-pin ${color}'><i class='fa-solid ${icon}'></i></div><div class='marker-shadow'></div>`,
                iconSize: [30, 42], iconAnchor: [15, 42], popupAnchor: [0, -35]
            });
        }
        var goldIcon = createCustomMarker('marker-gold', 'fa-star');
        var greenIcon = createCustomMarker('marker-green', 'fa-car');
        var redIcon = createCustomMarker('marker-red', 'fa-flag-checkered');

        // --- 2. AUTOCOMPLÉTION ---
        function setupMapAutocomplete(inputId, resultsId) {
            const input = document.getElementById(inputId);
            const results = document.getElementById(resultsId);
            let timeout = null;

            input.addEventListener('input', function() {
                const query = this.value.toLowerCase().trim();
                results.innerHTML = ''; 
                if (query.length < 2) return;

                const matchesLocal = lieuxFrequents.filter(lieu => 
                    lieu.nom_lieu.toLowerCase().includes(query) || 
                    lieu.ville.toLowerCase().includes(query)
                );

                if (matchesLocal.length > 0) {
                    matchesLocal.forEach(lieu => {
                        const div = document.createElement('div');
                        div.className = 'autocomplete-suggestion is-frequent';
                        div.innerHTML = `<div class="sugg-icon"><i class="bi bi-star-fill"></i></div>
                                         <div class="sugg-text"><span class="sugg-main">${lieu.nom_lieu}</span><span class="sugg-sub">${lieu.ville}</span></div>`;
                        div.addEventListener('click', function() { input.value = lieu.nom_lieu; results.innerHTML = ''; });
                        results.appendChild(div);
                    });
                }

                if (query.length > 3) {
                    clearTimeout(timeout);
                    timeout = setTimeout(() => {
                        fetch('https://api-adresse.data.gouv.fr/search/?q=' + query + '&limit=3')
                            .then(response => response.json())
                            .then(data => {
                                if (data.features && data.features.length > 0) {
                                    data.features.forEach(feature => {
                                        const div = document.createElement('div');
                                        div.className = 'autocomplete-suggestion is-api';
                                        div.innerHTML = `<div class="sugg-icon"><i class="bi bi-geo-alt-fill"></i></div>
                                                         <div class="sugg-text"><span class="sugg-main">${feature.properties.name}</span><span class="sugg-sub">${feature.properties.city || ''}</span></div>`;
                                        div.addEventListener('click', function() { input.value = feature.properties.label; results.innerHTML = ''; });
                                        results.appendChild(div);
                                    });
                                }
                            });
                    }, 300);
                }
            });
            document.addEventListener('click', function(e) { if (e.target !== input && e.target !== results) results.innerHTML = ''; });
        }
        setupMapAutocomplete('departInput', 'suggestions-depart');
        setupMapAutocomplete('arriveeInput', 'suggestions-arrivee');

        // --- 3. AFFICHAGE LIEUX FREQUENTS ---
        function afficherLieuxFrequents() {
            lieuxFrequents.forEach(function(lieu) {
                if(lieu.latitude && lieu.longitude) {
                    L.marker([lieu.latitude, lieu.longitude], {icon: goldIcon})
                        .bindPopup('<b>' + lieu.nom_lieu + '</b><br><span class="text-muted">Lieu fréquent</span>')
                        .addTo(frequentLayer);
                }
            });
        }
        afficherLieuxFrequents();

        // --- 4. GÉOCODAGE HYBRIDE ---
        async function geocodeVille(nomVille) {
            // A. Vérification locale (Check si nom ou rue match)
            const lieuConnu = lieuxFrequents.find(l => {
                let dbName = l.nom_lieu.toLowerCase().trim();
                let dbStreet = (l.rue || '').toLowerCase().trim();
                let searchName = nomVille.toLowerCase().trim();
                return dbName.includes(searchName) || searchName.includes(dbName) || (dbStreet && searchName.includes(dbStreet));
            });
            
            if (lieuConnu && lieuConnu.latitude && lieuConnu.longitude) {
                return L.latLng(lieuConnu.latitude, lieuConnu.longitude);
            }

            // B. API ADRESSE GOUV
            let cleanQuery = nomVille.split('(')[0].trim();
            try {
                const url = `https://api-adresse.data.gouv.fr/search/?q=${encodeURIComponent(cleanQuery)}&limit=1`;
                const response = await fetch(url);
                const data = await response.json();
                
                if (data.features && data.features.length > 0) {
                    const coords = data.features[0].geometry.coordinates; 
                    return L.latLng(coords[1], coords[0]);
                }
                return null;
            } catch (error) { return null; }
        }

        // --- 5. RECHERCHE INTELLIGENTE ---
        function rechercherTrajet() {
            var departTxt = document.getElementById('departInput').value.toLowerCase().trim();
            var arriveeTxt = document.getElementById('arriveeInput').value.toLowerCase().trim();
            var statusDiv = document.getElementById('searchStatus');

            if(departTxt === "" && arriveeTxt === "") {
                statusDiv.innerHTML = "Saisissez un lieu.";
                return;
            }

            statusDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Recherche...';
            
            // 1. Recherche STRICTE
            var resultats = tousLesTrajets.filter(function(trajet) {
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

            // 2. Recherche ALTERNATIVE
            var modeAlternatif = false;
            
            // Si vide, on tente par destination
            if (resultats.length === 0 && arriveeTxt !== "") {
                modeAlternatif = true;
                resultats = tousLesTrajets.filter(t => {
                    var dbArrivee = t.ville_arrivee.toLowerCase();
                    return dbArrivee.includes(arriveeTxt) || arriveeTxt.includes(dbArrivee);
                });
            }

            // Si encore vide, on tente par départ
            if (resultats.length === 0 && departTxt !== "") {
                modeAlternatif = true;
                resultats = tousLesTrajets.filter(t => {
                    var dbDepart = t.ville_depart.toLowerCase();
                    return dbDepart.includes(departTxt) || departTxt.includes(dbDepart);
                });
            }

            // Si TOUJOURS vide, on prend tout
            if (resultats.length === 0) {
                modeAlternatif = true;
                resultats = tousLesTrajets.slice(0, 10);
            }

            // Nettoyage carte
            if (currentRoutingControl) {
                map.removeControl(currentRoutingControl);
                currentRoutingControl = null;
            }
            routeMarkersLayer.clearLayers();
            
            // Affichage
            if (resultats.length > 0) {
                if (modeAlternatif) {
                    statusDiv.innerHTML = '<span class="text-warning fw-bold"><i class="bi bi-exclamation-triangle"></i> Trajet exact introuvable. <br>Voici des alternatives :</span>';
                } else {
                    statusDiv.innerHTML = '<span class="text-success fw-bold">' + resultats.length + ' trajet(s) trouvé(s).</span>';
                }
                afficherResultatsSidebar(resultats, modeAlternatif);
            } else {
                statusDiv.innerHTML = '<span class="text-danger">Aucun trajet trouvé.</span>';
                document.getElementById('infoSidebar').classList.remove('active');
            }
        }

        // --- 6. ITINÉRAIRE ---
        async function afficherItineraire(idTrajet) {
            var trajet = tousLesTrajets.find(t => t.id_trajet == idTrajet);
            if(!trajet) return;

            var statusDiv = document.getElementById('searchStatus');
            statusDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Calcul itinéraire...';

            try {
                if (currentRoutingControl) map.removeControl(currentRoutingControl);
                routeMarkersLayer.clearLayers();

                const [departLatLng, arriveeLatLng] = await Promise.all([
                    geocodeVille(trajet.ville_depart),
                    geocodeVille(trajet.ville_arrivee)
                ]);

                if (!departLatLng || !arriveeLatLng) {
                    statusDiv.innerHTML = '<span class="text-danger">Localisation impossible.</span>';
                    return;
                }

                L.marker(departLatLng, {icon: greenIcon}).addTo(routeMarkersLayer).bindPopup("<b>Départ</b><br>" + trajet.ville_depart);
                L.marker(arriveeLatLng, {icon: redIcon}).addTo(routeMarkersLayer).bindPopup("<b>Arrivée</b><br>" + trajet.ville_arrivee);

                currentRoutingControl = L.Routing.control({
                    waypoints: [departLatLng, arriveeLatLng],
                    routeWhileDragging: false,
                    addWaypoints: false,
                    draggableWaypoints: false,
                    fitSelectedRoutes: true, 
                    show: false, 
                    lineOptions: { styles: [{color: '#007bff', opacity: 0.7, weight: 5}] },
                    createMarker: function() { return null; } 
                }).addTo(map);

                statusDiv.innerHTML = '<span class="text-success">Itinéraire affiché !</span>';
                highlightSelectedCard(idTrajet);

            } catch (error) { statusDiv.innerHTML = '<span class="text-warning">Erreur calcul.</span>'; }
        }

        function afficherResultatsSidebar(resultats, isAlternative) {
            var container = document.getElementById('listeTrajetsContainer');
            var html = '';

            if(isAlternative) {
                html += '<div class="alert alert-warning small mb-3">Nous n\'avons pas trouvé de trajet exact. Voici d\'autres propositions :</div>';
            }

            resultats.forEach(function(t) {
                var dateObj = new Date(t.date_heure_depart.replace(' ', 'T'));
                var heure = ('0'+dateObj.getHours()).slice(-2) + ':' + ('0'+dateObj.getMinutes()).slice(-2);
                var date = ('0'+dateObj.getDate()).slice(-2) + '/' + ('0'+(dateObj.getMonth()+1)).slice(-2);
                
                var cardClass = isAlternative ? 'trip-card alternative' : 'trip-card';
                var badgeClass = isAlternative ? 'badge badge-alternative rounded-pill px-3' : 'badge bg-success rounded-pill px-3';

                html += `
                <div class="${cardClass}" id="card-${t.id_trajet}" onclick="afficherItineraire(${t.id_trajet})">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <span class="trip-time">${heure}</span>
                            <span class="text-muted small ms-1">(${date})</span>
                        </div>
                        <span class="${badgeClass}">${t.places_proposees} pl.</span>
                    </div>
                    <div class="mt-2">
                        <strong>${t.ville_depart.split(',')[0]}</strong> 
                        <i class="bi bi-arrow-right text-muted mx-1"></i> 
                        <strong>${t.ville_arrivee.split(',')[0]}</strong>
                    </div>
                    <div class="trip-meta">
                        <span><i class="bi bi-car-front-fill me-1"></i> Voiture</span>
                        <span><i class="bi bi-person-fill me-1"></i> Conducteur</span>
                    </div>
                </div>`;
            });

            container.innerHTML = html;
            document.getElementById('sidebarTitle').innerText = isAlternative ? "Suggestions" : "Résultats";
            document.getElementById('sidebarSubtitle').innerText = resultats.length + " trajet(s)";
            document.getElementById('infoSidebar').classList.add('active');
        }

        function highlightSelectedCard(id) {
            document.querySelectorAll('.trip-card').forEach(c => c.classList.remove('selected'));
            const card = document.getElementById('card-' + id);
            if (card) card.classList.add('selected');
        }

        function closeSidebar() {
            document.getElementById('infoSidebar').classList.remove('active');
            if (currentRoutingControl) {
                map.removeControl(currentRoutingControl);
                currentRoutingControl = null;
            }
            routeMarkersLayer.clearLayers();
        }

        function handleEnter(e) { if(e.key === 'Enter') rechercherTrajet(); }
    </script>
    {/literal}
</body>
</html>