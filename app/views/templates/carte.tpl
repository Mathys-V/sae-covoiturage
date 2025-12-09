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
            height: calc(100vh - 160px); /* Prend toute la hauteur moins le header/footer */
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
            border: 1px solid #8c52ff; /* Bordure violette [cite: 10] */
        }

        .search-btn {
            background-color: #8c52ff; /* Ton violet principal [cite: 50] */
            color: white;
            border: none;
        }
        .search-btn:hover {
            background-color: #703ccf; /* Violet foncé au survol [cite: 51] */
            color: white;
        }

        /* Personnalisation de l'input */
        .form-control:focus {
            border-color: #8c52ff;
            box-shadow: 0 0 0 0.25rem rgba(140, 82, 255, 0.25);
        }
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
        </div>

    </div>

    {include file='includes/footer.tpl'} [cite: 25]

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

        // Variable pour stocker le marqueur actuel
        var currentMarker = null;

        // Icône violette personnalisée 
        // Sinon Leaflet utilise un marqueur bleu par défaut
        var violetIcon = new L.Icon({
            iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-violet.png',
            shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
            iconSize: [25, 41],
            iconAnchor: [12, 41],
            popupAnchor: [1, -34],
            shadowSize: [41, 41]
        });

        // Marqueur par défaut sur l'IUT
        L.marker([49.87172, 2.26430], {icon: violetIcon}).addTo(map)

            .bindPopup("<b>IUT d'Amiens</b><br>")
            .openPopup();

        // 3. FONCTION : Clic sur la carte pour récupérer les infos
        map.on('click', function(e) {
            var lat = e.latlng.lat;
            var lng = e.latlng.lng;

            placeMarker(lat, lng, "Position sélectionnée");
            
            // Mise à jour de l'affichage texte
            document.getElementById('resultInfo').innerHTML = 
                "<strong>Coordonnées :</strong><br>Lat: " + lat.toFixed(5) + "<br>Lon: " + lng.toFixed(5);
            
            // Remplissage des champs cachés (utile pour l'envoi en base de données)
            document.getElementById('latResult').value = lat;
            document.getElementById('lngResult').value = lng;
        });

        // Fonction pour placer/déplacer le marqueur
        function placeMarker(lat, lng, title) {
            // Si un marqueur existe déjà, on le supprime pour ne pas en avoir 50
            if (currentMarker) {
                map.removeLayer(currentMarker);
            }

            // On crée le nouveau marqueur
            currentMarker = L.marker([lat, lng], {icon: violetIcon}).addTo(map);
            currentMarker.bindPopup(title).openPopup();
            
            // On centre la carte dessus
            map.flyTo([lat, lng], 15);
        }

        // 4. FONCTION DE RECHERCHE D'ADRESSE 
        function searchAddress() {
            var address = document.getElementById('addressInput').value;
            if(address.length > 3) {
                // Utilisation de l'API Nominatim d'OpenStreetMap (gratuite)
                var url = "https://nominatim.openstreetmap.org/search?format=json&q=" + encodeURIComponent(address);

                fetch(url)
                    .then(response => response.json())
                    .then(data => {
                        if(data && data.length > 0) {
                            var result = data[0]; // On prend le premier résultat
                            var lat = result.lat;
                            var lon = result.lon;
                            
                            // On place le marqueur et on centre
                            placeMarker(lat, lon, result.display_name);
                            
                            document.getElementById('resultInfo').innerHTML = "<strong>Adresse trouvée :</strong><br>" + result.display_name;
                        } else {
                            alert("Adresse introuvable !");
                        }
                    })
                    .catch(error => console.log('Erreur:', error));
            } else {
                alert("Veuillez entrer une adresse plus précise.");
            }
        }
    </script>
{/literal}
</body>
</html>