{include file='includes/header.tpl'}

<div class="container mt-5 mb-5 d-flex justify-content-center">
    <div class="card shadow-lg p-4" style="max-width: 500px; width: 100%; border-radius: 20px;">
        <h2 class="text-center fw-bold mb-3" style="color: #8c52ff;">Nouveau mot de passe</h2>
        
        {if isset($error)}
            <div class="alert alert-danger">{$error}</div>
        {/if}

        <form action="/sae-covoiturage/public/mot-de-passe-oublie/save" method="POST">
            
            <div class="mb-3 position-relative">
                <label class="form-label fw-bold">Nouveau mot de passe</label>
                <input type="password" name="mdp" class="form-control rounded-pill pe-5" required minlength="8" placeholder="8 caractères minimum">
                <i class="bi bi-eye-slash toggle-password position-absolute top-50 end-0 translate-middle-y me-3 pt-4" 
                   style="cursor: pointer; color: #8c52ff;"></i>
            </div>

            <div class="mb-4 position-relative">
                <label class="form-label fw-bold">Confirmer le mot de passe</label>
                <input type="password" name="confirm_mdp" class="form-control rounded-pill pe-5" required placeholder="Répétez le mot de passe">
                <i class="bi bi-eye-slash toggle-password position-absolute top-50 end-0 translate-middle-y me-3 pt-4" 
                   style="cursor: pointer; color: #8c52ff;"></i>
            </div>

            <button type="submit" class="btn btn-purple w-100 py-2">Enregistrer</button>
        </form>
    </div>
</div>

<script>
    // On sélectionne toutes les icônes qui ont la classe "toggle-password"
    const toggles = document.querySelectorAll('.toggle-password');

    toggles.forEach(icon => {
        icon.addEventListener('click', function() {
            // On trouve le champ input juste avant l'icône
            const input = this.previousElementSibling;
            
            // On bascule entre 'password' et 'text'
            const type = input.getAttribute('type') === 'password' ? 'text' : 'password';
            input.setAttribute('type', type);
            
            // On change l'icône (oeil barré ou ouvert)
            this.classList.toggle('bi-eye');
            this.classList.toggle('bi-eye-slash');
        });
    });
</script>

{include file='includes/footer.tpl'}