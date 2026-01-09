// Variable globale destinée à stocker l'instance de la modale Bootstrap.
// Elle est déclarée en dehors du scope pour être accessible par toutes les fonctions du script.
let modalBan;

/*
 * Initialisation au chargement du DOM.
 * On récupère l'élément HTML de la modale et on crée une nouvelle instance Bootstrap.
 * Cela permettra de la manipuler programmatiquement (méthodes .show() et .hide()) plus tard.
 */
document.addEventListener("DOMContentLoaded", () => {
    modalBan = new bootstrap.Modal(document.getElementById("modalBan"));
});

/*
 * Gère l'action "Classer sans suite".
 * Cette fonction sert de garde-fou avec une confirmation native. Si l'administrateur valide,
 * on déclenche l'appel réseau avec l'action 'vu' pour archiver le signalement sans sanction.
 */
function classer(id) {
    if (
        !confirm("Êtes-vous sûr de vouloir classer ce signalement sans suite ?")
    )
        return;
    envoyerAction({ id: id, action: "vu" });
}

/*
 * Prépare l'interface avant d'afficher la fenêtre de bannissement.
 * On injecte dynamiquement l'ID du signalement et le nom de l'utilisateur concerné dans le DOM de la modale.
 * C'est nécessaire pour que la fonction confirmerBan() sache ensuite quelle entité cibler.
 */
function ouvrirModalBan(id, nom) {
    document.getElementById("modalSigId").value = id;
    document.getElementById("modalUserName").innerText = nom;
    modalBan.show();
}

/*
 * Exécute la sanction après validation dans la modale.
 * La fonction récupère les données contextuelles (ID stocké dans le champ caché et durée choisie via les radio buttons).
 * Elle construit ensuite le payload pour l'envoyer au contrôleur via la fonction générique d'envoi.
 */
function confirmerBan() {
    const id = document.getElementById("modalSigId").value;
    // Sélectionne l'input radio coché pour récupérer sa valeur (24h, 168h, etc.)
    const duree = document.querySelector(
        'input[name="banDuration"]:checked'
    ).value;
    envoyerAction({ id: id, action: "ban", duree: duree });
}

/*
 * Permet de lever une sanction existante.
 * C'est une action critique qui nécessite une confirmation explicite avant d'envoyer
 * l'instruction de débannissement ('unban') au serveur.
 */
function debannir(idUser) {
    if (!confirm("Réactiver ce compte immédiatement ?")) return;
    envoyerAction({ id_user: idUser, action: "unban" });
}

/*
 * Fonction utilitaire centralisant tous les appels AJAX vers le back-office.
 * Elle utilise l'API Fetch pour envoyer des requêtes POST asynchrones avec un corps en JSON.
 * Elle gère aussi le retour du serveur : rechargement de la page en cas de succès (HTTP 200 + success: true)
 * ou affichage d'une alerte en cas d'erreur logique renvoyée par le PHP.
 */
function envoyerAction(data) {
    fetch("/sae-covoiturage/public/admin/signalement/traiter", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
    })
        .then((res) => res.json())
        .then((resp) => {
            if (resp.success) location.reload();
            else alert("Erreur : " + resp.msg);
        });
}
