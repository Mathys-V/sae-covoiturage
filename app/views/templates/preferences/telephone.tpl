{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/preferences/style_telephone.css">

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