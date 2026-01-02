function ouvrirSignalement(idTrajet, idPassager, nomPassager) {
    document.getElementById("sig-id-trajet").value = idTrajet;
    document.getElementById("sig-id-passager").value = idPassager;
    document.getElementById("modal-passager-nom").textContent = nomPassager;

    const myModal = new bootstrap.Modal(
        document.getElementById("signalementModal")
    );
    myModal.show();
}

document.addEventListener("DOMContentLoaded", function () {
    const formSig = document.getElementById("form-signalement");

    if (formSig) {
        formSig.addEventListener("submit", async function (e) {
            e.preventDefault();

            const btn = this.querySelector('button[type="submit"]');
            const originalText = btn.textContent;
            btn.disabled = true;
            btn.textContent = "Envoi...";

            const data = {
                id_trajet: document.getElementById("sig-id-trajet").value,
                id_signale: document.getElementById("sig-id-passager").value,
                motif: document.getElementById("sig-motif").value,
                description: document.getElementById("sig-desc").value,
            };

            try {
                const response = await fetch(
                    "/sae-covoiturage/public/api/signalement/nouveau",
                    {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify(data),
                    }
                );
                const result = await response.json();

                if (result.success) {
                    alert("Signalement enregistré.");
                    const modalEl = document.getElementById("signalementModal");
                    const modalInstance = bootstrap.Modal.getInstance(modalEl);
                    modalInstance.hide();
                    formSig.reset();
                } else {
                    alert("Erreur : " + result.msg);
                }
            } catch (error) {
                console.error(error);
                alert("Erreur technique lors du signalement.");
            } finally {
                btn.disabled = false;
                btn.textContent = originalText;
            }
        });
    }
});
