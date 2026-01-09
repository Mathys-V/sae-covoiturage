{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/pages_footer/style_contact.css">

<div class="page-wrapper">

    <main class="main-content">
        
        <h1 class="contact-title">Contactez-nous</h1>

        <div class="simulation-info">
            ℹ️ <strong>Mode Démonstration :</strong> Aucun email réel ne sera envoyé. 
            Votre message sera enregistré dans un fichier texte sur le serveur.
        </div>

        {if isset($smarty.session.flash_success)}
            <div class="alert alert-success">
                {$smarty.session.flash_success}
            </div>
            {* On efface le message après affichage pour qu'il ne réapparaisse pas *}
            {$smarty.session.flash_success = null} 
        {/if}

        {if isset($smarty.session.flash_error)}
            <div class="alert alert-error">
                {$smarty.session.flash_error}
            </div>
            {$smarty.session.flash_error = null}
        {/if}

        <form class="contact-form" action="" method="POST">
            
            <div class="form-group">
                <label class="form-label" for="problem">
                    Quel est votre problème ?<span class="required-star">*</span>
                </label>
                <input type="text" id="problem" name="problem" class="form-input" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="email">
                    Quel est votre e-mail ?<span class="required-star">*</span>
                </label>
                <input type="email" id="email" name="email" class="form-input" value="{if isset($smarty.session.user.email)}{$smarty.session.user.email}{/if}" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="message">
                    Décrivez-nous votre demande en détail<span class="required-star">*</span>
                </label>
                <textarea id="message" name="message" class="form-textarea" required></textarea>
            </div>

            <div class="submit-container">
                <button type="submit" class="btn-submit">
                    Envoyer (Simulation)
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M22 2L11 13" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <path d="M22 2L15 22L11 13L2 9L22 2Z" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </button>
            </div>

        </form>

        <p class="required-note">*champ obligatoire</p>

    </main>

    {include file='includes/footer.tpl'}

</div>