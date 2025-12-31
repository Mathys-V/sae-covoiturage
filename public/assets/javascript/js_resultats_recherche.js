/* * js_resultat_recherche.js
 * Gestion des interactions sur la liste des résultats.
 */

document.addEventListener('DOMContentLoaded', function() {
    // Exemple : Animation d'apparition progressive des cartes (Optionnel)
    const cards = document.querySelectorAll('.card-result');
    cards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.animation = `fadeIn 0.5s ease forwards ${index * 0.1}s`;
    });

    // --- LOGIQUE DU SIGNALEMENT ---
    const modalSignalement = document.getElementById('modalSignalement');
    const formSignalement = document.getElementById('formSignalementRecherche');
    
    // 1. Quand on ouvre la modale, on remplit les IDs cachés
    if (modalSignalement) {
        modalSignalement.addEventListener('show.bs.modal', function (event) {
            const button = event.relatedTarget; // Le bouton cliqué
            
            const idTrajet = button.getAttribute('data-id-trajet');
            const idConducteur = button.getAttribute('data-id-conducteur');
            
            // On remplit les inputs cachés
            document.getElementById('signalement_id_trajet').value = idTrajet;
            document.getElementById('signalement_id_conducteur').value = idConducteur;
        });
    }

    // 2. Quand on soumet le formulaire
    if (formSignalement) {
        formSignalement.addEventListener('submit', function(e) {
            e.preventDefault(); // Empêche le rechargement de page (Stop l'erreur 404)

            // Récupération des données
            const idTrajet = document.getElementById('signalement_id_trajet').value;
            const idSignale = document.getElementById('signalement_id_conducteur').value;
            const motif = document.getElementById('signalement_motif').value;
            const description = document.getElementById('signalement_details').value;

            // Préparation des données pour votre API PHP existante
            const payload = {
                id_trajet: idTrajet,
                id_signale: idSignale, // L'API attend 'id_signale'
                motif: motif,
                description: description
            };

            // Envoi vers votre API existante
            fetch('/sae-covoiturage/public/api/signalement/nouveau', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            })
            .then(response => response.json()) // On lit la réponse JSON de Flight::json()
            .then(data => {
                if (data.success) {
                    alert("Signalement envoyé avec succès !");
                    // Fermer la modale
                    const modalInstance = bootstrap.Modal.getInstance(modalSignalement);
                    modalInstance.hide();
                    formSignalement.reset(); // Vider le formulaire
                } else {
                    alert("Erreur : " + data.msg);
                }
            })
            .catch(error => {
                console.error('Erreur:', error);
                alert("Une erreur technique est survenue.");
            });
        });
    }
});

// Ajoutons la keyframe pour l'animation JS ci-dessus
const styleSheet = document.createElement("style");
styleSheet.innerText = `
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
`;
document.head.appendChild(styleSheet);

    