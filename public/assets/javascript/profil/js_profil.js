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

// GESTION SUPPRESSION COMPTE
function showStep2() { document.getElementById('step-1-content').classList.add('d-none'); document.getElementById('step-2-content').classList.remove('d-none'); }
function showStep1() { document.getElementById('step-2-content').classList.add('d-none'); document.getElementById('step-1-content').classList.remove('d-none'); }
var modalSuppr = document.getElementById('modalSuppression');
if (modalSuppr) { modalSuppr.addEventListener('hidden.bs.modal', function() { showStep1(); }); }

// GESTION VOIR PLUS
function toggleHistory() {
    const hiddenItems = document.querySelectorAll('.history-hidden');
    const btn = document.getElementById('btn-see-more');
    if (!hiddenItems.length) return;
    const isHidden = hiddenItems[0].classList.contains('d-none');
    hiddenItems.forEach(item => { isHidden ? item.classList.remove('d-none') : item.classList.add('d-none'); });
    btn.innerText = isHidden ? "Voir moins" : "Voir plus";
}

// GESTION EDIT NOM
function toggleIdentityEdit() {
    const display = document.getElementById('identity-display');
    const edit = document.getElementById('identity-edit');
    if (display.classList.contains('d-flex')) {
        display.classList.remove('d-flex'); display.classList.add('d-none');
        edit.classList.remove('d-none'); edit.classList.add('d-flex');
    } else {
        display.classList.add('d-flex'); display.classList.remove('d-none');
        edit.classList.add('d-none'); edit.classList.remove('d-flex');
    }
}

// GESTION SIGNALEMENT
document.addEventListener('DOMContentLoaded', function() {
    const btns = document.querySelectorAll('.btn-report');
    const modalEl = document.getElementById('modalSignalement');
    
    // Vérification que les éléments existent pour éviter erreur console si pas connectés ou pas de signalements
    if(modalEl && btns.length > 0) {
        const modal = new bootstrap.Modal(modalEl);
        const form = document.getElementById('formSignalement');

        btns.forEach(btn => {
            btn.addEventListener('click', function() {
                document.getElementById('trajetSignalement').value = this.dataset.trajet;
                document.getElementById('userSignalement').value = this.dataset.concerne;
                document.getElementById('nomUserSignalement').innerText = this.dataset.nom;
                modal.show();
            });
        });

        if(form) {
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                const tid = document.getElementById('trajetSignalement').value;
                const uid = document.getElementById('userSignalement').value;
                const motif = document.getElementById('motifSignalement').value;
                const desc = document.getElementById('detailsSignalement').value;

                fetch('/sae-covoiturage/public/api/signalement/nouveau', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({ id_trajet: tid, id_signale: uid, motif: motif, description: desc })
                })
                .then(r => r.json())
                .then(d => {
                    modal.hide();
                    if(d.success) { alert("Signalement envoyé !"); form.reset(); }
                    else { alert("Erreur : " + d.msg); }
                });
            });
        }
    }

    // --- VALIDATION DU VÉHICULE (SANS RECHARGEMENT) ---
    const formVehicule = document.getElementById('form-vehicule');
    const inputImmat = document.getElementById('immat-input');
    const errorMsg = document.getElementById('immat-error');

    if (formVehicule && inputImmat) {
        // Regex formats: SIV (AA-123-AA) ou FNI (1234 AB 56)
        const regexSIV = /^[A-Z]{2}[-\s]?\d{3}[-\s]?[A-Z]{2}$/;
        const regexFNI = /^\d{1,4}[-\s]?[A-Z]{2,3}[-\s]?[A-Z]{2}$/;

        formVehicule.addEventListener('submit', function(e) {
            const val = inputImmat.value.trim();
            // Si le format est invalide, on coupe tout de suite
            if (!regexSIV.test(val) && !regexFNI.test(val)) {
                e.preventDefault(); // STOP : Pas d'envoi au serveur, pas de rechargement
                inputImmat.classList.add('is-invalid'); // Ajoute bordure rouge bootstrap si dispo
                inputImmat.style.border = "2px solid #dc3545"; // Force bordure rouge
                if(errorMsg) errorMsg.style.display = "block";
                
                // Petit effet visuel "Shake"
                inputImmat.animate([
                    { transform: 'translateX(0px)' },
                    { transform: 'translateX(10px)' },
                    { transform: 'translateX(-10px)' },
                    { transform: 'translateX(0px)' }
                ], { duration: 300 });
            } else {
                // Tout est bon, on laisse faire le serveur
                if(errorMsg) errorMsg.style.display = "none";
                inputImmat.style.border = "1px solid #ccc";
            }
        });

        // Nettoyage erreur quand on tape
        inputImmat.addEventListener('input', function() {
            if (errorMsg && errorMsg.style.display === 'block') {
                errorMsg.style.display = 'none';
                inputImmat.style.border = "1px solid #ccc";
            }
        });

        // Formatage automatique SIV (ajoute les tirets)
        inputImmat.addEventListener('keyup', function(e) {
            // Ne pas formater si on efface (Backspace)
            if (e.key === 'Backspace' || e.key === 'Delete') return;

            let v = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
            if (v.length > 2 && /^[A-Z]{2}/.test(v)) { // Détection SIV commence par 2 lettres
                if(v.length <= 5) {
                    this.value = v.slice(0, 2) + '-' + v.slice(2);
                } else {
                    this.value = v.slice(0, 2) + '-' + v.slice(2, 5) + '-' + v.slice(5, 7);
                }
            }
        });
    }
});