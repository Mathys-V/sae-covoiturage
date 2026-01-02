<!DOCTYPE html>
<html lang="fr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes Avis - MonCovoitJV</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <link rel="stylesheet" href="/sae-covoiturage/public/assets/css/avis/style_avis.css">
</head>

<body>
    <div class="page-wrapper">

        {include file='includes/header.tpl'}

        <main class="container my-5" style="max-width: 900px;">

            <div class="d-flex align-items-center mb-4">
                <a href="/sae-covoiturage/public/profil" class="btn btn-outline-secondary me-3">
                    <i class="bi bi-arrow-left"></i> Retour
                </a>
                <h2 class="fw-bold mb-0">Avis reçus</h2>
            </div>

            <div class="custom-tabs">
                <button class="tab-btn active" onclick="switchTab('cond')" id="btn-cond">
                    <i class="bi bi-person-badge-fill d-block fs-3 mb-1"></i>
                    Conducteur
                </button>
                <button class="tab-btn" onclick="switchTab('pass')" id="btn-pass">
                    <i class="bi bi-person-fill d-block fs-3 mb-1"></i>
                    Passager
                </button>
            </div>

            <div class="content-box">

                <div id="view-cond">
                    <div class="text-center mb-5">
                        <div class="display-4 fw-bold text-primary">{$moy_cond}<span class="fs-4 text-muted">/5</span></div>
                        <div class="text-warning fs-3 mb-2">
                            {section name=i loop=5}
                                {if $smarty.section.i.index < $moy_cond}<i class="bi bi-star-fill"></i>{else}<i class="bi bi-star"></i>{/if}
                            {/section}
                        </div>
                        <div class="text-muted">Basé sur {$nb_cond} avis conducteur</div>
                    </div>

                    <div class="row g-3">
                        {if $nb_cond > 0}
                            {foreach from=$avis_cond item=avis}
                                <div class="col-12 col-md-6">
                                    <div class="card p-3 border-0 shadow-sm h-100 bg-light">
                                        <div class="d-flex">
                                            <div class="me-3">
                                                {if !empty($avis.photo_profil)}
                                                    <img src="/sae-covoiturage/public/uploads/{$avis.photo_profil}"
                                                        class="rounded-circle"
                                                        style="width: 50px; height: 50px; object-fit: cover;">
                                                {else}
                                                    <img src="/sae-covoiturage/public/assets/img/default.png" class="rounded-circle"
                                                        style="width: 50px; height: 50px; object-fit: cover;">
                                                {/if}
                                            </div>
                                            <div class="flex-grow-1">
                                                <div class="d-flex justify-content-between align-items-start">
                                                    <h6 class="fw-bold mb-1">{$avis.prenom} {$avis.nom}</h6>
                                                    <small class="text-muted">{$avis.date_avis|date_format:"%d/%m/%Y"}</small>
                                                </div>
                                                <div class="text-warning mb-2" style="font-size: 0.8rem;">
                                                    {section name=star loop=5}
                                                        {if $smarty.section.star.index < $avis.note}<i class="bi bi-star-fill"></i>{else}<i class="bi bi-star"></i>{/if}
                                                    {/section}
                                                </div>
                                                <p class="mb-0 text-secondary small">{$avis.commentaire|nl2br}</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            {/foreach}
                        {else}
                            <div class="col-12">
                                <div class="alert alert-light text-center border">
                                    <i class="bi bi-car-front d-block fs-2 mb-2 text-muted"></i>
                                    Aucun avis en tant que conducteur.
                                </div>
                            </div>
                        {/if}
                    </div>
                </div>

                <div id="view-pass" style="display: none;">
                    <div class="text-center mb-5">
                        <div class="display-4 fw-bold text-primary">{$moy_pass}<span class="fs-4 text-muted">/5</span></div>
                        <div class="text-warning fs-3 mb-2">
                            {section name=i loop=5}
                                {if $smarty.section.i.index < $moy_pass}<i class="bi bi-star-fill"></i>{else}<i class="bi bi-star"></i>{/if}
                            {/section}
                        </div>
                        <div class="text-muted">Basé sur {$nb_pass} avis passager</div>
                    </div>

                    <div class="row g-3">
                        {if $nb_pass > 0}
                            {foreach from=$avis_pass item=avis}
                                <div class="col-12 col-md-6">
                                    <div class="card p-3 border-0 shadow-sm h-100 bg-light">
                                        <div class="d-flex">
                                            <div class="me-3">
                                                {if !empty($avis.photo_profil)}
                                                    <img src="/sae-covoiturage/public/uploads/{$avis.photo_profil}"
                                                        class="rounded-circle"
                                                        style="width: 50px; height: 50px; object-fit: cover;">
                                                {else}
                                                    <img src="/sae-covoiturage/public/assets/img/default.png" class="rounded-circle"
                                                        style="width: 50px; height: 50px; object-fit: cover;">
                                                {/if}
                                            </div>
                                            <div class="flex-grow-1">
                                                <div class="d-flex justify-content-between align-items-start">
                                                    <h6 class="fw-bold mb-1">{$avis.prenom} {$avis.nom}</h6>
                                                    <small class="text-muted">{$avis.date_avis|date_format:"%d/%m/%Y"}</small>
                                                </div>
                                                <div class="text-warning mb-2" style="font-size: 0.8rem;">
                                                    {section name=star loop=5}
                                                        {if $smarty.section.star.index < $avis.note}<i class="bi bi-star-fill"></i>{else}<i class="bi bi-star"></i>{/if}
                                                    {/section}
                                                </div>
                                                <p class="mb-0 text-secondary small">{$avis.commentaire|nl2br}</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            {/foreach}
                        {else}
                            <div class="col-12">
                                <div class="alert alert-light text-center border">
                                    <i class="bi bi-person-fill d-block fs-1 mb-3 text-secondary"></i>
                                    Aucun avis en tant que passager.
                                </div>
                            </div>
                        {/if}
                    </div>
                </div>

            </div>

        </main>

        {include file='includes/footer.tpl'}
    </div>

    <script>
        function switchTab(type) {
            document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
            document.getElementById('btn-' + type).classList.add('active');
            document.getElementById('view-cond').style.display = 'none';
            document.getElementById('view-pass').style.display = 'none';
            
            const targetView = document.getElementById('view-' + type);
            targetView.style.display = 'block';
            targetView.style.opacity = '0';
            setTimeout(() => {
                targetView.style.transition = 'opacity 0.3s ease';
                targetView.style.opacity = '1';
            }, 10);
        }
    </script>
</body>
</html>