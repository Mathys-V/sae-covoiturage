{include file='includes/header.tpl'}

<style>
    /* --- CSS GLOBAL --- */
    :root {
        --bg-dark-purple: #422875;
        --accent-light: #8C52FF;
        --green-check: #00e676; 
        --error-red: #ff4444;
    }

    body { background-color: var(--bg-dark-purple) !important; }

    main.pref-main {
        background-color: var(--bg-dark-purple);
        flex-grow: 1;
        display: flex; flex-direction: column; align-items: center; 
        padding: 40px 20px; color: white; width: 100%;
        min-height: 80vh;
    }

    .header-top {
        width: 100%; max-width: 600px; display: flex; align-items: center; 
        margin-bottom: 30px; position: relative;
    }
    .back-btn {
        text-decoration: none; color: white; 
        border: 1px solid rgba(255,255,255,0.3); border-radius: 50%; 
        width: 40px; height: 40px; display: flex; justify-content: center; align-items: center; 
        transition: background 0.3s; margin-right: 15px;
    }
    .back-btn:hover { background: rgba(255,255,255,0.1); color: white; }

    h1.pref-title {
        flex-grow: 1; text-align: center; margin: 0; font-size: 1.8rem; padding-right: 40px; color: white; font-weight: bold;
    }

    form.pref-form { width: 100%; max-width: 600px; display: flex; flex-direction: column; gap: 30px; }

    /* --- INPUT TELEPHONE --- */
    .phone-input-wrapper {
        position: relative; width: 100%; margin-bottom: 5px;
    }
    .phone-input {
        width: 100%; padding: 15px; border-radius: 10px; border: none; font-size: 1.2rem;
        box-sizing: border-box; color: #333; outline: none; padding-right: 40px;
        background-color: white;
        transition: border 0.3s;
        border: 2px solid transparent;
    }
    /* Classe pour l'erreur (Bordure Rouge) */
    .phone-input.error {
        border-color: var(--error-red);
        color: var(--error-red);
    }

    .clear-btn {
        position: absolute; right: 15px; top: 50%; transform: translateY(-50%);
        font-size: 1.5rem; cursor: pointer; color: #333;
    }
    
    /* Message d'erreur sous l'input */
    .error-msg {
        color: var(--error-red); font-size: 0.9rem; margin-bottom: 10px; display: none; text-align: left; width: 100%;
    }

    .info-text { margin-bottom: 10px; font-size: 0.95rem; line-height: 1.4; opacity: 0.9; text-align: center; }

    /* --- CHECKBOX STYLE --- */
    .option-row {
        display: flex; gap: 20px; align-items: flex-start;
        padding-bottom: 20px; border-bottom: 1px solid var(--accent-light);
        cursor: pointer;
    }
    .option-row input[type="checkbox"] { display: none; }
    
    .custom-check {
        position: relative;
        width: 24px; height: 24px; border: 2px solid white; border-radius: 6px;
        display: flex; justify-content: center; align-items: center; flex-shrink: 0;
        transition: all 0.2s; background-color: transparent;
    }
    
    /* État coché */
    .option-row input:checked + .custom-check { background-color: transparent; }
    .option-row input:checked + .custom-check::after {
        content: '✓'; color: white; font-size: 16px;
    }
    
    .text-content { display: flex; flex-direction: column; }
    .label-title { font-size: 1.1rem; font-weight: normal; margin-bottom: 5px; }
    .label-desc { font-size: 0.8rem; color: #ccc; line-height: 1.3; }

    .btn-save {
        background: var(--accent-light); color: white; border: none; padding: 15px 40px;
        border-radius: 30px; font-size: 1.2rem; font-weight: bold; cursor: pointer;
        align-self: center; margin-top: 20px; transition: background 0.3s;
    }
    .btn-save:hover { background: #7a42ea; }

    .btn-save:disabled {
        background-color: #ccc;  /* Gris */
        cursor: not-allowed;     /* Curseur interdit */
        opacity: 0.6;
        pointer-events: none;    /* Empêche le clic */
    }

    /* --- POPUPS --- */
    .custom-overlay { 
        position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
        background: rgba(0,0,0,0.6); display: none; 
        justify-content: center; align-items: center; z-index: 99999; 
    }
    .custom-box { 
        background: #E6DFF0; padding: 30px; border-radius: 20px; 
        text-align: center; width: 90%; max-width: 400px; color: black; 
        box-shadow: 0 10px 25px rgba(0,0,0,0.5);
    }
    .custom-box h2 { color: var(--bg-dark-purple); margin-top: 0; font-weight: bold; margin-bottom: 15px; }
    .custom-box p { font-size: 1.1rem; margin-bottom: 25px; color: #333; }

    .btns { display: flex; justify-content: center; gap: 15px; }
    .btn-ok { background: var(--accent-light); color: white; padding: 10px 30px; border-radius: 20px; border: none; cursor: pointer; font-weight: bold; }
    .btn-cancel { background: #aaa; color: #333; padding: 10px 30px; border-radius: 20px; border: none; cursor: pointer; font-weight: bold; }
</style>

<main class="pref-main">
    <div class="header-top">
        <a href="/sae-covoiturage/public/profil/preferences" class="back-btn"><i class="bi bi-chevron-left"></i></a>
        <h1 class="pref-title">Notifications par téléphone</h1>
    </div>

    <form id="telForm" class="pref-form" onsubmit="return false;" novalidate>
        <p class="info-text">Ajoutez votre numéro de téléphone pour recevoir des alertes importantes concernant votre compte et vos réservations.</p>

        <div class="phone-input-wrapper">
            <input type="tel" id="user_tel" class="phone-input" value="{$tel_bdd}" placeholder="06 12 34 56 78" maxlength="14">
            <span class="clear-btn" onclick="window.clearInput()"><i class="bi bi-x-lg"></i></span>
        </div>
        <div class="error-msg" id="telError">Numéro incorrect (10 chiffres requis).</div>

        <label class="option-row" style="border:none;">
            <input type="checkbox" id="tel_sms">
            <div class="custom-check"></div>
            <div class="text-content">
                <span class="label-title">Notifications par téléphone</span>
                <span class="label-desc">Recevoir des alertes par téléphone</span>
            </div>
        </label>

        <button type="button" id="btnSave" class="btn-save" onclick="window.checkAndConfirm()" disabled>Enregistrer</button>
    </form>
</main>

<div class="custom-overlay" id="confirmModal">
    <div class="custom-box">
        <h2>Confirmation</h2>
        <p>Voulez-vous enregistrer ce numéro ?</p>
        <div class="btns">
            <button class="btn-cancel" onclick="window.closeAll()">Non</button>
            <button class="btn-ok" onclick="window.saveDataBDD()">Oui</button>
        </div>
    </div>
</div>

<div class="custom-overlay" id="successModal">
    <div class="custom-box">
        <h2>Succès</h2>
        <p>Numéro mis à jour avec succès !</p>
        <button class="btn-ok" onclick="window.closeAll()">Ok</button>
    </div>
</div>

<script>
{literal}
    // --- RÉFÉRENCES ---
    const telInput = document.getElementById('user_tel');
    const btnSave = document.getElementById('btnSave'); // Assure-toi d'avoir ajouté id="btnSave" au bouton HTML
    const telError = document.getElementById('telError');

    // --- FONCTION DE NETTOYAGE ---
    // Retourne juste les chiffres
    const getRawValue = () => telInput.value.replace(/\D/g, '');

    // --- 1. VALIDATION ET ÉTAT DU BOUTON ---
    const checkValidity = () => {
        const raw = getRawValue();
        const isValid = /^\d{10}$/.test(raw);

        // Gestion du BOUTON (Actif / Inactif)
        if (isValid) {
            btnSave.disabled = false;
        } else {
            btnSave.disabled = true;
        }
        
        return isValid; // On renvoie true/false pour l'utiliser ailleurs
    };

    // --- 2. FORMATAGE VISUEL (Espaces) ---
    const formatPhoneNumber = (val) => {
        const cleaned = ('' + val).replace(/\D/g, '');
        let formatted = '';
        for (let i = 0; i < cleaned.length; i++) {
            if (i > 0 && i % 2 === 0) { formatted += ' '; }
            formatted += cleaned[i];
        }
        return formatted;
    };

    // --- 3. ÉCOUTEURS D'ÉVÉNEMENTS ---

    // A. PENDANT LA FRAPPE (Input)
    telInput.addEventListener('input', function() {
        // On formate (ajoute les espaces)
        this.value = formatPhoneNumber(this.value);
        
        // On vérifie si on doit allumer le bouton
        const isValid = checkValidity();

        // UX : Si l'utilisateur corrige et atteint 10 chiffres, on enlève l'erreur rouge tout de suite
        if (isValid) {
            telError.style.display = 'none';
            telInput.classList.remove('error');
        }
    });

    // B. QUAND ON QUITTE LE CHAMP (Blur) -> C'est ici qu'on AFFICHE l'erreur rouge
    telInput.addEventListener('blur', function() {
        const raw = getRawValue();
        
        // Si le champ n'est pas vide ET qu'il ne fait pas 10 chiffres
        if (raw.length > 0 && raw.length !== 10) {
            telError.style.display = 'block'; // Affiche le texte
            telInput.classList.add('error');  // Ajoute la bordure rouge
        }
    });

    // C. QUAND ON REVIENT DANS LE CHAMP (Focus) -> On cache l'erreur pour laisser corriger
    telInput.addEventListener('focus', function() {
        telError.style.display = 'none';
        telInput.classList.remove('error');
    });

    // --- 4. CONFIRMATION (Au clic du bouton) ---
    window.checkAndConfirm = function() {
        if (checkValidity()) {
            document.getElementById('confirmModal').style.display = 'flex';
        } else {
            // Sécurité : si on arrive à cliquer quand même, on réaffiche l'erreur
            telError.style.display = 'block';
            telInput.classList.add('error');
        }
    };

    // --- 5. AUTRES FONCTIONS DU TEMPLATE ---
    window.closeAll = function() { 
        document.querySelectorAll('.custom-overlay').forEach(el => el.style.display = 'none');
    };

    window.clearInput = function() {
        telInput.value = '';
        telInput.focus(); // Redonne le focus (donc cache l'erreur via l'event focus)
        checkValidity();  // Met à jour le bouton (le désactive)
    };

    window.saveDataBDD = function() {
        const telValue = telInput.value; 
        const smsChecked = document.getElementById('tel_sms').checked;
        localStorage.setItem('tel_sms', smsChecked);

        fetch('/sae-covoiturage/public/profil/preferences/telephone/save', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ telephone: telValue })
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                document.getElementById('confirmModal').style.display = 'none';
                document.getElementById('successModal').style.display = 'flex';
            } else {
                alert("Erreur : " + data.message);
                window.closeAll();
            }
        })
        .catch(err => { console.error(err); alert("Erreur technique"); });
    };

    // --- 6. INITIALISATION ---
    document.addEventListener('DOMContentLoaded', () => {
        if(localStorage.getItem('tel_sms') === 'true') {
            document.getElementById('tel_sms').checked = true;
        }
        if(telInput.value) {
            telInput.value = formatPhoneNumber(telInput.value);
        }
        // Vérifie l'état initial du bouton
        checkValidity();
    });
{/literal}
</script>

{include file='includes/footer.tpl'}