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
            margin: 0;
            font-family: 'Segoe UI', sans-serif; 
            background-color: #f0f0f0; 
            display: flex; flex-direction: column; min-height: 100vh;
        }

        main { 
            background-color: var(--primary-purple);
            flex-grow: 1; 
            display: flex; flex-direction: column; align-items: center; justify-content: flex-start; 
            padding: 40px 20px; color: white;
        }

        h1 { 
            font-size: 3rem; margin-bottom: 10px; font-weight: bold; text-align: center;
        }

        .subtitle {
            text-align: center; font-size: 1rem; margin-bottom: 40px; opacity: 0.9; max-width: 600px;
        }

        form { 
            width: 100%; max-width: 500px; display: flex; flex-direction: column; gap: 25px; 
        }

        .input-group { display: flex; flex-direction: column; position: relative; }

        .input-group label { font-size: 1.2rem; margin-bottom: 10px; font-weight: 500; }

        .input-wrapper { position: relative; width: 100%; }

        .input-wrapper input {
            width: 100%; padding: 15px 50px 15px 20px;
            border-radius: 10px; border: none; font-size: 1rem; 
            box-sizing: border-box; outline: none;
        }

        .toggle-password {
            position: absolute; right: 15px; top: 50%; transform: translateY(-50%);
            cursor: pointer; width: 24px; height: 24px; fill: var(--accent-purple);
        }

        /* Messages d'erreur */
        .error-text {
            color: var(--error-red); font-size: 0.9rem; margin-top: 8px; font-weight: bold;
            display: none; 
        }
        .show-error-php { display: block !important; }

        .btn-confirm {
            background: var(--accent-purple); color: white; border: none; padding: 15px; 
            border-radius: 30px; font-size: 1.3rem; font-weight: bold; cursor: pointer; 
            margin-top: 20px; width: 200px; align-self: center; transition: background 0.3s;
        }
        .btn-confirm:hover { background: #7a42ea; }

        /* --- MODALES (CONFIRMATION & SUCCÈS) --- */
        .custom-overlay { 
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(0,0,0,0.6); display: none; 
            justify-content: center; align-items: center; z-index: 99999;
        }
        .show-modal { display: flex !important; }

        .custom-modal-box { 
            background: #E6DFF0; padding: 40px; border-radius: 20px; text-align: center; 
            width: 90%; max-width: 500px; color: black; 
            box-shadow: 0 10px 25px rgba(0,0,0,0.5); 
        }
        .custom-modal-box h2 { margin-top: 0; margin-bottom: 20px; font-size: 1.8rem; font-weight: bold; }
        .custom-modal-box p { font-size: 1.2rem; margin-bottom: 30px; }
        
        /* Boutons de la modale */
        .modal-actions { display: flex; justify-content: center; gap: 15px; }
        
        .modal-btn {
            background: var(--accent-purple); color: white; border: none; 
            padding: 10px 30px; border-radius: 20px; font-size: 1rem; cursor: pointer; font-weight: bold;
        }
        .modal-btn-cancel {
            background: #aaa; color: #333; /* Gris pour annuler */
        }
        .modal-btn:hover { opacity: 0.9; }

    </style>
</head>
<body>

    {include file='includes/header.tpl'}

    <main>
        <h1>Mot de passe</h1>
        <div class="subtitle">Il doit comporter au moins 8 caractères dont 1 lettre, 1 chiffre et 1 caractère spécial.</div>

        <form action="/sae-covoiturage/public/profil/modifier_mdp" method="POST" id="mdpForm">
            
            <div class="input-group">
                <label>Entrez votre mot de passe actuel</label>
                <div class="input-wrapper">
                    <input type="password" name="current_password" id="current_password" required>
                    <svg class="toggle-password" onclick="togglePwd('current_password')" viewBox="0 0 24 24"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/></svg>
                </div>
                <div class="error-text {if isset($errors.current)}show-error-php{/if}" id="msg-error-current">
                    {$errors.current|default:"Le mot de passe n'est pas celui actuel"}
                </div>
            </div>

            <div class="input-group">
                <label>Entrez votre nouveau mot de passe</label>
                <div class="input-wrapper">
                    <input type="password" name="new_password" id="new_password" required>
                    <svg class="toggle-password" onclick="togglePwd('new_password')" viewBox="0 0 24 24"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/></svg>
                </div>
                <div class="error-text {if isset($errors.format)}show-error-php{/if}" id="msg-error-format">
                    Le mot de passe saisi n'est pas valide. Vérifiez qu'il ne manque pas une consigne.
                </div>
            </div>

            <div class="input-group">
                <label>Confirmez votre nouveau mot de passe</label>
                <div class="input-wrapper">
                    <input type="password" name="confirm_password" id="confirm_password" required>
                    <svg class="toggle-password" onclick="togglePwd('confirm_password')" viewBox="0 0 24 24"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/></svg>
                </div>
                <div class="error-text {if isset($errors.confirm)}show-error-php{/if}" id="msg-error-confirm">
                    Les mots de passe ne correspondent pas.
                </div>
            </div>

            <button type="submit" class="btn-confirm" id="btnSubmit">Confirmer</button>
        </form>
    </main>

    <div class="custom-overlay" id="confirmModal">
        <div class="custom-modal-box">
            <h2>Confirmation</h2>
            <p>Voulez-vous vraiment modifier votre mot de passe ?</p>
            <div class="modal-actions">
                <button class="modal-btn modal-btn-cancel" onclick="closeConfirm()">Non</button>
                <button class="modal-btn" onclick="submitRealForm()">Oui</button>
            </div>
        </div>
    </div>

    <div class="custom-overlay {if isset($success)}show-modal{/if}">
        <div class="custom-modal-box">
            <h2>Mot de passe</h2>
            <p>La modification du mot de passe a été effectuée.</p>
            <button class="modal-btn" onclick="window.location.href='/sae-covoiturage/public/profil'">Ok</button>
        </div>
    </div>

    {include file='includes/footer.tpl'}

    <script>
        {literal}
        // --- 1. Gestion de l'affichage des mots de passe (Oeil) ---
        function togglePwd(id) {
            const input = document.getElementById(id);
            input.type = (input.type === "password") ? "text" : "password";
        }

        // --- 2. Validation et Modale ---
        const form = document.getElementById('mdpForm');
        const confirmModal = document.getElementById('confirmModal');
        const currentInput = document.getElementById('current_password');
        const newInput = document.getElementById('new_password');
        const confirmInput = document.getElementById('confirm_password');
        
        const regex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/;

        // Reset erreur PHP au typage
        currentInput.addEventListener('input', function() {
            document.getElementById('msg-error-current').classList.remove('show-error-php');
        });

        // Validation temps réel (Format)
        newInput.addEventListener('input', function() {
            const val = this.value;
            const errorMsg = document.getElementById('msg-error-format');
            if (val.length > 0 && !regex.test(val)) {
                errorMsg.style.display = 'block';
            } else {
                errorMsg.style.display = 'none';
            }
        });

        // Validation temps réel (Correspondance)
        confirmInput.addEventListener('input', function() {
            const errorMsg = document.getElementById('msg-error-confirm');
            if (this.value !== newInput.value) {
                errorMsg.style.display = 'block';
            } else {
                errorMsg.style.display = 'none';
            }
        });

        // --- INTERCEPTION DU SUBMIT ---
        form.addEventListener('submit', function(e) {
            e.preventDefault(); // On bloque l'envoi immédiat

            let isValid = true;

            // Vérification finale avant d'ouvrir la modale
            if (!regex.test(newInput.value)) {
                document.getElementById('msg-error-format').style.display = 'block';
                isValid = false;
            }
            if (newInput.value !== confirmInput.value) {
                document.getElementById('msg-error-confirm').style.display = 'block';
                isValid = false;
            }

            // Si tout est bon, on affiche la modale de confirmation
            if (isValid) {
                confirmModal.style.display = 'flex';
            }
        });

        // Fermer la modale
        function closeConfirm() {
            confirmModal.style.display = 'none';
        }

        // Envoyer vraiment le formulaire
        function submitRealForm() {
            form.submit();
        }
        {/literal}
    </script>
</body>
</html>