document.addEventListener('DOMContentLoaded', () => {
    const keys = ['mail_newsletter', 'mail_recap', 'mail_partenaires'];
    
    // Load
    keys.forEach(k => { if(localStorage.getItem(k) === 'true') document.getElementById(k).checked = true; });

    // Save
    document.getElementById('emailForm').addEventListener('submit', (e) => {
        e.preventDefault();
        keys.forEach(k => localStorage.setItem(k, document.getElementById(k).checked));
        
        const btn = document.querySelector('.btn-save');
        btn.innerText = "Préférences mises à jour !";
        btn.style.background = "#00e676";
        setTimeout(() => { btn.innerText = "Enregistrer"; btn.style.background = "#8C52FF"; }, 2000);
    });
});