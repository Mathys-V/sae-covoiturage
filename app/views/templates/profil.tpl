<!DOCTYPE html>
<html lang="fr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mon Profil - MonCovoitJV</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <link rel="stylesheet" href="/sae-covoiturage/public/assets/css/style_profil.css">
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
                        {if !empty($user.photo_profil)}<img src="/sae-covoiturage/public/uploads/{$user.photo_profil}"
                            class="avatar-img">{else}<i class="bi bi-person-fill"></i>
                        {/if}
                    </div>
                    <div>
                        <div class="d-flex align-items-center gap-2 justify-content-center justify-content-md-start">
                            <h1 class="fw-bold mb-0">{$user.prenom} {$user.nom}</h1>
                            <i class="bi bi-pencil-fill fs-5 text-secondary" style="cursor:pointer;"
                                title="Modifier"></i>
                        </div>
                        <div class="text-white-50 fs-5">{$user.email}</div>
                        <div class="text-success fw-bold fs-5 mt-1">Profil vérifié <i
                                class="bi bi-check-circle-fill"></i></div>
                        <div class="d-flex align-items-center mt-3 gap-3">

                            <div class="d-flex flex-column gap-1">

                                <div class="d-flex align-items-center">
                                    <span class="fs-5 me-2 text-white">Conducteur :</span>
                                    <div class="text-warning fs-5">
                                        <i class="bi bi-star-fill"></i>
                                        <i class="bi bi-star-fill"></i>
                                        <i class="bi bi-star-fill"></i>
                                        <i class="bi bi-star-fill"></i>
                                        <i class="bi bi-star-half"></i>
                                    </div>
                                </div>

                                <div class="d-flex align-items-center">
                                    <span class="fs-5 me-2 text-white">Passager :</span>
                                    <div class="text-warning fs-5 ms-3">
                                        <i class="bi bi-star-fill"></i>
                                        <i class="bi bi-star-fill"></i>
                                        <i class="bi bi-star-fill"></i>
                                        <i class="bi bi-star-fill"></i>
                                        <i class="bi bi-star"></i>
                                    </div>
                                </div>
                            </div>

                            <a href="/sae-covoiturage/public/profil/avis" class="big-arrow-btn ms-3">
                                <i class="bi bi-chevron-right"></i>
                            </a>

                        </div>


                    </div>
                </div>

                <span class="card-label">Description</span>
                <div class="info-card" id="card-description">
                    <form action="/sae-covoiturage/public/profil/update-description" method="POST">
                        <div class="view-content">
                            <p class="fw-bold fs-5">{if !empty($user.description)}{$user.description}
                                {else}Une personne
                                agréable et plutôt motivée, je serais ravi de passer ce voyage avec vous.{/if}</p>
                            <div class="d-flex justify-content-end mt-4"><button type="button" class="btn-purple"
                                    onclick="toggleEdit('description')">Modifier</button></div>
                        </div>
                        <div class="edit-content edit-mode">
                            <textarea name="description" class="form-control-custom"
                                rows="4">{$user.description|default:''}</textarea>
                            <div class="d-flex justify-content-end mt-3">
                                <button type="button" class="btn-cancel"
                                    onclick="toggleEdit('description')">Annuler</button>
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
                                <div class="d-flex justify-content-end mt-3"><button type="button" class="btn-purple"
                                        onclick="toggleEdit('vehicule')">Modifier</button></div>
                            {else}
                                <p class="fs-5">Aucun véhicule.</p>
                                <div class="d-flex justify-content-end"><button type="button" class="btn-purple"
                                        onclick="toggleEdit('vehicule')">Ajouter</button></div>
                            {/if}
                        </div>
                        <div class="edit-content edit-mode">
                            <div class="row g-3">
                                <div class="col-6"><input type="text" name="marque" class="form-control-custom"
                                        placeholder="Marque" value="{$vehicule.marque|default:''}" required></div>
                                <div class="col-6"><input type="text" name="modele" class="form-control-custom"
                                        placeholder="Modèle" value="{$vehicule.modele|default:''}" required></div>
                                <div class="col-6"><input type="text" name="couleur" class="form-control-custom"
                                        placeholder="Couleur" value="{$vehicule.couleur|default:''}"></div>
                                <div class="col-6"><input type="number" name="nb_places" class="form-control-custom"
                                        placeholder="Places" value="{$vehicule.nb_places_totales|default:''}" min="1"
                                        max="8" required></div>
                                <div class="col-12"><input type="text" name="immat" class="form-control-custom"
                                        placeholder="Immatriculation" value="{$vehicule.immatriculation|default:''}"
                                        required></div>
                            </div>
                            <div class="d-flex justify-content-end mt-3">
                                <button type="button" class="btn-cancel"
                                    onclick="toggleEdit('vehicule')">Annuler</button>
                                <button type="submit" class="btn-purple">Enregistrer</button>
                            </div>
                        </div>
                    </form>
                </div>

                <span class="card-label">Historique des trajets effectués</span>

                {if isset($historique_trajets) && $historique_trajets|@count > 0}

                    {foreach from=$historique_trajets item=trajet}
                        <div class="info-card p-4">
                            <div class="row">
                                <div class="col-md-7 border-end-md">

                                    <h5 class="fw-bold mb-3">Informations du conducteur</h5>
                                    <div class="d-flex align-items-center mb-4">
                                        <div class="avatar-small">
                                            {if isset($trajet.conducteur_photo)}<img src="{$trajet.conducteur_photo}"
                                                class="avatar-img">{else}<i class="bi bi-person-fill"></i>
                                            {/if}
                                        </div>
                                        <div>
                                            <div class="fw-bold fs-5">{$trajet.conducteur_nom|default:'Conducteur Inconnu'}
                                            </div>
                                            <div class="small text-muted">{$trajet.conducteur_age|default:'--'} ans</div>
                                        </div>
                                        <button class="btn-mini-purple ms-3">Noter</button>

<a href="/sae-covoiturage/public/avis/laisser/{$trajet.id_trajet}/{$trajet.id_conducteur}" class="btn-mini-purple ms-3 text-decoration-none">Noter</a>
                                    </div>

                                    <h5 class="fw-bold mb-3">Trajet effectué</h5>
                                    <div class="ps-3 border-start border-3" style="border-color: #8c52ff !important;">
                                        <div class="mb-1">le {$trajet.date|default:'--/--/----'}</div>
                                        <div class="fw-bold">{$trajet.ville_depart|default:'Départ'}</div>
                                        <div class="mb-1"><i class="bi bi-arrow-right-short"></i>
                                            {$trajet.ville_arrivee|default:'Arrivée'}</div>
                                        <div>Départ : {$trajet.heure_depart|default:'--:--'}</div>
                                        <div class="small text-muted mt-1">Durée estimée : {$trajet.duree|default:'--'} minutes
                                        </div>
                                    </div>

                                    <div class="mt-4">
                                        {if isset($trajet.passagers)}
                                            {foreach from=$trajet.passagers item=passager}
                                                <div class="passenger-item">
                                                    <i class="bi bi-person-circle fs-4 me-2 text-secondary"></i>
                                                    <span class="fw-bold me-2">{$passager.prenom}</span>
                                                    <button class="btn-mini-dark me-2">Signaler</button>
                                                    <a href="/sae-covoiturage/public/avis/laisser/{$trajet.id_trajet}/{$passager.id_utilisateur}" class="btn-mini-purple text-decoration-none">Noter</a>

<a href="/sae-covoiturage/public/avis/laisser/{$trajet.id_trajet}/{$passager.id_utilisateur}" class="btn-mini-purple text-decoration-none">Noter</a>
                                                </div>
                                            {/foreach}
                                        {else}
                                            <div class="passenger-item">
                                                <i class="bi bi-person-circle fs-4 me-2 text-secondary"></i>
                                                <span class="fw-bold me-2">Passager 1</span>
                                                <button class="btn-mini-dark me-2">Signaler</button>
                                                <button class="btn-mini-purple">Noter</button>

<a href="/sae-covoiturage/public/avis/laisser/{$trajet.id_trajet}/{$passager.id_utilisateur}" class="btn-mini-purple text-decoration-none">Noter</a>
                                            </div>
                                            <div class="passenger-item">
                                                <i class="bi bi-person-circle fs-4 me-2 text-secondary"></i>
                                                <span class="fw-bold me-2">Passager 2</span>
                                                <button class="btn-mini-dark me-2">Signaler</button>
                                                <button class="btn-mini-purple">Noter</button>

<a href="/sae-covoiturage/public/avis/laisser/{$trajet.id_trajet}/{$passager.id_utilisateur}" class="btn-mini-purple text-decoration-none">Noter</a>
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
                    <a href="/sae-covoiturage/public/profil/gestion_mdp" class="settings-item"><span>Mot de
                            passe</span><i class="bi bi-chevron-right"></i></a>
                    <a href="/sae-covoiturage/public/profil/modifier_adresse" class="settings-item"><span>Adresse
                            postale</span><i class="bi bi-chevron-right"></i></a>
                    <a href="/sae-covoiturage/public/profil/mes_signalements" class="settings-item"><span>Mes
                            signalements</span><i class="bi bi-chevron-right"></i></a>
                    <a href="/sae-covoiturage/public/profil/preferences" class="settings-item"><span>Préférences de
                            communication</span><i class="bi bi-chevron-right"></i></a>
                    <a href="#" class="settings-item"><span>Politique de confidentialité</span><i
                            class="bi bi-chevron-right"></i></a>
                    <a href="/sae-covoiturage/public/deconnexion" class="settings-item"><span>Déconnexion</span><i
                            class="bi bi-chevron-right"></i></a>
                    <a href="#" class="settings-item text-danger-custom"><span>Fermer le compte</span></a>
                </div>
            </div>

        </main>

        {include file='includes/footer.tpl'}
    </div>

    <script src="/sae-covoiturage/public/assets/javascript/js_profil.js"></script>

</body>

</html>