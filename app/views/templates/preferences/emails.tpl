{include file='includes/header.tpl'}

<style>
    /* --- CSS GLOBAL --- */
    :root {
        --bg-dark-purple: #422875;
        --accent-light: #8C52FF;
        --green-check: #00e676; 
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
        flex-grow: 1; text-align: center; margin: 0; font-size: 2rem; padding-right: 40px; color: white; font-weight: bold;
    }

    form.pref-form { width: 100%; max-width: 600px; display: flex; flex-direction: column; gap: 30px; }
    
    /* --- STYLE CHECKBOX --- */
    .option-row {
        display: flex; gap: 20px; align-items: flex-start;
        padding-bottom: 20px; border-bottom: 1px solid var(--accent-light);
        cursor: pointer;
    }
    .option-row input[type="checkbox"] { display: none; }
    
    .custom-check {
        position: relative;
        width: 24px; height: 24px; 
        border: 2px solid white; border-radius: 6px;
        flex-shrink: 0;
        transition: all 0.2s;
        background-color: transparent;
    }
    
    /* État coché */
    .option-row input:checked + .custom-check { background-color: transparent; }
    .option-row input:checked + .custom-check::after {
        content: '✔'; color: white; font-size: 16px;
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
        <h1 class="pref-title">E-mails</h1>
    </div>

    <form id="emailForm" class="pref-form" onsubmit="return false;">
        <label class="option-row">
            <input type="checkbox" id="email_messages">
            <div class="custom-check"></div>
            <div class="text-content">
                <span class="label-title">Messages d'autres membres</span>
                <span class="label-desc">Recevez une notification quand d'autres membres vous contactent...</span>
            </div>
        </label>

        <label class="option-row">
            <input type="checkbox" id="email_news">
            <div class="custom-check"></div>
            <div class="text-content">
                <span class="label-title">Actualités de MonCovoitJV</span>
                <span class="label-desc">Restez au courant des dernières fonctionnalités...</span>
            </div>
        </label>

         <label class="option-row">
            <input type="checkbox" id="email_sondages">
            <div class="custom-check"></div>
            <div class="text-content">
                <span class="label-title">Sondages</span>
                <span class="label-desc">Participez à des études menées par monCovoitJV</span>
            </div>
        </label>

        <button type="button" class="btn-save" onclick="window.openConfirm()">Enregistrer</button>
    </form>
</main>

<div class="custom-overlay" id="confirmModal">
    <div class="custom-box">
        <h2>Confirmation</h2>
        <p>Voulez-vous enregistrer ces préférences ?</p>
        <div class="btns">
            <button class="btn-cancel" onclick="window.closeAll()">Non</button>
            <button class="btn-ok" onclick="window.saveData()">Oui</button>
        </div>
    </div>
</div>

<div class="custom-overlay" id="successModal">
    <div class="custom-box">
        <h2>Succès</h2>
        <p>Vos préférences ont bien été enregistrées.</p>
        <button class="btn-ok" onclick="window.closeAll()">Ok</button>
    </div>
</div>

<script>
{literal}
    window.openConfirm = function() {
        document.getElementById('confirmModal').style.display = 'flex';
    };

    window.closeAll = function() { 
        document.querySelectorAll('.custom-overlay').forEach(el => el.style.display = 'none'); 
    };

    window.saveData = function() {
        localStorage.setItem('email_messages', document.getElementById('email_messages').checked);
        localStorage.setItem('email_news', document.getElementById('email_news').checked);
        localStorage.setItem('email_sondages', document.getElementById('email_sondages').checked);
        
        document.getElementById('confirmModal').style.display = 'none';
        document.getElementById('successModal').style.display = 'flex';
    };

    document.addEventListener('DOMContentLoaded', () => {
        if(localStorage.getItem('email_messages') === 'true') document.getElementById('email_messages').checked = true;
        if(localStorage.getItem('email_news') === 'true') document.getElementById('email_news').checked = true;
        if(localStorage.getItem('email_sondages') === 'true') document.getElementById('email_sondages').checked = true;
    });
{/literal}
</script>

{include file='includes/footer.tpl'}