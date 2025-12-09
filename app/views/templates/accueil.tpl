<!doctype html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <title>Accueil - monCovoitJV</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
</head>
<body>
    {include file='includes/header.tpl'}

    <section class="section-heros">
        <img src="assets/img/image-BU-accueil.png" class="img-heros" alt="image-BU" width="auto" height="900px">
        <div class="card mx-auto p-4" style="width: 600px; height : auto;">
            <div class="card-body">
                <h1 class="card-title text-center mb-3">COVOIT</h1>
                <p class="card-text text-center">Covoiturage gratuit pour étudiants de l'IUT d'Amiens.</p>

                <div class="search-system mt-4">
                    <div class="mb-3" style="width: 280px;">
                        <label class="form-label text-start">Départ</label>
                        <input type="text" class="form-control input" placeholder="Adresse de départ">
                    </div>

                    <div class="mb-3" style="width: 280px;">
                        <label class="form-label text-start">Arrivée</label>
                        <input type="text" class="form-control input" placeholder="Adresse d'arrivée">
                    </div>
                </div>
                <div style="text-align: center;">
                    <a href="#" class="btn custom-btn mt-2">Rechercher</a>
                </div>
            </div>
        </div>
    </section>

    <section class="section-detail">
        <h1 style="color: white" class="text-center">Pourquoi choisir monConvoitJV ?</h1>
        <div class="card-grid">
            <div class="card">
                <div class="card-container">
                    <h3><i class="bi bi-car-front-fill">&nbsp;</i>Gratuit et écologique</h3>
                    <p class="text-start">Partager vos trajets gratuitement et réduisez votre empreinte carbonne</p>
                </div>
            </div>
            <div class="card">
                <div class="card-container">
                    <h3><i class="bi bi-people-fill me-2">&nbsp;</i>Entre étudiants</h3>
                    <p class="text-start">Une communauté réservée aux étudiants de l'IUT d'Amiens</p>
                </div>
            </div>   
            <div class="card">
                <div class="card-container">
                    <h3><i class="bi bi-shield-lock-fill me-2">&nbsp;</i>Sécurisé</h3>
                    <p class="text-start">Profils vérifiés et système d'avis pour voyager en confiance</p>
                </div>
            </div>   
            <div class="card">
                <div class="card-container">
                    <h3><i class="bi bi-clock-fill me-2">&nbsp;</i>Flexible</h3>
                    <p class="text-start">Trouvez ou proposez des trajets selon votre emploi du temps</p>
                </div>
            </div>                      
        </div>
    </section>

    {include file='includes/footer.tpl'}
</body>

<style>
    body {
        background-color: #452b85;
    }

    /* section-heros */
    .section-heros {
        display: flex;
        justify-content: center;
        align-items: center;
        width: 100%;
        height: 100%;
        margin : 0px;
    }

    .search-system {
        display: flex;
        justify-content: center;
        align-items: center;
        align-content: center;
        gap: 50px;
    }

    label {
        background-color:#8c52ff;
        color:white;
        padding: 5px 15px;
        border-radius: 10px;
    }

    .custom-btn {
        background-color:#8c52ff;
        color: white;
    }

    .custom-btn:hover {
        background-color:#452b85;
        color: white;
    }

    p {
        font-size: large;
    }

    .input {
        border: 2px solid #8c52ff;
        border-radius: 10px;
    }

    /* section-detail */
    .section-detail {
        background-color: #452b85;
        padding: 150px 100px;
    }

    .section-detail h1 {
        color: white;
        margin-bottom: 80px;
    }

    .card-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 50px;
        max-width: 1100px;
        margin: 0 auto;
    }

    /* card */
    .section-detail .card {
        background-color: white;
        padding: 40px 30px;
        border-radius: 20px;
        text-align: center;
        box-shadow: 0 10px 30px rgba(0,0,0,0.15);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .section-detail .card:hover {
        transform: translateY(-8px);
        box-shadow: 0 20px 40px rgba(0,0,0,0.25);
    }

    .section-detail h3 {
        margin-bottom: 15px;
        font-weight: bold;
    }

    /* Responsive */
    @media (max-width: 1200px) {
    .section-heros {
        flex-direction: column;
        padding: 60px 20px;
    }

    .img-heros {
        display: none;
    }

    .section-heros .card {
        width: 100% !important;
        max-width: 500px;
    }

    .search-system {
        gap: 20px;
    }
    }

    @media (max-width: 768px) {

    .card-grid {
        grid-template-columns: 1fr;
    }

    .section-prom {
        padding: 100px 30px;
    }
    }

    @media (max-width: 576px) {
    .search-system > div {
        width: 100% !important;
    }

    label {
        display: inline-block;
        margin-bottom: 5px;
    }
    }

</style>
</html>
