document.addEventListener('DOMContentLoaded', () => {
    // --- VARIABLES GLOBALES ---
    const rueInput = document.getElementById('rue');
    const suggestionsList = document.getElementById('suggestions');
    const villeInput = document.getElementById('ville');
    const cpInput = document.getElementById('cp');
    const form = document.getElementById('addressForm');
    const confirmModal = document.getElementById('confirmModal');
    
    // NOUVEAU : On part du principe que si le champ est déjà rempli (par la BDD), c'est valide.
    // Mais dès qu'on y touche, ça deviendra faux.
    let isAddressSelected = (rueInput.value.trim() !== "");

    // --- 1. SYSTÈME D'AUTOCOMPLÉTION ---

    // A. Quand l'utilisateur tape -> On invalide l'adresse
    rueInput.addEventListener('input', function() {
        // Sécurité : L'utilisateur modifie le texte, donc ce n'est plus une adresse certifiée API pour l'instant
        isAddressSelected = false;
        
        const query = this.value;

        if (query.length < 3) {
            suggestionsList.style.display = 'none';
            return;
        }

        // Appel API
        fetch('https://api-adresse.data.gouv.fr/search/?q=' + query + '&limit=5')
            .then(response => response.json())
            .then(data => {
                suggestionsList.innerHTML = ''; 
                
                if (data.features.length > 0) {
                    suggestionsList.style.display = 'block';
                    
                    data.features.forEach(feature => {
                        const li = document.createElement('li');
                        li.className = 'suggestion-item';
                        li.innerHTML = `<strong>${feature.properties.name}</strong><small>${feature.properties.postcode} ${feature.properties.city}</small>`;
                        
                        // B. Quand l'utilisateur CLIQUE -> On valide l'adresse
                        li.addEventListener('click', function() {
                            // Remplissage des champs
                            rueInput.value = feature.properties.name;
                            villeInput.value = feature.properties.city;
                            cpInput.value = feature.properties.postcode;

                            // Cacher la liste
                            suggestionsList.style.display = 'none';
                            
                            // Cacher les erreurs
                            document.querySelectorAll('.error-message').forEach(el => el.style.display = 'none');

                            // VALIDATION OK : L'utilisateur a bien choisi une suggestion
                            isAddressSelected = true;
                        });

                        suggestionsList.appendChild(li);
                    });
                } else {
                    suggestionsList.style.display = 'none';
                }
            })
            .catch(err => console.error(err));
    });

    // Cacher la liste au clic extérieur
    document.addEventListener('click', function(e) {
        if (e.target !== rueInput && e.target !== suggestionsList) {
            suggestionsList.style.display = 'none';
        }
    });

    // --- 2. VALIDATION ET ENVOI ---
    
    form.addEventListener('submit', function(e) {
        e.preventDefault(); 
        if (validateForm()) {
            confirmModal.style.display = 'flex';
        }
    });

    function validateForm() {
        let isValid = true;
        document.querySelectorAll('.error-message').forEach(el => el.style.display = 'none');

        // 1. Vérif Rue Vide
        if (rueInput.value.trim() === "") {
            document.getElementById('errorRue').style.display = 'block';
            isValid = false;
        }
        // 2. NOUVEAU : Vérif Adresse API
        // Si le champ n'est pas vide MAIS que l'utilisateur n'a pas cliqué sur une suggestion
        else if (isAddressSelected === false) {
            document.getElementById('errorRueApi').style.display = 'block';
            isValid = false;
        }

        // 3. Vérif Ville
        if (villeInput.value.trim() === "") {
            document.getElementById('errorVille').style.display = 'block';
            isValid = false;
        }
        
        // 4. Vérif CP
        let rawCp = cpInput.value.replace(/[^0-9]/g, '');
        if (rawCp.length !== 5) {
            document.getElementById('errorCp').style.display = 'block';
            isValid = false;
        } else {
            cpInput.value = rawCp;
        }

        return isValid;
    }

    cpInput.addEventListener('input', function (e) {
        this.value = this.value.replace(/[^0-9]/g, '');
    });
});

// Fonctions globales pour le HTML
function closeConfirm() {
    document.getElementById('confirmModal').style.display = 'none';
}

function submitRealForm() {
    document.getElementById('addressForm').submit();
}