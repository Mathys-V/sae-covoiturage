<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$titre}</title>
    
    <style>
        /* --- STYLES GLOBAUX --- */
        :root { 
            --primary-purple: #422875; 
            --accent-purple: #8C52FF; 
            --white: #ffffff; 
            --error-red: #ff4444; 
        }

        body { 
            margin: 0; font-family: 'Segoe UI', sans-serif; 
            background-color: #f0f0f0; display: flex; flex-direction: column; min-height: 100vh; 
        }
        
        main { 
            background-color: var(--primary-purple); flex-grow: 1; 
            display: flex; flex-direction: column; align-items: center; justify-content: center; 
            padding: 40px 20px; color: white; 
        }
        
        h1 { font-size: 2.5rem; margin-bottom: 30px; margin-top: 0; text-align: center; }

        form { width: 100%; max-width: 500px; display: flex; flex-direction: column; gap: 15px; }

        .input-group { display: flex; flex-direction: column; position: relative; } /* Relative pour le menu déroulant */
        .input-group label { font-size: 1.1rem; margin-bottom: 8px; font-weight: bold; }
        .required-star { color: var(--error-red); }

        .input-wrapper input {
            width: 100%; padding: 12px 15px; border-radius: 8px; border: none; font-size: 1rem; box-sizing: border-box;
        }

        .error-message { color: var(--error-red); font-size: 0.85rem; margin-top: 5px; display: none; }
        
        .btn-confirm {
            background: var(--accent-purple); color: white; border: none; padding: 15px; border-radius: 30px;
            font-size: 1.2rem; font-weight: bold; cursor: pointer; margin-top: 20px; width: 200px; align-self: center;
            transition: background 0.3s;
        }
        .btn-confirm:hover { background: #7a42ea; }

        /* --- STYLE AUTOCOMPLÉTION (NOUVEAU) --- */
        /* C'est ce qui crée la liste blanche sous le champ */
        .suggestions-list {
            position: absolute;
            top: 75px; /* Ajuster selon la hauteur de votre label+input */
            left: 0;
            right: 0;
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            z-index: 100;
            max-height: 200px;
            overflow-y: auto;
            list-style: none;
            padding: 0;
            margin: 0;
            display: none; /* Caché par défaut */
            color: #333;
        }

        .suggestion-item {
            padding: 10px 15px;
            cursor: pointer;
            border-bottom: 1px solid #eee;
            font-size: 0.95rem;
        }

        .suggestion-item:last-child { border-bottom: none; }
        .suggestion-item:hover { background-color: #f0f0ff; color: var(--accent-purple); }
        .suggestion-item strong { display: block; font-weight: bold; }
        .suggestion-item small { color: #666; }


        /* --- MODALES (Styles existants) --- */
        .custom-overlay { 
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(0,0,0,0.7); display: none; justify-content: center; align-items: center; z-index: 99999;
        }
        .show-custom-modal { display: flex !important; }

        .custom-modal-box { 
            background: #ffffff; padding: 30px; border-radius: 20px; text-align: center; 
            width: 90%; max-width: 400px; color: #333; box-shadow: 0 10px 25px rgba(0,0,0,0.5); 
            display: block !important;
        }
        .custom-modal-box h2 { margin-top: 0; color: var(--primary-purple); }
        
        .modal-actions { display: flex; justify-content: center; gap: 15px; margin-top: 20px; }
        .custom-btn { background: var(--accent-purple); color: white; border: none; padding: 10px 30px; border-radius: 20px; cursor: pointer; font-weight: bold; }
        .custom-btn-cancel { background: #ddd; color: #333; }

    </style>
</head>
<body>

    {include file='includes/header.tpl'}

    <main>
        <h1>Votre adresse postale</h1>

        <form action="/sae-covoiturage/public/profil/modifier_adresse" method="POST" id="addressForm">
            
<div class="input-group">
    <label>Votre rue ?<span class="required-star">*</span></label>
    <input type="text" name="rue" id="rue" value="{$adresse.voie|default:''}" placeholder="Commencez à taper votre adresse..." autocomplete="off">
    
    <ul class="suggestions-list" id="suggestions"></ul>
    
    <div class="error-message" id="errorRue">Ce champ est obligatoire.</div>
    <div class="error-message" id="errorRueApi">Veuillez sélectionner une adresse existante dans la liste.</div>
</div>

            <div class="input-group">
                <label>Un complément ?</label>
                <input type="text" name="complement" id="complement" value="{$adresse.complement|default:''}" placeholder="Ex: Appartement 6">
            </div>

            <div class="input-group">
                <label>Votre ville ?<span class="required-star">*</span></label>
                <input type="text" name="ville" id="ville" value="{$adresse.ville|default:''}" placeholder="Sera rempli automatiquement">
                <div class="error-message" id="errorVille">Veuillez entrer une ville valide.</div>
            </div>

            <div class="input-group">
                <label>Le code postal ?<span class="required-star">*</span></label>
                <input type="text" name="cp" id="cp" value="{$adresse.code_postal|default:''}" placeholder="Sera rempli automatiquement" maxlength="5">
                <div class="error-message" id="errorCp">Le code postal doit contenir 5 chiffres.</div>
            </div>
            
            <div style="font-size: 0.8rem; color: #aaa; margin-top: -10px;">*champ obligatoire</div>

            <button type="submit" class="btn-confirm">Confirmer</button>
        </form>
    </main>

    <div class="custom-overlay" id="confirmModal">
        <div class="custom-modal-box">
            <h2>Confirmation</h2>
            <p>Voulez-vous vraiment enregistrer cette nouvelle adresse ?</p>
            <div class="modal-actions">
                <button class="custom-btn custom-btn-cancel" onclick="closeConfirm()">Non</button>
                <button class="custom-btn" onclick="submitRealForm()">Oui, modifier</button>
            </div>
        </div>
    </div>

    <div class="custom-overlay {if isset($success)}show-custom-modal{/if}" id="successModal">
        <div class="custom-modal-box">
            <h2>Succès !</h2>
            <p>Votre adresse a été mise à jour avec succès.</p>
            <button class="custom-btn" onclick="window.location.href='/sae-covoiturage/public/profil'">Retour au profil</button>
        </div>
    </div>

    {include file='includes/footer.tpl'}

<script>
    {literal}
    // --- VARIABLES GLOBALES ---
    const rueInput = document.getElementById('rue');
    const suggestionsList = document.getElementById('suggestions');
    const villeInput = document.getElementById('ville');
    const cpInput = document.getElementById('cp');
    
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
    
    const form = document.getElementById('addressForm');
    const confirmModal = document.getElementById('confirmModal');

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

    function closeConfirm() {
        confirmModal.style.display = 'none';
    }

    function submitRealForm() {
        form.submit();
    }

    cpInput.addEventListener('input', function (e) {
        this.value = this.value.replace(/[^0-9]/g, '');
    });
    {/literal}
</script>
</body>
</html>