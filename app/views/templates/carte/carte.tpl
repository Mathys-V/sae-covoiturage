{include file='includes/header.tpl'}

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin=""/>
<link rel="stylesheet" href="https://unpkg.com/leaflet-routing-machine@latest/dist/leaflet-routing-machine.css" />
<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/carte/style_carte.css">

<style>
    /* Cache les listes d'autocomplétion vides pour éviter les bordures fantômes */
    .autocomplete-suggestions:empty { display: none !important; border: none !important; padding: 0 !important; }
</style>

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
        <div id="map"></div> <div id="infoSidebar" class="info-sidebar">
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
    // Variables globales pour le fichier JS externe
    var lieuxFrequents = [];
    var tousLesTrajets = [];
    var userId = 0;

    // Injection sécurisée des données PHP vers JS
    try {
        // Transformation des tableaux PHP en objets JSON valides
        lieuxFrequents = {$lieux_frequents|json_encode|default:'[]'};
        tousLesTrajets = {$trajets|json_encode|default:'[]'};
        
        {if isset($user)}
            userId = {$user.id_utilisateur|default:0};
        {/if}
        
    } catch(e) { 
        console.error("Erreur chargement données :", e); 
    }
</script>

<script src="/sae-covoiturage/public/assets/javascript/carte/js_carte.js"></script>