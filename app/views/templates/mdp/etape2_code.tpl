{include file='includes/header.tpl'}
<div class="container mt-5 mb-5 d-flex justify-content-center">
    <div class="card shadow-lg p-4" style="max-width: 500px; width: 100%; border-radius: 20px;">
        <h2 class="text-center fw-bold mb-3" style="color: #8c52ff;">Vérification</h2>
        <p class="text-center text-muted">Un code a été envoyé (simulé dans code_mail.txt).</p>
        
        {if isset($error)}
            <div class="alert alert-danger">{$error}</div>
        {/if}

        <form action="/sae-covoiturage/public/mot-de-passe-oublie/verify" method="POST">
            <div class="mb-3">
                <label class="form-label fw-bold">Code reçu</label>
                <input type="text" name="code" class="form-control rounded-pill text-center fs-4" placeholder="000000" maxlength="6" required>
            </div>
            <button type="submit" class="btn btn-purple w-100 py-2">Vérifier</button>
        </form>
    </div>
</div>
{include file='includes/footer.tpl'}