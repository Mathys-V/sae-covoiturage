<!doctype html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Accueil - monCovoitJV</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    

    <link rel="stylesheet" href="/sae-covoiturage/public/assets/css/accueil/style_accueil.css">

</head>
<body>

    {include file='includes/header.tpl'}

    <section class="section-heros">
        <div class="hero-container">
            <div class="search-card">
                <div class="text-center mb-4">
                    <h1 class="hero-title">monCovoitJV</h1>
                    <p class="hero-subtitle">Le covoiturage gratuit pour les étudiants de l'IUT d'Amiens.</p>
                </div>

                <form action="/sae-covoiturage/public/recherche/resultats" method="GET" autocomplete="off"> 
                    
                    <div class="form-group-modern autocomplete-wrapper"> <label for="depart">D'où partez-vous ?</label>
                        <i class="bi bi-geo-alt-fill input-icon"></i>
                        <input type="text" id="depart" name="depart" class="input-modern" 
                            placeholder="Ex: Gare d'Amiens..." 
                            value="{$recherche_precedente.depart|default:''}" required>
                        
                        <div id="depart-list" class="autocomplete-suggestions"></div>
                    </div>

                    <div class="form-group-modern autocomplete-wrapper">
                        <label for="arrivee">Où allez-vous ?</label>
                        <i class="bi bi-pin-map-fill input-icon"></i>
                        <input type="text" id="arrivee" name="arrivee" class="input-modern" 
                            placeholder="Ex: IUT Amiens" 
                            value="{$recherche_precedente.arrivee|default:''}" required>
                        
                        <div id="arrivee-list" class="autocomplete-suggestions"></div>
                    </div>

                    <input type="hidden" name="date" value="{$smarty.now|date_format:'%Y-%m-%d'}">

                    <button type="submit" class="btn-search">
                        <i class="bi bi-search me-2"></i> Rechercher
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

    <script>
        window.lieuxFrequents = [];
        try {
            window.lieuxFrequents = JSON.parse('{$lieux_frequents|default:[]|json_encode|escape:"javascript"}');
        } catch(e) { console.warn("Pas de lieux fréquents chargés"); }
    </script>

    <script src="/sae-covoiturage/public/assets/javascript/accueil/js_accueil.js"></script>
</body>
</html>