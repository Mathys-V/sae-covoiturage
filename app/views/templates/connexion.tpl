{include file='includes/header.tpl'}
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion - MonCovoitJV</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* --- COULEURS PERSONNALISÉES --- */
        :root {
            --primary-purple: #8A2BE2; /* Violet similaire à l'image */
            --light-purple: #E6E6FA;
            --link-blue: #0dcaf0; /* Cyan pour "Mot de passe oublié" */
        }

        /* --- SECTION BACKGROUND --- */
        .login-section {
            /* Remplace l'URL par ton image de fond */
            background-image: url(../../../public/assets/img/Image-IUT-connexion.jpg);
            background-size: cover;
            background-position: center;
            /* Hauteur minimale pour centrer verticalement */
            min-height: 80vh; 
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* --- CARTE DE CONNEXION --- */
        .card-login {
            background: white;
            border-radius: 20px;
            padding: 2rem;
            width: 100%;
            max-width: 400px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
            border: 2px solid var(--primary-purple); /* Bordure violette fine autour de la card si souhaitée, sinon supprimer */
        }

        .card-title {
            color: var(--primary-purple);
            font-weight: bold;
            text-align: center;
            margin-bottom: 1.5rem;
            font-size: 1.8rem;
        }

        /* --- INPUTS --- */
        .form-label {
            color: var(--primary-purple);
            font-weight: 500;
            margin-bottom: 0.2rem;
        }

        .custom-input {
            border: 2px solid var(--primary-purple);
            border-radius: 10px;
            padding: 10px 15px;
            color: #333;
        }
        
        .custom-input:focus {
            box-shadow: 0 0 0 0.25rem rgba(138, 43, 226, 0.25);
            border-color: var(--primary-purple);
        }

        /* --- GROUPE PASSWORD (pour l'icône œil) --- */
        .password-group {
            position: relative;
        }
        
        .toggle-password {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: var(--primary-purple);
        }

        /* --- LIENS ET BOUTONS --- */
        .forgot-pass {
            color: var(--link-blue);
            text-decoration: none;
            font-size: 0.9rem;
            display: block;
            margin-top: 5px;
        }

        .btn-purple {
            background-color: var(--primary-purple);
            color: white;
            border-radius: 10px;
            padding: 10px 30px;
            font-weight: bold;
            font-size: 1.1rem;
            width: 100%;
            border: none;
            margin-top: 1.5rem;
            margin-bottom: 1rem;
            transition: background 0.3s;
        }

        .btn-purple:hover {
            background-color: #721cbe;
            color: white;
        }

        .register-link {
            display: block;
            text-align: center;
            color: var(--primary-purple);
            text-decoration: none;
            font-weight: 500;
        }
    </style>
</head>
<body>

    <main class="login-section">
        <div class="card-login">
            <h2 class="card-title">Se connecter</h2>
            
            <form>
                <div class="mb-3">
                    <label for="emailInput" class="form-label">Adresse email</label>
                    <input type="email" class="form-control custom-input" id="emailInput">
                </div>

                <div class="mb-3">
                    <label for="passwordInput" class="form-label">Mot de passe</label>
                    <div class="password-group">
                        <input type="password" class="form-control custom-input" id="passwordInput">
                        <i class="fa-regular fa-eye toggle-password" id="togglePassword"></i>
                    </div>
                    <a href="#" class="forgot-pass">Mot de passe oublié ?</a>
                </div>

                <div class="text-center">
                    <button type="submit" class="btn btn-purple">Connexion</button>
                </div>

                <a href="#" class="register-link">S'inscrire</a>
            </form>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        const togglePassword = document.querySelector('#togglePassword');
        const password = document.querySelector('#passwordInput');

        togglePassword.addEventListener('click', function (e) {
            // Basculer le type d'input
            const type = password.getAttribute('type') === 'password' ? 'text' : 'password';
            password.setAttribute('type', type);
            // Basculer l'icône (œil barré ou non)
            this.classList.toggle('fa-eye-slash');
        });
    </script>
</body>
</html>
{include file='includes/footer.tpl'}