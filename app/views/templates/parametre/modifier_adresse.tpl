<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$titre}</title>
    
    <link rel="stylesheet" href="/sae-covoiturage/public/assets/css/parametre/style_modifier_adresse.css">
</head>
<body>

    {include file='includes/header.tpl'}

    <main>
        <h1>Votre adresse postale</h1>

        <form action="/sae-covoiturage/public/profil/modifier_adresse" method="POST" id="addressForm">
            
            <div class="input-group">
                <label>Votre rue ?<span class="required-star">*</span></label>
                <input type="text" name="rue" id="rue" value="{$adresse.voie|default:''}" placeholder="Commencez à taper votre adresse..." autocomplete="off">
                
                <ul class="suggestions-list" id="suggestions"></ul>
                
                <div class="error-message" id="errorRue">Ce champ est obligatoire.</div>
                <div class="error-message" id="errorRueApi">Veuillez sélectionner une adresse existante dans la liste.</div>
            </div>

            <div class="input-group">
                <label>Un complément ?</label>
                <input type="text" name="complement" id="complement" value="{$adresse.complement|default:''}" placeholder="Ex: Appartement 6">
            </div>

            <div class="input-group">
                <label>Votre ville ?<span class="required-star">*</span></label>
                <input type="text" name="ville" id="ville" value="{$adresse.ville|default:''}" placeholder="Sera rempli automatiquement">
                <div class="error-message" id="errorVille">Veuillez entrer une ville valide.</div>
            </div>

            <div class="input-group">
                <label>Le code postal ?<span class="required-star">*</span></label>
                <input type="text" name="cp" id="cp" value="{$adresse.code_postal|default:''}" placeholder="Sera rempli automatiquement" maxlength="5">
                <div class="error-message" id="errorCp">Le code postal doit contenir 5 chiffres.</div>
            </div>
            
            <div style="font-size: 0.8rem; color: #aaa; margin-top: -10px;">*champ obligatoire</div>

            <button type="submit" class="btn-confirm">Confirmer</button>
        </form>
    </main>

    <div class="custom-overlay" id="confirmModal">
        <div class="custom-modal-box">
            <h2>Confirmation</h2>
            <p>Voulez-vous vraiment enregistrer cette nouvelle adresse ?</p>
            <div class="modal-actions">
                <button class="custom-btn custom-btn-cancel" onclick="closeConfirm()">Non</button>
                <button class="custom-btn" onclick="submitRealForm()">Oui, modifier</button>
            </div>
        </div>
    </div>

    <div class="custom-overlay {if isset($success)}show-custom-modal{/if}" id="successModal">
        <div class="custom-modal-box">
            <h2>Succès !</h2>
            <p>Votre adresse a été mise à jour avec succès.</p>
            <button class="custom-btn" onclick="window.location.href='/sae-covoiturage/public/profil'">Retour au profil</button>
        </div>
    </div>

    {include file='includes/footer.tpl'}

    <script src="/sae-covoiturage/public/assets/javascript/js_modifier_adresse.js"></script>

</body>
</html>