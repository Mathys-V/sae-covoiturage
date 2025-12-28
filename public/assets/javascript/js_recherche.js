// --- AUTOCOMPLÉTION ---
function setupAutocomplete(inputId, resultsId) {
    const input = document.getElementById(inputId);
    const results = document.getElementById(resultsId);
    
    // Sécurité si les éléments n'existent pas
    if (!input || !results) return;

    let timeout = null;

    input.addEventListener('input', function() {
        const query = this.value.toLowerCase().trim();
        results.innerHTML = ''; 
        if (query.length < 2) return;

        // Récupération de la variable globale définie dans le TPL
        // On utilise un tableau vide par défaut si la variable n'existe pas
        const localData = window.lieuxFrequents || [];

        // A. Locale (Lieux Fréquents)
        const matchesLocal = localData.filter(lieu => 
            lieu.nom_lieu.toLowerCase().includes(query) || 
            lieu.ville.toLowerCase().includes(query)
        );

        if (matchesLocal.length > 0) {
            matchesLocal.forEach(lieu => {
                const div = document.createElement('div');
                div.className = 'autocomplete-suggestion is-frequent';
                div.innerHTML = `
                    <div class="sugg-icon"><i class="bi bi-star-fill"></i></div>
                    <div class="sugg-text">
                        <span class="sugg-main">${lieu.nom_lieu}</span>
                        <span class="sugg-sub">${lieu.ville}</span>
                    </div>`;
                div.addEventListener('click', function() { input.value = lieu.nom_lieu; results.innerHTML = ''; });
                results.appendChild(div);
            });
        }

        // B. API Gouv
        if (query.length > 3) {
            clearTimeout(timeout);
            timeout = setTimeout(() => {
                fetch('https://api-adresse.data.gouv.fr/search/?q=' + query + '&limit=5')
                    .then(response => response.json())
                    .then(data => {
                        if (data.features && data.features.length > 0) {
                            data.features.forEach(feature => {
                                const div = document.createElement('div');
                                div.className = 'autocomplete-suggestion is-api';
                                div.innerHTML = `
                                    <div class="sugg-icon"><i class="bi bi-geo-alt-fill"></i></div>
                                    <div class="sugg-text">
                                        <span class="sugg-main">${feature.properties.name}</span>
                                        <span class="sugg-sub">${feature.properties.city || ''}</span>
                                    </div>`;
                                div.addEventListener('click', function() { input.value = feature.properties.label; results.innerHTML = ''; });
                                results.appendChild(div);
                            });
                        }
                    });
            }, 300);
        }
    });

    // Fermeture des suggestions au clic ailleurs
    document.addEventListener('click', function(e) { 
        if (e.target !== input && e.target !== results) {
            results.innerHTML = ''; 
        }
    });
}

// Lancement des fonctions au chargement du DOM
document.addEventListener('DOMContentLoaded', function() {
    setupAutocomplete('depart', 'suggestions-depart');
    setupAutocomplete('arrivee', 'suggestions-arrivee');
});