document.addEventListener("DOMContentLoaded", function () {
    // --- Initialisation des éléments du DOM ---
    // On récupère tous les boutons "Signaler" présents sur la page (un par réservation)
    const btnSignalerList = document.querySelectorAll(".btn-report");

    // On cible la fenêtre modale et le formulaire
    const modalEl = document.getElementById("modalSignalement");

    // Initialisation de l'instance Bootstrap pour pouvoir la manipuler via JS (show/hide)
    // Note: Cela nécessite que Bootstrap JS soit bien chargé sur la page
    const modal = new bootstrap.Modal(modalEl);
    const formSignalement = document.getElementById("formSignalement");

    // --- Gestion de l'ouverture de la modale ---
    // On ajoute un écouteur d'événement sur CHAQUE bouton "Signaler"
    btnSignalerList.forEach((btn) => {
        btn.addEventListener("click", function () {
            // 1. On récupère l'ID du trajet stocké dans l'attribut 'data-trajet' du bouton cliqué
            const idTrajet = btn.dataset.trajet;

            // 2. On injecte cet ID dans le champ caché du formulaire
            // Cela permet de savoir quel trajet est concerné lors de l'envoi
            document.getElementById("trajetSignalement").value = idTrajet;

            // 3. On affiche la modale à l'utilisateur
            modal.show();
        });
    });

    // --- Gestion de la soumission du formulaire (AJAX) ---
    formSignalement.addEventListener("submit", function (e) {
        // Empêche le rechargement classique de la page
        e.preventDefault();

        // Récupération des valeurs du formulaire
        const trajetId = document.getElementById("trajetSignalement").value;
        const userId = document.getElementById("userSignalement").value; // ID de la personne signalée ou du signalant (selon ton HTML)
        const motif = document.getElementById("motifSignalement").value;
        const details = document.getElementById("detailsSignalement").value;

        // Validation simple côté client
        if (!userId || !motif) {
            alert("Veuillez remplir tous les champs obligatoires.");
            return;
        }

        // Envoi des données au serveur via fetch (API)
        fetch("/sae-covoiturage/public/api/signalement/nouveau", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                id_trajet: trajetId,
                id_signale: userId,
                motif: motif,
                description: details,
            }),
        })
            .then((res) => res.json()) // On attend une réponse au format JSON
            .then((data) => {
                // Une fois la réponse reçue, on ferme la modale
                modal.hide();

                // Gestion de la réponse (Succès ou Erreur)
                if (data.success) {
                    alert("Signalement envoyé. Merci !");
                    formSignalement.reset(); // On vide le formulaire pour la prochaine fois
                } else {
                    // Affiche le message d'erreur renvoyé par l'API ou un message par défaut
                    alert(
                        "Erreur : " +
                            (data.msg || "Impossible d'envoyer le signalement.")
                    );
                }
            })
            .catch((error) => {
                console.error("Erreur réseau ou JS :", error);
                alert("Une erreur technique est survenue.");
            });
    });
});
