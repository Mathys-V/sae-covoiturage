{include file='includes/header.tpl'}

<style>
    /* Fond violet global */
    body {
        background-color: #422875 !important;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
    }

    /* Bouton violet */
    .btn-purple {
        background-color: #8c52ff;
        color: white;
        border: none;
        transition: all 0.3s ease;
    }
    .btn-purple:hover {
        background-color: #7a46e0;
        transform: translateY(-2px);
        color: white;
    }

    /* Bandeau de simulation */
    .simu-alert {
        background-color: #fff3cd;
        border: 1px solid #ffecb5;
        color: #664d03;
        border-radius: 12px;
        padding: 15px;
        font-size: 0.9rem;
        margin-bottom: 25px;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    /* Input spécial pour le code */
    .code-input {
        letter-spacing: 5px;
        font-family: monospace;
        font-weight: bold;
    }
</style>

<div class="container d-flex justify-content-center align-items-center flex-grow-1 my-5">
    <div class="card shadow-lg p-4 p-md-5" style="max-width: 500px; width: 100%; border-radius: 20px; border: none;">
        
        <h2 class="text-center fw-bold mb-3" style="color: #8c52ff;">Vérification</h2>
        <p class="text-center text-muted mb-4">Saisissez le code de sécurité reçu.</p>
        
        <div class="simu-alert">
            <i class="bi bi-info-circle-fill fs-5"></i>
            <div>
                <strong>Simulation</strong> : Le code se trouve dans le fichier <code>code_mail.txt</code> sur le serveur.
            </div>
        </div>

        {if isset($error)}
            <div class="alert alert-danger text-center rounded-3 mb-4">
                <i class="bi bi-exclamation-triangle me-2"></i>{$error}
            </div>
        {/if}

        <form action="/sae-covoiturage/public/mot-de-passe-oublie/verify" method="POST">
            <div class="mb-4">
                <label class="form-label fw-bold text-dark">Code à 6 chiffres</label>
                <input type="text" name="code" class="form-control bg-light border-0 rounded-pill py-3 text-center fs-3 code-input" 
                       placeholder="000000" maxlength="6" required autocomplete="off">
            </div>
            
            <button type="submit" class="btn btn-purple w-100 py-2 rounded-pill fw-bold shadow-sm">
                Vérifier le code
            </button>
        </form>

        <div class="text-center mt-4">
            <a href="/sae-covoiturage/public/mot-de-passe-oublie" class="text-decoration-none text-secondary fw-semibold small">
                <i class="bi bi-arrow-counterclockwise me-1"></i> Renvoyer un code
            </a>
        </div>
    </div>
</div>

{include file='includes/footer.tpl'}