<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carte - MonCovoitJV</title>

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin=""/>
    <link rel="stylesheet" href="https://unpkg.com/leaflet-routing-machine@latest/dist/leaflet-routing-machine.css" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link rel="stylesheet" href="/sae-covoiturage/public/assets/css/carte/style_carte.css">

    <style>
        .autocomplete-suggestions:empty { display: none !important; border: none !important; padding: 0 !important; }
    </style>
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
            
            {if isset($user)}
            <div class="d-flex gap-2 mt-2">
                <button class="btn btn-sm btn-outline-primary flex-grow-1" onclick="afficherMesAnnonces()">
                    <i class="bi bi-car-front-fill"></i> Mes annonces
                </button>
                <button class="btn btn-sm btn-outline-info flex-grow-1" onclick="afficherMesReservations()">
                    <i class="bi bi-ticket-perforated-fill"></i> Mes réservations
                </button>
            </div>
            {/if}

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
    // Initialisation des variables globales
    var lieuxFrequents = [];
    var tousLesTrajets = [];
    var mesAnnonces = [];
    var mesReservations = [];

    // On utilise json_encode directement sans les guillemets JS autour
    // Smarty va écrire directement le tableau JS valide 
    try {
        lieuxFrequents = {$lieux_frequents|json_encode|default:'[]'};
        tousLesTrajets = {$trajets|json_encode|default:'[]'};
        
        {if isset($mes_annonces)}
            mesAnnonces = {$mes_annonces|json_encode|default:'[]'};
        {/if}
        
        {if isset($mes_reservations)}
            mesReservations = {$mes_reservations|json_encode|default:'[]'};
        {/if}

        console.log("Données chargées :", {
            lieux: lieuxFrequents.length,
            publics: tousLesTrajets.length,
            annonces: mesAnnonces.length,
            reservations: mesReservations.length
        });

    } catch(e) { 
        console.error("Erreur critique chargement données :", e); 
    }
</script>

<script src="/sae-covoiturage/public/assets/javascript/carte/js_carte.js"></script>
</body>
</html>
