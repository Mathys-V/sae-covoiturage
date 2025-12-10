{include file='includes/header.tpl'}

<style>
    /* --- SECTION BACKGROUND --- */
    .login-section {
        background-image: url('/sae-covoiturage/public/assets/img/Image-IUT-connexion.jpg');
        background-size: cover;
        background-position: center;
        min-height: 80vh; 
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
    }

    .card-login {
        background: white;
        border-radius: 20px;
        padding: 2rem;
        width: 100%;
        max-width: 400px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        border: 2px solid var(--main-purple);
    }

    .card-title {
        color: var(--main-purple);
        font-weight: bold;
        text-align: center;
        margin-bottom: 1.5rem;
        font-size: 1.8rem;
    }

    .custom-input {
        border: 2px solid var(--main-purple);
        border-radius: 10px;
        padding: 10px 15px;
    }
    
    /* Icône oeil */
    .password-group { position: relative; }
    
    .toggle-password {
        position: absolute;
        right: 15px;
        top: 50%;
        transform: translateY(-50%);
        cursor: pointer;
        color: var(--main-purple);
        font-size: 1.2rem; /* Ajusté pour être plus propre */
        z-index: 10;
    }
</style>

<main class="login-section">
    <div class="card-login">
        <h2 class="card-title">Se connecter</h2>
        
        {if isset($error)}
            <div class="alert alert-danger text-center" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> {$error}
            </div>
        {/if}
        <form action="/sae-covoiturage/public/connexion" method="POST">
            
            <div class="mb-3">
                <label for="emailInput" class="form-label text-purple fw-bold">Adresse email</label>
                <input type="email" name="email" class="form-control custom-input" id="emailInput" placeholder="exemple@etu.u-picardie.fr" required>
            </div>

            <div class="mb-3">
                <label for="passwordInput" class="form-label text-purple fw-bold">Mot de passe</label>
                <div class="password-group">
                    <input type="password" name="password" class="form-control custom-input" id="passwordInput" placeholder="Votre mot de passe" style="padding-right: 50px;" required>
                    <i class="bi bi-eye-slash toggle-password" id="togglePassword"></i>
                </div>
                
                <a href="/sae-covoiturage/public/mot-de-passe-oublie" class="text-decoration-none small mt-2 d-block text-start ms-3" style="color: #0dcaf0;">
                    Mot de passe oublié ?
                </a>
            </div>

            <div class="d-flex justify-content-center mt-4">
                <button type="submit" class="btn btn-purple py-2 px-5 fs-5">Connexion</button>
            </div>

            <div class="text-center mt-3">
                <a href="/sae-covoiturage/public/inscription" class="text-decoration-none fw-bold text-purple">S'inscrire</a>
            </div>
        </form>
    </div>
</main>

<script>
    const togglePassword = document.querySelector('#togglePassword');
    const password = document.querySelector('#passwordInput');

    if(togglePassword) {
        togglePassword.addEventListener('click', function (e) {
            const type = password.getAttribute('type') === 'password' ? 'text' : 'password';
            password.setAttribute('type', type);
            this.classList.toggle('bi-eye');
            this.classList.toggle('bi-eye-slash');
        });
    }
</script>

{include file='includes/footer.tpl'}