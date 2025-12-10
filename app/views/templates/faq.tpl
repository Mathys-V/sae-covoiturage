<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FAQ - MonCovoitJV</title>
    
    <style>
        /* 1. CONFIGURATION GLOBALE (Thème Violet) */
        html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            font-family: 'Segoe UI', system-ui, sans-serif;
            background-color: #463077 !important; /* Violet principal */
            color: white !important;
        }

        /* 2. WRAPPER (Pour le footer sticky) */
        .page-wrapper {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* 3. CONTENU PRINCIPAL */
        .main-content {
            flex: 1;
            width: 100%;
            max-width: 800px; /* Un peu plus étroit pour la lecture */
            margin: 0 auto;
            padding: 60px 20px;
            box-sizing: border-box;
        }

        /* --- STYLES FAQ --- */
        .faq-title {
            text-align: center;
            margin-bottom: 60px;
            font-size: 2.5em;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 2px;
            color: white;
        }

        .faq-item {
            background-color: rgba(255, 255, 255, 0.05); /* Fond très léger */
            border-radius: 15px;
            margin-bottom: 20px;
            padding: 0 20px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: background-color 0.3s ease;
        }

        .faq-item:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }

        .faq-question {
            padding: 20px 0;
            cursor: pointer;
            font-weight: 600;
            font-size: 1.2em;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: #fff;
            user-select: none;
        }

        .faq-answer {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.4s ease-out, padding 0.4s ease;
            font-size: 1em;
            line-height: 1.6;
            color: #dcd6f7; /* Blanc cassé violet pour le texte */
        }

        /* État ouvert */
        .faq-item.active .faq-answer {
            max-height: 500px; /* Suffisant pour du texte long */
            padding-bottom: 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            margin-top: 10px;
        }

        /* Icône + / - */
        .toggle-icon {
            font-size: 1.5em;
            font-weight: 300;
            color: #bfaee3;
            transition: transform 0.3s ease;
        }
        
        .faq-item.active .toggle-icon {
            transform: rotate(45deg); /* Effet croix */
        }
    </style>
</head>

<body>
    
    <div class="page-wrapper">

        {include file='includes/header.tpl'}

        <main class="main-content">
            
            <h1 class="faq-title">Questions Fréquentes</h1>

            <div class="faq-item">
                <div class="faq-question">
                    Qui se cache derrière MonCovoitJV ?
                    <span class="toggle-icon">+</span>
                </div>
                <div class="faq-answer">
                    <p>MonCovoitJV est une initiative développée par un <strong> groupe d'étudiants  </strong> en informatique de l'IUT d'Amiens. Notre projet vise à faciliter la mobilité au sein de l'Université de Picardie Jules Verne grâce à une solution numérique moderne et solidaire.</p>
                </div>
            </div>

            <div class="faq-item">
                <div class="faq-question">
                    Le service est-il payant ?
                    <span class="toggle-icon">+</span>
                </div>
                <div class="faq-answer">
                    <p>Non, l'utilisation de la plateforme est <strong>entièrement gratuite</strong>. MonCovoitJV ne prélève aucune commission sur les trajets. Les conducteurs et les passagers sont libres de s'arranger entre eux pour le partage des frais (essence, péage) de manière équitable.</p>
                </div>
            </div>

            <div class="faq-item">
                <div class="faq-question">
                    Comment la sécurité est-elle assurée ?
                    <span class="toggle-icon">+</span>
                </div>
                <div class="faq-answer">
                    <p>La sécurité est notre priorité. L'accès à la plateforme est réservé aux étudiants de l'UPJV. Nous avons mis en place :</p>
                    <ul style="margin-bottom:0;">
                        <li>Un système de <strong>profils vérifiés</strong>.</li>
                        <li>Une fonctionnalité d'<strong>avis et de notation</strong> après chaque trajet.</li>
                        <li>Un bouton de <strong>signalement</strong> pour rapporter tout comportement inapproprié à nos modérateurs.</li>
                    </ul>
                </div>
            </div>

            <div class="faq-item">
                <div class="faq-question">
                    Puis-je annuler une réservation ?
                    <span class="toggle-icon">+</span>
                </div>
                <div class="faq-answer">
                    <p>Oui, vous pouvez annuler une réservation en un clic depuis votre espace "Mes Trajets".</p>
                    <p>Le système se charge de tout : <strong>le conducteur recevra automatiquement un message</strong> pour l'informer de votre désistement. Nous vous invitons toutefois à annuler le plus tôt possible pour permettre à un autre étudiant de récupérer votre place.</p>
                </div>
            </div>

            <div class="faq-item">
                <div class="faq-question">
                    J'ai rencontré un bug technique, que faire ?
                    <span class="toggle-icon">+</span>
                </div>
                <div class="faq-answer">
                    <p>Le site étant un projet étudiant en constante amélioration, des bugs peuvent survenir. N'hésitez pas à nous contacter via le formulaire de contact en bas de page pour nous signaler le problème. Votre retour nous aide à améliorer l'expérience pour tous !</p>
                </div>
            </div>

        </main>

        {include file='includes/footer.tpl'}

    </div>

    <script>
        document.querySelectorAll('.faq-question').forEach(item => {
            item.addEventListener('click', event => {
                const parent = item.parentElement;
                
                // Ferme automatiquement les autres onglets ouverts (Effet Accordéon)
                document.querySelectorAll('.faq-item').forEach(child => {
                    if (child !== parent) {
                        child.classList.remove('active');
                    }
                });

                // Bascule l'état de l'élément cliqué
                parent.classList.toggle('active');
            });
        });
    </script>
    
</body>
</html>