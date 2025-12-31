{include file='includes/header.tpl'}

<style>
    :root { --bg-dark: #422875; --accent: #8C52FF; }
    body { background-color: var(--bg-dark) !important; color: white; }
    .pref-main { max-width: 600px; margin: 0 auto; padding: 40px 20px; }
    
    .header-top { display: flex; align-items: center; margin-bottom: 30px; }
    .back-btn { color: white; border: 1px solid rgba(255,255,255,0.3); width: 40px; height: 40px; display: grid; place-items: center; border-radius: 50%; text-decoration: none; }
    .title { flex-grow: 1; text-align: center; font-weight: bold; margin: 0; padding-right: 40px; }

    /* BANDEAU INFO SAE */
    .sae-info {
        background: rgba(140, 82, 255, 0.15); border: 1px solid var(--accent);
        border-radius: 15px; padding: 15px; margin-bottom: 30px; font-size: 0.9rem;
        display: flex; gap: 15px; align-items: center;
    }

    .input-group-custom {
        background: white; border-radius: 15px; padding: 5px;
        display: flex; align-items: center; margin-bottom: 10px;
    }
    .input-group-custom input {
        border: none; flex-grow: 1; padding: 15px; font-size: 1.1rem;
        outline: none; background: transparent; color: #333;
    }
    .clear-icon { color: #999; padding: 0 15px; cursor: pointer; }

    .section-title {
        color: #b0a4c5; font-size: 0.9rem; text-transform: uppercase;
        margin-top: 30px; margin-bottom: 10px; letter-spacing: 1px;
    }

    /* Switch CSS */
    .option-row { display: flex; justify-content: space-between; align-items: center; padding: 15px 0; border-bottom: 1px solid rgba(255,255,255,0.1); }
    .switch { position: relative; display: inline-block; width: 50px; height: 28px; }
    .switch input { opacity: 0; width: 0; height: 0; }
    .slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #553a85; transition: .4s; border-radius: 34px; }
    .slider:before { position: absolute; content: ""; height: 20px; width: 20px; left: 4px; bottom: 4px; background-color: white; transition: .4s; border-radius: 50%; }
    input:checked + .slider { background-color: var(--accent); }
    input:checked + .slider:before { transform: translateX(22px); }

    .btn-save {
        display: block; width: 100%; border: none; padding: 15px;
        border-radius: 30px; background: var(--accent); color: white;
        font-weight: bold; font-size: 1.1rem; margin-top: 40px;
        opacity: 1; transition: 0.3s;
    }
    .btn-save:disabled { opacity: 0.5; cursor: not-allowed; background: #666; }
</style>

<div class="pref-main">
    <div class="header-top">
        <a href="/sae-covoiturage/public/profil/preferences" class="back-btn"><i class="bi bi-chevron-left"></i></a>
        <h2 class="title">Mobile & SMS</h2>
    </div>

    <div class="sae-info">
        <i class="bi bi-info-circle-fill sae-icon" style="font-size: 1.5rem; color: #8C52FF;"></i>
        <div>
            <strong>Stockage Réel / Usage Inactif</strong><br>
            Votre numéro est bien <strong>sauvegardé</strong> en base de données.
            Cependant, l'application <strong>n'enverra jamais</strong> de SMS (ni urgence, ni pub), car aucun service de messagerie n'est connecté.
        </div>
    </div>

    <div class="section-title">Votre Numéro (Sécurisé)</div>
    <p class="small text-white-50 mb-3">
        Numéro stocké pour compléter votre profil. (La fonctionnalité d'appel d'urgence n'est pas implémentée).
    </p>
    
    <div class="input-group-custom">
        <input type="tel" id="user_tel" value="{$tel_bdd}" placeholder="06 12 34 56 78" maxlength="14">
        <i class="bi bi-x-circle-fill clear-icon" onclick="document.getElementById('user_tel').value=''; checkVal();"></i>
    </div>
    <div id="telError" style="color: #ff4444; font-size: 0.9rem; display: none; margin-bottom: 10px;">
        Format invalide (10 chiffres requis).
    </div>

    <div class="section-title">Préférences SMS (Simulation)</div>
    
    <div class="option-row">
        <div>
            <div style="font-weight: bold;">Recevoir des SMS marketing</div>
            <small style="color: #b0a4c5;">Codes promos et partenaires.</small>
        </div>
        <label class="switch">
            <input type="checkbox" id="simu_sms_marketing">
            <span class="slider"></span>
        </label>
    </div>

    <button type="button" id="btnSave" class="btn-save" onclick="saveAll()">Enregistrer</button>
</div>

<script>
    const telInput = document.getElementById('user_tel');
    const btnSave = document.getElementById('btnSave');
    const errorMsg = document.getElementById('telError');

    // Nettoie : garde que les chiffres
    const cleanNumber = (val) => val.replace(/\D/g, '');

    // Formate : ajoute des espaces tous les 2 chiffres
    const formatNumber = (val) => {
        let clean = cleanNumber(val);
        let formatted = '';
        for(let i=0; i<clean.length; i++) {
            if(i>0 && i%2===0) formatted += ' ';
            formatted += clean[i];
        }
        return formatted;
    };

    // Vérification
    const checkVal = () => {
        const raw = cleanNumber(telInput.value);
        // On autorise vide (pour supprimer) OU 10 chiffres exacts
        const isValid = raw.length === 0 || raw.length === 10;
        
        if (!isValid && raw.length > 0) {
            errorMsg.style.display = 'block';
            btnSave.disabled = true;
        } else {
            errorMsg.style.display = 'none';
            btnSave.disabled = false;
        }
    };

    telInput.addEventListener('input', function() {
        this.value = formatNumber(this.value);
        checkVal();
    });

    // Chargement Option SMS (Fictif)
    if(localStorage.getItem('simu_sms_marketing') === 'true') {
        document.getElementById('simu_sms_marketing').checked = true;
    }

    function saveAll() {
        const rawTel = cleanNumber(telInput.value);
        const smsPref = document.getElementById('simu_sms_marketing').checked;

        // 1. Sauvegarde Préférence Fictive
        localStorage.setItem('simu_sms_marketing', smsPref);

        // 2. Sauvegarde Numéro Réel (API)
        btnSave.innerText = "Enregistrement...";
        
        fetch('/sae-covoiturage/public/profil/preferences/telephone/save', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ telephone: rawTel })
        })
        .then(res => res.json())
        .then(data => {
            if(data.success) {
                btnSave.innerText = "Tout est enregistré !";
                btnSave.style.background = "#00e676";
                setTimeout(() => { 
                    btnSave.innerText = "Enregistrer"; 
                    btnSave.style.background = "#8C52FF"; 
                }, 2000);
            } else {
                alert("Erreur BDD : " + data.message);
                btnSave.innerText = "Réessayer";
            }
        });
    }
</script>

{include file='includes/footer.tpl'}