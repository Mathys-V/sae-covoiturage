<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$titre}</title>
    
    <link rel="stylesheet" href="/sae-covoiturage/public/assets/css/style_modif_mdp.css">
</head>
<body>

    {include file='includes/header.tpl'}

    <main>
        <h1>Mot de passe</h1>
        <div class="subtitle">Il doit comporter au moins 8 caractères dont 1 lettre, 1 chiffre et 1 caractère spécial.</div>

        <form action="/sae-covoiturage/public/profil/modifier_mdp" method="POST" id="mdpForm">
            
            <div class="input-group">
                <label>Entrez votre mot de passe actuel</label>
                <div class="input-wrapper">
                    <input type="password" name="current_password" id="current_password" required>
                    <svg class="toggle-password" onclick="togglePwd('current_password')" viewBox="0 0 24 24"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/></svg>
                </div>
                <div class="error-text {if isset($errors.current)}show-error-php{/if}" id="msg-error-current">
                    {$errors.current|default:"Le mot de passe n'est pas celui actuel"}
                </div>
            </div>

            <div class="input-group">
                <label>Entrez votre nouveau mot de passe</label>
                <div class="input-wrapper">
                    <input type="password" name="new_password" id="new_password" required>
                    <svg class="toggle-password" onclick="togglePwd('new_password')" viewBox="0 0 24 24"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/></svg>
                </div>
                <div class="error-text {if isset($errors.format)}show-error-php{/if}" id="msg-error-format">
                    Le mot de passe saisi n'est pas valide. Vérifiez qu'il ne manque pas une consigne.
                </div>
            </div>

            <div class="input-group">
                <label>Confirmez votre nouveau mot de passe</label>
                <div class="input-wrapper">
                    <input type="password" name="confirm_password" id="confirm_password" required>
                    <svg class="toggle-password" onclick="togglePwd('confirm_password')" viewBox="0 0 24 24"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/></svg>
                </div>
                <div class="error-text {if isset($errors.confirm)}show-error-php{/if}" id="msg-error-confirm">
                    Les mots de passe ne correspondent pas.
                </div>
            </div>

            <button type="submit" class="btn-confirm" id="btnSubmit">Confirmer</button>
        </form>
    </main>

    <div class="custom-overlay" id="confirmModal">
        <div class="custom-modal-box">
            <h2>Confirmation</h2>
            <p>Voulez-vous vraiment modifier votre mot de passe ?</p>
            <div class="modal-actions">
                <button class="modal-btn modal-btn-cancel" onclick="closeConfirm()">Non</button>
                <button class="modal-btn" onclick="submitRealForm()">Oui</button>
            </div>
        </div>
    </div>

    <div class="custom-overlay {if isset($success)}show-modal{/if}">
        <div class="custom-modal-box">
            <h2>Mot de passe</h2>
            <p>La modification du mot de passe a été effectuée.</p>
            <button class="modal-btn" onclick="window.location.href='/sae-covoiturage/public/profil'">Ok</button>
        </div>
    </div>

    {include file='includes/footer.tpl'}

    <script src="/sae-covoiturage/public/assets/javascript/js_modif_mdp.js"></script>

</body>
</html>