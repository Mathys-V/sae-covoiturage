document.addEventListener("DOMContentLoaded", function() {

    // Configuration
    const MIN_LENGTH = 2; // Déclenche dès 2 lettres

    function setupAutocomplete(inputId, listId) {
        const input = document.getElementById(inputId);
        const list = document.getElementById(listId);

        if (!input || !list) return;

        input.addEventListener("input", function(e) {
            let val = this.value;
            list.innerHTML = '';
            
            if (!val || val.length < MIN_LENGTH) return false;

            // 1. CHERCHER DANS LES LIEUX FRÉQUENTS (BDD)
            // On filtre les lieux qui contiennent le texte tapé
            let matchesDb = [];
            if (window.lieuxFrequents) {
                matchesDb = window.lieuxFrequents.filter(lieu => 
                    lieu.nom_lieu.toLowerCase().includes(val.toLowerCase()) || 
                    lieu.ville.toLowerCase().includes(val.toLowerCase())
                );
            }

            // On affiche d'abord les résultats de la BDD (style "fréquent")
            matchesDb.forEach(lieu => {
                const div = document.createElement("div");
                div.className = "autocomplete-suggestion is-frequent";
                
                // Construction du HTML identique à la page Recherche
                div.innerHTML = `
                    <div class="sugg-icon"><i class="bi bi-star-fill"></i></div>
                    <div class="sugg-text">
                        <span class="sugg-main">${lieu.nom_lieu}</span>
                        <span class="sugg-sub">${lieu.ville}</span>
                    </div>
                `;

                div.addEventListener("click", function() {
                    input.value = lieu.nom_lieu; // On remplit avec le nom du lieu
                    list.innerHTML = '';
                });
                list.appendChild(div);
            });

            // 2. CHERCHER DANS L'API GOUV (Adresse)
            fetch(`https://api-adresse.data.gouv.fr/search/?q=${encodeURIComponent(val)}&limit=5`)
                .then(response => response.json())
                .then(data => {
                    // On n'efface pas la liste, on ajoute à la suite des lieux fréquents
                    
                    data.features.forEach(feature => {
                        let label = feature.properties.label;
                        let context = feature.properties.context || ""; 
                        
                        const div = document.createElement("div");
                        div.className = "autocomplete-suggestion is-api"; // Style standard
                        
                        div.innerHTML = `
                            <div class="sugg-icon"><i class="bi bi-geo-alt-fill"></i></div>
                            <div class="sugg-text">
                                <span class="sugg-main">${label}</span>
                                <span class="sugg-sub">${context}</span>
                            </div>
                        `;
                        
                        div.addEventListener("click", function() {
                            input.value = label;
                            list.innerHTML = '';
                        });
                        
                        list.appendChild(div);
                    });
                })
                .catch(err => console.error("Erreur API:", err));
        });

        // Fermeture au clic extérieur
        document.addEventListener("click", function(e) {
            if (e.target !== input) {
                list.innerHTML = '';
            }
        });
    }

    setupAutocomplete("depart", "depart-list");
    setupAutocomplete("arrivee", "arrivee-list");
});