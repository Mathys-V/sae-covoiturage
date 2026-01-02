let modalBan;
document.addEventListener('DOMContentLoaded', () => {
    modalBan = new bootstrap.Modal(document.getElementById('modalBan'));
});

function classer(id) {
    if(!confirm("Êtes-vous sûr de vouloir classer ce signalement sans suite ?")) return;
    envoyerAction({ id: id, action: 'vu' });
}

function ouvrirModalBan(id, nom) {
    document.getElementById('modalSigId').value = id;
    document.getElementById('modalUserName').innerText = nom;
    modalBan.show();
}

function confirmerBan() {
    const id = document.getElementById('modalSigId').value;
    const duree = document.querySelector('input[name="banDuration"]:checked').value;
    envoyerAction({ id: id, action: 'ban', duree: duree });
}

function debannir(idUser) {
    if(!confirm("Réactiver ce compte immédiatement ?")) return;
    envoyerAction({ id_user: idUser, action: 'unban' });
}

function envoyerAction(data) {
    fetch('/sae-covoiturage/public/admin/signalement/traiter', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    })
    .then(res => res.json())
    .then(resp => {
        if(resp.success) location.reload();
        else alert("Erreur : " + resp.msg);
    });
}