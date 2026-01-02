{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/mdp/style_etape3_nouveau.css">

<div class="container d-flex justify-content-center align-items-center flex-grow-1 my-5">
    <div class="card shadow-lg p-4 p-md-5" style="max-width: 500px; width: 100%; border-radius: 20px; border: none;">
        
        <h2 class="text-center fw-bold mb-1" style="color: #8c52ff;">Nouveau mot de passe</h2>
        <p class="text-center fw-bold text-dark mb-4">Compte : {$nom_user|default:'Utilisateur'}</p>
        
        {if isset($error)}
            <div class="alert alert-danger text-center rounded-3 mb-4">
                <i class="bi bi-exclamation-triangle me-2"></i>{$error}
            </div>
        {/if}

        <form action="/sae-covoiturage/public/mot-de-passe-oublie/save" method="POST">
            
            <div class="mb-3">
                <label class="form-label fw-bold text-dark">Nouveau mot de passe</label>
                
                <div class="position-relative">
                    <input type="password" name="mdp" class="form-control rounded-pill py-2 pe-5" required minlength="8" placeholder="••••••••">
                    <i class="bi bi-eye-slash toggle-password position-absolute top-50 end-0 translate-middle-y me-3 text-secondary" 
                       style="cursor: pointer; z-index: 5;"></i>
                </div>

                <div class="form-text text-muted mt-2 ps-2" style="font-size: 0.85rem;">
                    <i class="bi bi-shield-lock me-1"></i> Min. 8 caractères, 1 chiffre, 1 caractère spécial (@$!%*#?&).
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label fw-bold text-dark">Confirmer le mot de passe</label>
                
                <div class="position-relative">
                    <input type="password" name="confirm_mdp" class="form-control rounded-pill py-2 pe-5" required placeholder="••••••••">
                    <i class="bi bi-eye-slash toggle-password position-absolute top-50 end-0 translate-middle-y me-3 text-secondary" 
                       style="cursor: pointer; z-index: 5;"></i>
                </div>
            </div>

            <button type="submit" class="btn btn-purple w-100 py-2 rounded-pill fw-bold shadow-sm">
                Enregistrer le mot de passe
            </button>
        </form>
    </div>
</div>

<script>
    // Gestion de l'affichage du mot de passe (Eye Icon)
    const toggles = document.querySelectorAll('.toggle-password');

    toggles.forEach(icon => {
        icon.addEventListener('click', function() {
            // On cherche l'input dans le même conteneur parent (le div.position-relative)
            const input = this.parentElement.querySelector('input');
            
            if (input) {
                const type = input.getAttribute('type') === 'password' ? 'text' : 'password';
                input.setAttribute('type', type);
                
                this.classList.toggle('bi-eye');
                this.classList.toggle('bi-eye-slash');
                
                if (type === 'text') {
                    this.style.color = '#8c52ff';
                    this.classList.remove('text-secondary');
                } else {
                    this.style.color = '';
                    this.classList.add('text-secondary');
                }
            }
        });
    });
</script>

{include file='includes/footer.tpl'}