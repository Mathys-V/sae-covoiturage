{include file='includes/header.tpl'}

<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/style_inscription.css">

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

                        <div id="error-email-doublon" class="text-danger mt-2 small d-none">
                            Cette adresse email possède déjà un compte. <a href="/sae-covoiturage/public/connexion">Connectez-vous ici</a>.
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
                        <div id="error-post" class="text-danger mt-2 small d-none">
                            Le code postal doit contenir exactement 5 chiffres (ex: 80000).
                        </div>
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
                        <label for="immatInput" class="form-label immat-texte fw-bold mb-3">
                            Sa plaque d'immatriculation ? <span class="asterisque">*</span>
                        </label>
                        <input
                            type="text"
                            id="immatInput"
                            name="immat"
                            class="form-control"
                            placeholder="AA-123-AA ou 1234-ABC-12"
                            maxlength="14"
                            oninput="this.value = this.value.toUpperCase()"
                            onblur="validerImmatriculation()"
                            required>
                        <div class="invalid-feedback">
                            Format invalide. Exemples : AA-123-AA (nouveau) ou 1234-ABC-12 (ancien)
                        </div>
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

<script src="/sae-covoiturage/public/assets/javascript/js_inscription.js"></script>

{include file='includes/footer.tpl'}