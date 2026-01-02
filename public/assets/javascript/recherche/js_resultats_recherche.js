/* * js_resultat_recherche.js
 * Gestion des interactions sur la liste des résultats.
 */

document.addEventListener('DOMContentLoaded', function() {
    console.log("JS Chargé"); // Pour vérifier que le fichier est bien lu

    // Exemple : Animation d'apparition progressive des cartes
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
            const button = event.relatedTarget; // Le bouton cliqué (drapeau)
            
            // Sécurité si button est null
            if (!button) return;

            const idTrajet = button.getAttribute('data-id-trajet');
            const idConducteur = button.getAttribute('data-id-conducteur');
            
            console.log("Ouverture modal pour Trajet:", idTrajet, "Conducteur:", idConducteur);

            // On remplit les inputs cachés
            const inputTrajet = document.getElementById('signalement_id_trajet');
            const inputConducteur = document.getElementById('signalement_id_conducteur');

            if(inputTrajet) inputTrajet.value = idTrajet;
            if(inputConducteur) inputConducteur.value = idConducteur;
        });
    }

    // 2. NOUVELLE MÉTHODE : Délégation d'événement (Plus robuste)
    // On écoute les clics sur tout le document
    document.addEventListener('click', function(e) {
        
        // On vérifie si l'élément cliqué a l'ID "btnConfirmSignalement"
        if (e.target && e.target.id === 'btnConfirmSignalement') {
            e.preventDefault();
            console.log("Bouton cliqué !"); // Vérif console

            const btnConfirm = e.target;

            // Récupération des données
            const idTrajet = document.getElementById('signalement_id_trajet').value;
            const idSignale = document.getElementById('signalement_id_conducteur').value;
            const motifEl = document.getElementById('signalement_motif');
            const descEl = document.getElementById('signalement_details');

            const motif = motifEl ? motifEl.value : '';
            const description = descEl ? descEl.value : '';

            // Vérification basique
            if (!motif) {
                alert("Veuillez choisir un motif.");
                return;
            }

            // Désactive le bouton
            btnConfirm.disabled = true;
            const originalText = btnConfirm.textContent;
            btnConfirm.textContent = "Envoi...";

            const payload = {
                id_trajet: idTrajet,
                id_signale: idSignale,
                motif: motif,
                description: description
            };

            console.log("Envoi payload:", payload);

            fetch('/sae-covoiturage/public/api/signalement/nouveau', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            })
            .then(response => response.json())
            .then(data => {
                // Réactive le bouton
                btnConfirm.disabled = false;
                btnConfirm.textContent = originalText;

                if (data.success) {
                    alert("Signalement envoyé avec succès !");
                    
                    // Fermer la modale via Bootstrap
                    const modalInstance = bootstrap.Modal.getInstance(modalSignalement);
                    if(modalInstance) modalInstance.hide();
                    
                    // Vider le formulaire
                    if(formSignalement) formSignalement.reset();
                } else {
                    alert("Erreur serveur : " + (data.msg || "Inconnue"));
                }
            })
            .catch(error => {
                console.error('Erreur Fetch:', error);
                alert("Une erreur technique est survenue.");
                btnConfirm.disabled = false;
                btnConfirm.textContent = originalText;
            });
        }
    });
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