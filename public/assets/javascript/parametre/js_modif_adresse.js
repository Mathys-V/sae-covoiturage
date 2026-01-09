document.addEventListener("DOMContentLoaded", () => {
    console.log("✅ CHARGEMENT: js_modif_adresse.js");

    // --- VARIABLES ---
    const rueInput = document.getElementById("rue");
    const suggestionsContainer = document.querySelector(
        ".autocomplete-suggestions"
    ); // La DIV
    const villeInput = document.getElementById("ville");
    const cpInput = document.getElementById("cp");
    const form = document.getElementById("addressForm");
    const confirmModal = document.getElementById("confirmModal");

    let timeout = null;

    if (!rueInput || !suggestionsContainer) {
        console.error("❌ ERREUR: Champs introuvables");
        return;
    }

    // --- 1. AUTOCOMPLÉTION ---
    rueInput.addEventListener("input", function () {
        const query = this.value.trim();

        // Si vide, on cache la liste
        if (query.length === 0) {
            suggestionsContainer.style.display = "none";
            return;
        }

        clearTimeout(timeout);
        timeout = setTimeout(() => {
            console.log("🔎 Recherche API : " + query);

            // Appel API avec encodage
            fetch(
                "https://api-adresse.data.gouv.fr/search/?q=" +
                    encodeURIComponent(query) +
                    "&limit=5"
            )
                .then((response) => response.json())
                .then((data) => {
                    suggestionsContainer.innerHTML = "";

                    if (data.features && data.features.length > 0) {
                        suggestionsContainer.style.display = "block"; // Affiche la liste

                        data.features.forEach((feature) => {
                            const props = feature.properties;

                            // CRÉATION DE LA DIV (Comme Inscription)
                            const div = document.createElement("div");
                            div.className = "autocomplete-suggestion";
                            div.innerHTML = `<i class="bi bi-geo-alt-fill"></i> <strong>${props.name}</strong> <span style="font-size:0.85em; color:#666; margin-left:5px;">(${props.postcode} ${props.city})</span>`;

                            // CLIC SUR UNE SUGGESTION
                            div.addEventListener("click", function () {
                                rueInput.value = props.name;
                                villeInput.value = props.city;
                                cpInput.value = props.postcode;

                                // Petit effet visuel vert
                                villeInput.style.backgroundColor = "#d4edda";
                                cpInput.style.backgroundColor = "#d4edda";
                                setTimeout(() => {
                                    villeInput.style.backgroundColor = "";
                                    cpInput.style.backgroundColor = "";
                                }, 500);

                                suggestionsContainer.style.display = "none";
                                // On cache les erreurs s'il y en avait
                                document
                                    .querySelectorAll(".error-message")
                                    .forEach(
                                        (el) => (el.style.display = "none")
                                    );
                            });

                            suggestionsContainer.appendChild(div);
                        });
                    } else {
                        suggestionsContainer.style.display = "none";
                    }
                })
                .catch((err) => console.error("❌ Erreur API", err));
        }, 300);
    });

    // Fermeture au clic extérieur
    document.addEventListener("click", function (e) {
        if (e.target !== rueInput && e.target !== suggestionsContainer) {
            suggestionsContainer.style.display = "none";
        }
    });

    // --- 2. VALIDATION ---
    if (form) {
        form.addEventListener("submit", function (e) {
            e.preventDefault();
            if (validateForm()) {
                confirmModal.style.display = "flex";
            }
        });
    }

    function validateForm() {
        let isValid = true;
        document
            .querySelectorAll(".error-message")
            .forEach((el) => (el.style.display = "none"));

        if (rueInput.value.trim() === "") {
            document.getElementById("errorRue").style.display = "block";
            isValid = false;
        }
        if (villeInput.value.trim() === "") {
            document.getElementById("errorVille").style.display = "block";
            isValid = false;
        }
        if (cpInput.value.trim().length !== 5) {
            document.getElementById("errorCp").style.display = "block";
            isValid = false;
        }
        return isValid;
    }
});

// Fonctions globales (pour les onclick dans le HTML)
function closeConfirm() {
    document.getElementById("confirmModal").style.display = "none";
}

function submitRealForm() {
    document.getElementById("addressForm").submit();
}
document.addEventListener("DOMContentLoaded", () => {
    console.log("✅ CHARGEMENT: js_modif_adresse.js");

    // --- VARIABLES ---
    const rueInput = document.getElementById("rue");
    const suggestionsContainer = document.querySelector(
        ".autocomplete-suggestions"
    ); // La DIV
    const villeInput = document.getElementById("ville");
    const cpInput = document.getElementById("cp");
    const form = document.getElementById("addressForm");
    const confirmModal = document.getElementById("confirmModal");

    let timeout = null;

    if (!rueInput || !suggestionsContainer) {
        console.error("❌ ERREUR: Champs introuvables");
        return;
    }

    // --- 1. AUTOCOMPLÉTION ---
    rueInput.addEventListener("input", function () {
        const query = this.value.trim();

        // Si vide, on cache la liste
        if (query.length === 0) {
            suggestionsContainer.style.display = "none";
            return;
        }

        clearTimeout(timeout);
        timeout = setTimeout(() => {
            console.log("🔎 Recherche API : " + query);

            // Appel API avec encodage
            fetch(
                "https://api-adresse.data.gouv.fr/search/?q=" +
                    encodeURIComponent(query) +
                    "&limit=5"
            )
                .then((response) => response.json())
                .then((data) => {
                    suggestionsContainer.innerHTML = "";

                    if (data.features && data.features.length > 0) {
                        suggestionsContainer.style.display = "block"; // Affiche la liste

                        data.features.forEach((feature) => {
                            const props = feature.properties;

                            // CRÉATION DE LA DIV (Comme Inscription)
                            const div = document.createElement("div");
                            div.className = "autocomplete-suggestion";
                            div.innerHTML = `<i class="bi bi-geo-alt-fill"></i> <strong>${props.name}</strong> <span style="font-size:0.85em; color:#666; margin-left:5px;">(${props.postcode} ${props.city})</span>`;

                            // CLIC SUR UNE SUGGESTION
                            div.addEventListener("click", function () {
                                rueInput.value = props.name;
                                villeInput.value = props.city;
                                cpInput.value = props.postcode;

                                // Petit effet visuel vert
                                villeInput.style.backgroundColor = "#d4edda";
                                cpInput.style.backgroundColor = "#d4edda";
                                setTimeout(() => {
                                    villeInput.style.backgroundColor = "";
                                    cpInput.style.backgroundColor = "";
                                }, 500);

                                suggestionsContainer.style.display = "none";
                                // On cache les erreurs s'il y en avait
                                document
                                    .querySelectorAll(".error-message")
                                    .forEach(
                                        (el) => (el.style.display = "none")
                                    );
                            });

                            suggestionsContainer.appendChild(div);
                        });
                    } else {
                        suggestionsContainer.style.display = "none";
                    }
                })
                .catch((err) => console.error("❌ Erreur API", err));
        }, 300);
    });

    // Fermeture au clic extérieur
    document.addEventListener("click", function (e) {
        if (e.target !== rueInput && e.target !== suggestionsContainer) {
            suggestionsContainer.style.display = "none";
        }
    });

    // --- 2. VALIDATION ---
    if (form) {
        form.addEventListener("submit", function (e) {
            e.preventDefault();
            if (validateForm()) {
                confirmModal.style.display = "flex";
            }
        });
    }

    function validateForm() {
        let isValid = true;
        document
            .querySelectorAll(".error-message")
            .forEach((el) => (el.style.display = "none"));

        if (rueInput.value.trim() === "") {
            document.getElementById("errorRue").style.display = "block";
            isValid = false;
        }
        if (villeInput.value.trim() === "") {
            document.getElementById("errorVille").style.display = "block";
            isValid = false;
        }
        if (cpInput.value.trim().length !== 5) {
            document.getElementById("errorCp").style.display = "block";
            isValid = false;
        }
        return isValid;
    }
});

// Fonctions globales (pour les onclick dans le HTML)
function closeConfirm() {
    document.getElementById("confirmModal").style.display = "none";
}

function submitRealForm() {
    document.getElementById("addressForm").submit();
}
