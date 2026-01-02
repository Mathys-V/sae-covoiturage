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