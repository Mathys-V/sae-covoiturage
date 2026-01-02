// --- AUTOCOMPLÉTION POUR LA RECHERCHE ---
function setupAutocomplete(inputId, resultsId) {
    const input = document.getElementById(inputId);
    const results = document.getElementById(resultsId);
    
    // Sécurité si les éléments n'existent pas sur la page
    if (!input || !results) return;

    let timeout = null;

    input.addEventListener('input', function() {
        const query = this.value.toLowerCase().trim();
        results.innerHTML = ''; 
        
        if (query.length < 2) return;

        // 1. RECHERCHE LOCALE (Lieux Fréquents)
        // Récupération de la variable globale définie dans le TPL par Smarty
        const localData = window.lieuxFrequents || [];

        const matchesLocal = localData.filter(lieu => 
            lieu.nom_lieu.toLowerCase().includes(query) || 
            lieu.ville.toLowerCase().includes(query)
        );

        if (matchesLocal.length > 0) {
            matchesLocal.forEach(lieu => {
                const div = document.createElement('div');
                div.className = 'autocomplete-suggestion is-frequent';
                div.innerHTML = `
                    <div class="sugg-icon"><i class="bi bi-star-fill text-warning"></i></div>
                    <div class="sugg-text">
                        <span class="sugg-main">${lieu.nom_lieu}</span>
                        <span class="sugg-sub">${lieu.ville}</span>
                    </div>`;
                
                div.addEventListener('click', function() { 
                    // Pour la recherche, on met juste le nom du lieu, le PHP se débrouille
                    input.value = lieu.nom_lieu; 
                    results.innerHTML = ''; 
                });
                results.appendChild(div);
            });
        }

        // 2. RECHERCHE API GOUV
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
                                
                                // On affiche Label (ex: "Gare d'Amiens") + Ville
                                div.innerHTML = `
                                    <div class="sugg-icon"><i class="bi bi-geo-alt-fill text-muted"></i></div>
                                    <div class="sugg-text">
                                        <span class="sugg-main">${feature.properties.name}</span>
                                        <span class="sugg-sub">${feature.properties.city || ''} (${feature.properties.postcode || ''})</span>
                                    </div>`;
                                
                                div.addEventListener('click', function() { 
                                    // On remplit l'input avec le libellé complet pour que le PHP ait un max d'infos
                                    // Ex: "Gare d'Amiens"
                                    input.value = feature.properties.name + ' ' + (feature.properties.city || ''); 
                                    results.innerHTML = ''; 
                                });
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