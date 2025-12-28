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