document.addEventListener('DOMContentLoaded', () => {
    // --- 1. Gestion de l'affichage des mots de passe (Oeil) ---
    window.togglePwd = function(id) {
        const input = document.getElementById(id);
        input.type = (input.type === "password") ? "text" : "password";
    };

    // --- 2. Validation et Modale ---
    const form = document.getElementById('mdpForm');
    const confirmModal = document.getElementById('confirmModal');
    const currentInput = document.getElementById('current_password');
    const newInput = document.getElementById('new_password');
    const confirmInput = document.getElementById('confirm_password');
    
    const regex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/;

    // Reset erreur PHP au typage
    currentInput.addEventListener('input', function() {
        const errCurrent = document.getElementById('msg-error-current');
        if (errCurrent) errCurrent.classList.remove('show-error-php');
    });

    // Validation temps réel (Format)
    newInput.addEventListener('input', function() {
        const val = this.value;
        const errorMsg = document.getElementById('msg-error-format');
        if (val.length > 0 && !regex.test(val)) {
            errorMsg.style.display = 'block';
        } else {
            errorMsg.style.display = 'none';
        }
    });

    // Validation temps réel (Correspondance)
    confirmInput.addEventListener('input', function() {
        const errorMsg = document.getElementById('msg-error-confirm');
        if (this.value !== newInput.value) {
            errorMsg.style.display = 'block';
        } else {
            errorMsg.style.display = 'none';
        }
    });

    // --- INTERCEPTION DU SUBMIT ---
    form.addEventListener('submit', function(e) {
        e.preventDefault(); // On bloque l'envoi immédiat

        let isValid = true;

        // Vérification finale avant d'ouvrir la modale
        if (!regex.test(newInput.value)) {
            document.getElementById('msg-error-format').style.display = 'block';
            isValid = false;
        }
        if (newInput.value !== confirmInput.value) {
            document.getElementById('msg-error-confirm').style.display = 'block';
            isValid = false;
        }

        // Si tout est bon, on affiche la modale de confirmation
        if (isValid) {
            confirmModal.style.display = 'flex';
        }
    });
});

// Fonctions globales pour le HTML
function closeConfirm() {
    document.getElementById('confirmModal').style.display = 'none';
}

function submitRealForm() {
    document.getElementById('mdpForm').submit();
}