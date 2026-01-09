const telInput = document.getElementById("user_tel");
const btnSave = document.getElementById("btnSave");
const errorMsg = document.getElementById("telError");

/*
 * Fonctions utilitaires pour la manipulation de chaînes de caractères.
 * 'cleanNumber' utilise une Expression Régulière (Regex) pour supprimer tout ce qui n'est pas un chiffre,
 * ce qui est crucial pour stocker une donnée propre en base de données.
 * 'formatNumber' réinjecte des espaces tous les deux caractères pour améliorer la lisibilité (UX) lors de la saisie.
 */
// Nettoie : garde que les chiffres
const cleanNumber = (val) => val.replace(/\D/g, ""); // \D = tout sauf des chiffres

// Formate : ajoute des espaces tous les 2 chiffres
const formatNumber = (val) => {
    let clean = cleanNumber(val);
    let formatted = "";
    for (let i = 0; i < clean.length; i++) {
        if (i > 0 && i % 2 === 0) formatted += " "; // Ajout d'espace pair
        formatted += clean[i];
    }
    return formatted;
};

/*
 * Logique de validation en temps réel.
 * Cette fonction vérifie si la donnée saisie correspond aux critères métiers (10 chiffres exacts pour un numéro français).
 * Elle gère l'état de l'interface : affichage du message d'erreur et désactivation du bouton de sauvegarde
 * tant que la saisie n'est pas valide.
 */
// Vérification
const checkVal = () => {
    const raw = cleanNumber(telInput.value);
    // On autorise vide (pour supprimer le numéro) OU 10 chiffres exacts
    const isValid = raw.length === 0 || raw.length === 10;

    if (!isValid && raw.length > 0) {
        errorMsg.style.display = "block"; // Affiche l'erreur
        btnSave.disabled = true; // Bloque le bouton
    } else {
        errorMsg.style.display = "none";
        btnSave.disabled = false;
    }
};

/*
 * Initialisation des écouteurs d'événements.
 * À chaque frappe (input), on formate visuellement la valeur et on relance la validation.
 * On charge également les préférences utilisateur simulées (SMS Marketing) depuis le LocalStorage
 * pour persister l'état de la case à cocher entre les rechargements de page.
 */
telInput.addEventListener("input", function () {
    this.value = formatNumber(this.value); // Application du masque de saisie
    checkVal();
});

// Chargement Option SMS (Persistance locale)
if (localStorage.getItem("simu_sms_marketing") === "true") {
    document.getElementById("simu_sms_marketing").checked = true;
}

/*
 * Fonction principale de sauvegarde (Orchestration).
 * Elle gère deux types de persistance :
 * 1. Locale (LocalStorage) pour les préférences marketing (simulation front-end).
 * 2. Distante (API) pour le numéro de téléphone réel.
 * Elle pilote aussi le feedback visuel (Texte "Enregistrement..." -> "Succès") pour rassurer l'utilisateur.
 */
function saveAll() {
    const rawTel = cleanNumber(telInput.value);
    const smsPref = document.getElementById("simu_sms_marketing").checked;

    // 1. Sauvegarde Préférence Fictive
    localStorage.setItem("simu_sms_marketing", smsPref);

    // 2. Sauvegarde Numéro Réel (Appel API asynchrone)
    btnSave.innerText = "Enregistrement..."; // Feedback immédiat

    fetch("/sae-covoiturage/public/profil/preferences/telephone/save", {
        method: "POST",
        headers: { "Content-Type": "application/json" }, // Indique au serveur qu'on envoie du JSON
        body: JSON.stringify({ telephone: rawTel }),
    })
        .then((res) => res.json()) // Parsing de la réponse
        .then((data) => {
            if (data.success) {
                // Gestion du succès visuel
                btnSave.innerText = "Tout est enregistré !";
                btnSave.style.background = "#00e676"; // Vert succès

                // Timer pour remettre le bouton à l'état initial
                setTimeout(() => {
                    btnSave.innerText = "Enregistrer";
                    btnSave.style.background = "#8C52FF";
                }, 2000);
            } else {
                // Gestion des erreurs métier (ex: format invalide côté serveur)
                alert("Erreur BDD : " + data.message);
                btnSave.innerText = "Réessayer";
            }
        });
}
