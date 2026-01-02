{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/mdp/style_etape1_email.css">

<div class="container d-flex justify-content-center align-items-center flex-grow-1 my-5">
    <div class="card shadow-lg p-4 p-md-5" style="max-width: 500px; width: 100%; border-radius: 20px; border: none;">
        
        <h2 class="text-center fw-bold mb-2" style="color: #8c52ff;">Mot de passe oublié ?</h2>
        <p class="text-center text-muted mb-4">Réinitialisation du compte</p>
        
        <div class="simu-alert">
            <i class="bi bi-info-circle-fill fs-5 mt-1"></i>
            <div>
                <strong>Mode Simulation (SAE)</strong><br>
                L'envoi d'e-mail est désactivé. Le code de récupération sera généré et écrit dans un <strong>fichier texte</strong> sur le serveur (logs) pour validation.
            </div>
        </div>

        {if isset($error)}
            <div class="alert alert-danger text-center rounded-3 mb-4">
                <i class="bi bi-exclamation-triangle me-2"></i>{$error}
            </div>
        {/if}

        <form action="/sae-covoiturage/public/mot-de-passe-oublie" method="POST">
            <div class="mb-4">
                <label class="form-label fw-bold text-dark">Adresse email</label>
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0 rounded-start-pill ps-3">
                        <i class="bi bi-envelope text-muted"></i>
                    </span>
                    <input type="email" name="email" class="form-control bg-light border-start-0 rounded-end-pill py-2" 
                           placeholder="exemple@etud.u-picardie.fr" required>
                </div>
            </div>
            
            <button type="submit" class="btn btn-purple w-100 py-2 rounded-pill fw-bold shadow-sm">
                Envoyer le code (Simulé)
            </button>
        </form>

        <div class="text-center mt-4">
            <a href="/sae-covoiturage/public/connexion" class="text-decoration-none text-secondary fw-semibold small hover-opacity">
                <i class="bi bi-arrow-left me-1"></i> Retour à la connexion
            </a>
        </div>
    </div>
</div>

{include file='includes/footer.tpl'}