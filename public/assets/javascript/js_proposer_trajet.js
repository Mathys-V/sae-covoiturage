// Fonction pour afficher/masquer la date de fin
function toggleDateFin(show) {
    const wrapper = document.getElementById('date_fin_wrapper');
    const input = wrapper.querySelector('input');
    if (show) {
        wrapper.classList.add('visible');
        input.required = true;
    } else {
        wrapper.classList.remove('visible');
        input.required = false;
        input.value = '';
    }
}

// Fonction d'autocomplétion
function setupAutocomplete(inputId, resultsId) {
    const input = document.getElementById(inputId);
    const results = document.getElementById(resultsId);
    
    // Sécurité
    if (!input || !results) return;

    let timeout = null;

    input.addEventListener('input', function() {
        // Reset de la validation au changement de texte
        this.setAttribute('data-valid', 'false');
        this.classList.remove('is-valid');
        
        const query = this.value.toLowerCase().trim();
        results.innerHTML = ''; 

        if (query.length < 2) return;

        // Utilisation de la variable globale window.lieuxFrequents
        const localData = window.lieuxFrequents || [];
        const matchesLocal = localData.filter(lieu => 
            lieu.nom_lieu.toLowerCase().includes(query) || 
            lieu.ville.toLowerCase().includes(query)
        );

        if (matchesLocal.length > 0) {
            matchesLocal.forEach(lieu => {
                const div = document.createElement('div');
                div.className = 'autocomplete-suggestion is-frequent';
                div.innerHTML = '<i class="bi bi-star-fill suggestion-icon"></i>' + lieu.nom_lieu + ' <small>(' + lieu.ville + ')</small>';
                
                div.addEventListener('click', function() {
                    let adresseComplete = lieu.rue + ', ' + lieu.code_postal + ' ' + lieu.ville;
                    if(!lieu.rue) adresseComplete = lieu.ville;

                    input.value = adresseComplete;
                    input.setAttribute('data-valid', 'true');
                    input.classList.remove('input-error');
                    results.innerHTML = '';
                });
                results.appendChild(div);
            });
        }

        if (query.length > 3) {
            clearTimeout(timeout);
            timeout = setTimeout(() => {
                fetch('https://api-adresse.data.gouv.fr/search/?q=' + query + '&limit=5')
                    .then(response => response.json())
                    .then(data => {
                        if (data.features && data.features.length > 0) {
                            data.features.forEach(feature => {
                                const div = document.createElement('div');
                                div.className = 'autocomplete-suggestion';
                                div.innerHTML = '<i class="bi bi-geo-alt suggestion-icon text-muted"></i>' + feature.properties.label;
                                
                                div.addEventListener('click', function() {
                                    input.value = feature.properties.label;
                                    input.setAttribute('data-valid', 'true');
                                    input.classList.remove('input-error');
                                    results.innerHTML = '';
                                });
                                results.appendChild(div);
                            });
                        }
                    });
            }, 300);
        }
    });

    document.addEventListener('click', function(e) {
        if (e.target !== input && e.target !== results) {
            results.innerHTML = '';
        }
    });
}

// Initialisation au chargement de la page
document.addEventListener('DOMContentLoaded', function() {
    setupAutocomplete('depart', 'suggestions-depart');
    setupAutocomplete('arrivee', 'suggestions-arrivee');

    // Validation du formulaire
    const form = document.getElementById('trajetForm');
    if (form) {
        form.addEventListener('submit', function(e) {
            const depart = document.getElementById('depart');
            const arrivee = document.getElementById('arrivee');
            const errorMsg = document.getElementById('js-error-message');
            let isValid = true;

            // Vérifie si l'utilisateur a cliqué sur une suggestion
            if (depart.getAttribute('data-valid') !== 'true') {
                e.preventDefault(); 
                depart.classList.add('input-error'); 
                isValid = false;
            }
            if (arrivee.getAttribute('data-valid') !== 'true') {
                e.preventDefault(); 
                arrivee.classList.add('input-error'); 
                isValid = false;
            }

            if (!isValid) {
                errorMsg.classList.remove('d-none');
                window.scrollTo({ top: 0, behavior: 'smooth' });
            } else {
                errorMsg.classList.add('d-none');
            }
        });
    }
});