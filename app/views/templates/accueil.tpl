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
        <img src="assets/img/image-BU-accueil.png" alt="image-BU" width="auto" height="900px">
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

    h1 {
        font-weight: bold;
        font-size: 3em;
        color: white;
    }

    .input {
        border: 2px solid #8c52ff;
        border-radius: 10px;
    }
</style>
</html>
