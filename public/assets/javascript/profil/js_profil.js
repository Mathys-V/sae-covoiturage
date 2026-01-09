/*
 * Gestion de la navigation par onglets dans le profil.
 * Cette fonction bascule l'affichage entre la section "Compte" et "Paramètres".
 * Elle manipule les classes CSS (.tab-active) pour l'aspect visuel et le style (display: none/block)
 * pour afficher le contenu correspondant.
 */
function switchTab(tabName) {
    const tabCompte = document.getElementById("tab-compte");
    const tabParams = document.getElementById("tab-parametres");
    const sectCompte = document.getElementById("section-compte");
    const sectParams = document.getElementById("section-parametres");
    const headerProfil = document.querySelector(".profile-header");

    if (tabName === "compte") {
        // Activation de l'onglet Compte
        tabCompte.className = "tab tab-active";
        tabParams.className = "tab tab-inactive";
        sectCompte.style.display = "block";
        sectParams.style.display = "none";
        if (headerProfil) headerProfil.style.display = "flex";
    } else {
        // Activation de l'onglet Paramètres
        tabCompte.className = "tab tab-inactive";
        tabParams.className = "tab tab-active";
        sectCompte.style.display = "none";
        sectParams.style.display = "block";
        if (headerProfil) headerProfil.style.display = "none"; // On masque le header pour épuré la vue paramètres
    }
}

/*
 * Système de bascule "Voir / Modifier".
 * Permet d'afficher un formulaire d'édition à la place du texte statique pour une carte donnée.
 * Utile pour les modifications rapides sans changer de page.
 */
function toggleEdit(id) {
    let card = document.getElementById("card-" + id);
    let view = card.querySelector(".view-content");
    let edit = card.querySelector(".edit-content");

    // Si l'éditeur est visible, on le cache, sinon on l'affiche
    if (edit.style.display === "block") {
        edit.style.display = "none";
        view.style.display = "block";
    } else {
        edit.style.display = "block";
        view.style.display = "none";
    }
}

/*
 * Gestion du processus de suppression de compte en 2 étapes.
 * UX : On demande une confirmation supplémentaire (Step 2) pour éviter les erreurs.
 * On utilise un écouteur sur la fermeture de la modale Bootstrap pour réinitialiser
 * l'état à l'étape 1 si l'utilisateur annule.
 */
// GESTION SUPPRESSION COMPTE
function showStep2() {
    document.getElementById("step-1-content").classList.add("d-none");
    document.getElementById("step-2-content").classList.remove("d-none");
}

function showStep1() {
    document.getElementById("step-2-content").classList.add("d-none");
    document.getElementById("step-1-content").classList.remove("d-none");
}

var modalSuppr = document.getElementById("modalSuppression");
if (modalSuppr) {
    // Event Bootstrap : déclenché quand la modale est complètement fermée
    modalSuppr.addEventListener("hidden.bs.modal", function () {
        showStep1();
    });
}

/*
 * Fonctionnalité "Voir plus / Voir moins" pour l'historique des trajets.
 * Elle agit sur une liste d'éléments possédant la classe 'history-hidden'.
 * Le texte du bouton est mis à jour dynamiquement selon l'état.
 */
// GESTION VOIR PLUS
function toggleHistory() {
    const hiddenItems = document.querySelectorAll(".history-hidden");
    const btn = document.getElementById("btn-see-more");

    if (!hiddenItems.length) return; // Sécurité si la liste est vide

    // On vérifie l'état du premier élément pour savoir si on doit ouvrir ou fermer
    const isHidden = hiddenItems[0].classList.contains("d-none");

    hiddenItems.forEach((item) => {
        isHidden
            ? item.classList.remove("d-none")
            : item.classList.add("d-none");
    });

    btn.innerText = isHidden ? "Voir moins" : "Voir plus";
}

/*
 * Bascule spécifique pour l'édition de l'identité (Nom/Prénom).
 * Utilise les classes utilitaires Bootstrap (d-flex/d-none) pour gérer l'affichage.
 */
// GESTION EDIT NOM
function toggleIdentityEdit() {
    const display = document.getElementById("identity-display");
    const edit = document.getElementById("identity-edit");

    if (display.classList.contains("d-flex")) {
        display.classList.remove("d-flex");
        display.classList.add("d-none");
        edit.classList.remove("d-none");
        edit.classList.add("d-flex");
    } else {
        display.classList.add("d-flex");
        display.classList.remove("d-none");
        edit.classList.add("d-none");
        edit.classList.remove("d-flex");
    }
}

document.addEventListener("DOMContentLoaded", function () {
    /*
     * Gestionnaire des signalements via une modale Bootstrap.
     * 1. On intercepte le clic sur les boutons "Signaler".
     * 2. On injecte les données (ID trajet, ID utilisateur) dans les champs cachés du formulaire via les attributs 'dataset'.
     * 3. On soumet le formulaire via Fetch (AJAX) pour ne pas recharger la page.
     */
    // GESTION SIGNALEMENT
    const btns = document.querySelectorAll(".btn-report");
    const modalEl = document.getElementById("modalSignalement");

    // Vérification que les éléments existent pour éviter erreur console si pas connectés ou pas de signalements
    if (modalEl && btns.length > 0) {
        const modal = new bootstrap.Modal(modalEl); // Instance JS de la modale
        const form = document.getElementById("formSignalement");

        btns.forEach((btn) => {
            btn.addEventListener("click", function () {
                // Récupération des données via les attributs data-* du HTML (ex: data-trajet="12")
                document.getElementById("trajetSignalement").value =
                    this.dataset.trajet;
                document.getElementById("userSignalement").value =
                    this.dataset.concerne;
                document.getElementById("nomUserSignalement").innerText =
                    this.dataset.nom;
                modal.show();
            });
        });

        if (form) {
            form.addEventListener("submit", function (e) {
                e.preventDefault(); // Empêche le rechargement standard

                // Récupération des valeurs
                const tid = document.getElementById("trajetSignalement").value;
                const uid = document.getElementById("userSignalement").value;
                const motif = document.getElementById("motifSignalement").value;
                const desc =
                    document.getElementById("detailsSignalement").value;

                // Envoi asynchrone au backend PHP
                fetch("/sae-covoiturage/public/api/signalement/nouveau", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({
                        id_trajet: tid,
                        id_signale: uid,
                        motif: motif,
                        description: desc,
                    }),
                })
                    .then((r) => r.json())
                    .then((d) => {
                        modal.hide(); // Fermeture modale
                        if (d.success) {
                            alert("Signalement envoyé !");
                            form.reset();
                        } else {
                            alert("Erreur : " + d.msg);
                        }
                    });
            });
        }
    }

    /*
     * Validation et formatage en temps réel de la plaque d'immatriculation.
     * 1. Vérifie si le format correspond au SIV (AA-123-AA) ou FNI (1234 AB 56) via Regex.
     * 2. Ajoute une animation "Shake" et une bordure rouge si le format est invalide lors de l'envoi.
     * 3. Formate automatiquement la saisie en ajoutant les tirets pour le format SIV.
     */
    // --- VALIDATION DU VÉHICULE (SANS RECHARGEMENT) ---
    const formVehicule = document.getElementById("form-vehicule");
    const inputImmat = document.getElementById("immat-input");
    const errorMsg = document.getElementById("immat-error");

    if (formVehicule && inputImmat) {
        // Regex formats: SIV (Nouveau) ou FNI (Ancien)
        const regexSIV = /^[A-Z]{2}[-\s]?\d{3}[-\s]?[A-Z]{2}$/;
        const regexFNI = /^\d{1,4}[-\s]?[A-Z]{2,3}[-\s]?[A-Z]{2}$/;

        formVehicule.addEventListener("submit", function (e) {
            const val = inputImmat.value.trim();

            // Si le format est invalide, on coupe tout de suite
            if (!regexSIV.test(val) && !regexFNI.test(val)) {
                e.preventDefault(); // STOP : Pas d'envoi au serveur

                inputImmat.classList.add("is-invalid"); // Style Bootstrap
                inputImmat.style.border = "2px solid #dc3545"; // Force bordure rouge
                if (errorMsg) errorMsg.style.display = "block";

                // Petit effet visuel "Shake" (Animation CSS via Web Animations API)
                inputImmat.animate(
                    [
                        { transform: "translateX(0px)" },
                        { transform: "translateX(10px)" },
                        { transform: "translateX(-10px)" },
                        { transform: "translateX(0px)" },
                    ],
                    { duration: 300 }
                );
            } else {
                // Tout est bon, on laisse faire le serveur (submit naturel)
                if (errorMsg) errorMsg.style.display = "none";
                inputImmat.style.border = "1px solid #ccc";
            }
        });

        // UX : Nettoyage erreur quand l'utilisateur recommence à taper
        inputImmat.addEventListener("input", function () {
            if (errorMsg && errorMsg.style.display === "block") {
                errorMsg.style.display = "none";
                inputImmat.style.border = "1px solid #ccc";
            }
        });

        // UX : Formatage automatique SIV (ajoute les tirets intelligemment)
        inputImmat.addEventListener("keyup", function (e) {
            // Ne pas formater si on efface (Backspace) pour ne pas coincer l'utilisateur
            if (e.key === "Backspace" || e.key === "Delete") return;

            // On ne garde que les lettres et chiffres
            let v = this.value.toUpperCase().replace(/[^A-Z0-9]/g, "");

            // Détection début SIV (commence par 2 lettres)
            if (v.length > 2 && /^[A-Z]{2}/.test(v)) {
                if (v.length <= 5) {
                    this.value = v.slice(0, 2) + "-" + v.slice(2);
                } else {
                    this.value =
                        v.slice(0, 2) +
                        "-" +
                        v.slice(2, 5) +
                        "-" +
                        v.slice(5, 7);
                }
            }
        });
    }
});
