<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mon Profil - MonCovoitJV</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <style>
        /* --- CONFIGURATION GLOBALE --- */
        html, body {
            margin: 0; padding: 0; width: 100%; height: 100%;
            font-family: 'Segoe UI', system-ui, sans-serif;
            background-color: #463077 !important; /* Violet Foncé (Fond page) */
            color: white !important;
        }
        .page-wrapper { display: flex; flex-direction: column; min-height: 100vh; }
        .main-content { flex: 1; width: 100%; max-width: 800px; margin: 0 auto; padding: 20px; }

        /* --- NAVIGATION ONGLETS (TABS) --- */
        .tabs-container {
            display: flex; width: 100%; max-width: 800px; margin: 0 auto;
            margin-top: 20px;
        }
        .tab {
            flex: 1; padding: 15px; text-align: center;
            font-size: 2rem; font-weight: bold; cursor: pointer;
            border-top-left-radius: 20px; border-top-right-radius: 20px;
            transition: all 0.2s;
        }
        /* Onglet Actif : Même couleur que le fond pour fondre */
        .tab-active {
            background-color: #463077; 
            color: white;
            position: relative; z-index: 2;
        }
        /* Onglet Inactif : Violet clair pour contraster */
        .tab-inactive {
            background-color: #9370DB; /* Couleur lavande/violet clair */
            color: rgba(255,255,255,0.7);
        }
        .tab-inactive:hover { background-color: #8A2BE2; color: white; }

        /* --- HEADER PROFIL (Avatar + Infos) --- */
        .profile-header { display: flex; align-items: center; gap: 30px; margin-top: 30px; margin-bottom: 40px; }
        
        .avatar-circle {
            width: 130px; height: 130px;
            background-color: #8c52ff; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 4rem; color: white; overflow: hidden;
            border: 4px solid #7B61FF; /* Bordure violette autour de l'avatar */
        }
        .avatar-img { width: 100%; height: 100%; object-fit: cover; }
        
        /* Correction des étoiles (Notes) */
        .stars { color: #FFD700; font-size: 1.5rem; margin: 0 10px; } /* Or jaune */
        .chevron-link { color: white; font-size: 1.5rem; cursor: pointer; }

        /* --- CARTES INFO (Description/Véhicule) --- */
        .info-card {
            background-color: #EBE6F5; /* Violet très pâle (presque blanc) */
            color: black !important;
            border-radius: 30px;
            padding: 30px; margin-bottom: 30px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }
        .card-label {
            color: white; font-weight: 600; font-size: 1.1rem;
            margin-left: 20px; margin-bottom: 10px; display: block;
            border-bottom: 1px solid rgba(255,255,255,0.3); padding-bottom: 5px; width: fit-content;
        }

        /* --- LISTE PARAMÈTRES (Nouveau Design) --- */
        .settings-list {
            list-style: none; padding: 0; margin-top: 20px;
        }
        .settings-item {
            display: flex; justify-content: space-between; align-items: center;
            padding: 20px 0;
            border-bottom: 2px solid #7B61FF; /* Ligne de séparation violette */
            color: white; text-decoration: none; font-size: 1.4rem; font-weight: 500;
            transition: padding-left 0.2s; cursor: pointer;
        }
        .settings-item:hover { padding-left: 10px; color: #E0D4FF; }
        .settings-item i { font-size: 1.5rem; }
        
        /* Lien rouge pour "Fermer le compte" */
        .text-danger-custom { color: #FF6B6B !important; border-bottom: none; margin-top: 20px; }
        .text-danger-custom:hover { color: #FF4444 !important; }

        /* --- BOUTONS --- */
        .btn-purple {
            background-color: #8c52ff; color: white; border: none;
            padding: 10px 25px; border-radius: 50px; font-weight: 600;
            transition: 0.3s;
        }
        .btn-purple:hover { background-color: #703ccf; color: white; }
        
        .btn-cancel {
            background-color: #9370DB; color: white; border: none;
            padding: 10px 25px; border-radius: 50px; font-weight: 600; margin-right: 10px;
        }
        .btn-cancel:hover { background-color: #8060c0; }

        /* Formulaires */
        .edit-mode { display: none; }
        .form-control-custom {
            width: 100%; padding: 10px; border-radius: 15px; border: 1px solid #ccc;
            background-color: white; color: black; margin-bottom: 10px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .profile-header { flex-direction: column; text-align: center; }
            .tab { font-size: 1.5rem; }
        }
    </style>
</head>

<body>
<div class="page-wrapper">
    
    {include file='includes/header.tpl'}

    <div class="tabs-container">
        <div id="tab-compte" class="tab tab-active" onclick="switchTab('compte')">Compte</div>
        <div id="tab-parametres" class="tab tab-inactive" onclick="switchTab('parametres')">Paramètres</div>
    </div>

    <main class="main-content">
        
        <div id="section-compte">
            
            <div class="profile-header">
                <div class="avatar-circle">
                    {if !empty($user.photo_profil)}
                        <img src="/sae-covoiturage/public/uploads/{$user.photo_profil}" class="avatar-img">
                    {else}
                        <i class="bi bi-person-fill"></i>
                    {/if}
                </div>
                <div>
                    <div class="d-flex align-items-center gap-2 justify-content-center justify-content-md-start">
                        <h1 class="fw-bold mb-0">{$user.prenom} {$user.nom}</h1>
                        <i class="bi bi-pencil-fill fs-5 text-secondary" style="cursor:pointer;" title="Modifier"></i>
                    </div>
                    
                    <div class="text-white-50 fs-5">{$user.email}</div>
                    
                    <div class="text-success fw-bold fs-5 mt-1">
                        Profil vérifié <i class="bi bi-check-circle-fill"></i>
                    </div>

                    <div class="d-flex align-items-center mt-2 justify-content-center justify-content-md-start">
                        <span class="fw-bold fs-4">Notes</span>
                        <div class="stars">
                            <i class="bi bi-star-fill"></i>
                            <i class="bi bi-star-fill"></i>
                            <i class="bi bi-star-fill"></i>
                            <i class="bi bi-star"></i> <i class="bi bi-star"></i>
                        </div>
                        <i class="bi bi-chevron-right chevron-link"></i>
                    </div>
                </div>
            </div>

            <span class="card-label">Description</span>
            <div class="info-card" id="card-description">
                <form action="/sae-covoiturage/public/profil/update-description" method="POST">
                    <div class="view-content">
                        <p class="fw-bold fs-5">
                            {if !empty($user.description)}{$user.description}{else}Une personne agréable et plutôt motivée, je serais ravi de passer ce voyage avec vous.{/if}
                        </p>
                        <div class="d-flex justify-content-end mt-4">
                            <button type="button" class="btn-purple" onclick="toggleEdit('description')">Modifier</button>
                        </div>
                    </div>
                    
                    <div class="edit-content edit-mode">
                        <textarea name="description" class="form-control-custom" rows="4">{$user.description|default:''}</textarea>
                        <div class="d-flex justify-content-end mt-3">
                            <button type="button" class="btn-cancel" onclick="toggleEdit('description')">Annuler</button>
                            <button type="submit" class="btn-purple">Enregistrer</button>
                        </div>
                    </div>
                </form>
            </div>

            <span class="card-label">Véhicule</span>
            <div class="info-card" id="card-vehicule">
                <form action="/sae-covoiturage/public/profil/update-vehicule" method="POST">
                    <div class="view-content">
                        {if isset($vehicule)}
                            <div class="fs-5 lh-lg">
                                <strong>Marque :</strong> {$vehicule.marque}<br>
                                <strong>Modèle :</strong> {$vehicule.modele}<br>
                                <strong>Couleur :</strong> {$vehicule.couleur}<br>
                                <strong>Nombre de places :</strong> {$vehicule.nb_places_totales}<br>
                                <strong>Immatriculation :</strong> {$vehicule.immatriculation}
                            </div>
                            <div class="d-flex justify-content-end mt-3">
                                <button type="button" class="btn-purple" onclick="toggleEdit('vehicule')">Modifier</button>
                            </div>
                        {else}
                            <p class="fs-5">Aucun véhicule.</p>
                            <div class="d-flex justify-content-end">
                                <button type="button" class="btn-purple" onclick="toggleEdit('vehicule')">Ajouter</button>
                            </div>
                        {/if}
                    </div>

                    <div class="edit-content edit-mode">
                        <div class="row g-3">
                            <div class="col-6"><input type="text" name="marque" class="form-control-custom" placeholder="Marque" value="{$vehicule.marque|default:''}" required></div>
                            <div class="col-6"><input type="text" name="modele" class="form-control-custom" placeholder="Modèle" value="{$vehicule.modele|default:''}" required></div>
                            <div class="col-6"><input type="text" name="couleur" class="form-control-custom" placeholder="Couleur" value="{$vehicule.couleur|default:''}"></div>
                            <div class="col-6"><input type="number" name="nb_places" class="form-control-custom" placeholder="Places" value="{$vehicule.nb_places_totales|default:''}" required></div>
                            <div class="col-12"><input type="text" name="immat" class="form-control-custom" placeholder="Immatriculation" value="{$vehicule.immatriculation|default:''}" required></div>
                        </div>
                        <div class="d-flex justify-content-end mt-3">
                            <button type="button" class="btn-cancel" onclick="toggleEdit('vehicule')">Annuler</button>
                            <button type="submit" class="btn-purple">Enregistrer</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <div id="section-parametres" style="display:none;">
            <div class="settings-list">
                <a href="#" class="settings-item">
                    <span>Avis</span>
                    <i class="bi bi-chevron-right"></i>
                </a>
                
                <a href="/sae-covoiturage/public/profil/gestion_mdp" class="settings-item">
                    <span>Mot de passe</span>
                    <i class="bi bi-chevron-right"></i>
                </a>

                <a href="/sae-covoiturage/public/profil/modifier_adresse" class="settings-item">
                    <span>Adresse postale</span>
                    <i class="bi bi-chevron-right"></i>
                </a>

                <a href="/sae-covoiturage/public/profil/preferences" class="settings-item">
                    <span>Préférences de communication</span>
                    <i class="bi bi-chevron-right"></i>
                </a>

                <a href="#" class="settings-item">
                    <span>Politique de confidentialité</span>
                    <i class="bi bi-chevron-right"></i>
                </a>

                <a href="/sae-covoiturage/public/deconnexion" class="settings-item">
                    <span>Déconnexion</span>
                    <i class="bi bi-chevron-right"></i>
                </a>

                <a href="#" class="settings-item text-danger-custom">
                    <span>Fermer le compte</span>
                </a>
            </div>
        </div>

    </main>

    {include file='includes/footer.tpl'}
</div>

<script>
    // 1. GESTION DES ONGLETS
    function switchTab(tabName) {
        // Classes pour les onglets
        const tabCompte = document.getElementById('tab-compte');
        const tabParams = document.getElementById('tab-parametres');
        const sectCompte = document.getElementById('section-compte');
        const sectParams = document.getElementById('section-parametres');
        
        // Header du profil (Avatar...) : 
        // Sur ta maquette Paramètres, on ne voit pas l'avatar. 
        // On va donc le masquer quand on est sur Paramètres.
        const headerProfil = document.querySelector('.profile-header');

        if (tabName === 'compte') {
            tabCompte.className = 'tab tab-active';
            tabParams.className = 'tab tab-inactive';
            sectCompte.style.display = 'block';
            sectParams.style.display = 'none';
            if(headerProfil) headerProfil.style.display = 'flex'; // Afficher avatar
        } else {
            tabCompte.className = 'tab tab-inactive';
            tabParams.className = 'tab tab-active';
            sectCompte.style.display = 'none';
            sectParams.style.display = 'block';
            if(headerProfil) headerProfil.style.display = 'none'; // Masquer avatar
        }
    }

    // 2. GESTION DU MODE ÉDITION
    function toggleEdit(id) {
        let card = document.getElementById('card-' + id);
        let view = card.querySelector('.view-content');
        let edit = card.querySelector('.edit-content');
        
        if (edit.style.display === 'block') {
            edit.style.display = 'none';
            view.style.display = 'block';
        } else {
            edit.style.display = 'block';
            view.style.display = 'none';
        }
    }
</script>

</body>
</html>