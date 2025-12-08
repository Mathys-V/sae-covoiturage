{include file='includes/header.tpl'}
<main class="login-container">
    <div class="login-card">
        <h2>Se connecter</h2>
        
        <form action="#" method="POST">
            <div class="input-group">
                <label for="email">Adresse email</label>
                <input type="email" id="email" name="email" required>
            </div>

            <div class="input-group">
                <label for="password">Mot de passe</label>
                <div class="password-wrapper">
                    <input type="password" id="password" name="password" required>
                    <span class="toggle-password">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#8A2BE2" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                    </span>
                </div>
            </div>

            <div class="forgot-password">
                <a href="#">Mot de passe oublié ?</a>
            </div>

            <button type="submit" class="btn-login">Connexion</button>

            <div class="register-link">
                <a href="#">S'inscrire</a>
            </div>
        </form>
    </div>
</main>
{include file='includes/footer.tpl'}