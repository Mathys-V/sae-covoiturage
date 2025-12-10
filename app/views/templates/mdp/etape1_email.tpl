{include file='includes/header.tpl'}
<div class="container mt-5 mb-5 d-flex justify-content-center">
    <div class="card shadow-lg p-4" style="max-width: 500px; width: 100%; border-radius: 20px;">
        <h2 class="text-center fw-bold mb-3" style="color: #8c52ff;">Mot de passe oublié ?</h2>
        <p class="text-center text-muted">Entrez votre email, nous vous enverrons un code.</p>
        
        {if isset($error)}
            <div class="alert alert-danger">{$error}</div>
        {/if}

        <form action="/sae-covoiturage/public/mot-de-passe-oublie" method="POST">
            <div class="mb-3">
                <label class="form-label fw-bold">Adresse email</label>
                <input type="email" name="email" class="form-control rounded-pill" required>
            </div>
            <button type="submit" class="btn btn-purple w-100 py-2">Envoyer le code</button>
        </form>
        <div class="text-center mt-3">
            <a href="/sae-covoiturage/public/connexion" class="text-decoration-none">Retour</a>
        </div>
    </div>
</div>
{include file='includes/footer.tpl'}