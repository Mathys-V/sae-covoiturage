<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Footer MonCovoitJV Final</title>

    <style>
        /* La couleur violette utilisée dans votre design */
        :root {
            --mon-covoit-purple: #8c52ff;
        }

        /* --- STYLES DU FOOTER --- */
        .footer-custom {
            /* Couleur de fond très claire (comme sur l'image) */
            background-color: #ffffff; 
            color: #212529; /* Texte sombre */
        }
        .footer-link {
            text-decoration: none;
            color: inherit;
            /* Espace entre les liens */
            margin-right: 1.5rem; 
            font-size: 0.9rem;
            white-space: nowrap; 
        }
        /* Style du texte du logo dans le footer */
        .footer-logo-text {
            /* Utilise la couleur violette directement */
            color: var(--mon-covoit-purple); 
            font-size: 1rem; 
            font-weight: bold;
        }
        .footer-link:hover {
            color: var(--mon-covoit-purple); /* Surlignage violet */
        }
    </style>
</head>
    <footer class="footer-custom pt-3 pb-3 border-top">
        <div class="container">
            <div class="row">
                <div class="col-12 d-flex justify-content-center align-items-center flex-wrap">
                    
                    <a href="#" class="footer-link">Contactez-nous</a>
                    <a href="#" class="footer-link">Paramètres des Cookies</a>
                    <a href="#" class="footer-link">Informations légales</a>
                    <a href="#" class="footer-link">F.A.Q</a>
                    
                    <div class="d-flex align-items-center">
                        <img src="assets/img/logo.png" alt="Logo MonCovoitJV" style="height: 20px; margin-right: 5px;">
                        <span class="footer-logo-text">MonCovoitJV</span>
                    </div>
                </div>
            </div>
        </div>
    </footer>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>