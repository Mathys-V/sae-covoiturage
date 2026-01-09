/*
 * Gère l'affichage dynamique des différentes étapes du formulaire d'inscription.
 * Cette fonction agit comme un "routeur visuel" côté client :
 * 1. Elle masque toutes les sections (divs avec la classe .bloc-etape).
 * 2. Elle affiche uniquement la section correspondant au numéro d'étape demandé.
 * 3. Elle gère la visibilité des éléments contextuels comme le bouton "Retour",
 * le titre fixe en haut de la carte, et les mentions légales en bas.
 * 4. Elle réinitialise le scroll de la carte pour que l'utilisateur arrive toujours en haut de la nouvelle étape.
 */
let etapeActuelle = 1;

function changerEtape(numeroEtape) {
    etapeActuelle = numeroEtape;

    // Masquage de toutes les étapes
    let toutesLesEtapes = document.querySelectorAll(".bloc-etape");
    toutesLesEtapes.forEach((div) => div.classList.add("d-none"));

    // Affichage de l'étape cible
    let etapeVisee = document.getElementById("step-" + numeroEtape);
    if (etapeVisee) etapeVisee.classList.remove("d-none");

    // Gestion du bouton retour (caché à l'étape 1 et à la fin)
    const btnRetour = document.getElementById("btnRetourGlobal");
    if (btnRetour) {
        if (numeroEtape === 1 || numeroEtape === 8) {
            btnRetour.classList.add("d-none");
        } else {
            btnRetour.classList.remove("d-none");
        }
    }

    // Gestion de la visibilité Header/Footer pour l'immersion
    let headerFixe = document.querySelector(".card > div.text-center");
    let footerText = document.querySelector(".texte-champ");

    if (numeroEtape === 8) {
        if (headerFixe) headerFixe.classList.add("d-none");
    } else {
        if (headerFixe) headerFixe.classList.remove("d-none");
    }

    if (numeroEtape === 6 || numeroEtape === 8) {
        if (footerText && footerText.parentElement)
            footerText.parentElement.classList.add("d-none");
    } else {
        if (footerText && footerText.parentElement)
            footerText.parentElement.classList.remove("d-none");
    }

    // Reset du scroll vers le haut
    const cardScrollable = document.querySelector(".card-scrollable");
    if (cardScrollable) cardScrollable.scrollTop = 0;
}

// Fonction appelée par le bouton retour global
function retourArriere() {
    if (etapeActuelle > 1) {
        changerEtape(etapeActuelle - 1);
    }
}

/*
 * Met en place l'autocomplétion sur le champ "Rue" en utilisant l'API Adresse du gouvernement français.
 * Le script crée dynamiquement un conteneur pour les suggestions sous l'input.
 * À la frappe (événement 'input'), il interroge l'API avec un délai (debounce) pour éviter de spammer les requêtes.
 * Au clic sur une suggestion, il remplit automatiquement les champs Rue, Ville et Code Postal,
 * et ajoute un feedback visuel (clignotement couleur) pour confirmer le remplissage à l'utilisateur.
 */
function setupAddressAutocomplete() {
    const rueInput = document.getElementById("rueInput");
    const villeInput = document.getElementById("villeInput");
    const postInput = document.getElementById("postInput");

    if (!rueInput) return;

    // Création ou récupération du conteneur de suggestions
    let suggestionsContainer = document.querySelector(
        ".autocomplete-suggestions"
    );
    if (!suggestionsContainer) {
        suggestionsContainer = document.createElement("div");
        suggestionsContainer.className = "autocomplete-suggestions";
        suggestionsContainer.style.display = "none";
        rueInput.parentNode.appendChild(suggestionsContainer);
    }

    let timeout = null;

    rueInput.addEventListener("input", function () {
        const query = this.value.trim();
        // Pas de requête si moins de 3 caractères
        if (query.length < 3) {
            suggestionsContainer.style.display = "none";
            return;
        }

        clearTimeout(timeout);
        // Debounce de 300ms
        timeout = setTimeout(() => {
            fetch(
                `https://api-adresse.data.gouv.fr/search/?q=${encodeURIComponent(
                    query
                )}&limit=3`
            )
                .then((response) => response.json())
                .then((data) => {
                    suggestionsContainer.innerHTML = "";
                    if (data.features && data.features.length > 0) {
                        suggestionsContainer.style.display = "block";
                        data.features.forEach((feature) => {
                            const props = feature.properties;
                            const div = document.createElement("div");
                            div.className = "autocomplete-suggestion";
                            div.innerHTML = `<i class="bi bi-geo-alt-fill"></i> ${props.label}`;

                            // Remplissage des champs au clic
                            div.addEventListener("click", function () {
                                rueInput.value = props.name;

                                if (villeInput) {
                                    villeInput.value = props.city;
                                    // Feedback visuel
                                    villeInput.style.backgroundColor =
                                        "#e8f0fe";
                                    setTimeout(
                                        () =>
                                            (villeInput.style.backgroundColor =
                                                "#f9f9f9"),
                                        500
                                    );
                                }

                                if (postInput) {
                                    postInput.value = props.postcode;
                                    postInput.style.backgroundColor = "#e8f0fe";
                                    setTimeout(
                                        () =>
                                            (postInput.style.backgroundColor =
                                                "#f9f9f9"),
                                        500
                                    );
                                    postInput.classList.remove("is-invalid");
                                    const errDiv =
                                        document.getElementById("error-post");
                                    if (errDiv) errDiv.classList.add("d-none");
                                }

                                suggestionsContainer.style.display = "none";
                            });
                            suggestionsContainer.appendChild(div);
                        });
                    } else {
                        suggestionsContainer.style.display = "none";
                    }
                })
                .catch((err) => console.error("Erreur API", err));
        }, 300);
    });

    // Fermeture des suggestions si clic en dehors
    document.addEventListener("click", function (e) {
        if (e.target !== rueInput && e.target !== suggestionsContainer) {
            suggestionsContainer.style.display = "none";
        }
    });
}

/*
 * Vérifie la validité de l'email saisi avant de passer à l'étape suivante.
 * Effectue d'abord une validation de format standard HTML5.
 * Si le format est bon, envoie une requête asynchrone au serveur pour vérifier si l'email existe déjà en base de données (doublon).
 * Affiche les erreurs correspondantes ou passe à l'étape 2.
 */
async function verifierEmail() {
    const emailInput = document.getElementById("emailInput");
    const errorFormat = document.getElementById("error-email");
    const errorDoublon = document.getElementById("error-email-doublon");

    errorFormat.classList.add("d-none");
    errorDoublon.classList.add("d-none");
    emailInput.classList.remove("is-invalid");

    if (!emailInput.checkValidity()) {
        errorFormat.classList.remove("d-none");
        emailInput.classList.add("is-invalid");
        return;
    }

    try {
        const response = await fetch(
            "/sae-covoiturage/public/api/check-email?email=" +
                encodeURIComponent(emailInput.value)
        );
        const data = await response.json();
        if (data.exists) {
            errorDoublon.classList.remove("d-none");
            emailInput.classList.add("is-invalid");
        } else {
            changerEtape(2);
        }
    } catch (error) {
        // En cas d'erreur serveur, on laisse passer (fail-open) ou on gère l'erreur différemment
        changerEtape(2);
    }
}

/*
 * Valide le mot de passe et sa confirmation.
 * Applique des règles de complexité (longueur, caractères spéciaux, chiffres).
 * Si tout est conforme, passe à l'étape suivante, sinon affiche un message d'erreur.
 */
function verifierMDP() {
    const mdp = document.getElementById("mdpInput").value;
    const conf = document.getElementById("confMdpInput").value;

    if (mdp !== conf)
        return afficherErreur("Les mots de passe ne correspondent pas.");
    if (mdp.length < 8) return afficherErreur("8 caractères minimum.");
    if (
        !/[a-zA-Z]/.test(mdp) ||
        !/[0-9]/.test(mdp) ||
        !/[^a-zA-Z0-9]/.test(mdp)
    )
        return afficherErreur(
            "1 lettre, 1 chiffre, 1 caractère spécial requis."
        );

    document.getElementById("error-mdp").classList.add("d-none");
    changerEtape(3);
}

function afficherErreur(msg) {
    const err = document.getElementById("error-mdp");
    err.textContent = msg;
    err.classList.remove("d-none");
}

// Bascule l'affichage du mot de passe (texte clair <-> masqué)
function togglePassword(inputId, iconId) {
    const input = document.getElementById(inputId);
    const icon = document.getElementById(iconId);
    input.type = input.type === "password" ? "text" : "password";
    icon.classList.toggle("bi-eye");
    icon.classList.toggle("bi-eye-slash");
}

// Validations intermédiaires simples (champs non vides) pour avancer dans les étapes
function validerEtape3() {
    if (
        document.getElementById("nomInput").value.trim() &&
        document.getElementById("prenomInput").value.trim()
    )
        changerEtape(4);
}

function validerEtape4() {
    const dateInput = document.getElementById("dateInput");
    if (!dateInput.value) return alert("Date requise.");
    if (document.getElementById("telInput").value.length < 10)
        return alert("Numéro invalide.");
    changerEtape(5);
}

function validerEtape5() {
    if (
        !document.getElementById("rueInput").value.trim() ||
        !document.getElementById("villeInput").value.trim() ||
        !document.getElementById("postInput").value.trim()
    )
        return alert("Tout remplir.");
    changerEtape(6);
}

function choisirVoiture() {
    changerEtape(7);
}

/*
 * Soumission du formulaire pour un utilisateur SANS véhicule.
 * Désactive les champs liés à la voiture pour éviter qu'ils ne soient traités ou validés par le serveur,
 * définit un champ caché "voiture" à "non", puis soumet le formulaire.
 */
function soumettreSansVoiture() {
    document
        .querySelectorAll("#step-7 input, #step-7 select")
        .forEach((el) => (el.disabled = true));
    document.getElementById("voitureInput").value = "non";
    document.querySelector("form").submit();
}

/*
 * Soumission du formulaire pour un utilisateur AVEC véhicule.
 * Vérifie d'abord la validité de la plaque d'immatriculation via une Regex.
 * Si valide, définit "voiture" à "oui" et soumet.
 */
function soumettreAvecVoiture() {
    if (!validerImmatriculation()) return alert("Plaque invalide.");
    document.getElementById("voitureInput").value = "oui";
    document.querySelector("form").submit();
}

// Vérifie le format de la plaque d'immatriculation (Ancien FNI ou Nouveau SIV)
function validerImmatriculation() {
    const val = document.getElementById("immatInput").value.toUpperCase();
    return /^([A-Z]{2}[- ]?\d{3}[- ]?[A-Z]{2})|(\d{1,4}[- ]?[A-Z]{2,3}[- ]?\d{2})$/.test(
        val
    );
}

// Gestion des boutons +/- pour le nombre de places
function modifierPlaces(n) {
    const input = document.getElementById("nbPlacesInput");
    let val = parseInt(input.value) + n;
    if (val >= 1 && val <= 8) input.value = val;
}

document.addEventListener("DOMContentLoaded", function () {
    // Restriction de l'âge minimum (13 ans) sur le sélecteur de date
    const dateInput = document.getElementById("dateInput");
    if (dateInput) {
        const today = new Date();
        const year = today.getFullYear() - 13;
        const m = String(today.getMonth() + 1).padStart(2, "0");
        const d = String(today.getDate()).padStart(2, "0");
        dateInput.setAttribute("max", `${year}-${m}-${d}`);
    }

    setupAddressAutocomplete();
    changerEtape(1);

    // UX : Permettre de valider l'étape courante avec la touche "Entrée"
    document.addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
            event.preventDefault();
            const btn = document.querySelector(
                ".bloc-etape:not(.d-none) .btn-inscription"
            );
            if (btn) btn.click();
        }
    });
});
