function changerEtape(numeroEtape) {
    let toutesLesEtapes = document.querySelectorAll(".bloc-etape");
    toutesLesEtapes.forEach((div) => div.classList.add("d-none"));

    let etapeVisee = document.getElementById("step-" + numeroEtape);
    if (etapeVisee) etapeVisee.classList.remove("d-none");

    let headerFixe = document.querySelector(".card > div.text-center");
    let footerText = document.querySelector(".texte-champ");

    if (numeroEtape === 8) {
        if (headerFixe) headerFixe.classList.add("d-none");
    } else {
        if (headerFixe) headerFixe.classList.remove("d-none");
    }

    if (numeroEtape === 6 || numeroEtape === 8) {
        if (footerText && footerText.parentElement) {
            footerText.parentElement.classList.add("d-none");
        }
    } else {
        if (footerText && footerText.parentElement) {
            footerText.parentElement.classList.remove("d-none");
        }
    }
}

async function verifierEmail() {
    const emailInput = document.getElementById("emailInput");
    const errorFormat = document.getElementById("error-email");
    const errorDoublon = document.getElementById("error-email-doublon");

    // 1. Reset des erreurs visuelles
    errorFormat.classList.add("d-none");
    errorDoublon.classList.add("d-none");
    emailInput.classList.remove("is-invalid");

    // 2. Vérification du format HTML5 (le @, etc.)
    if (!emailInput.checkValidity()) {
        errorFormat.classList.remove("d-none");
        emailInput.classList.add("is-invalid");
        return; // On arrête tout si le format est mauvais
    }

    // 3. Vérification en base de données via AJAX
    try {
        const emailValue = emailInput.value;
        const response = await fetch(
            "/sae-covoiturage/public/api/check-email?email=" +
                encodeURIComponent(emailValue)
        );
        const data = await response.json();

        if (data.exists) {
            // L'email existe déjà en BDD
            errorDoublon.classList.remove("d-none");
            emailInput.classList.add("is-invalid");
        } else {
            // L'email est libre, on passe à l'étape 2
            changerEtape(2);
        }
    } catch (error) {
        console.error("Erreur lors de la vérification email:", error);
        alert(
            "Impossible de vérifier l'email pour le moment. Veuillez réessayer."
        );
    }
}

function verifierMDP() {
    const mdpInput = document.getElementById("mdpInput");
    const confMdpInput = document.getElementById("confMdpInput");
    const errorMsg = document.getElementById("error-mdp");

    const mdp = mdpInput.value;
    const confMdp = confMdpInput.value;

    // 1. Vérifier la correspondance
    if (mdp !== confMdp) {
        afficherErreur("Les mots de passe ne correspondent pas.");
        return;
    }

    // 2. Vérifier la longueur (min 8)
    if (mdp.length < 8) {
        afficherErreur("Le mot de passe doit faire au moins 8 caractères.");
        return;
    }

    // 3. Vérifier le contenu sans Regex
    let aUneLettre = false;
    let aUnChiffre = false;
    let aUnSpecial = false;

    for (let i = 0; i < mdp.length; i++) {
        let char = mdp[i];

        if (char >= "0" && char <= "9") {
            aUnChiffre = true;
        } else if (char.toLowerCase() !== char.toUpperCase()) {
            aUneLettre = true;
        } else {
            aUnSpecial = true;
        }
    }

    if (!aUneLettre || !aUnChiffre || !aUnSpecial) {
        afficherErreur(
            "Il faut au moins 1 lettre, 1 chiffre et 1 caractère spécial."
        );
        return;
    }

    // Tout est bon
    errorMsg.classList.add("d-none");
    mdpInput.classList.remove("is-invalid");
    confMdpInput.classList.remove("is-invalid");
    changerEtape(3);
}

function afficherErreur(message) {
    const errorMsg = document.getElementById("error-mdp");
    const mdpInput = document.getElementById("mdpInput");
    const confMdpInput = document.getElementById("confMdpInput");

    errorMsg.textContent = message;
    errorMsg.classList.remove("d-none");
    mdpInput.classList.add("is-invalid");
    confMdpInput.classList.add("is-invalid");
}

function modifierPlaces(direction) {
    const input = document.getElementById("nbPlacesInput");
    let valeur = parseInt(input.value);
    let nouvelleValeur = valeur + direction;

    if (nouvelleValeur >= 1 && nouvelleValeur <= 8) {
        input.value = nouvelleValeur;
    }
}

function validerEtape3() {
    const nom = document.getElementById("nomInput").value.trim();
    const prenom = document.getElementById("prenomInput").value.trim();

    if (nom && prenom) {
        changerEtape(4);
    }
}

function validerEtape4() {
    const dateInput = document.getElementById("dateInput");
    const tel = document.getElementById("telInput").value;

    const dateSaisie = new Date(dateInput.value);

    const dateLimite13ans = new Date();
    dateLimite13ans.setFullYear(dateLimite13ans.getFullYear() - 13);
    dateLimite13ans.setHours(0, 0, 0, 0);

    const dateMin = new Date("1900-01-01");

    if (!dateInput.value) {
        alert("Veuillez entrer une date.");
        return;
    }

    if (dateSaisie > dateLimite13ans) {
        alert("Vous devez avoir au moins 13 ans pour vous inscrire.");
        return;
    }

    if (dateSaisie < dateMin) {
        alert("Veuillez entrer une année de naissance valide.");
        return;
    }

    if (tel.length === 10) {
        changerEtape(5);
    } else {
        alert("Le numéro de téléphone doit comporter 10 chiffres.");
    }
}

function validerEtape5() {
    const rueInput = document.getElementById("rueInput");
    const villeInput = document.getElementById("villeInput");
    const postInput = document.getElementById("postInput");
    const errorPost = document.getElementById("error-post");

    const rue = rueInput.value.trim();
    const ville = villeInput.value.trim();
    const post = postInput.value.trim();

    errorPost.classList.add("d-none");
    postInput.classList.remove("is-invalid");

    if (!rue || !ville || !post) {
        alert(
            "Veuillez remplir tous les champs obligatoires (Rue, Ville, Code Postal)."
        );
        return;
    }

    const regexCP = /^[0-9]{5}$/;

    if (!regexCP.test(post)) {
        errorPost.classList.remove("d-none");
        postInput.classList.add("is-invalid");
        return;
    }

    changerEtape(6);
}

function choisirVoiture() {
    changerEtape(7);
}

function soumettreSansVoiture() {
    let champsVoiture = document.querySelectorAll("#step-7 input");
    champsVoiture.forEach(function (champ) {
        champ.removeAttribute("required");
        champ.disabled = true;
    });

    let form = document.querySelector("form");
    let hiddenInput = document.createElement("input");
    hiddenInput.type = "hidden";
    hiddenInput.name = "voiture";
    hiddenInput.value = "non";
    form.appendChild(hiddenInput);

    form.submit();
}

function validerImmatriculation() {
    const immatInput = document.getElementById("immatInput");
    const immat = immatInput.value.trim().toUpperCase();

    const nouveau = "[A-Z][A-Z][- ]?\\d\\d\\d[- ]?[A-Z][A-Z]";
    const ancien = "\\d+[- ]?[A-Z][A-Z][A-Z]?[- ]?\\d\\d";

    const pattern = "^((" + nouveau + ")|(" + ancien + "))$";
    const regexImmat = new RegExp(pattern);

    if (!regexImmat.test(immat)) {
        immatInput.classList.add("is-invalid");
        return false;
    } else {
        immatInput.classList.remove("is-invalid");
        return true;
    }
}

function soumettreAvecVoiture() {
    const marque = document.getElementById("marqueInput").value.trim();
    const modele = document.getElementById("modelInput").value.trim();
    const immat = document.getElementById("immatInput").value.trim();

    // 1. Vérifier que les champs sont remplis
    if (!marque || !modele || !immat) {
        alert("Veuillez remplir tous les champs obligatoires de la voiture.");
        return;
    }

    // 2. IMPORTANT : Vérifier que la plaque est valide (format)
    // On appelle explicitement la fonction de validation. Si elle renvoie false, on arrête.
    if (!validerImmatriculation()) {
        alert("Le format de la plaque d'immatriculation est incorrect.");
        document.getElementById("immatInput").focus(); // On remet le curseur dans le champ erreur
        return;
    }

    let form = document.querySelector("form");

    // 3. Nettoyage : Supprimer l'input caché s'il existe déjà (cas de double clic)
    let ancienInput = form.querySelector('input[name="voiture"]');
    if (ancienInput) {
        ancienInput.remove();
    }

    // 4. Création de l'input caché pour dire "J'ai une voiture"
    let hiddenInput = document.createElement("input");
    hiddenInput.type = "hidden";
    hiddenInput.name = "voiture";
    hiddenInput.value = "oui";
    form.appendChild(hiddenInput);

    // 5. Soumission finale
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

document.addEventListener("DOMContentLoaded", function () {
    const dateInput = document.getElementById("dateInput");
    if (dateInput) {
        const today = new Date();
        today.setFullYear(today.getFullYear() - 13);

        // Formatage en YYYY-MM-DD pour l'attribut HTML
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, "0");
        const day = String(today.getDate()).padStart(2, "0");

        const maxDate = `${year}-${month}-${day}`;
        dateInput.setAttribute("max", maxDate);
        dateInput.setAttribute("min", "1900-01-01");
    }
});
