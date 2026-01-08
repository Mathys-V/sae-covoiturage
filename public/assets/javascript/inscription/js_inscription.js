/* ==========================================
   1. GESTION DES ÉTAPES & BOUTON GLOBAL
   ========================================== */
let etapeActuelle = 1;

function changerEtape(numeroEtape) {
    etapeActuelle = numeroEtape;

    // 1. Hide all steps
    let toutesLesEtapes = document.querySelectorAll(".bloc-etape");
    toutesLesEtapes.forEach((div) => div.classList.add("d-none"));

    // 2. Show target step
    let etapeVisee = document.getElementById("step-" + numeroEtape);
    if (etapeVisee) etapeVisee.classList.remove("d-none");

    // 3. Manage Global Back Button
    const btnRetour = document.getElementById("btnRetourGlobal");
    if (btnRetour) {
        if (numeroEtape === 1 || numeroEtape === 8) {
            btnRetour.classList.add("d-none");
        } else {
            btnRetour.classList.remove("d-none");
        }
    }

    // 4. Manage Header/Footer Visibility
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

    // Reset Scroll
    const cardScrollable = document.querySelector(".card-scrollable");
    if (cardScrollable) cardScrollable.scrollTop = 0;
}

// Function called by the global back button
function retourArriere() {
    if (etapeActuelle > 1) {
        changerEtape(etapeActuelle - 1);
    }
}

/* ==========================================
   2. AUTOCOMPLÉTION ADRESSE (VERSION API GOUV)
   ========================================== */
function setupAddressAutocomplete() {
    const rueInput = document.getElementById("rueInput");
    const villeInput = document.getElementById("villeInput");
    const postInput = document.getElementById("postInput");

    if (!rueInput) return;

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
        if (query.length < 3) {
            suggestionsContainer.style.display = "none";
            return;
        }

        clearTimeout(timeout);
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
                            div.addEventListener("click", function () {
                                rueInput.value = props.name;
                                if (villeInput) {
                                    villeInput.value = props.city;
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

    document.addEventListener("click", function (e) {
        if (e.target !== rueInput && e.target !== suggestionsContainer) {
            suggestionsContainer.style.display = "none";
        }
    });
}

/* ==========================================
   3. VALIDATIONS
   ========================================== */
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
        changerEtape(2);
    }
}

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

function togglePassword(inputId, iconId) {
    const input = document.getElementById(inputId);
    const icon = document.getElementById(iconId);
    input.type = input.type === "password" ? "text" : "password";
    icon.classList.toggle("bi-eye");
    icon.classList.toggle("bi-eye-slash");
}

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

function soumettreSansVoiture() {
    document
        .querySelectorAll("#step-7 input, #step-7 select")
        .forEach((el) => (el.disabled = true));
    document.getElementById("voitureInput").value = "non";
    document.querySelector("form").submit();
}

function soumettreAvecVoiture() {
    if (!validerImmatriculation()) return alert("Plaque invalide.");
    document.getElementById("voitureInput").value = "oui";
    document.querySelector("form").submit();
}

function validerImmatriculation() {
    const val = document.getElementById("immatInput").value.toUpperCase();
    return /^([A-Z]{2}[- ]?\d{3}[- ]?[A-Z]{2})|(\d{1,4}[- ]?[A-Z]{2,3}[- ]?\d{2})$/.test(
        val
    );
}

function modifierPlaces(n) {
    const input = document.getElementById("nbPlacesInput");
    let val = parseInt(input.value) + n;
    if (val >= 1 && val <= 8) input.value = val;
}

// INIT
document.addEventListener("DOMContentLoaded", function () {
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
