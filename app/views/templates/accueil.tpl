<!doctype html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Accueil - monCovoitJV</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">

    <style>
        /* --- VARIABLES & GLOBAL --- */
        :root {
            --primary-color: #452b85;
            --accent-color: #8c52ff;
            --accent-hover: #703ccf;
            --text-dark: #2c3e50;
            --bg-light: #f8f9fa;
        }

        body {
            background-color: var(--primary-color);
            font-family: 'Poppins', sans-serif;
            overflow-x: hidden;
        }

        /* --- SECTION HÉROS (VERSION PRO) --- */
        .section-heros {
            position: relative;
            padding: 80px 20px 60px; /* Marges confortables */
            background: linear-gradient(135deg, #452b85 0%, #2a1a5e 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            /* Hauteur minimale adaptive : remplit l'écran sur PC, s'adapte sur mobile */
            min-height: 85vh; 
            overflow: hidden; /* Sécurité : rien ne dépasse */
        }

        .hero-container {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 5rem; /* Espace aéré entre image et carte */
            max-width: 1400px;
            width: 100%;
            z-index: 1;
        }

        /* IMAGE : C'est ici que la magie opère */
        .img-heros {
            width: 100%;
            max-width: 600px; /* Taille généreuse sur PC */
            height: auto;
            object-fit: contain;
            filter: drop-shadow(0 20px 40px rgba(0,0,0,0.3));
            
            /* Par défaut (Mobile) : PAS d'animation pour la performance et la lisibilité */
            transform: translateY(0);
        }

        /* CARTE "GLASSMORPHISM" */
        .search-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(12px); /* Flou d'arrière-plan plus moderne */
            -webkit-backdrop-filter: blur(12px);
            border-radius: 24px;
            padding: 3rem;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.35); /* Ombre plus douce et diffuse */
            border: 1px solid rgba(255,255,255,0.3);
            position: relative;
            z-index: 2;
        }

        /* --- TYPOGRAPHIE --- */
        .hero-title {
            color: var(--primary-color);
            font-weight: 800;
            font-size: 3rem;
            letter-spacing: -1.5px;
            margin-bottom: 0.5rem;
            line-height: 1.1;
        }

        .hero-subtitle {
            color: #555;
            font-size: 1.1rem;
            font-weight: 400;
            margin-bottom: 2rem;
        }

        /* --- FORMULAIRE MODERNE --- */
        .form-group-modern {
            margin-bottom: 1.2rem;
            position: relative;
        }

        .form-group-modern label {
            font-size: 0.8rem;
            font-weight: 700;
            color: var(--accent-color);
            margin-bottom: 0.4rem;
            display: block;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .input-modern {
            border: 2px solid #eaecf0;
            border-radius: 16px;
            padding: 14px 20px 14px 50px; /* Espace icône */
            width: 100%;
            font-size: 1rem;
            color: var(--text-dark);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            background-color: #fff;
        }

        .input-modern:focus {
            border-color: var(--accent-color);
            box-shadow: 0 0 0 4px rgba(140, 82, 255, 0.15); /* Focus ring moderne */
            outline: none;
        }

        .input-icon {
            position: absolute;
            left: 18px;
            top: 42px;
            color: #98a2b3;
            font-size: 1.3rem;
            transition: color 0.3s;
        }

        .input-modern:focus + .input-icon,
        .form-group-modern:focus-within .input-icon {
            color: var(--accent-color);
        }

        .btn-search {
            background: linear-gradient(135deg, var(--accent-color), var(--primary-color));
            color: white;
            border: none;
            padding: 16px 0;
            width: 100%;
            border-radius: 50px;
            font-weight: 600;
            font-size: 1.1rem;
            letter-spacing: 0.5px;
            box-shadow: 0 10px 20px rgba(140, 82, 255, 0.25);
            transition: all 0.3s ease;
            margin-top: 10px;
            cursor: pointer;
        }

        .btn-search:hover {
            transform: translateY(-3px);
            box-shadow: 0 20px 30px rgba(140, 82, 255, 0.35);
        }

        /* --- ANIMATION FLOTTANTE (Desktop Uniquement) --- */
        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-15px); }
            100% { transform: translateY(0px); }
        }

        /* --- RESPONSIVE INTELLIGENT --- */
        
        /* PC et Grand Écrans (> 992px) */
        @media (min-width: 992px) {
            .img-heros {
                /* On active l'animation UNIQUEMENT si on a de la place */
                animation: float 6s ease-in-out infinite;
            }
            /* Marge de sécurité pour que l'image qui flotte ne touche pas le haut */
            .hero-container {
                padding-top: 20px; 
            }
        }

        /* Tablettes et Mobiles (< 992px) */
        @media (max-width: 992px) {
            .section-heros {
                padding: 40px 20px; /* Moins de padding */
                display: block; /* On empile tout */
            }
            .hero-container {
                flex-direction: column;
                gap: 2rem;
            }
            .img-heros {
                max-width: 80%; /* Image plus petite */
                max-height: 350px; /* On limite la hauteur pour ne pas pousser le formulaire trop bas */
                margin: 0 auto; /* Centré */
                display: block;
                order: 1; /* Image en premier */
            }
            .search-card {
                order: 2; /* Formulaire en dessous */
                padding: 2rem;
            }
            .hero-title {
                font-size: 2.2rem;
            }
        }
        
        /* --- RESTE DU CSS (Sections détails, etc.) --- */
        /* Je garde le CSS précédent pour le bas de page qui était très bien */
        
        .section-detail { background-color: var(--primary-color); padding: 80px 20px; }
        .section-title { color: white; font-weight: 700; font-size: 2.2rem; margin-bottom: 50px; position: relative; display: inline-block; }
        .section-title::after { content: ''; display: block; width: 60px; height: 4px; background-color: var(--accent-color); margin: 15px auto 0; border-radius: 2px; }
        .card-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 25px; max-width: 1200px; margin: 0 auto; }
        .feature-card { background: white; padding: 30px 25px; border-radius: 20px; text-align: left; transition: all 0.3s ease; border-bottom: 5px solid transparent; }
        .feature-card:hover { transform: translateY(-8px); border-bottom-color: var(--accent-color); box-shadow: 0 20px 40px rgba(0,0,0,0.2); }
        .icon-box { width: 50px; height: 50px; background-color: rgba(140, 82, 255, 0.1); border-radius: 15px; display: flex; align-items: center; justify-content: center; margin-bottom: 15px; color: var(--accent-color); font-size: 1.5rem; }
        .feature-card h3 { font-weight: 700; font-size: 1.2rem; margin-bottom: 8px; color: var(--text-dark); }
        .feature-card p { color: #666; line-height: 1.5; margin: 0; font-size: 0.95rem; }
        .section-steps { background-color: white; padding: 120px 20px 80px; position: relative; margin-top: -2px; }
        .steps-wave { position: absolute; top: 0; left: 0; width: 100%; overflow: hidden; line-height: 0; }
        .steps-wave svg { position: relative; display: block; width: calc(100% + 1.3px); height: 80px; }
        .steps-wave .shape-fill { fill: var(--primary-color); }
        .steps-container { display: flex; justify-content: center; align-items: flex-start; max-width: 1000px; margin: 0 auto; position: relative; }
        .step-item { text-align: center; flex: 1; z-index: 2; padding: 0 15px; }
        .step-circle { width: 70px; height: 70px; background: linear-gradient(135deg, var(--accent-color), var(--primary-color)); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; font-weight: 700; margin: 0 auto 20px; box-shadow: 0 10px 20px rgba(69, 43, 133, 0.2); position: relative; z-index: 2; }
        .step-content strong { display: block; font-size: 1.1rem; color: var(--primary-color); margin-bottom: 8px; }
        .step-content { color: #666; font-size: 0.95rem; }
        .step-connector { flex-grow: 1; height: 3px; background-image: linear-gradient(to right, var(--accent-color) 50%, transparent 50%); background-size: 20px 100%; margin-top: 35px; opacity: 0.5; }
        
        @media (max-width: 768px) {
            .steps-container { flex-direction: column; align-items: center; gap: 30px; }
            .step-connector { width: 3px; height: 40px; background-image: linear-gradient(to bottom, var(--accent-color) 50%, transparent 50%); background-size: 100% 20px; margin: 0; }
        }
    </style>
</head>
<body>

    {include file='includes/header.tpl'}

    <section class="section-heros">
        <div class="hero-container">
            <img src="assets/img/image-BU-accueil.png" class="img-heros" alt="Campus IUT Amiens">

            <div class="search-card">
                <div class="text-center mb-4">
                    <h1 class="hero-title">monCovoitJV</h1>
                    <p class="hero-subtitle">Le covoiturage gratuit et exclusif pour les étudiants de l'IUT d'Amiens.</p>
                </div>

                <form action="/sae-covoiturage/public/recherche/resultats" method="GET"> 
                    
                    <div class="form-group-modern">
                        <label for="depart">D'où partez-vous ?</label>
                        <i class="bi bi-geo-alt-fill input-icon"></i>
                        <input type="text" id="depart" name="depart" class="input-modern" placeholder="Ex: Gare d'Amiens, Dury..." required>
                    </div>

                    <div class="form-group-modern">
                        <label for="arrivee">Où allez-vous ?</label>
                        <i class="bi bi-pin-map-fill input-icon"></i>
                        <input type="text" id="arrivee" name="arrivee" class="input-modern" placeholder="Ex: IUT Amiens" required>
                    </div>

                    <input type="hidden" name="date" value="{$smarty.now|date_format:'%Y-%m-%d'}">

                    <button type="submit" class="btn-search">
                        <i class="bi bi-search me-2"></i> Rechercher un trajet
                    </button>
                </form>
            </div>
        </div>
    </section>

    <section class="section-detail">
        <div class="text-center">
            <h2 class="section-title">Pourquoi nous choisir ?</h2>
        </div>
        
        <div class="card-grid">
            <div class="feature-card">
                <div class="icon-box">
                    <i class="bi bi-piggy-bank-fill"></i>
                </div>
                <h3>100% Gratuit</h3>
                <p>Aucune commission. Arrangez-vous librement entre vous : partage des frais, alternance ou gratuité.</p>
            </div>

            <div class="feature-card">
                <div class="icon-box">
                    <i class="bi bi-mortarboard-fill"></i>
                </div>
                <h3>Communauté IUT</h3>
                <p>Pour les étudiants et le personnel de l'IUT d'Amiens. Voyagez entre collègues et camarades.</p>
            </div>

            <div class="feature-card">
                <div class="icon-box">
                    <i class="bi bi-shield-check"></i>
                </div>
                <h3>Sécurisé & Vérifié</h3>
                <p>Profils vérifiés et système d'avis pour voyager sereinement.</p>
            </div>

            <div class="feature-card">
                <div class="icon-box">
                    <i class="bi bi-calendar-check-fill"></i>
                </div>
                <h3>Flexible</h3>
                <p>Trajets réguliers pour les cours ou ponctuels pour les partiels ? Trouvez ce qui vous convient.</p>
            </div>
        </div>
    </section>

    <section class="section-steps">
        <div class="steps-wave">
            <svg data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none">
                <path d="M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z" class="shape-fill"></path>
            </svg>
        </div>

        <div class="steps-container">
            <div class="step-item">
                <div class="step-circle">1</div>
                <div class="step-content">
                    <strong>Inscription Rapide</strong>
                    <p>Connectez-vous simplement et créez votre profil en 2 minutes.</p>
                </div>
            </div>

            <div class="step-connector"></div>

            <div class="step-item">
                <div class="step-circle">2</div>
                <div class="step-content">
                    <strong>Recherchez ou Proposez</strong>
                    <p>Indiquez vos horaires de cours et trouvez un covoitureur compatible.</p>
                </div>
            </div>

            <div class="step-connector"></div>

            <div class="step-item">
                <div class="step-circle">3</div>
                <div class="step-content">
                    <strong>Roulez ensemble</strong>
                    <p>Retrouvez-vous au point de rendez-vous et économisez sur vos trajets !</p>
                </div>
            </div>
        </div>
    </section>

    {include file='includes/footer.tpl'}
</body>
</html>