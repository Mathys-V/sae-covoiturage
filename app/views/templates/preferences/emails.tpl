{include file='includes/header.tpl'}

<style>
    /* Mêmes styles de base */
    :root { --bg-dark: #422875; --accent: #8C52FF; }
    body { background-color: var(--bg-dark) !important; color: white; }
    .pref-main { max-width: 600px; margin: 0 auto; padding: 40px 20px; }
    .header-top { display: flex; align-items: center; margin-bottom: 30px; }
    .back-btn { color: white; border: 1px solid rgba(255,255,255,0.3); width: 40px; height: 40px; display: grid; place-items: center; border-radius: 50%; text-decoration: none; }
    .title { flex-grow: 1; text-align: center; font-weight: bold; margin: 0; padding-right: 40px; }
    
    .sae-info {
        background: rgba(140, 82, 255, 0.15); border: 1px solid var(--accent);
        border-radius: 15px; padding: 15px; margin-bottom: 30px; font-size: 0.9rem;
        display: flex; gap: 15px; align-items: center;
    }
    
    .checkbox-card {
        background: rgba(255, 255, 255, 0.05);
        padding: 20px; border-radius: 15px; margin-bottom: 15px;
        display: flex; align-items: center; gap: 15px; cursor: pointer;
        border: 2px solid transparent; transition: 0.2s;
    }
    .checkbox-card:hover { background: rgba(255, 255, 255, 0.1); }
    
    /* Checkbox cachée mais fonctionnelle */
    .checkbox-card input { display: none; }
    
    /* Indicateur visuel */
    .indicator {
        width: 24px; height: 24px; border-radius: 50%; border: 2px solid #b0a4c5;
        display: flex; align-items: center; justify-content: center; transition: 0.2s;
    }
    .checkbox-card input:checked + .indicator {
        background: var(--accent); border-color: var(--accent);
    }
    .checkbox-card input:checked + .indicator::after {
        content: "✔"; font-size: 14px; color: white;
    }
    
    .btn-save {
        display: block; width: 100%; border: none; padding: 15px;
        border-radius: 30px; background: var(--accent); color: white;
        font-weight: bold; font-size: 1.1rem; margin-top: 30px;
    }
</style>

<div class="pref-main">
    <div class="header-top">
        <a href="/sae-covoiturage/public/profil/preferences" class="back-btn"><i class="bi bi-chevron-left"></i></a>
        <h2 class="title">Préférences E-mail</h2>
    </div>

    <div class="sae-info">
        <i class="bi bi-envelope-exclamation sae-icon" style="font-size: 1.5rem; color: #8C52FF;"></i>
        <div>
            <strong>Configuration Fictive</strong><br>
            Aucun e-mail réel ne sera envoyé. Ces options servent à démontrer la gestion des préférences utilisateur (RGPD).
        </div>
    </div>

    <form id="emailForm">
        <label class="checkbox-card">
            <input type="checkbox" id="mail_newsletter">
            <div class="indicator"></div>
            <div>
                <div class="fw-bold">Newsletter Mensuelle</div>
                <small style="color: #b0a4c5;">Actualités et mises à jour de la plateforme.</small>
            </div>
        </label>

        <label class="checkbox-card">
            <input type="checkbox" id="mail_recap">
            <div class="indicator"></div>
            <div>
                <div class="fw-bold">Récapitulatif de trajet</div>
                <small style="color: #b0a4c5;">Recevoir un PDF après chaque voyage.</small>
            </div>
        </label>

        <label class="checkbox-card">
            <input type="checkbox" id="mail_partenaires">
            <div class="indicator"></div>
            <div>
                <div class="fw-bold">Offres partenaires</div>
                <small style="color: #b0a4c5;">Promotions de nos partenaires (Assurances, etc.).</small>
            </div>
        </label>

        <button type="submit" class="btn-save">Enregistrer</button>
    </form>
</div>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        const keys = ['mail_newsletter', 'mail_recap', 'mail_partenaires'];
        
        // Load
        keys.forEach(k => { if(localStorage.getItem(k) === 'true') document.getElementById(k).checked = true; });

        // Save
        document.getElementById('emailForm').addEventListener('submit', (e) => {
            e.preventDefault();
            keys.forEach(k => localStorage.setItem(k, document.getElementById(k).checked));
            
            const btn = document.querySelector('.btn-save');
            btn.innerText = "Préférences mises à jour !";
            btn.style.background = "#00e676";
            setTimeout(() => { btn.innerText = "Enregistrer"; btn.style.background = "#8C52FF"; }, 2000);
        });
    });
</script>

{include file='includes/footer.tpl'}