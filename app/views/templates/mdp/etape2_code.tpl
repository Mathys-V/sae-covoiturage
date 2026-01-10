{include file='includes/header.tpl'}

{* Inclusion de la feuille de style spécifique à la saisie du code *}
<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/mdp/style_etape2_code.css">

<div class="container d-flex justify-content-center align-items-center flex-grow-1 my-5">
    <div class="card shadow-lg p-4 p-md-5" style="max-width: 500px; width: 100%; border-radius: 20px; border: none;">
        
        <h2 class="text-center fw-bold mb-3" style="color: #8c52ff;">Vérification</h2>
        <p class="text-center text-muted mb-4">Saisissez le code de sécurité reçu.</p>
        
        {* Alerte informative spécifique au contexte SAE (Simulation) *}
        <div class="simu-alert">
            <i class="bi bi-info-circle-fill fs-5"></i>
            <div>
                <strong>Simulation</strong> : Le code se trouve dans le fichier <code>code_mail.txt</code> sur le serveur.
            </div>
        </div>

        {* Affichage des erreurs (ex: code invalide ou expiré) *}
        {if isset($error)}
            <div class="alert alert-danger text-center rounded-3 mb-4">
                <i class="bi bi-exclamation-triangle me-2"></i>{$error}
            </div>
        {/if}

        {* Formulaire de soumission du code de vérification *}
        <form action="/sae-covoiturage/public/mot-de-passe-oublie/verify" method="POST">
            <div class="mb-4">
                <label class="form-label fw-bold text-dark">Code à 6 chiffres</label>
                {* Champ de saisie du code (centré, gros caractères) *}
                <input type="text" name="code" class="form-control bg-light border-0 rounded-pill py-3 text-center fs-3 code-input" 
                       placeholder="000000" maxlength="6" required autocomplete="off">
            </div>
            
            {* Bouton de validation *}
            <button type="submit" class="btn btn-purple w-100 py-2 rounded-pill fw-bold shadow-sm">
                Vérifier le code
            </button>
        </form>

        {* Lien pour recommencer la procédure (renvoi de code) *}
        <div class="text-center mt-4">
            <a href="/sae-covoiturage/public/mot-de-passe-oublie" class="text-decoration-none text-secondary fw-semibold small">
                <i class="bi bi-arrow-counterclockwise me-1"></i> Renvoyer un code
            </a>
        </div>
    </div>
</div>

{include file='includes/footer.tpl'}