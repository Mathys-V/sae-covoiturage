document.addEventListener('DOMContentLoaded', () => {
    // Chargement (Simulation LocalStorage)
    ['push_trajet', 'push_messages', 'push_promo'].forEach(id => {
        if(localStorage.getItem(id) === 'true') document.getElementById(id).checked = true;
    });

    // Sauvegarde avec Feedback visuel
    document.getElementById('pushForm').addEventListener('submit', (e) => {
        e.preventDefault();
        
        ['push_trajet', 'push_messages', 'push_promo'].forEach(id => {
            localStorage.setItem(id, document.getElementById(id).checked);
        });

        // Feedback simple et natif (plus propre qu'une modale lourde pour ça)
        const btn = document.querySelector('.btn-save');
        const originalText = btn.innerText;
        btn.innerText = "Sauvegardé !";
        btn.style.background = "#00e676"; // Vert succès
        
        setTimeout(() => {
            btn.innerText = originalText;
            btn.style.background = "#8C52FF";
        }, 2000);
    });
});