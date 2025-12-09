{include file='includes/header.tpl'}

<section class="d-flex justify-content-center align-items-center p-3" style="min-height: 90vh;">
    
    <div class="card shadow-lg border-0 rounded-4 p-4 p-md-5 position-relative card-scrollable" style="width: 100%; max-width: 800px;">        
        <h1 class="text-center mb-5 titre-inscription">S'inscrire</h1>

        <form action="traitement_inscription.php" method="POST">
            
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

                <div class="text-center mt-5 mb-4">
                    <button type="button" class="btn btn-inscription fw-bold" onclick="verifierEmail()">Continuer</button>
                </div>
            </div>


            <div class="d-none bloc-etape" id="step-2">
                
                <div class="mb-4">
                    <label for="mdpInput" class="form-label mdp-texte fw-bold mb-3">
                        Entrez votre mot de passe <span class="asterisque">*</span>
                    </label>
                    <input type="password" id="mdpInput" name="mdp" class="form-control" required>
                </div>

                <div class="mb-4">
                    <label for="confMdpInput" class="form-label mdp-texte fw-bold mb-3">
                        Confirmez votre mot de passe <span class="asterisque">*</span>
                    </label>
                    <input type="password" id="confMdpInput" name="conf-mdp" class="form-control" required>
                    
                    <div id="error-mdp" class="text-danger mt-2 small d-none">
                        Les mots de passe ne correspondent pas ou sont vides.
                    </div>
                </div>

                <div class="text-center mt-5 mb-4">
                    <button type="button" class="btn btn-inscription fw-bold" onclick="verifierMDP()">Continuer</button>
                </div>
            </div>


            <div class="d-none bloc-etape" id="step-3">
                <div class="mb-4">
                    <label for="nomInput" class="form-label nom-texte fw-bold mb-3">
                        Quelle est votre nom ?  <span class="asterisque">*</span>
                    </label>
                    <input type="text" id="nomInput" name="nom" class="form-control" required>
                </div>

                <div class="mb-4">
                    <label for="prenomInput" class="form-label prenom-texte fw-bold mb-3">
                        Quelle est votre prénom ?  <span class="asterisque">*</span>
                    </label>
                    <input type="text" id="prenomInput" name="prenom" class="form-control" required>
                </div>

                <div class="text-center mt-5 mb-4">
                    <button type="submit" class="btn btn-inscription fw-bold" onclick="changerEtape(4)">Continuer</button>
                </div>
            </div>


            <div class="d-none bloc-etape" id="step-4">
                <div class="mb-4">
                    <label for="dateInput" class="form-label date-texte fw-bold mb-3">
                        Quelle est votre date de naissance ?  <span class="asterisque">*</span>
                    </label>
                    <input type="date" id="dateInput" name="date" class="form-control" required>
                </div>

                <div class="mb-4">
                    <label for="telInput" class="form-label tel-texte fw-bold mb-3">
                        Quelle est votre numéro de téléphone ?  <span class="asterisque">*</span>
                    </label>
                    <input type="tel" 
                        id="telInput" 
                        name="telephone" 
                        class="form-control" 
                        placeholder="0612345678" 
           
                        maxlength="10" 
                        pattern="[0-9]{10}" 
                        inputmode="numeric" 
           
                        oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                        required>
                </div>

                <div class="text-center mt-5 mb-4">
                    <button type="submit" class="btn btn-inscription fw-bold" onclick="changerEtape(5)">Continuer</button>
                </div>
            </div>


            <div class="d-none bloc-etape" id="step-5">
                <div class="mb-4">
                    <label for="rueInput" class="form-label rue-texte fw-bold mb-3">
                        Votre rue ?  <span class="asterisque">*</span>
                    </label>
                    <input type="text" id="rueInput" name="rue" class="form-control" required>
                </div>

                <div class="mb-4">
                    <label for="complementInput" class="form-label complement-texte fw-bold mb-3">
                        Un complement ?
                    </label>
                    <input type="text" id="complementInput" name="complement" class="form-control" required>
                </div>

                <div class="mb-4">
                    <label for="villeInput" class="form-label ville-texte fw-bold mb-3">
                        Un complement ?  <span class="asterisque">*</span>
                    </label>
                    <input type="text" id="villeInput" name="ville" class="form-control" required>
                </div>

                <div class="mb-4">
                    <label for="postInput" class="form-label post-texte fw-bold mb-3">
                        Le code postal ?  <span class="asterisque">*</span>
                    </label>
                    <input type="text" id="postInput" name="post" class="form-control" required>
                </div>

                <div class="text-center mt-5 mb-4">
                    <button type="submit" class="btn btn-inscription fw-bold" onclick="changerEtape(5)">Continuer</button>
                </div>
            </div>


        </form>

        <p class="position-absolute bottom-0 start-0 m-4 texte-champ small">
            <span class="asterisque">*</span> champ obligatoire
        </p>
    </div>

</section>

<script>
    function changerEtape(numeroEtape) {
        let toutesLesEtapes = document.querySelectorAll('.bloc-etape');
        toutesLesEtapes.forEach(div => div.classList.add('d-none'));

        let etapeVisee = document.getElementById('step-' + numeroEtape);
        if(etapeVisee) etapeVisee.classList.remove('d-none');
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
            
            // Erreur !
            errorMsg.classList.remove('d-none');
            mdpInput.classList.add('is-invalid');
            confMdpInput.classList.add('is-invalid');
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

    /* Style du bouton unique */
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

    @media (min-width: 768px) {
        .btn-inscription { width: 40%; padding: 12px 40px; }
    }

    .card-scrollable {
        /* Hauteur maximum : 75% de la hauteur de l'écran */
        max-height: 75vh; 
    
        /* Si ça dépasse, on active le scroll vertical */
        overflow-y: auto; 
    
        /* Pour que le scroll soit fluide */
        scroll-behavior: smooth;
    }


    .card-scrollable::-webkit-scrollbar {
        width: 8px; /* Largeur fine */
    }

    .card-scrollable::-webkit-scrollbar-track {
        background: #f1f1f1; /* Fond de la barre gris clair */
        border-radius: 10px;
        margin: 20px 0; /* Marges en haut et bas pour l'esthétique */
    }

    .card-scrollable::-webkit-scrollbar-thumb {
        background: #8c52ff; /* Couleur violette de votre site */
        border-radius: 10px;
    }

    .card-scrollable::-webkit-scrollbar-thumb:hover {
        background: #452b85; /* Violet foncé au survol */
    }
</style>
{include file='includes/footer.tpl'}