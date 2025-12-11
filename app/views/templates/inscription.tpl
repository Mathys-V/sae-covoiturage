{include file='includes/header.tpl'}

<section class="d-flex justify-content-center align-items-center p-3" style="min-height: 90vh;">
    
    <div class="card shadow-lg border-0 rounded-4 position-relative d-flex flex-column overflow-hidden" 
        style="width: 100%; max-width: 800px; max-height: 80vh;">
        
        <div class="flex-shrink-0 text-center pt-4 pt-md-5 px-4 bg-white">
            <h1 class="mb-2 titre-inscription">S'inscrire</h1>
        </div>

        <div class="card-scrollable px-4 px-md-5 py-3 flex-grow-1 bg-white">
            
            <form action="" method="POST">
                
                <div class="bloc-etape" id="step-1">        
                    <div class="mb-5">
                        <label for="emailInput" class="form-label adresse-texte fw-bold mb-3">
                            Quelle est votre adresse mail ?<span class="asterisque">*</span>
                        </label>
                        <input type="email" id="emailInput" name="email" class="form-control email-input" placeholder="exemple@mcovoitjv.com" required>
                        <div id="error-email" class="text-danger mt-2 small d-none">
                            Veuillez entrer une adresse email valide (avec un @).
                        </div>
                    </div>
                    <div class="text-center mt-4 mb-1">
                        <button type="button" class="btn btn-inscription fw-bold" onclick="verifierEmail()">Continuer</button>
                    </div>
                    <div class="text-center mt-0">
                        <a href="/sae-covoiturage/public/connexion" class="text-decoration-none fw-bold text-purple" style="margin-top=0">Se connecter</a>
                    </div>
                </div>

                <div class="d-none bloc-etape" id="step-2">
    
                    <div class="mb-4">
                        <label for="mdpInput" class="form-label mdp-texte fw-bold mb-3">
                            Entrez votre mot de passe <span class="asterisque">*</span>
                        </label>
                        <div class="input-group">
                            <input type="password" id="mdpInput" name="mdp" class="form-control border-end-0" required>
                            <span class="input-group-text bg-white border-start-0" style="cursor: pointer;" onclick="togglePassword('mdpInput', 'icon-mdp')">
                                <i class="bi bi-eye" id="icon-mdp" style="color: #8c52ff;"></i>
                            </span>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label for="confMdpInput" class="form-label mdp-texte fw-bold mb-3">
                            Confirmez votre mot de passe <span class="asterisque">*</span>
                        </label>
                        <div class="input-group">
                            <input type="password" id="confMdpInput" name="conf-mdp" class="form-control border-end-0" required>
                            <span class="input-group-text bg-white border-start-0" style="cursor: pointer;" onclick="togglePassword('confMdpInput', 'icon-conf')">
                                <i class="bi bi-eye" id="icon-conf" style="color: #8c52ff;"></i>
                            </span>
                        </div>
        
                        <div id="error-mdp" class="text-danger mt-2 small d-none">
                            Les mots de passe ne correspondent pas ou sont vides.
                        </div>
                    </div>

                    <div class="text-center mt-4 mb-1">
                        <button type="button" class="btn btn-inscription fw-bold" onclick="verifierMDP()">Continuer</button>
                    </div>
                    <div class="text-center mt-0">
                        <a href="/sae-covoiturage/public/connexion" class="text-decoration-none fw-bold text-purple" style="margin-top=0">Se connecter</a>
                    </div>
                </div>

                <div class="d-none bloc-etape" id="step-3">
                    <div class="mb-4">
                        <label for="nomInput" class="form-label nom-texte fw-bold mb-3">
                            Quel est votre nom ? <span class="asterisque">*</span>
                        </label>
                        <input type="text" id="nomInput" name="nom" class="form-control" autocomplete="family-name" required>
                    </div>
                    <div class="mb-4">
                        <label for="prenomInput" class="form-label prenom-texte fw-bold mb-3">
                            Quel est votre prénom ? <span class="asterisque">*</span>
                        </label>
                        <input type="text" id="prenomInput" name="prenom" class="form-control" autocomplete="given-name" required>
                    </div>
                    <div class="text-center mt-4 mb-1">
                        <button type="button" class="btn btn-inscription fw-bold" onclick="validerEtape3()">Continuer</button>
                    </div>
                    <div class="text-center mt-0">
                        <a href="/sae-covoiturage/public/connexion" class="text-decoration-none fw-bold text-purple" style="margin-top=0">Se connecter</a>
                    </div>
                </div>

                <div class="d-none bloc-etape" id="step-4">
                    <div class="mb-4">
                        <label for="dateInput" class="form-label date-texte fw-bold mb-3">
                            Quelle est votre date de naissance ? <span class="asterisque">*</span>
                        </label>
                        <input type="date" id="dateInput" name="date" class="form-control"  required>
                    </div>
                    <div class="mb-4">
                        <label for="telInput" class="form-label tel-texte fw-bold mb-3">
                            Quel est votre numéro de téléphone ? <span class="asterisque">*</span>
                        </label>
                        <input type="tel" id="telInput" name="telephone" class="form-control" placeholder="0612345678" maxlength="10" pattern="[0-9]{10}" inputmode="numeric" oninput="this.value = this.value.replace(/[^0-9]/g, '')" required>
                    </div>
                    <div class="text-center mt-4 mb-1">
                        <button type="button" class="btn btn-inscription fw-bold" onclick="validerEtape4()">Continuer</button>
                    </div>
                    <div class="text-center mt-0">
                        <a href="/sae-covoiturage/public/connexion" class="text-decoration-none fw-bold text-purple" style="margin-top=0">Se connecter</a>
                    </div>
                </div>

                <div class="d-none bloc-etape" id="step-5">
                    <div class="mb-4">
                        <label for="rueInput" class="form-label rue-texte fw-bold mb-3">Votre rue ? <span class="asterisque">*</span></label>
                        <input type="text" id="rueInput" name="rue" class="form-control" placeholder="1 Rue Albert Catoire" required>
                    </div>
                    <div class="mb-4">
                        <label for="complementInput" class="form-label complement-texte fw-bold mb-3">Un complément ?</label>
                        <input type="text" id="complementInput" name="complement" class="form-control" placeholder="Bâtiment A">
                    </div>
                    <div class="mb-4">
                        <label for="villeInput" class="form-label ville-texte fw-bold mb-3">Votre ville ? <span class="asterisque">*</span></label>
                        <input type="text" id="villeInput" name="ville" class="form-control" placeholder="Amiens" required>
                    </div>
                    <div class="mb-4">
                        <label for="postInput" class="form-label post-texte fw-bold mb-3">Le code postal ? <span class="asterisque">*</span></label>
                        <input type="number" id="postInput" name="post" class="form-control" maxlength="5" pattern="[0-9]{5}"  placeholder="80000" required>
                    </div>
                    <div class="text-center mt-4 mb-1">
                        <button type="button" class="btn btn-inscription fw-bold" onclick="validerEtape5()">Continuer</button>
                    </div>
                    <div class="text-center mt-0">
                        <a href="/sae-covoiturage/public/connexion" class="text-decoration-none fw-bold text-purple" style="margin-top=0">Se connecter</a>
                    </div>
                </div>

                <div class="d-none bloc-etape" id="step-6">
                    <div class="mb-5 text-center">
                        <h3 style="color: #8c52ff;">Avez-vous une voiture ?</h3>
                    </div>
                    <div class="text-center mt-5 mb-4 d-flex justify-content-center gap-3">
                        <button type="button" class="btn btn-inscription btn-petit fw-bold" onclick="choisirVoiture()">Oui</button>
                        <button type="button" class="btn btn-inscription btn-petit fw-bold" onclick="soumettreSansVoiture()">Non</button>
                    </div>
                </div>


                <div class="d-none bloc-etape" id="step-7">
                    <div class="mb-5 text-center">
                        <h3 style="color: #8c52ff;">Parlez-nous de votre voiture</h3>
                    </div>
                    <div class="mb-4">
                        <label for="marqueInput" class="form-label marque-texte fw-bold mb-3">La marque ? <span class="asterisque">*</span></label>
                        <input type="text" id="marqueInput" name="marque" class="form-control" placeholder="Ford" required>
                    </div>
                    <div class="mb-4">
                        <label for="modelInput" class="form-label model-texte fw-bold mb-3">Le modèle ? <span class="asterisque">*</span></label>
                        <input type="text" id="modelInput" name="model" class="form-control" placeholder="Fiesta 5" required>
                    </div>
                    <div class="mb-4">
                        <label for="immatInput" class="form-label immat-texte fw-bold mb-3">Sa plaque d’immatriculation ? <span class="asterisque">*</span></label>
                        <input type="text" id="immatInput" name="immat" class="form-control" placeholder="XX-000-XX" required>
                    </div>
                    <div class="mb-4">
                        <label for="couleurInput" class="form-label couleur-texte fw-bold mb-3">La couleur ?</label>
                        <input type="text" id="couleurInput" name="couleur" class="form-control" placeholder="Violet">
                    </div>

                    <div class="mb-4">
                        <label class="form-label adresse-texte fw-bold mb-3">
                            Nombre de places? <span class="asterisque">*</span>
                        </label>
                    </div>
                    <div class="number-input-container">
                    <input type="number" id="nbPlacesInput" name="nb_places" class="form-control number-field" value="1" min="1" max="8" readonly>

                    <div class="spinners-container">
                        <button type="button" class="spinner-btn" onclick="modifierPlaces(1)">
                            <i class="bi bi-chevron-up"></i> </button>
            
                        <button type="button" class="spinner-btn" onclick="modifierPlaces(-1)">
                            <i class="bi bi-chevron-down"></i> </button>
                        </div>
                    </div>

                    <div class="text-center mt-4 mb-1">
                        <button type="button" class="btn btn-inscription fw-bold" onclick="soumettreAvecVoiture()">S'inscrire</button>
                    </div>
                    <div class="text-center mt-0">
                        <a href="/sae-covoiturage/public/connexion" class="text-decoration-none fw-bold text-purple" style="margin-top=0">Se connecter</a>
                    </div>
                </div>


                <div class="d-none bloc-etape" id="step-8">
                    <p class="form-label text-center fw-bold mb-3" style="center">
                        Votre compte a été créé avec succès
                    </p>

                    <div class="text-center mt-5 mb-4">
                        <button type="submit" class="btn btn-inscription fw-bold" onclick="window.location.href='/sae-covoiturage/public'">Continuer</button>
                    </div>
                </div>
            </form>
        </div>

        <div class="flex-shrink-0 p-4 bg-white">
            <p class="m-0 text-start texte-champ small">
                <span class="asterisque">*</span> champ obligatoire
            </p>
        </div>

    </div>
</section>

<script>
    function changerEtape(numeroEtape) {
        let toutesLesEtapes = document.querySelectorAll('.bloc-etape');
        toutesLesEtapes.forEach(div => div.classList.add('d-none'));

        let etapeVisee = document.getElementById('step-' + numeroEtape);
        if(etapeVisee) etapeVisee.classList.remove('d-none');

        let headerFixe = document.querySelector('.card > div.text-center'); 
        let footerText = document.querySelector('.texte-champ');

        if (numeroEtape === 8) {
            if(headerFixe) headerFixe.classList.add('d-none');
        } else {
            if(headerFixe) headerFixe.classList.remove('d-none');
        }

        if (numeroEtape === 6 || numeroEtape === 8) {
            if(footerText && footerText.parentElement) {
                footerText.parentElement.classList.add('d-none');
            }
        } else {
            if(footerText && footerText.parentElement) {
                footerText.parentElement.classList.remove('d-none');
            }
        }
    }
    
    function verifierEmail() {
        const emailInput = document.getElementById('emailInput');
        const errorMsg = document.getElementById('error-email');
        if (emailInput.checkValidity()) {
            errorMsg.classList.add('d-none');
            emailInput.classList.remove('is-invalid');
            changerEtape(2);
        } else {
            errorMsg.classList.remove('d-none');
            emailInput.classList.add('is-invalid');
        }
    }

    function verifierMDP() {
        const mdpInput = document.getElementById('mdpInput');
        const confMdpInput = document.getElementById('confMdpInput'); 
        const errorMsg = document.getElementById('error-mdp');

        if (mdpInput.value.length > 0 && mdpInput.value === confMdpInput.value) {
            errorMsg.classList.add('d-none');
            mdpInput.classList.remove('is-invalid');
            confMdpInput.classList.remove('is-invalid');
            changerEtape(3);
        } else {
            errorMsg.classList.remove('d-none');
            mdpInput.classList.add('is-invalid');
            confMdpInput.classList.add('is-invalid');
        }
    }

    function modifierPlaces(direction) {
        const input = document.getElementById('nbPlacesInput');
        let valeur = parseInt(input.value);
        let nouvelleValeur = valeur + direction;
        
        if (nouvelleValeur >= 1 && nouvelleValeur <= 8) {
            input.value = nouvelleValeur;
        }
    }

    // CORRECTION : Fonction pour valider les étapes intermédiaires
    function validerEtape3() {
        const nom = document.getElementById('nomInput').value.trim();
        const prenom = document.getElementById('prenomInput').value.trim();
        
        if (nom && prenom) {
            changerEtape(4);
        }
    }

    function validerEtape4() {
        const date = document.getElementById('dateInput').value;
        const tel = document.getElementById('telInput').value;
        
        if (date && tel.length === 10) {
            changerEtape(5);
        }
    }

    function validerEtape5() {
        const rue = document.getElementById('rueInput').value.trim();
        const ville = document.getElementById('villeInput').value.trim();
        const post = document.getElementById('postInput').value.trim();
        
        if (rue && ville && post.length === 5) {
            changerEtape(6);
        }
    }

    // CORRECTION : Fonction pour passer à l'étape voiture
    function choisirVoiture() {
        changerEtape(7);
    }

    // CORRECTION : Fonction pour soumettre SANS voiture
    function soumettreSansVoiture() {
        let champsVoiture = document.querySelectorAll('#step-7 input');
        champsVoiture.forEach(function(champ) {
            champ.removeAttribute('required');
            champ.disabled = true; 
        });

        let form = document.querySelector('form');
        let hiddenInput = document.createElement('input');
        hiddenInput.type = 'hidden';
        hiddenInput.name = 'voiture';
        hiddenInput.value = 'non';
        form.appendChild(hiddenInput);

        form.submit();
    }

    // CORRECTION : Fonction pour soumettre AVEC voiture
    function soumettreAvecVoiture() {
        const marque = document.getElementById('marqueInput').value.trim();
        const modele = document.getElementById('modelInput').value.trim();
        const immat = document.getElementById('immatInput').value.trim();
        const places = document.getElementById('nbPlacesInput').value;

        // Validation des champs obligatoires
        if (!marque || !modele || !immat) {
            alert('Veuillez remplir tous les champs obligatoires de la voiture.');
            return;
        }

        // On ajoute un champ caché pour indiquer "voiture=oui"
        let form = document.querySelector('form');
        let hiddenInput = document.createElement('input');
        hiddenInput.type = 'hidden';
        hiddenInput.name = 'voiture';
        hiddenInput.value = 'oui';
        form.appendChild(hiddenInput);

        // Soumission du formulaire
        form.submit();
    }

    function togglePassword(inputId, iconId) {
        const input = document.getElementById(inputId);
        const icon = document.getElementById(iconId);

        if (input.type === "password") {
            input.type = "text";
            icon.classList.remove("bi-eye");
            icon.classList.add("bi-eye-slash");
        } else {
            input.type = "password";
            icon.classList.remove("bi-eye-slash");
            icon.classList.add("bi-eye");
        }
    }
</script>

<style>
    body { background-color: #452b85; }
    
    .titre-inscription { color: #8c52ff; font-family: 'Garet', sans-serif; font-weight: bold; }
    .form-label { color: #8c52ff; font-size: 1.2rem; }
    .asterisque { color: #ED3F27; margin-left: 5px; }
    .texte-champ { color: #ED3F27; font-style: italic; }

    .form-control {
        border: 2px solid #8c52ff;
        border-radius: 12px;
        padding: 15px 20px;
        font-size: 1.1rem;
        background-color: #f9f9f9;
        transition: all 0.3s ease;
    }
    .form-control:focus {
        background-color: #fff;
        border-color: #452b85;
        box-shadow: 0 0 0 0.25rem rgba(140, 82, 255, 0.25);
        outline: none;
    }

    .btn-inscription {
        background-color: #8c52ff;
        color: white;
        border: none;
        padding: 12px 0;
        border-radius: 12px;
        font-size: 1.2rem;
        width: 100%;
        transition: transform 0.2s, background-color 0.3s;
    }
    .btn-inscription:hover {
        background-color: #452b85;
        color: white;
        transform: scale(1.02);
    }

    .btn-petit { 
        width: 100px !important;
        padding: 10px 0 !important;
        margin-left: 40px; 
        margin-right: 40px;
    }

    @media (min-width: 768px) {
        .btn-inscription { width: 40%; padding: 12px 40px; }
    }

    /* CSS POUR LE SCROLLBAR INTERNE */
    .card-scrollable {
        overflow-y: auto; /* Active le scroll vertical */
        scroll-behavior: smooth;
    }
    
    /* Scrollbar personnalisée */
    .card-scrollable::-webkit-scrollbar { width: 8px; }
    .card-scrollable::-webkit-scrollbar-track { background: #f1f1f1; border-radius: 10px; margin: 10px 0; }
    .card-scrollable::-webkit-scrollbar-thumb { background: #8c52ff; border-radius: 10px; }
    .card-scrollable::-webkit-scrollbar-thumb:hover { background: #452b85; }

    .number-input-container {
    display: flex;
    width: 120px; /* Largeur totale du bloc */
    height: 50px; /* Hauteur du bloc */
    border: 2px solid #8c52ff; /* Bordure violette autour de tout */
    border-radius: 8px; /* Un peu arrondi quand même, ou 0px si vous voulez carré */
    overflow: hidden; /* Pour que rien ne dépasse */
    background-color: white;
}

    .number-field {
        border: none !important; /* On enlève la bordure du champ lui-même */
        height: 100%;
        text-align: center;
        font-size: 1.5rem;
        color: #000;
        width: 100%;
        background: transparent;
        -moz-appearance: textfield;
    }
    .number-field:focus {
        box-shadow: none; /* Pas de halo bleu */
    }
    /* Cacher flèches Chrome/Safari */
    .number-field::-webkit-outer-spin-button,
    .number-field::-webkit-inner-spin-button {
        -webkit-appearance: none;
        margin: 0;
    }

    /* La colonne de droite (fond violet) */
    .spinners-container {
        display: flex;
        flex-direction: column; /* Empile les boutons haut/bas */
        width: 40px; /* Largeur de la zone violette */
        background-color: #8c52ff;
        border-left: 1px solid #8c52ff;
    }

    /* Les petits boutons flèches */
    .spinner-btn {
        flex: 1; /* Chaque bouton prend 50% de la hauteur */
        border: none;
        background: none;
        color: white; /* Flèches blanches */
        font-size: 0.8rem;
        cursor: pointer;
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 0;
    }

    .spinner-btn:hover {
        background-color: #452b85; /* Plus foncé au survol */
    }

    /* Petite ligne entre les deux boutons flèches */
    .spinner-btn:first-child {
        border-bottom: 1px solid rgba(255,255,255,0.3);
    }

    //Pour les boutons cacher/montrer mdp
    .input-group .form-control {
        border: 2px solid #8c52ff;
        border-right: none; /* On enlève le côté droit de l'input */
        border-radius: 12px 0 0 12px;
    }

    .input-group .input-group-text {
        border: 2px solid #8c52ff;
        border-left: none; /* On enlève le côté gauche de l'icône */
        border-radius: 0 12px 12px 0;
        background-color: white;
    }

    .input-group .form-control:focus {
        box-shadow: none; /* On gère le shadow manuellement si besoin */
        border-color: #8c52ff;
    }

</style>

{include file='includes/footer.tpl'}