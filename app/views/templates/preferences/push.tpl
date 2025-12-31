{include file='includes/header.tpl'}

<style>
    /* Réutilisation des variables pour cohérence */
    :root { --bg-dark: #422875; --accent: #8C52FF; }
    body { background-color: var(--bg-dark) !important; color: white; }

    .pref-main { max-width: 600px; margin: 0 auto; padding: 40px 20px; }
    
    .header-top { display: flex; align-items: center; margin-bottom: 30px; }
    .back-btn { 
        color: white; border: 1px solid rgba(255,255,255,0.3); 
        width: 40px; height: 40px; display: grid; place-items: center; 
        border-radius: 50%; text-decoration: none; transition: 0.3s;
    }
    .back-btn:hover { background: rgba(255,255,255,0.2); color: white; }
    
    .title { flex-grow: 1; text-align: center; font-weight: bold; margin: 0; padding-right: 40px; }

    /* BANDEAU INFO SAE */
    .sae-info {
        background: rgba(140, 82, 255, 0.15);
        border: 1px solid var(--accent);
        border-radius: 15px;
        padding: 15px;
        margin-bottom: 30px;
        font-size: 0.9rem;
        display: flex;
        gap: 15px;
        align-items: center;
    }
    .sae-icon { font-size: 1.5rem; color: var(--accent); }

    /* TOGGLES IOS STYLE */
    .option-row {
        display: flex; justify-content: space-between; align-items: center;
        padding: 20px 0; border-bottom: 1px solid rgba(255,255,255,0.1);
    }
    .text-content h4 { font-size: 1.1rem; margin: 0 0 5px 0; }
    .text-content p { font-size: 0.85rem; color: #b0a4c5; margin: 0; }

    /* Switch CSS pur */
    .switch { position: relative; display: inline-block; width: 50px; height: 28px; }
    .switch input { opacity: 0; width: 0; height: 0; }
    .slider {
        position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0;
        background-color: #553a85; transition: .4s; border-radius: 34px;
    }
    .slider:before {
        position: absolute; content: ""; height: 20px; width: 20px;
        left: 4px; bottom: 4px; background-color: white; transition: .4s; border-radius: 50%;
    }
    input:checked + .slider { background-color: var(--accent); }
    input:checked + .slider:before { transform: translateX(22px); }

    .btn-save {
        display: block; width: 100%; border: none; padding: 15px;
        border-radius: 30px; background: var(--accent); color: white;
        font-weight: bold; font-size: 1.1rem; margin-top: 30px;
        transition: transform 0.2s;
    }
    .btn-save:active { transform: scale(0.98); }
</style>

<div class="pref-main">
    <div class="header-top">
        <a href="/sae-covoiturage/public/profil/preferences" class="back-btn"><i class="bi bi-chevron-left"></i></a>
        <h2 class="title">Notifications Mobile</h2>
    </div>

    <div class="sae-info">
        <i class="bi bi-info-circle sae-icon"></i>
        <div>
            <strong>Mode Simulation</strong><br>
            Cette page simule les réglages pour une future application mobile (iOS/Android). Les notifications internes du site web restent toujours actives.
        </div>
    </div>

    <form id="pushForm">
        <div class="option-row">
            <div class="text-content">
                <h4>Alertes de trajet</h4>
                <p>Recevoir une notif. mobile en cas de retard ou d'annulation.</p>
            </div>
            <label class="switch">
                <input type="checkbox" id="push_trajet">
                <span class="slider"></span>
            </label>
        </div>

        <div class="option-row">
            <div class="text-content">
                <h4>Messages privés</h4>
                <p>Être notifié sur mon téléphone quand je reçois un message.</p>
            </div>
            <label class="switch">
                <input type="checkbox" id="push_messages">
                <span class="slider"></span>
            </label>
        </div>

        <div class="option-row">
            <div class="text-content">
                <h4>Offres promotionnelles</h4>
                <p>Recevoir des codes promos fictifs.</p>
            </div>
            <label class="switch">
                <input type="checkbox" id="push_promo">
                <span class="slider"></span>
            </label>
        </div>

        <button type="submit" class="btn-save">Sauvegarder les préférences</button>
    </form>
</div>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        // Chargement (Simulation LocalStorage)
        ['push_trajet', 'push_messages', 'push_promo'].forEach(id => {
            if(localStorage.getItem(id) === 'true') document.getElementById(id).checked = true;
        });

        // Sauvegarde avec Feedback visuel
        document.getElementById('pushForm').addEventListener('submit', (e) => {
            e.preventDefault();
            
            ['push_trajet', 'push_messages', 'push_promo'].forEach(id => {
                localStorage.setItem(id, document.getElementById(id).checked);
            });

            // Feedback simple et natif (plus propre qu'une modale lourde pour ça)
            const btn = document.querySelector('.btn-save');
            const originalText = btn.innerText;
            btn.innerText = "Sauvegardé !";
            btn.style.background = "#00e676"; // Vert succès
            
            setTimeout(() => {
                btn.innerText = originalText;
                btn.style.background = "#8C52FF";
            }, 2000);
        });
    });
</script>

{include file='includes/footer.tpl'}