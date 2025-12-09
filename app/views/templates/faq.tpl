<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo isset($titre) ? $titre : 'FAQ'; ?></title>
    
    <style>
        /* 1. On force le fond violet sur toute la page */
        html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            font-family: 'Segoe UI', sans-serif;
            background-color: #463077 !important; /* Force le violet */
            color: white !important; /* Force le texte en blanc */
        }

        /* 2. Wrapper pour pousser le footer en bas */
        .page-wrapper {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* 3. Le contenu pousse le footer */
        .main-content {
            flex: 1;
            width: 100%;
            max-width: 900px;
            margin: 0 auto;
            padding: 40px 20px;
            box-sizing: border-box;
        }

        /* --- STYLES FAQ --- */
        .faq-title {
            text-align: center;
            margin-bottom: 50px;
            font-size: 2.5em;
            font-weight: bold;
            text-transform: uppercase;
            color: white;
        }

        .faq-item {
            border-bottom: 1px solid rgba(255,255,255,0.3); /* Ligne blanche semi-transparente */
            margin-bottom: 20px;
        }

        .faq-question {
            padding: 15px 0;
            cursor: pointer;
            font-weight: bold;
            font-size: 1.4em;
            display: flex;
            justify-content: space-between;
            align-items: center;
            text-decoration: underline;
            text-underline-offset: 5px;
            color: white;
        }

        .faq-question:hover {
            color: #ddd;
        }

        .faq-answer {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.4s ease;
            font-size: 1.1em;
            line-height: 1.6;
            color: #f0f0f0;
        }

        .faq-item.active .faq-answer {
            max-height: 500px;
            padding-bottom: 20px;
        }

        .toggle-icon {
            font-size: 1.2em;
            text-decoration: none;
            color: white;
        }
    </style>
</head>

<body>
    
    <div class="page-wrapper">

        {include file='includes/header.tpl'}

        <main class="main-content">
            
            <h2 class="faq-title">F.A.Q</h2>

            <div class="faq-item">
                <div class="faq-question">
                    Qui sommes nous ?
                    <span class="toggle-icon">+</span>
                </div>
                <div class="faq-answer">
                    Nous sommes une plateforme de covoiturage conçue pour les étudiants de l’Université de Picardie Jules Verne.
                </div>
            </div>

            <div class="faq-item">
                <div class="faq-question">
                    Quel est notre objectif ?
                    <span class="toggle-icon">+</span>
                </div>
                <div class="faq-answer">
                    Notre objectif est de simplifier les déplacements des étudiants tout en permettant de réduire leurs émissions en CO2.
                </div>
            </div>

            <div class="faq-item">
                <div class="faq-question">
                    Les trajets sont-ils sécurisés ?
                    <span class="toggle-icon">+</span>
                </div>
                <div class="faq-answer">
                    <p>Nous mettons en place un système de vérification des utilisateurs pour permettre aux étudiants de réserver leurs trajets en toute confiance.</p>
                    <p>Nous ne pouvons pas directement sécuriser les trajets, c’est pourquoi nous vous permettons de signaler les utilisateurs ayant des comportements allant à l’encontre du bon déroulement de notre système de covoiturage.</p>
                </div>
            </div>

        </main>

        {include file='includes/footer.tpl'}

    </div>

    <script>
        document.querySelectorAll('.faq-question').forEach(item => {
            item.addEventListener('click', event => {
                const parent = item.parentElement;
                
                // Ferme les autres (optionnel)
                document.querySelectorAll('.faq-item').forEach(child => {
                    if (child !== parent) {
                        child.classList.remove('active');
                        child.querySelector('.toggle-icon').textContent = '+';
                    }
                });

                parent.classList.toggle('active');
                const icon = item.querySelector('.toggle-icon');
                icon.textContent = parent.classList.contains('active') ? '-' : '+';
            });
        });
    </script>
    
</body>
</html>