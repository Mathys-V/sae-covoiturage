{* Fichier: carte.tpl *}
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carte - MonCovoitJV</title>

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <style>
        body { overflow: hidden; } 
        
        #map-container {
            height: calc(100vh - 80px);
            width: 100%;
            position: relative;
            z-index: 1;
        }

        #map { height: 100%; width: 100%; }

        /* --- CARTE DE RECHERCHE FLOTTANTE --- */
        .search-card {
            position: absolute;
            top: 20px;
            left: 20px;
            z-index: 1000;
            background: white;
            padding: 20px;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            width: 340px; /* Un peu plus large pour les input groups */
            border: 1px solid rgba(140, 82, 255, 0.2);
        }

        .search-title {
            color: #452b85;
            font-weight: 800;
            margin-bottom: 15px;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* Style des Input Groups (L'icône est dans une boite à côté) */
        .input-group-text {
            background-color: #f8f9fa;
            border-color: #eee;
            color: #8c52ff; /* Couleur de l'icone */
            border-radius: 10px 0 0 10px !important;
            border-right: none;
        }

        .form-control-map {
            border-left: none;
            border-color: #eee;
            background-color: #f8f9fa;
            border-radius: 0 10px 10px 0 !important;
            height: 45px;
        }

        .form-control-map:focus {
            box-shadow: none;
            border-color: #eee;
            background-color: white;
        }
        
        /* Focus sur tout le groupe quand on clique */
        .input-group:focus-within .input-group-text,
        .input-group:focus-within .form-control-map {
            border-color: #8c52ff;
            background-color: white;
        }

        .btn-search-map {
            width: 100%;
            background-color: #8c52ff;
            color: white;
            border: none;
            border-radius: 10px;
            padding: 10px;
            font-weight: 600;
            transition: background 0.3s;
            margin-top: 10px;
        }
        
        .btn-search-map:hover { background-color: #703ccf; color: white; }

        /* --- MARQUEURS CSS PUR (Pour éviter les bugs d'images) --- */
        .marker-pin {
            width: 30px;
            height: 30px;
            border-radius: 50% 50% 50% 0;
            position: absolute;
            transform: rotate(-45deg);
            left: 50%;
            top: 50%;
            margin: -15px 0 0 -15px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 3px 5px rgba(0,0,0,0.3);
        }

        /* L'icône à l'intérieur du marqueur */
        .marker-pin i {
            transform: rotate(45deg);
            color: white;
            font-size: 14px;
            margin-top: 2px; /* Petit ajustement optique */
        }

        /* Couleurs des marqueurs */
        .marker-gold { background: #FFD700; border: 2px solid #fff; }
        .marker-green { background: #28a745; border: 2px solid #fff; }
        .marker-purple { background: #8c52ff; border: 2px solid #fff; }

        /* Ombre sous le marqueur */
        .marker-shadow {
            width: 14px; height: 4px;
            background: rgba(0,0,0,0.3);
            border-radius: 50%;
            margin-top: 30px; margin-left: 8px;
            filter: blur(2px);
        }

        /* --- Sidebar & Légende (Inchangés) --- */
        .info-sidebar {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 350px;
            height: calc(100% - 40px);
            background: white;
            z-index: 2000;
            box-shadow: -5px 0 20px rgba(0,0,0,0.1);
            border-radius: 16px;
            transform: translateX(120%);
            transition: transform 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            display: flex; flex-direction: column; overflow: hidden;
        }
        .info-sidebar.active { transform: translateX(0); }
        .sidebar-header { padding: 20px; background-color: #452b85; color: white; position: relative; }
        .close-sidebar-btn { position: absolute; top: 15px; right: 15px; background: rgba(255,255,255,0.2); color: white; border: none; border-radius: 50%; width: 30px; height: 30px; cursor: pointer; display: flex; align-items: center; justify-content: center;}
        
        .trip-card { background: white; border-radius: 12px; padding: 15px; margin-bottom: 12px; box-shadow: 0 3px 10px rgba(0,0,0,0.05); border-left: 5px solid #8c52ff; cursor: pointer; transition: transform 0.2s; border: 1px solid #f0f0f0; }
        .trip-card:hover { transform: translateY(-3px); border-color: #8c52ff; }
        .trip-time { font-size: 1.2rem; font-weight: 800; color: #452b85; }
        .trip-meta { font-size: 0.85rem; color: #666; margin-top: 5px; display: flex; justify-content: space-between; }

        .legend-card { position: absolute; bottom: 20px; left: 20px; background: white; padding: 10px 15px; border-radius: 8px; z-index: 1000; font-size: 0.8rem; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .legend-item { display: flex; align-items: center; gap: 8px; margin-bottom: 5px; }
        .dot { width: 12px; height: 12px; border-radius: 50%; display: inline-block; }
    </style>
</head>
<body>

    {include file='includes/header.tpl'} 

    <div class="container-fluid p-0 position-relative">
        
        <div class="search-card">
            <div class="search-title">
                <i class="bi bi-map-fill"></i> Trouver un trajet
            </div>
            
            <div class="input-group mb-3">
                <span class="input-group-text">
                    <i class="bi bi-geo-alt-fill"></i>
                </span>
                <input type="text" id="departInput" class="form-control form-control-map" placeholder="Départ (ex: Amiens)" onkeypress="handleEnter(event)">
            </div>

            <div class="input-group mb-3">
                <span class="input-group-text">
                    <i class="bi bi-flag-fill"></i>
                </span>
                <input type="text" id="arriveeInput" class="form-control form-control-map" placeholder="Arrivée (ex: IUT)" onkeypress="handleEnter(event)">
            </div>

            <button class="btn-search-map" onclick="rechercherTrajet()">
                Rechercher
            </button>

            <div id="searchStatus" class="mt-2 text-center small text-muted"></div>
        </div>

        <div class="legend-card">
            <div class="legend-item"><span class="dot" style="background: #FFD700;"></span> Lieux Fréquents</div>
            <div class="legend-item"><span class="dot" style="background: #28a745;"></span> Trajets Trouvés</div>
        </div>

        <div id="map-container">
            <div id="map"></div>
            
            <div id="infoSidebar" class="info-sidebar">
                <div class="sidebar-header">
                    <button class="close-sidebar-btn" onclick="closeSidebar()"><i class="fa-solid fa-xmark"></i></button>
                    <h4 class="m-0 fw-bold" id="sidebarTitle">Résultats</h4>
                    <small id="sidebarSubtitle" class="opacity-75">Trajets disponibles</small>
                </div>

                <div id="listeTrajetsContainer" class="p-3" style="background-color: #f8f9fa; flex-grow: 1; overflow-y: auto;">
                </div>
            </div>
        </div>
    </div>

    {include file='includes/footer.tpl'}

   <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
{literal}
    <script>
        var map = L.map('map').setView([49.89407, 2.29575], 13);
        
        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; OpenStreetMap'
        }).addTo(map);

        var markersLayer = L.layerGroup().addTo(map); 
        var frequentLayer = L.layerGroup().addTo(map); 

        // --- GÉNÉRATEUR DE MARQUEURS CSS (Sans image) ---
        function createCustomMarker(color) {
            return L.divIcon({
                className: 'custom-div-icon',
                html: `<div class='marker-pin ${color}'><i class='fa-solid fa-location-dot'></i></div><div class='marker-shadow'></div>`,
                iconSize: [30, 42],
                iconAnchor: [15, 42],
                popupAnchor: [0, -35]
            });
        }

        var goldIcon = createCustomMarker('marker-gold');
        var greenIcon = createCustomMarker('marker-green');
        var purpleIcon = createCustomMarker('marker-purple');

{/literal}
        var lieuxFrequents = {json_encode($lieux_frequents|default:[])};
        var tousLesTrajets = {json_encode($trajets|default:[])};
{literal}

        function afficherLieuxFrequents() {
            lieuxFrequents.forEach(function(lieu) {
                if(lieu.latitude && lieu.longitude) {
                    var marker = L.marker([lieu.latitude, lieu.longitude], {icon: goldIcon})
                        .bindPopup('<b>' + lieu.nom_lieu + '</b><br><span class="text-muted">Lieu fréquent</span>');
                    marker.on('click', function(){ map.flyTo([lieu.latitude, lieu.longitude], 15); });
                    marker.addTo(frequentLayer);
                }
            });
        }
        afficherLieuxFrequents();

        function rechercherTrajet() {
            var departTxt = document.getElementById('departInput').value.toLowerCase().trim();
            var arriveeTxt = document.getElementById('arriveeInput').value.toLowerCase().trim();
            var statusDiv = document.getElementById('searchStatus');

            if(departTxt === "" && arriveeTxt === "") {
                statusDiv.innerHTML = "Veuillez saisir au moins une ville.";
                return;
            }

            statusDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Recherche en cours...';
            
            var resultats = tousLesTrajets.filter(function(trajet) {
                var matchDepart = true;
                var matchArrivee = true;
                if (departTxt !== "") matchDepart = trajet.ville_depart.toLowerCase().includes(departTxt);
                if (arriveeTxt !== "") matchArrivee = trajet.ville_arrivee.toLowerCase().includes(arriveeTxt);
                return matchDepart && matchArrivee;
            });

            markersLayer.clearLayers(); 
            
            if (resultats.length > 0) {
                statusDiv.innerHTML = '<span class="text-success">' + resultats.length + ' trajet(s) trouvé(s) !</span>';
                afficherResultatsSidebar(resultats);
                placerMarqueursResultats(resultats);
            } else {
                statusDiv.innerHTML = '<span class="text-danger">Aucun trajet ne correspond.</span>';
                document.getElementById('infoSidebar').classList.remove('active');
            }
        }

        function afficherResultatsSidebar(trajets) {
            var container = document.getElementById('listeTrajetsContainer');
            var html = '';

            trajets.forEach(function(t) {
                var dateObj = new Date(t.date_heure_depart.replace(' ', 'T'));
                var heure = ('0'+dateObj.getHours()).slice(-2) + ':' + ('0'+dateObj.getMinutes()).slice(-2);
                var date = ('0'+dateObj.getDate()).slice(-2) + '/' + ('0'+(dateObj.getMonth()+1)).slice(-2);

                html += `
                <div class="trip-card" onclick="focusTrajet('${t.ville_depart}')">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <span class="trip-time">${heure}</span>
                            <span class="text-muted small">(${date})</span>
                        </div>
                        <span class="badge bg-success">${t.places_proposees} pl.</span>
                    </div>
                    <div class="mt-2">
                        <strong>${t.ville_depart}</strong> <i class="bi bi-arrow-right text-muted"></i> <strong>${t.ville_arrivee}</strong>
                    </div>
                    <div class="trip-meta">
                        <span><i class="bi bi-car-front"></i> Voiture</span>
                        <span><i class="bi bi-person"></i> Conducteur</span>
                    </div>
                </div>`;
            });

            container.innerHTML = html;
            document.getElementById('sidebarTitle').innerText = "Résultats";
            document.getElementById('sidebarSubtitle').innerText = trajets.length + " trajet(s) correspondant(s)";
            document.getElementById('infoSidebar').classList.add('active');
        }

        function placerMarqueursResultats(trajets) {
            if(trajets.length > 0) {
                var premierTrajet = trajets[0];
                var query = premierTrajet.ville_depart;

                fetch('https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(query))
                .then(res => res.json())
                .then(data => {
                    if(data.length > 0) {
                        var lat = data[0].lat;
                        var lon = data[0].lon;
                        var marker = L.marker([lat, lon], {icon: greenIcon})
                            .bindPopup("<b>Zone de départ trouvée</b><br>" + query)
                            .addTo(markersLayer);
                        map.flyTo([lat, lon], 14);
                    }
                });
            }
        }

        function closeSidebar() {
            document.getElementById('infoSidebar').classList.remove('active');
        }

        function handleEnter(e) {
            if(e.key === 'Enter') rechercherTrajet();
        }

        window.focusTrajet = function(ville) {
            console.log("Focus sur " + ville);
        }

    </script>
{/literal}
</body>
</html>