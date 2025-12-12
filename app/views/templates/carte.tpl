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
            height: 600px; 
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
            z-index: 2001; /* ✅ Déjà présent, mais vérifiez */
            display: flex; /* ✅ AJOUTEZ ÇA */
            align-items: center; /* ✅ AJOUTEZ ÇA */
            justify-content: center; /* ✅ AJOUTEZ ÇA */
        }

        .form-control:focus {
            border-color: #8c52ff;
            box-shadow: 0 0 0 0.25rem rgba(140, 82, 255, 0.25);
        }

        .coordinates-navbar {
            position: absolute;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 1000;
            background: linear-gradient(135deg, #8c52ff, #452b85);
            color: white;
            padding: 15px 30px;
            border-radius: 50px;
            box-shadow: 0 8px 25px rgba(140, 82, 255, 0.4);
            display: none;
            animation: slideUp 0.3s ease-out;
            font-weight: 600;
        }

        .coordinates-navbar.show {
            display: block;
        }

        @keyframes slideUp {
            from { 
                bottom: -50px; 
                opacity: 0; 
            }
            to { 
                bottom: 20px; 
                opacity: 1; 
            }
        }

        .trip-card {
    background: white;
    border-radius: 12px;
    padding: 12px 16px;
    margin-bottom: 12px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    border-left: 4px solid #8c52ff; /* Petite touche couleur */
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
                <input type="text" id="addressInput" class="form-control" placeholder="Adresse (ex: Gare d'Amiens)">
                <button class="btn search-btn" onclick="searchAddress()"><i class="fa-solid fa-magnifying-glass"></i></button>
            </div>
            <div id="resultInfo" class="small text-muted mt-2">
                Cliquez sur la carte ou cherchez une adresse.
            </div>
            <input type="hidden" id="latResult">
            <input type="hidden" id="lngResult">
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

        // Icône violette personnalisée + Lieu Fréquents
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
            L.DomEvent.stopPropagation(e); // Empêche le clic de se propager à la carte
    
        map.flyTo([49.87172, 2.26430], 16, { animate: true, duration: 1 });
    
        openSidebar({
            titre: "IUT d'Amiens",
            type: "Institut Universitaire de Technologie",
            adresse: "Avenue des Facultés, 80000 Amiens",
            desc: "Point de départ principal. Pôle d'enseignement supérieur.",
            img: "https://www.iut-amiens.fr/wp-content/uploads/2022/01/Bandeau-IUT.jpg"
        });
});

        // 3. Clic sur la carte
        map.on('click', function(e) {
            
            var lat = e.latlng.lat;
            var lng = e.latlng.lng;

           placeMarker(lat, lng);
    
        // Ouvrir la sidebar "0 trajets trouvés"
        openSidebar({
            titre: "Aucun trajet disponible ici",
            adresse: "Coordonnées : " + lat.toFixed(5) + ", " + lng.toFixed(5),
            img: null
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

// --- GESTION DE LA SIDEBAR ---
function openSidebar(data) {
    // Remplir le titre et l'adresse
    document.getElementById('sidebarTitle').innerText = data.titre;
    document.getElementById('sidebarAddress').innerText = data.adresse;

    // Gérer l'image
    var imgEl = document.getElementById('sidebarImg');
    if(data.img) {
        imgEl.src = data.img;
        imgEl.style.display = 'block';
    } else {
        imgEl.style.display = 'none';
    }

    // ✅ NOUVEAU : Afficher la liste des trajets
    var container = document.getElementById('listeTrajetsContainer');
    
    if(data.trajets && data.trajets.length > 0) {
        // Il y a des trajets : on les affiche
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
        // Aucun trajet : message par défaut
        container.innerHTML = '<div class="text-center text-muted py-5"><i class="bi bi-emoji-frown fs-1 d-block mb-2"></i>Aucun trajet disponible pour ce lieu.</div>';
    }

    // Afficher la sidebar
    document.getElementById('infoSidebar').classList.add('active');
    document.querySelector('.search-card').style.opacity = '0';
}

{/literal}
    var lieuxFrequents = {json_encode($lieux_frequents|default:[])};
    var trajets = {json_encode($trajets|default:[])};
{literal}

function getTrajetsParLieu(nomLieu) {
    console.log("🔍 Recherche trajets pour : " + nomLieu);
    
    // Extraire juste le nom de la ville du lieu
    var ville = '';
    if(nomLieu.includes('Amiens')) ville = 'Amiens';
    else if(nomLieu.includes('Dury')) ville = 'Dury';
    else if(nomLieu.includes('Longueau')) ville = 'Longueau';
    
    console.log("📍 Ville extraite : " + ville);
    
    // Filtrer les trajets qui partent de cette ville
    var trajetsFiltre = trajets.filter(function(trajet) {
        return trajet.ville_depart === ville;
    });
    
    console.log("✅ Trajets trouvés : " + trajetsFiltre.length);
    
    return trajetsFiltre.map(function(trajet) {
        // Formatter la date/heure
        var dateStr = trajet.date_heure_depart.replace(' ', 'T'); // Format ISO
        var date = new Date(dateStr);
        var heure = ('0' + date.getHours()).slice(-2) + ':' + ('0' + date.getMinutes()).slice(-2);
        
        // Formatter la durée
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
    if (!lieuxFrequents || lieuxFrequents.length === 0) {
        console.log("Aucun lieu fréquent dans la base");
        return;
    }

    lieuxFrequents.forEach(function(lieu) {
        var lat = parseFloat(lieu.latitude);
        var lng = parseFloat(lieu.longitude);
        
        // Créer le marqueur
        var marker = L.marker([lat, lng], {icon: violetIcon});
        
        // Événement au clic
        marker.on('click', function(e) {
            L.DomEvent.stopPropagation(e);
            map.flyTo([lat, lng], 16, { animate: true, duration: 1 });

            var trajetsLieu = getTrajetsParLieu(lieu.nom_lieu);

            openSidebar({
            titre: lieu.nom_lieu,
            adresse: (lieu.rue ? lieu.rue + ", " : "") + lieu.ville + " " + lieu.code_postal,
            img: null,
            trajets: trajetsLieu  // ✅ Passer les trajets
            });
        });

        marker.addTo(markersGroup);
        
        console.log("✓ Marqueur ajouté : " + lieu.nom_lieu);
    });
}

// Lancer le chargement au démarrage
chargerLieuxFrequents();

    </script>
{/literal}
</body>
</html>