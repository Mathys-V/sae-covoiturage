<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contactez-nous - MonCovoitJV</title>
    
    <style>
        /* 1. CONFIGURATION GLOBALE (Identique à ton modèle) */
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
            max-width: 700px; /* Largeur optimale pour un formulaire */
            margin: 0 auto;
            padding: 40px 20px;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            justify-content: center; /* Centre verticalement si l'écran est grand */
        }

        /* --- STYLES SPÉCIFIQUES PAGE CONTACT --- */
        
        /* Titre "Contactez-nous" */
        .contact-title {
            text-align: center;
            font-size: 2.2em;
            font-weight: 700;
            margin-bottom: 40px;
            color: white;
        }

        /* Conteneur du formulaire */
        .contact-form {
            display: flex;
            flex-direction: column;
            gap: 25px; /* Espace entre les groupes de champs */
        }

        .form-group {
            display: flex;
            flex-direction: column;
            align-items: center; /* Centre les labels et inputs */
        }

        /* Labels */
        .form-label {
            margin-bottom: 10px;
            font-size: 1.1em;
            font-weight: 500;
        }

        .required-star {
            color: #ff4d4d; /* Rouge pour l'astérisque */
            margin-left: 4px;
        }

        /* Champs (Input & Textarea) */
        .form-input, .form-textarea {
            width: 100%;
            max-width: 500px; /* Largeur max des champs comme sur l'image */
            padding: 12px 20px;
            border-radius: 30px; /* Bords très arrondis */
            border: none;
            background-color: white;
            font-family: inherit;
            font-size: 1em;
            box-sizing: border-box;
            
            /* Lueur violette externe comme sur l'image */
            box-shadow: 0 0 15px rgba(139, 92, 246, 0.4); 
            outline: none;
            transition: box-shadow 0.3s ease;
        }

        .form-input:focus, .form-textarea:focus {
            box-shadow: 0 0 20px rgba(139, 92, 246, 0.8);
        }

        .form-textarea {
            border-radius: 20px; /* Un peu moins arrondi pour la zone de texte */
            min-height: 150px;
            resize: vertical;
        }

        /* Bouton Envoyer */
        .submit-container {
            display: flex;
            justify-content: center;
            margin-top: 20px;
        }

        .btn-submit {
            background: linear-gradient(90deg, #8A63D2, #6a4ab5); /* Dégradé violet clair */
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 50px;
            font-size: 1em;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(0,0,0,0.3);
        }

        /* Note champ obligatoire en bas à gauche */
        .required-note {
            color: #ff4d4d;
            font-size: 0.9em;
            margin-top: 40px;
        }

    </style>
</head>

<body>
    
    <div class="page-wrapper">

        {include file='includes/header.tpl'}

        <main class="main-content">
            
            <h1 class="contact-title">Contactez-nous</h1>

            <form class="contact-form" action="#" method="POST">
                
                <div class="form-group">
                    <label class="form-label" for="problem">
                        Quel est votre problème ?<span class="required-star">*</span>
                    </label>
                    <input type="text" id="problem" name="problem" class="form-input" required>
                </div>

                <div class="form-group">
                    <label class="form-label" for="email">
                        Quel est votre e-mail ?<span class="required-star">*</span>
                    </label>
                    <input type="email" id="email" name="email" class="form-input" required>
                </div>

                <div class="form-group">
                    <label class="form-label" for="message">
                        Décrivez-nous votre demande en détail<span class="required-star">*</span>
                    </label>
                    <textarea id="message" name="message" class="form-textarea" required></textarea>
                </div>

                <div class="submit-container">
                    <button type="submit" class="btn-submit">
                        Envoyer
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M22 2L11 13" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                            <path d="M22 2L15 22L11 13L2 9L22 2Z" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                    </button>
                </div>

            </form>

            <p class="required-note">*champ obligatoire</p>

        </main>

        {include file='includes/footer.tpl'}

    </div>
    
</body>
</html>