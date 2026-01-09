/**
 * Fonction globale appelée directement depuis le HTML (attribut onclick)
 * Elle permet d'ouvrir la modale et de pré-remplir les informations (ID Trajet, ID Passager)
 * avant que l'utilisateur ne saisisse son motif.
 */
function ouvrirSignalement(idTrajet, idPassager, nomPassager) {
    // 1. Injection des données dans les champs cachés (<input type="hidden">)
    document.getElementById("sig-id-trajet").value = idTrajet;
    document.getElementById("sig-id-passager").value = idPassager;

    // 2. Mise à jour visuelle : on affiche le nom de la personne concernée dans le titre ou le texte
    document.getElementById("modal-passager-nom").textContent = nomPassager;

    // 3. Initialisation et affichage de la modale Bootstrap
    const myModal = new bootstrap.Modal(
        document.getElementById("signalementModal")
    );
    myModal.show();
}

document.addEventListener("DOMContentLoaded", function () {
    const formSig = document.getElementById("form-signalement");

    // On vérifie que le formulaire existe sur la page avant d'ajouter l'écouteur
    if (formSig) {
        formSig.addEventListener("submit", async function (e) {
            // Empêche le rechargement de la page
            e.preventDefault();

            // --- Gestion de l'interface utilisateur (UX) ---
            // On désactive le bouton pour éviter les doubles clics pendant l'envoi
            const btn = this.querySelector('button[type="submit"]');
            const originalText = btn.textContent;
            btn.disabled = true;
            btn.textContent = "Envoi...";

            // --- Préparation des données ---
            const data = {
                id_trajet: document.getElementById("sig-id-trajet").value,
                id_signale: document.getElementById("sig-id-passager").value,
                motif: document.getElementById("sig-motif").value,
                description: document.getElementById("sig-desc").value,
            };

            try {
                // --- Appel API (Asynchrone) ---
                const response = await fetch(
                    "/sae-covoiturage/public/api/signalement/nouveau",
                    {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify(data),
                    }
                );

                // Attente de la conversion de la réponse en JSON
                const result = await response.json();

                // --- Gestion de la réponse ---
                if (result.success) {
                    alert("Signalement enregistré avec succès.");

                    // Récupération de l'instance de la modale pour la fermer proprement
                    const modalEl = document.getElementById("signalementModal");
                    const modalInstance = bootstrap.Modal.getInstance(modalEl);
                    modalInstance.hide();

                    // Remise à zéro du formulaire
                    formSig.reset();
                } else {
                    alert("Erreur : " + result.msg);
                }
            } catch (error) {
                // Gestion des erreurs réseau ou serveur
                console.error(error);
                alert("Erreur technique lors du signalement.");
            } finally {
                // --- Nettoyage (s'exécute toujours, succès ou échec) ---
                // On réactive le bouton pour permettre une nouvelle action
                btn.disabled = false;
                btn.textContent = originalText;
            }
        });
    }
});
