document.addEventListener('DOMContentLoaded', () => {
    const modal = new bootstrap.Modal(document.getElementById('modalSignalement'));
    document.querySelector('[data-bs-target="#modalSignalement"]').addEventListener('click', () => { modal.show(); });
    document.getElementById('btnEnvoyerSignalement').addEventListener('click', () => {
        const t = document.getElementById('trajetSignalement').value;
        const c = document.getElementById('conducteurSignalement').value;
        const m = document.getElementById('motifSignalement').value;
        const d = document.getElementById('detailsSignalement').value;
        if(!m || !d){ alert("Veuillez remplir tous les champs."); return; }
        fetch('/sae-covoiturage/public/api/signalement/nouveau', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ id_trajet: t, id_signale: c, motif: m, description: d })
        }).then(r => r.json()).then(data => {
            modal.hide();
            if(data.success){ alert("Signalement envoyé."); } else { alert(data.msg || "Erreur"); }
        });
    });
});