document.addEventListener('DOMContentLoaded', function() {
    const btnSignalerList = document.querySelectorAll('.btn-report');
    const modalEl = document.getElementById('modalSignalement');
    const modal = new bootstrap.Modal(modalEl);
    const formSignalement = document.getElementById('formSignalement');

    btnSignalerList.forEach(btn => {
        btn.addEventListener('click', function() {
            document.getElementById('trajetSignalement').value = btn.dataset.trajet;
            modal.show();
        });
    });

    formSignalement.addEventListener('submit', function(e) {
        e.preventDefault();
        const trajetId = document.getElementById('trajetSignalement').value;
        const userId = document.getElementById('userSignalement').value;
        const motif = document.getElementById('motifSignalement').value;
        const details = document.getElementById('detailsSignalement').value;

        if(!userId || !motif) {
            alert("Veuillez remplir tous les champs obligatoires.");
            return;
        }

        fetch('/sae-covoiturage/public/api/signalement/nouveau', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                id_trajet: trajetId,
                id_signale: userId,
                motif: motif,
                description: details
            })
        })
        .then(res => res.json())
        .then(data => {
            modal.hide();
            if(data.success) {
                alert("Signalement envoyé. Merci !");
                formSignalement.reset();
            } else {
                alert("Erreur : " + (data.msg || "Impossible d'envoyer"));
            }
        });
    });
});