document.addEventListener("DOMContentLoaded", () => {
    // --- Initialisation de la Modale Bootstrap ---
    // On récupère l'élément HTML de la modale et on crée une instance Bootstrap
    // pour pouvoir la contrôler via JavaScript (méthodes .show() et .hide())
    const modalEl = document.getElementById("modalSignalement");
    const modal = new bootstrap.Modal(modalEl);

    // --- Gestion de l'ouverture de la modale ---
    // On cible le bouton qui sert à déclencher le signalement
    const btnOpen = document.querySelector(
        '[data-bs-target="#modalSignalement"]'
    );

    if (btnOpen) {
        btnOpen.addEventListener("click", () => {
            modal.show();
        });
    }

    // --- Gestion de l'envoi du signalement ---
    const btnEnvoyer = document.getElementById("btnEnvoyerSignalement");

    if (btnEnvoyer) {
        btnEnvoyer.addEventListener("click", () => {
            // 1. Récupération des valeurs des champs du formulaire
            // (On utilise des noms de variables clairs au lieu de t, c, m, d)
            const trajetId = document.getElementById("trajetSignalement").value;
            const conducteurId = document.getElementById(
                "conducteurSignalement"
            ).value;
            const motif = document.getElementById("motifSignalement").value;
            const description =
                document.getElementById("detailsSignalement").value;

            // 2. Validation basique côté client
            // On vérifie que le motif et la description sont remplis
            if (!motif || !description) {
                alert("Veuillez remplir tous les champs.");
                return; // On arrête l'exécution ici si c'est vide
            }

            // 3. Appel API (Fetch) pour enregistrer le signalement
            fetch("/sae-covoiturage/public/api/signalement/nouveau", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                // Conversion de l'objet JS en chaîne JSON pour l'envoi
                body: JSON.stringify({
                    id_trajet: trajetId,
                    id_signale: conducteurId,
                    motif: motif,
                    description: description,
                }),
            })
                .then((response) => response.json()) // Transformation de la réponse en JSON
                .then((data) => {
                    // Une fois la réponse reçue :
                    modal.hide(); // On ferme la modale visuellement

                    // On informe l'utilisateur du résultat
                    if (data.success) {
                        alert("Signalement envoyé avec succès.");
                    } else {
                        // Affiche le message d'erreur du serveur ou un message par défaut
                        alert(
                            data.msg ||
                                "Une erreur est survenue lors de l'envoi."
                        );
                    }
                })
                .catch((error) => {
                    console.error("Erreur réseau :", error);
                    alert("Impossible de contacter le serveur.");
                });
        });
    }
});
