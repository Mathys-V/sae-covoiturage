document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.faq-question').forEach(item => {
        item.addEventListener('click', event => {
            const parent = item.parentElement;
            
            // Ferme automatiquement les autres onglets ouverts (Effet Accordéon)
            document.querySelectorAll('.faq-item').forEach(child => {
                if (child !== parent) {
                    child.classList.remove('active');
                }
            });

            // Bascule l'état de l'élément cliqué
            parent.classList.toggle('active');
        });
    });
});