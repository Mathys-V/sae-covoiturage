{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/parametre/style_modifier_adresse.css">

<main>
    <h1>Modifier votre adresse</h1>

    <form action="/sae-covoiturage/public/profil/modifier_adresse" method="POST" id="addressForm">
        
        <div class="input-group">
            <label for="rue">Votre rue ?<span class="required-star">*</span></label>
            
            <div class="autocomplete-wrapper">
                <input type="text" name="rue" id="rue" value="{$adresse.voie|default:''}" placeholder="Commencez à taper votre adresse..." autocomplete="off">
                
                <div class="autocomplete-suggestions"></div>
            </div>
            
            <div class="error-message" id="errorRue">Ce champ est obligatoire.</div>
        </div>

        <div class="input-group">
            <label for="complement">Un complément ?</label>
            <input type="text" name="complement" id="complement" value="{$adresse.complement|default:''}" placeholder="Ex: Appartement 6">
        </div>

        <div class="input-group">
            <label for="ville">Votre ville ?<span class="required-star">*</span></label>
            <input type="text" name="ville" id="ville" value="{$adresse.ville|default:''}" placeholder="Ville">
            <div class="error-message" id="errorVille">Veuillez entrer une ville.</div>
        </div>

        <div class="input-group">
            <label for="cp">Le code postal ?<span class="required-star">*</span></label>
            <input type="text" name="cp" id="cp" value="{$adresse.code_postal|default:''}" placeholder="Code postal" maxlength="5">
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

<script src="/sae-covoiturage/public/assets/javascript/parametre/js_modif_adresse.js"></script>