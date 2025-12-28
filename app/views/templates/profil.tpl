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
            background-color: #463077 !important;
            color: white !important;
        }
        .page-wrapper { display: flex; flex-direction: column; min-height: 100vh; }
        .main-content { flex: 1; width: 100%; max-width: 800px; margin: 0 auto; padding: 20px; }

        /* --- NAVIGATION ONGLETS --- */
        .tabs-container { display: flex; width: 100%; max-width: 800px; margin: 20px auto 0; }
        .tab {
            flex: 1; padding: 15px; text-align: center; font-size: 2rem; font-weight: bold; cursor: pointer;
            border-top-left-radius: 20px; border-top-right-radius: 20px; transition: all 0.2s;
        }
        .tab-active { background-color: #463077; color: white; position: relative; z-index: 2; }
        .tab-inactive { background-color: #9370DB; color: rgba(255,255,255,0.7); }
        .tab-inactive:hover { background-color: #8A2BE2; color: white; }

        /* --- HEADER PROFIL --- */
        .profile-header { display: flex; align-items: center; gap: 30px; margin-top: 30px; margin-bottom: 40px; }
        .avatar-circle {
            width: 130px; height: 130px; background-color: #8c52ff; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 4rem; color: white; overflow: hidden; border: 4px solid #7B61FF;
        }
        .avatar-img { width: 100%; height: 100%; object-fit: cover; }
        .stars { color: #FFD700; font-size: 1.5rem; margin: 0 10px; }
        .chevron-link { color: white; font-size: 1.5rem; cursor: pointer; }

        /* --- CARTES INFO --- */
        .info-card {
            background-color: #EBE6F5; color: black !important; border-radius: 30px;
            padding: 30px; margin-bottom: 30px; box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }
        .card-label {
            color: white; font-weight: 600; font-size: 1.1rem; margin-left: 20px; margin-bottom: 10px;
            display: block; border-bottom: 1px solid rgba(255,255,255,0.3); padding-bottom: 5px; width: fit-content;
        }

        /* --- BOUTONS --- */
        .btn-purple {
            background-color: #8c52ff; color: white; border: none; padding: 10px 25px;
            border-radius: 50px; font-weight: 600; transition: 0.3s;
        }
        .btn-purple:hover { background-color: #703ccf; color: white; }
        .btn-cancel {
            background-color: #9370DB; color: white; border: none; padding: 10px 25px;
            border-radius: 50px; font-weight: 600; margin-right: 10px;
        }
        .btn-cancel:hover { background-color: #8060c0; }

        /* --- NOUVEAUX STYLES POUR L'HISTORIQUE --- */
        .avatar-small {
            width: 60px; height: 60px; background-color: #8c52ff; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem; color: white; overflow: hidden; margin-right: 15px;
        }
        .btn-mini-purple {
            background-color: #8c52ff; color: white; border: none; border-radius: 50px;
            padding: 4px 15px; font-size: 0.85rem; font-weight: 600;
        }
        .btn-mini-dark {
            background-color: #463077; color: white; border: none; border-radius: 50px;
            padding: 4px 15px; font-size: 0.85rem; font-weight: 600;
        }
        .passenger-item { display: flex; align-items: center; margin-bottom: 8px; }
        .see-more-btn {
            background-color: #8c52ff; color: white; border: none; padding: 8px 30px;
            border-radius: 50px; font-weight: 600; display: block; margin: 0 auto;
        }

        /* Formulaires & Listes */
        .edit-mode { display: none; }
        .form-control-custom { width: 100%; padding: 10px; border-radius: 15px; border: 1px solid #ccc; background-color: white; color: black; margin-bottom: 10px; }
        .settings-list { list-style: none; padding: 0; margin-top: 20px; }
        .settings-item {
            display: flex; justify-content: space-between; align-items: center; padding: 20px 0;
            border-bottom: 2px solid #7B61FF; color: white; text-decoration: none; font-size: 1.4rem; font-weight: 500; cursor: pointer;
        }
        .settings-item:hover { padding-left: 10px; color: #E0D4FF; }
        .text-danger-custom { color: #FF6B6B !important; border-bottom: none; margin-top: 20px; }

        @media (max-width: 768px) {
            .profile-header { flex-direction: column; text-align: center; }
            .tab { font-size: 1.5rem; }
            .border-end-md { border-right: none !important; border-bottom: 1px solid #ccc; padding-bottom: 20px; margin-bottom: 20px; }
        }
        @media (min-width: 769px) {
            .border-end-md { border-right: 2px solid #d1d1d1; }
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
                    {if !empty($user.photo_profil)}<img src="/sae-covoiturage/public/uploads/{$user.photo_profil}" class="avatar-img">{else}<i class="bi bi-person-fill"></i>{/if}
                </div>
                <div>
                    <div class="d-flex align-items-center gap-2 justify-content-center justify-content-md-start">
                        <h1 class="fw-bold mb-0">{$user.prenom} {$user.nom}</h1>
                        <i class="bi bi-pencil-fill fs-5 text-secondary" style="cursor:pointer;" title="Modifier"></i>
                    </div>
                    <div class="text-white-50 fs-5">{$user.email}</div>
                    <div class="text-success fw-bold fs-5 mt-1">Profil vérifié <i class="bi bi-check-circle-fill"></i></div>
                    <div class="d-flex align-items-center mt-2 justify-content-center justify-content-md-start">
                        <span class="fw-bold fs-4">Notes</span>
                        <div class="stars"><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star"></i><i class="bi bi-star"></i></div>
                        <i class="bi bi-chevron-right chevron-link"></i>
                    </div>
                </div>
            </div>

            <span class="card-label">Description</span>
            <div class="info-card" id="card-description">
                <form action="/sae-covoiturage/public/profil/update-description" method="POST">
                    <div class="view-content">
                        <p class="fw-bold fs-5">{if !empty($user.description)}{$user.description}{else}Une personne agréable et plutôt motivée, je serais ravi de passer ce voyage avec vous.{/if}</p>
                        <div class="d-flex justify-content-end mt-4"><button type="button" class="btn-purple" onclick="toggleEdit('description')">Modifier</button></div>
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
                            <div class="d-flex justify-content-end mt-3"><button type="button" class="btn-purple" onclick="toggleEdit('vehicule')">Modifier</button></div>
                        {else}
                            <p class="fs-5">Aucun véhicule.</p>
                            <div class="d-flex justify-content-end"><button type="button" class="btn-purple" onclick="toggleEdit('vehicule')">Ajouter</button></div>
                        {/if}
                    </div>
                    <div class="edit-content edit-mode">
                        <div class="row g-3">
                            <div class="col-6"><input type="text" name="marque" class="form-control-custom" placeholder="Marque" value="{$vehicule.marque|default:''}" required></div>
                            <div class="col-6"><input type="text" name="modele" class="form-control-custom" placeholder="Modèle" value="{$vehicule.modele|default:''}" required></div>
                            <div class="col-6"><input type="text" name="couleur" class="form-control-custom" placeholder="Couleur" value="{$vehicule.couleur|default:''}"></div>
                            <div class="col-6"><input type="number" name="nb_places" class="form-control-custom" placeholder="Places" value="{$vehicule.nb_places_totales|default:''}" min="1" max="8" required></div>
                            <div class="col-12"><input type="text" name="immat" class="form-control-custom" placeholder="Immatriculation" value="{$vehicule.immatriculation|default:''}" required></div>
                        </div>
                        <div class="d-flex justify-content-end mt-3">
                            <button type="button" class="btn-cancel" onclick="toggleEdit('vehicule')">Annuler</button>
                            <button type="submit" class="btn-purple">Enregistrer</button>
                        </div>
                    </div>
                </form>
            </div>

            <span class="card-label">Historique des trajets effectués</span>
            
            {* Vérifie si la variable existe et contient des données *}
            {if isset($historique_trajets) && $historique_trajets|@count > 0}
                
                {foreach from=$historique_trajets item=trajet}
                <div class="info-card p-4">
                    <div class="row">
                        <div class="col-md-7 border-end-md">
                            
                            <h5 class="fw-bold mb-3">Informations du conducteur</h5>
                            <div class="d-flex align-items-center mb-4">
                                <div class="avatar-small">
                                    {if isset($trajet.conducteur_photo)}<img src="{$trajet.conducteur_photo}" class="avatar-img">{else}<i class="bi bi-person-fill"></i>{/if}
                                </div>
                                <div>
                                    <div class="fw-bold fs-5">{$trajet.conducteur_nom|default:'Conducteur Inconnu'}</div>
                                    <div class="small text-muted">{$trajet.conducteur_age|default:'--'} ans</div>
                                </div>
                                <button class="btn-mini-purple ms-3">Noter</button>
                            </div>

                            <h5 class="fw-bold mb-3">Trajet effectué</h5>
                            <div class="ps-3 border-start border-3" style="border-color: #8c52ff !important;">
                                <div class="mb-1">le {$trajet.date|default:'--/--/----'}</div>
                                <div class="fw-bold">{$trajet.ville_depart|default:'Départ'}</div>
                                <div class="mb-1"><i class="bi bi-arrow-right-short"></i> {$trajet.ville_arrivee|default:'Arrivée'}</div>
                                <div>Départ : {$trajet.heure_depart|default:'--:--'}</div>
                                <div class="small text-muted mt-1">Durée estimée : {$trajet.duree|default:'--'} minutes</div>
                            </div>
                            
                            <div class="mt-4">
                                {if isset($trajet.passagers)}
                                    {foreach from=$trajet.passagers item=passager}
                                    <div class="passenger-item">
                                        <i class="bi bi-person-circle fs-4 me-2 text-secondary"></i>
                                        <span class="fw-bold me-2">{$passager.prenom}</span>
                                        <button class="btn-mini-dark me-2">Signaler</button>
                                        <button class="btn-mini-purple">Noter</button>
                                    </div>
                                    {/foreach}
                                {else}
                                    <div class="passenger-item">
                                        <i class="bi bi-person-circle fs-4 me-2 text-secondary"></i>
                                        <span class="fw-bold me-2">Passager 1</span>
                                        <button class="btn-mini-dark me-2">Signaler</button>
                                        <button class="btn-mini-purple">Noter</button>
                                    </div>
                                    <div class="passenger-item">
                                        <i class="bi bi-person-circle fs-4 me-2 text-secondary"></i>
                                        <span class="fw-bold me-2">Passager 2</span>
                                        <button class="btn-mini-dark me-2">Signaler</button>
                                        <button class="btn-mini-purple">Noter</button>
                                    </div>
                                {/if}
                            </div>
                        </div>

                        <div class="col-md-5 d-flex flex-column justify-content-between">
                            <div>
                                <h5 class="fw-bold mb-3">Informations véhicule</h5>
                                <div class="fs-6">
                                    <div>{$trajet.vehicule_places|default:'4'} places disponibles</div>
                                    <div class="text-muted">{$trajet.vehicule_modele|default:'Véhicule standard'}</div>
                                </div>
                            </div>

                            <div class="mt-4 text-end">
                                <button class="btn btn-purple w-100 py-2 rounded-pill">Discussion de groupe</button>
                            </div>
                        </div>
                    </div>
                </div>
                {/foreach}

                <div class="text-center mb-4">
                    <button class="see-more-btn">Voir plus</button>
                </div>

            {else}
                <div class="info-card">
                    <p class="fs-5 text-center mb-0 fw-bold py-4">
                        <i class="bi bi-car-front fs-1 d-block mb-3 text-secondary"></i>
                        Aucun trajet effectué pour le moment.
                    </p>
                </div>
            {/if}
            </div>

        <div id="section-parametres" style="display:none;">
            <div class="settings-list">
                <a href="#" class="settings-item"><span>Avis</span><i class="bi bi-chevron-right"></i></a>
                <a href="/sae-covoiturage/public/profil/gestion_mdp" class="settings-item"><span>Mot de passe</span><i class="bi bi-chevron-right"></i></a>
                <a href="/sae-covoiturage/public/profil/modifier_adresse" class="settings-item"><span>Adresse postale</span><i class="bi bi-chevron-right"></i></a>
                <a href="/sae-covoiturage/public/profil/preferences" class="settings-item"><span>Préférences de communication</span><i class="bi bi-chevron-right"></i></a>
                <a href="#" class="settings-item"><span>Politique de confidentialité</span><i class="bi bi-chevron-right"></i></a>
                <a href="/sae-covoiturage/public/deconnexion" class="settings-item"><span>Déconnexion</span><i class="bi bi-chevron-right"></i></a>
                <a href="#" class="settings-item text-danger-custom"><span>Fermer le compte</span></a>
            </div>
        </div>

    </main>

    {include file='includes/footer.tpl'}
</div>

<script>
    function switchTab(tabName) {
        const tabCompte = document.getElementById('tab-compte');
        const tabParams = document.getElementById('tab-parametres');
        const sectCompte = document.getElementById('section-compte');
        const sectParams = document.getElementById('section-parametres');
        const headerProfil = document.querySelector('.profile-header');

        if (tabName === 'compte') {
            tabCompte.className = 'tab tab-active'; tabParams.className = 'tab tab-inactive';
            sectCompte.style.display = 'block'; sectParams.style.display = 'none';
            if(headerProfil) headerProfil.style.display = 'flex';
        } else {
            tabCompte.className = 'tab tab-inactive'; tabParams.className = 'tab tab-active';
            sectCompte.style.display = 'none'; sectParams.style.display = 'block';
            if(headerProfil) headerProfil.style.display = 'none';
        }
    }
    function toggleEdit(id) {
        let card = document.getElementById('card-' + id);
        let view = card.querySelector('.view-content'); let edit = card.querySelector('.edit-content');
        if (edit.style.display === 'block') { edit.style.display = 'none'; view.style.display = 'block'; }
        else { edit.style.display = 'block'; view.style.display = 'none'; }
    }
</script>

</body>
</html>