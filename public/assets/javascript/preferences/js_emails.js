document.addEventListener("DOMContentLoaded", () => {
    // Liste des identifiants (IDs) des checkboxes à gérer
    const keys = ["mail_newsletter", "mail_recap", "mail_partenaires"];

    /*
     * Restauration de l'état des cases à cocher au chargement de la page.
     * Le script parcourt les clés de configuration et interroge le LocalStorage du navigateur.
     * Si une préférence a été sauvegardée précédemment (valeur 'true'),
     * on coche la case correspondante dans le DOM pour que l'utilisateur retrouve ses réglages.
     */
    // Load
    keys.forEach((k) => {
        if (localStorage.getItem(k) === "true")
            document.getElementById(k).checked = true; // Lecture du stockage local
    });

    /*
     * Gestion de la sauvegarde et du feedback utilisateur (UX).
     * On intercepte la soumission du formulaire pour éviter un rechargement de page inutile.
     * Les nouvelles préférences sont enregistrées dans le LocalStorage.
     * Ensuite, on modifie temporairement l'apparence du bouton (texte et couleur)
     * pour confirmer visuellement à l'utilisateur que l'action a réussi.
     */
    // Save
    document.getElementById("emailForm").addEventListener("submit", (e) => {
        e.preventDefault(); // Bloque l'envoi HTTP standard du formulaire

        // Mise à jour des valeurs dans le stockage du navigateur
        keys.forEach((k) =>
            localStorage.setItem(k, document.getElementById(k).checked)
        );

        // Gestion du feedback visuel
        const btn = document.querySelector(".btn-save");
        btn.innerText = "Préférences mises à jour !";
        btn.style.background = "#00e676"; // Changement de couleur (Vert succès)

        // Timer pour remettre le bouton à son état initial après 2 secondes
        setTimeout(() => {
            btn.innerText = "Enregistrer";
            btn.style.background = "#8C52FF"; // Retour à la charte graphique
        }, 2000);
    });
});
