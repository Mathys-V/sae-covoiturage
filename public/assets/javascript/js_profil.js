function switchTab(tabName) {
    const tabCompte = document.getElementById('tab-compte');
    const tabParams = document.getElementById('tab-parametres');
    const sectCompte = document.getElementById('section-compte');
    const sectParams = document.getElementById('section-parametres');
    const headerProfil = document.querySelector('.profile-header');

    if (tabName === 'compte') {
        tabCompte.className = 'tab tab-active'; tabParams.className = 'tab tab-inactive';
        sectCompte.style.display = 'block'; sectParams.style.display = 'none';
        if(headerProfil) headerProfil.style.display = 'flex';
    } else {
        tabCompte.className = 'tab tab-inactive'; tabParams.className = 'tab tab-active';
        sectCompte.style.display = 'none'; sectParams.style.display = 'block';
        if(headerProfil) headerProfil.style.display = 'none';
    }
}

function toggleEdit(id) {
    let card = document.getElementById('card-' + id);
    let view = card.querySelector('.view-content'); let edit = card.querySelector('.edit-content');
    if (edit.style.display === 'block') { edit.style.display = 'none'; view.style.display = 'block'; }
    else { edit.style.display = 'block'; view.style.display = 'none'; }
}