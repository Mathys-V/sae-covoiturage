{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/preferences/style_push.css">

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