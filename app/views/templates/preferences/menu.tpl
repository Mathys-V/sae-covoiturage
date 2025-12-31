{include file='includes/header.tpl'}

<style>
    :root { --bg-dark: #422875; --accent: #8C52FF; --text-grey: #b0a4c5; }
    body { background-color: var(--bg-dark) !important; color: white; }
    
    .pref-container {
        max-width: 600px;
        margin: 40px auto;
        padding: 0 20px;
    }

    h1 { font-weight: 800; text-align: center; margin-bottom: 40px; }

    .menu-card {
        background-color: rgba(255, 255, 255, 0.05);
        border-radius: 20px;
        overflow: hidden;
        backdrop-filter: blur(10px);
    }

    .menu-item {
        display: flex;
        align-items: center;
        padding: 20px 25px;
        text-decoration: none;
        color: white;
        font-size: 1.1rem;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        transition: background 0.2s, padding-left 0.2s;
    }

    .menu-item:last-child { border-bottom: none; }
    
    .menu-item:hover {
        background-color: rgba(255, 255, 255, 0.1);
        padding-left: 30px;
        color: white;
    }

    .icon-box {
        width: 40px;
        height: 40px;
        background: var(--accent);
        border-radius: 12px;
        display: flex;
        justify-content: center;
        align-items: center;
        margin-right: 20px;
        font-size: 1.2rem;
    }

    .chevron { margin-left: auto; color: var(--text-grey); }
</style>

<div class="pref-container">
    <h1>Préférences</h1>
    
    <div class="menu-card">
        <a href="/sae-covoiturage/public/profil/preferences/push" class="menu-item">
            <div class="icon-box"><i class="bi bi-bell-fill"></i></div>
            <span>Notifications Push</span>
            <i class="bi bi-chevron-right chevron"></i>
        </a>

        <a href="/sae-covoiturage/public/profil/preferences/emails" class="menu-item">
            <div class="icon-box"><i class="bi bi-envelope-fill"></i></div>
            <span>E-mails & Newsletter</span>
            <i class="bi bi-chevron-right chevron"></i>
        </a>

        <a href="/sae-covoiturage/public/profil/preferences/telephone" class="menu-item">
            <div class="icon-box"><i class="bi bi-phone-fill"></i></div>
            <span>Téléphone & SMS</span>
            <i class="bi bi-chevron-right chevron"></i>
        </a>
    </div>

    <div class="text-center mt-4">
        <a href="/sae-covoiturage/public/profil" class="btn btn-outline-light rounded-pill px-4">
            <i class="bi bi-arrow-left me-2"></i>Retour au profil
        </a>
    </div>
</div>

{include file='includes/footer.tpl'}