{include file='includes/header.tpl'}

{* Inclusion de la feuille de style spécifique à la page d'accueil *}
<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/accueil/style_accueil.css">

<section class="section-heros">
    <div class="hero-container">
        {* Bloc de recherche principal *}
        <div class="search-card">
            <div class="text-center mb-4">
                <h1 class="hero-title">monCovoitJV</h1>
                <p class="hero-subtitle">Le covoiturage gratuit pour les étudiants de l'IUT d'Amiens.</p>
            </div>

            {* Formulaire de recherche de trajet *}
            <form action="/sae-covoiturage/public/recherche/resultats" method="GET" autocomplete="off"> 
                
                {* Champ de saisie du lieu de départ avec autocomplétion *}
                <div class="form-group-modern autocomplete-wrapper"> 
                    <label for="depart">D'où partez-vous ?</label>
                    <i class="bi bi-geo-alt-fill input-icon"></i>
                    <input type="text" id="depart" name="depart" class="input-modern" 
                        placeholder="Ex: Gare d'Amiens..." 
                        value="{$recherche_precedente.depart|default:''}" required>
                    
                    {* Conteneur pour les suggestions d'autocomplétion *}
                    <div id="depart-list" class="autocomplete-suggestions"></div>
                </div>

                {* Champ de saisie du lieu d'arrivée avec autocomplétion *}
                <div class="form-group-modern autocomplete-wrapper">
                    <label for="arrivee">Où allez-vous ?</label>
                    <i class="bi bi-pin-map-fill input-icon"></i>
                    <input type="text" id="arrivee" name="arrivee" class="input-modern" 
                        placeholder="Ex: IUT Amiens" 
                        value="{$recherche_precedente.arrivee|default:''}" required>
                    
                    {* Conteneur pour les suggestions d'autocomplétion *}
                    <div id="arrivee-list" class="autocomplete-suggestions"></div>
                </div>

                {* Champ caché pour la date (par défaut : date du jour) *}
                <input type="hidden" name="date" value="{$smarty.now|date_format:'%Y-%m-%d'}">

                {* Bouton de soumission du formulaire *}
                <button type="submit" class="btn-search">
                    <i class="bi bi-search me-2"></i> Rechercher
                </button>
            </form>
        </div>
    </div>
</section>

{* Section présentant les avantages du service *}
<section class="section-detail">
    <div class="text-center">
        <h2 class="section-title">Pourquoi nous choisir ?</h2>
    </div>
    
    <div class="card-grid">
        {* Carte avantage : Gratuité *}
        <div class="feature-card">
            <div class="icon-box">
                <i class="bi bi-piggy-bank-fill"></i>
            </div>
            <h3>100% Gratuit</h3>
            <p>Aucune commission. Arrangez-vous librement entre vous : partage des frais, alternance ou gratuité.</p>
        </div>

        {* Carte avantage : Communauté IUT *}
        <div class="feature-card">
            <div class="icon-box">
                <i class="bi bi-mortarboard-fill"></i>
            </div>
            <h3>Communauté IUT</h3>
            <p>Pour les étudiants et le personnel de l'IUT d'Amiens. Voyagez entre collègues et camarades.</p>
        </div>

        {* Carte avantage : Sécurité *}
        <div class="feature-card">
            <div class="icon-box">
                <i class="bi bi-shield-check"></i>
            </div>
            <h3>Sécurisé & Vérifié</h3>
            <p>Profils vérifiés et système d'avis pour voyager sereinement.</p>
        </div>

        {* Carte avantage : Flexibilité *}
        <div class="feature-card">
            <div class="icon-box">
                <i class="bi bi-calendar-check-fill"></i>
            </div>
            <h3>Flexible</h3>
            <p>Trajets réguliers pour les cours ou ponctuels pour les partiels ? Trouvez ce qui vous convient.</p>
        </div>
    </div>
</section>

{* Section expliquant les étapes d'utilisation *}
<section class="section-steps">
    {* Séparateur graphique en forme de vague *}
    <div class="steps-wave">
        <svg data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none">
            <path d="M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z" class="shape-fill"></path>
        </svg>
    </div>

    <div class="steps-container">
        {* Étape 1 : Inscription *}
        <div class="step-item">
            <div class="step-circle">1</div>
            <div class="step-content">
                <strong>Inscription Rapide</strong>
                <p>Connectez-vous simplement et créez votre profil en 2 minutes.</p>
            </div>
        </div>

        <div class="step-connector"></div>

        {* Étape 2 : Recherche/Proposition *}
        <div class="step-item">
            <div class="step-circle">2</div>
            <div class="step-content">
                <strong>Recherchez ou Proposez</strong>
                <p>Indiquez vos horaires de cours et trouvez un covoitureur compatible.</p>
            </div>
        </div>

        <div class="step-connector"></div>

        {* Étape 3 : Trajet *}
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

{* Initialisation des données JS pour l'autocomplétion (lieux fréquents) *}
<script>
    window.lieuxFrequents = [];
    try {
        window.lieuxFrequents = JSON.parse('{$lieux_frequents|default:[]|json_encode|escape:"javascript"}');
    } catch(e) { 
        console.warn("Pas de lieux fréquents chargés"); 
    }
</script>

{* Inclusion du script JS spécifique à la page d'accueil *}
<script src="/sae-covoiturage/public/assets/javascript/accueil/js_accueil.js"></script>