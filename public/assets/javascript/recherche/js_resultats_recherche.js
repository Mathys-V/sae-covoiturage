document.addEventListener("DOMContentLoaded", async () => {
    // --- Récupération des paramètres URL ---
    // Lit les valeurs passées dans l'adresse (ex: ?depart=Paris&arrivee=Lyon)
    const params = new URLSearchParams(window.location.search);
    const villeDepart = params.get("depart");
    const villeArrivee = params.get("arrivee");

    // Ciblage des éléments du DOM
    const titleEl = document.getElementById("titre-resultats");
    const containerEl = document.getElementById("liste-trajets");
    const loadingEl = document.getElementById("loading-trajets");

    // --- Logique d'initialisation ---
    if (villeDepart && villeArrivee) {
        // Mise à jour du titre H1 pour confirmer la recherche à l'utilisateur
        if (titleEl)
            titleEl.textContent = `Trajets de ${villeDepart} vers ${villeArrivee}`;

        // Lancement de la recherche asynchrone
        await rechercherTrajets(villeDepart, villeArrivee);
    } else {
        // Gestion d'erreur si les paramètres sont absents
        if (containerEl)
            containerEl.innerHTML =
                '<div class="alert alert-warning">Veuillez préciser un départ et une arrivée.</div>';
        if (loadingEl) loadingEl.style.display = "none";
    }

    /**
     * Simule la recherche en base de données et filtre les résultats
     */
    async function rechercherTrajets(depart, arrivee) {
        // Affichage du loader pendant le traitement
        if (loadingEl) loadingEl.style.display = "block";
        if (containerEl) containerEl.innerHTML = "";

        try {
            // Appel à la fausse API (remplace le fetch vers le serveur PHP)
            const trajetsDisponibles = await mockApiTrajets();

            // Filtrage des résultats : on vérifie la correspondance des villes
            // (Note: .split(' ')[0] compare uniquement le premier mot pour être plus souple)
            const resultats = trajetsDisponibles.filter((trajet) => {
                const matchDepart = trajet.depart
                    .toLowerCase()
                    .includes(depart.toLowerCase().split(" ")[0]);
                const matchArrivee = trajet.arrivee
                    .toLowerCase()
                    .includes(arrivee.toLowerCase().split(" ")[0]);
                return matchDepart && matchArrivee;
            });

            // Masquage du loader une fois terminé
            if (loadingEl) loadingEl.style.display = "none";

            // Appel de la fonction d'affichage
            afficherTrajets(resultats);
        } catch (error) {
            console.error(error);
            if (containerEl)
                containerEl.innerHTML =
                    '<div class="alert alert-danger">Erreur lors de la récupération des trajets.</div>';
        }
    }

    /**
     * Génère le HTML des cartes de trajet et les insère dans la page
     */
    function afficherTrajets(trajets) {
        // Cas où aucun trajet ne correspond
        if (trajets.length === 0) {
            containerEl.innerHTML = `
                <div class="no-results">
                    <p>Aucun covoiturage trouvé pour ce trajet 😕</p>
                    <button class="btn btn-primary">Créer une alerte</button>
                </div>`;
            return;
        }

        // Boucle sur chaque trajet trouvé pour créer le HTML
        trajets.forEach((trajet) => {
            const card = document.createElement("div");
            card.className = "trajet-card"; // Classe CSS pour le style

            // Injection des données via Template Literal
            card.innerHTML = `
                <div class="trajet-info">
                    <div class="heure-trajet">
                        <strong>${trajet.heure_depart}</strong>
                        <span class="duree">placeholder &rarr;</span>
                        <strong>${trajet.heure_arrivee}</strong>
                    </div>
                    <div class="villes-trajet">
                        <span>${trajet.depart}</span>
                        <span>${trajet.arrivee}</span>
                    </div>
                </div>
                <div class="conducteur-info">
                    <div class="avatar-placeholder">${trajet.conducteur.charAt(
                        0
                    )}</div>
                    <span>${trajet.conducteur}</span>
                    <span class="rating">★ ${trajet.note}</span>
                </div>
                <div class="prix-action">
                    <span class="prix">${trajet.prix} €</span>
                    <a href="#" class="btn-reserver">Réserver</a>
                </div>
            `;

            containerEl.appendChild(card);
        });
    }

    /**
     * Fonction de simulation d'API (Mock)
     * Retourne une promesse avec des données JSON après un délai
     */
    function mockApiTrajets() {
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve([
                    {
                        id: 1,
                        conducteur: "Thomas",
                        note: "4.8",
                        depart: "Gare d'Amiens",
                        arrivee: "Paris Porte Maillot",
                        heure_depart: "08:00",
                        heure_arrivee: "10:30",
                        prix: 12,
                    },
                    {
                        id: 2,
                        conducteur: "Sarah",
                        note: "5.0",
                        depart: "Amiens Centre",
                        arrivee: "Paris Nord",
                        heure_depart: "09:15",
                        heure_arrivee: "11:00",
                        prix: 14,
                    },
                    {
                        id: 3,
                        conducteur: "Lucas",
                        note: "4.5",
                        depart: "Lille Europe",
                        arrivee: "Lyon Part-Dieu",
                        heure_depart: "07:00",
                        heure_arrivee: "12:00",
                        prix: 45,
                    },
                ]);
            }, 800);
        });
    }
});
