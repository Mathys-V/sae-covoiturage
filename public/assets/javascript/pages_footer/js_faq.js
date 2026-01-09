/*
 * Gestion de l'affichage interactif de la Foire Aux Questions (FAQ) sous forme d'accordéon.
 * Le script écoute les clics sur chaque titre de question. L'objectif est de garantir qu'une seule
 * réponse est affichée à la fois pour ne pas surcharger la page.
 * Pour cela, avant d'ouvrir la section demandée, on force la fermeture de tous les autres éléments frères
 * en manipulant leurs classes CSS, puis on bascule l'état de l'élément ciblé.
 */
document.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll(".faq-question").forEach((item) => {
        item.addEventListener("click", (event) => {
            const parent = item.parentElement; // Remonte au conteneur parent (Question + Réponse)

            // Ferme automatiquement les autres onglets ouverts (Effet Accordéon)
            document.querySelectorAll(".faq-item").forEach((child) => {
                if (child !== parent) {
                    // Clause d'exclusion : on ne ferme pas celui qu'on veut ouvrir
                    child.classList.remove("active"); // Force la fermeture des autres
                }
            });

            // Bascule l'état de l'élément cliqué (Ouvert <-> Fermé)
            parent.classList.toggle("active"); // Manipulation de classe CSS pour l'affichage
        });
    });
});
