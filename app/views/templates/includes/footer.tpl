<style>
    :root {
        --mon-covoit-purple: #8c52ff;
    }

    /* Le bloc principal du footer */
    .footer-custom {
        background-color: #ffffff; /* Fond Blanc */
        border-top: 3px solid var(--mon-covoit-purple); /* Ligne violette au-dessus */
        color: #212529;
        width: 100%;
        margin-top: auto; /* Pousse le footer vers le bas */
    }

    /* Les liens à gauche */
    .footer-link {
        text-decoration: none;
        color: #212529;
        margin-right: 2rem;
        font-size: 0.95rem;
        font-weight: 500;
        transition: color 0.2s;
    }

    .footer-link:hover {
        color: var(--mon-covoit-purple);
    }

    /* Texte "MonCovoitJV" à droite */
    .footer-logo-text {
        color: #000000;
        font-weight: bold;
        font-size: 1.1rem;
        margin-left: 10px;
    }

    /* Conteneur de l'image (Carré simple, pas de rond) */
    .footer-logo-box {
        display: flex;
        align-items: center;
        justify-content: center;
    }

    /* L'image du logo */
    .footer-logo-box img {
        height: 40px; /* Même hauteur que dans le header */
        width: auto;  /* Garde les proportions */
        object-fit: contain;
    }
</style>

<footer class="footer-custom py-4 mt-5">
    <div class="container">
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-center">
            
            <div class="mb-3 mb-md-0 d-flex flex-wrap justify-content-center justify-content-md-start">
                <a href="/sae-covoiturage/public/contact" class="footer-link">Contactez-nous</a>
                <a href="/sae-covoiturage/public/cookies" class="footer-link">Paramètres des cookies</a>
                <a href="/sae-covoiturage/public/mentions_legales" class="footer-link">Informations légales</a>
                <a href="/sae-covoiturage/public/faq" class="footer-link">F.A.Q</a>
            </div>
            
            <div class="d-flex align-items-center">
                <div class="footer-logo-box">
                    <img src="/sae-covoiturage/public/assets/img/logo.png" alt="Logo"> 
                </div>
                <span class="footer-logo-text">MonCovoitJV ©</span>
            </div>

        </div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>