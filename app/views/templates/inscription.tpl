{include file='includes/header.tpl'}

<section class="d-flex justify-content-center align-items-center p-3" style="min-height: 90vh;">
    
    <div class="card shadow-lg border-0 rounded-4 p-4 p-md-5 position-relative" style="width: 100%; max-width: 800px;">
        
        <h1 class="text-center mb-5 titre-inscription">S'inscrire</h1>
        <form action="traitement_inscription.php" method="POST">
        </form>
        <div class="form-step" id="step-1">         

                <div class="mb-5">
                    <label for="emailInput" class="form-label adresse-texte fw-bold mb-3">
                        Quelle est votre adresse mail ?<span class="asterisque">*</span>
                    </label>
                    <input type="email" id="emailInput" name="email" class="form-control email-input" placeholder="exemple@mcovoitjv.com" required>
                </div>

                <div class="text-center mt-5 mb-4">
                    <button type="submit" class="btn btn-cont-email fw-bold">Continuer</button>
                </div>
        </div>

        <div class="form-step d-none" id="step-2">
            <h1 class="text-center mb-5 titre-inscription">S'inscrire</h1>

                <div class="mb-5">
                    <label for="emailInput" class="form-label adresse-texte fw-bold mb-3">
                        Quelle est votre adresse mail ?<span class="asterisque">*</span>
                    </label>
                    <input type="email" id="emailInput" name="email" class="form-control email-input" placeholder="exemple@mcovoitjv.com" required>
                </div>

                <div class="text-center mt-5 mb-4">
                    <button type="submit" class="btn btn-cont-email fw-bold">Continuer</button>
                </div>
        </div>

        <p class="position-absolute bottom-0 start-0 m-4 texte-champ small">
            <span class="asterisque">*</span> champ obligatoire
        </p>
    </div>

</section>

<script>
    function goToStep(stepNumber) {
        // On cache toutes les étapes
        document.querySelectorAll('.form-step').forEach(div => div.classList.add('d-none'));
        
        // On affiche celle demandée
        document.getElementById('step' + stepNumber).classList.remove('d-none');
    }
</script>

<style>
    body {
        background-color: #452b85;
    }
    
    /* TYPOGRAPHIE */
    .titre-inscription {
        color: #8c52ff;
        /* Si vous avez Garet, sinon mettez sans-serif */
        font-family: 'Garet', sans-serif; 
        font-weight: bold;
    }

    .adresse-texte {
        color: #8c52ff; /* Un violet plus foncé est souvent plus lisible pour les labels */
        font-size: 1.2rem; /* Texte un peu plus gros */
    }

    .asterisque {
        color: #ED3F27;
        margin-left: 5px;
    }

    .texte-champ {
        color: #ED3F27;
        font-style: italic;
    }

    /* INPUT (Champ de texte) */
    .email-input {
        border: 2px solid #8c52ff;
        border-radius: 12px;
        padding: 15px 20px; /* Plus d'espace intérieur */
        font-size: 1.1rem;
        background-color: #f9f9f9;
        transition: all 0.3s ease;
    }

    /* Changement de couleur quand on clique dedans */
    .email-input:focus {
        background-color: #fff;
        border-color: #8c52ff; /* Bordure plus foncée */
        box-shadow: 0 0 0 0.25rem rgba(140, 82, 255, 0.25); /* Halo violet */
        outline: none;
    }

    /* BOUTON */
    .btn-cont-email {
        background-color: #8c52ff;
        color: white;
        border: none;
        padding: 12px 0; /* Hauteur du bouton */
        border-radius: 12px;
        font-size: 1.2rem;
        transition: transform 0.2s, background-color 0.3s;
        
        /* Largeur Responsive */
        width: 100%; /* Par défaut (Mobile) : prend toute la largeur */
    }

    .btn-cont-email:hover {
        background-color: #452b85; /* Plus foncé au survol */
        color: white;
        transform: scale(1.02); /* Petit effet de grossissement */
    }

    /* RESPONSIVE : Version PC (écrans > 768px) */
    @media (min-width: 768px) {
        .btn-cont-email {
            width: 40%; /* Sur PC, le bouton ne fait que 40% de la largeur */
            padding: 12px 40px;
        }
    }
</style>
{include file='includes/footer.tpl'}