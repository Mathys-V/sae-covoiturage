{* Fichier: carte.tpl *}
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carte - MonCovoitJV</title>

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin=""/>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        /* --- Styles spécifiques à la carte --- */
        #map-container {
            height: calc(100vh - 160px);
            width: 100%;
            position: relative;
            z-index: 1;
        }

        #map {
            height: 100%; 
            width: 100%;
        }

        /* --- Barre de recherche flottante --- */
        .search-card {
            position: absolute;
            top: 20px;
            left: 0;
            right: 0;
            margin: 0 auto;
            z-index: 1000;
            background: white;
            padding: 15px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
            width: 350px;
            border: 1px solid #8c52ff;
        }

        .search-btn {
            background-color: #8c52ff;
            color: white;
            border: none;
        }
        .search-btn:hover {
            background-color: #703ccf;
            color: white;
        }

        /* --- Panneau latéral d'information --- */
        .info-sidebar {
            position: absolute;
            top: 10px;
            left: 10px;
            width: 380px;
            height: calc(100% - 20px);
            background: white;
            z-index: 2000;
            box-shadow: 0 0 20px rgba(0,0,0,0.2);
            border-radius: 8px;
            transform: translateX(-120%);
            transition: transform 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            padding: 0;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
        }

        .info-sidebar.active {
            transform: translateX(0);
        }

        .sidebar-hero-img {
            width: 100%;
            height: 200px;
            object-fit: cover;
            border-radius: 8px 8px 0 0;
        }

        .sidebar-content {
            padding: 20px;
        }

        .close-sidebar-btn {
            position: absolute;
            top: 10px;
            right: 10px;
            background: rgba(0,0,0,0.5);
            color: white;
            border: none;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            cursor: pointer;
            z-index: 2001;
            display: flex; 
            align-items: center; 
            justify-content: center; 
        }

        .form-control:focus {
            border-color: #8c52ff;
            box-shadow: 0 0 0 0.25rem rgba(140, 82, 255, 0.25);
        }

        .trip-card {
            background: white;
            border-radius: 12px;
            padding: 12px 16px;
            margin-bottom: 12px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            border-left: 4px solid #8c52ff; 
            cursor: pointer;
            transition: transform 0.2s;
        }
        .trip-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .trip-time { font-weight: 800; color: #000; font-size: 1.1em; width: 55px; display: inline-block; }
        .trip-place { color: #333; font-weight: 500; }
        .trip-duration { font-size: 0.85em; color: #666; margin-top: 8px; border-top: 1px solid #eee; padding-top: 8px;}
    </style>
</head>
<body>

    {include file='includes/header.tpl'} 

    <div class="container-fluid p-1 position-relative">
        
        <div class="search-card">
            <h5 style="color: #8c52ff; font-weight: bold;">Rechercher un trajet</h5>
            <div class="input-group mb-2">
                <input type="text" id="addressInput" class="form-control" placeholder="Adresse (ex: Gare d'Amiens)" onkeypress="handleEnter(event)">
                <button class="btn search-btn" onclick="searchAddress()"><i class="fa-solid fa-magnifying-glass"></i></button>
            </div>
            <div id="resultInfo" class="small text-muted mt-2">
                Cliquez sur la carte ou cherchez une adresse.
            </div>
        </div>

        <div id="map-container">
            <div id="map"></div>
            <div id="infoSidebar" class="info-sidebar">
                <button class="close-sidebar-btn" onclick="closeSidebar()"><i class="fa-solid fa-xmark"></i></button>
    
                <img id="sidebarImg" class="sidebar-hero-img" src="" style="display:none;">
                <div class="sidebar-content pb-0">
                    <h2 id="sidebarTitle" style="font-size: 24px; font-weight:bold; margin-bottom: 5px;">Titre</h2>
                    <p id="sidebarAddress" class="text-muted small mb-3">Adresse...</p>
        
                    <h5 style="color: #8c52ff; font-weight: bold; border-top: 1px solid #eee; padding-top: 15px;">
                      Trajets disponibles ici
                    </h5>
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
        // 1. Initialisation de la carte centrée sur l'IUT d'Amiens
        var map = L.map('map').setView([49.87172, 2.26430], 16);
        setTimeout(function(){ map.invalidateSize()}, 400);

        // 2. Ajout du fond de carte OpenStreetMap 
        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 20,
            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        }).addTo(map);

        var currentMarker = null;
        var markersGroup = L.layerGroup().addTo(map);

        // Icône violette personnalisée
        var violetIcon = new L.Icon({
            iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-violet.png',
            shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
            iconSize: [25, 41],
            iconAnchor: [12, 41],
            popupAnchor: [1, -34],
            shadowSize: [41, 41]
        });

        // Marqueur par defaut sur l'IUT
        var iutMarker = L.marker([49.87172, 2.26430], {icon: violetIcon}).addTo(map);

        iutMarker.on('click', function(e) {
            L.DomEvent.stopPropagation(e);
            map.flyTo([49.87172, 2.26430], 16, { animate: true, duration: 1 });
    
            // On récupère les trajets pour Amiens
            var trajetsLieu = getTrajetsParLieu("Amiens");

            openSidebar({
                titre: "IUT d'Amiens",
                type: "Institut Universitaire de Technologie",
                adresse: "Avenue des Facultés, 80000 Amiens",
                desc: "Point de départ principal.",
                img: "https://www.iut-amiens.fr/wp-content/uploads/2022/01/Bandeau-IUT.jpg",
                trajets: trajetsLieu // On passe les trajets
            });
        });

        // 3. Clic sur la carte
        map.on('click', function(e) {
            var lat = e.latlng.lat;
            var lng = e.latlng.lng;

            placeMarker(lat, lng);
    
            // Sidebar simple sans API de reverse geocoding pour l'instant
            openSidebar({
                titre: "Position sélectionnée",
                adresse: "Coordonnées : " + lat.toFixed(5) + ", " + lng.toFixed(5),
                img: null,
                trajets: [] // Pas de trajets liés à un clic aléatoire
            });
        });

        function placeMarker(lat, lng) {
            if (currentMarker) {
                map.removeLayer(currentMarker);
            }
            currentMarker = L.marker([lat, lng], {icon: violetIcon}).addTo(map);
            map.flyTo([lat, lng], 15);
        }

        function closeSidebar() {
            document.getElementById('infoSidebar').classList.remove('active');
            document.querySelector('.search-card').style.opacity = '1';
            document.getElementById('listeTrajetsContainer').innerHTML = '';

            if (currentMarker) {
                map.removeLayer(currentMarker);
                currentMarker = null;
            }
        }

        // --- NOUVEAU : FONCTION DE RECHERCHE D'ADRESSE (Géocodage) ---
        function searchAddress() {
            var input = document.getElementById('addressInput');
            var query = input.value;

            if(!query) return;

            // Utilisation de l'API Nominatim (OpenStreetMap) - Gratuit et sans clé
            var url = 'https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(query);

            fetch(url)
                .then(function(response) { return response.json(); })
                .then(function(data) {
                    if(data && data.length > 0) {
                        // On prend le premier résultat
                        var result = data[0];
                        var lat = result.lat;
                        var lng = result.lon;

                        // On place le marqueur et on centre
                        placeMarker(lat, lng);

                        // On essaie de trouver des trajets liés à ce nom
                        var trajetsLieu = getTrajetsParLieu(query);

                        // On ouvre la sidebar avec les infos trouvées
                        openSidebar({
                            titre: result.display_name.split(',')[0], // Juste le début de l'adresse
                            adresse: result.display_name,
                            img: null,
                            trajets: trajetsLieu
                        });

                        document.getElementById('resultInfo').innerHTML = '<span class="text-success"><i class="fas fa-check"></i> Trouvé !</span>';
                    } else {
                        document.getElementById('resultInfo').innerHTML = '<span class="text-danger"><i class="fas fa-times"></i> Adresse introuvable.</span>';
                    }
                })
                .catch(function(error) {
                    console.error('Erreur:', error);
                    document.getElementById('resultInfo').innerHTML = '<span class="text-danger">Erreur de connexion.</span>';
                });
        }

        // Permet de valider avec la touche Entrée
        function handleEnter(e) {
            if(e.key === 'Enter') {
                searchAddress();
            }
        }

        // --- GESTION DE LA SIDEBAR ---
        function openSidebar(data) {
            document.getElementById('sidebarTitle').innerText = data.titre;
            document.getElementById('sidebarAddress').innerText = data.adresse;

            var imgEl = document.getElementById('sidebarImg');
            if(data.img) {
                imgEl.src = data.img;
                imgEl.style.display = 'block';
            } else {
                imgEl.style.display = 'none';
            }

            var container = document.getElementById('listeTrajetsContainer');
            
            if(data.trajets && data.trajets.length > 0) {
                var html = '';
                data.trajets.forEach(function(trajet) {
                    html += '<div class="trip-card">';
                    html += '  <div class="trip-time">' + trajet.heure + '</div>';
                    html += '  <i class="bi bi-arrow-right mx-2"></i>';
                    html += '  <span class="trip-place">' + trajet.destination + '</span>';
                    html += '  <div class="trip-duration"><i class="bi bi-clock me-1"></i>' + trajet.duree + ' • ' + trajet.places + ' places</div>';
                    html += '</div>';
                });
                container.innerHTML = html;
            } else {
                container.innerHTML = '<div class="text-center text-muted py-5"><i class="bi bi-emoji-frown fs-1 d-block mb-2"></i>Aucun trajet disponible pour ce lieu.</div>';
            }

            document.getElementById('infoSidebar').classList.add('active');
            document.querySelector('.search-card').style.opacity = '0';
        }

{/literal}
    var lieuxFrequents = {json_encode($lieux_frequents|default:[])};
    var trajets = {json_encode($trajets|default:[])};
{literal}

        function getTrajetsParLieu(nomLieu) {
            // Filtrage simple sur le nom de la ville
            var ville = '';
            // On nettoie un peu la recherche pour comparer
            var recherche = nomLieu.toLowerCase();

            if(recherche.includes('amiens')) ville = 'Amiens';
            else if(recherche.includes('dury')) ville = 'Dury';
            else if(recherche.includes('longueau')) ville = 'Longueau';
            else if(recherche.includes('ailly')) ville = 'Ailly-sur-Noye';
            
            var trajetsFiltre = trajets.filter(function(trajet) {
                // On compare avec la ville de départ du trajet en base
                return trajet.ville_depart.toLowerCase() === ville.toLowerCase();
            });
            
            return trajetsFiltre.map(function(trajet) {
                var dateStr = trajet.date_heure_depart.replace(' ', 'T');
                var date = new Date(dateStr);
                var heure = ('0' + date.getHours()).slice(-2) + ':' + ('0' + date.getMinutes()).slice(-2);
                
                var duree = trajet.duree_estimee;
                if(duree && duree.length >= 5) {
                    duree = duree.substring(0, 5);
                }
                
                return {
                    heure: heure,
                    destination: trajet.ville_arrivee,
                    duree: duree,
                    places: trajet.places_proposees
                };
            });
        }

        function chargerLieuxFrequents() {
            if (!lieuxFrequents || lieuxFrequents.length === 0) return;

            lieuxFrequents.forEach(function(lieu) {
                var lat = parseFloat(lieu.latitude);
                var lng = parseFloat(lieu.longitude);
                
                var marker = L.marker([lat, lng], {icon: violetIcon});
                
                marker.on('click', function(e) {
                    L.DomEvent.stopPropagation(e);
                    map.flyTo([lat, lng], 16, { animate: true, duration: 1 });

                    var trajetsLieu = getTrajetsParLieu(lieu.nom_lieu);

                    openSidebar({
                        titre: lieu.nom_lieu,
                        adresse: (lieu.rue ? lieu.rue + ", " : "") + lieu.ville + " " + lieu.code_postal,
                        img: null,
                        trajets: trajetsLieu 
                    });
                });

                marker.addTo(markersGroup);
            });
        }

        // Lancer le chargement au démarrage
        chargerLieuxFrequents();

    </script>
{/literal}
</body>
</html>