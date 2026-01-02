{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/style_connexion.css">

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