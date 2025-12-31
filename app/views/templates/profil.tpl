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
                    <form id="form-photo" action="/sae-covoiturage/public/profil/update-photo" method="POST"
                        enctype="multipart/form-data" style="display:none;">
                        <input type="file" name="photo_profil" id="input-photo"
                            accept="image/png, image/jpeg, image/jpg, image/webp"
                            onchange="document.getElementById('form-photo').submit();">
                    </form>

                    <div class="avatar-circle" onclick="document.getElementById('input-photo').click();">
                        {if !empty($user.photo_profil)}
                            <img src="/sae-covoiturage/public/uploads/{$user.photo_profil}?t={$smarty.now}"
                                class="avatar-img">
                        {else}
                            <div class="default-avatar">
                                <i class="bi bi-person-fill"></i>
                            </div>
                        {/if}
                    </div>
                    <div class="ms-md-4 text-center text-md-start flex-grow-1">
                        <div class="d-flex align-items-center gap-2 justify-content-center justify-content-md-start">
                            <h1 class="fw-bold mb-0">{$user.prenom} {$user.nom}</h1>

                            <i class="bi bi-pencil-fill fs-5 text-secondary" style="cursor:pointer;"
                                title="Modifier la photo" onclick="document.getElementById('input-photo').click();">
                            </i>
                        </div>
                        <div class="text-white-50 fs-5">{$user.email}</div>

                        {if isset($user.verified_flag) && $user.verified_flag == 'Y'}
                            <div class="text-success fw-bold fs-5 mt-1">
                                Profil vérifié <i class="bi bi-check-circle-fill"></i>
                            </div>
                        {else}
                            <div class="mt-2">
                                <span class="badge bg-secondary opacity-75 fw-normal" style="cursor:help;" 
                                      title="Recevez au moins un avis positif pour faire vérifier votre profil.">
                                    Profil non vérifié <i class="bi bi-info-circle ms-1"></i>
                                </span>
                                <div class="small text-white-50 mt-1 fst-italic" style="font-size: 0.8rem;">
                                    Obtenez un premier avis pour certifier votre profil.
                                </div>
                            </div>
                        {/if}

                        <div class="d-flex flex-column align-items-center align-items-md-start mt-3 gap-2">

                            <div class="d-flex align-items-center gap-2">
                                <span class="text-white-50 small text-uppercase fw-bold" style="width: 90px; text-align:left;">Conducteur</span>
                                <div class="text-warning fs-5 d-flex align-items-center">
                                    {$noteC = $user.note_conducteur|default:0}
                                    {for $i=1 to 5}
                                        {if $noteC >= $i}<i class="bi bi-star-fill"></i>
                                        {elseif $noteC > ($i - 1)}<i class="bi bi-star-half"></i>
                                        {else}<i class="bi bi-star"></i>{/if}
                                    {/for}
                                    {if $noteC > 0}
                                        <span class="text-white-50 fs-6 ms-2">({$noteC|number_format:1})</span>
                                    {else}
                                        <span class="text-white-50 small ms-2 fst-italic" style="font-size:0.8rem;">(Aucun avis)</span>
                                    {/if}
                                </div>
                            </div>

                            <div class="d-flex align-items-center gap-2">
                                <span class="text-white-50 small text-uppercase fw-bold" style="width: 90px; text-align:left;">Passager</span>
                                <div class="text-warning fs-5 d-flex align-items-center">
                                    {$noteP = $user.note_passager|default:0}
                                    {for $i=1 to 5}
                                        {if $noteP >= $i}<i class="bi bi-star-fill"></i>
                                        {elseif $noteP > ($i - 1)}<i class="bi bi-star-half"></i>
                                        {else}<i class="bi bi-star"></i>{/if}
                                    {/for}
                                    {if $noteP > 0}
                                        <span class="text-white-50 fs-6 ms-2">({$noteP|number_format:1})</span>
                                    {else}
                                        <span class="text-white-50 small ms-2 fst-italic" style="font-size:0.8rem;">(Aucun avis)</span>
                                    {/if}
                                </div>
                            </div>
                            
                            <a href="/sae-covoiturage/public/profil/avis" class="text-white text-decoration-underline fs-6 mt-2 fw-bold">
                                Voir le détail des avis
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
                                <div class="col-6">
                                    <label class="small text-muted ms-1">Marque</label>
                                    <select name="marque" class="form-control-custom" required>
                                        <option value="" disabled {if !isset($vehicule.marque)}selected{/if}>Choisir...</option>
                                        {if isset($marques)}{foreach from=$marques item=m}<option value="{$m}" {if isset($vehicule.marque) && $vehicule.marque == $m}selected{/if}>{$m}</option>{/foreach}{else}<option value="Autre">Autre</option>{/if}
                                    </select>
                                </div>
                                <div class="col-6">
                                    <label class="small text-muted ms-1">Modèle</label>
                                    <input type="text" name="modele" class="form-control-custom"
                                        placeholder="Ex: Clio 5" value="{$vehicule.modele|default:''}" required maxlength="30">
                                </div>
                                <div class="col-6">
                                    <label class="small text-muted ms-1">Couleur</label>
                                    <select name="couleur" class="form-control-custom" required>
                                        <option value="" disabled {if !isset($vehicule.couleur)}selected{/if}>Choisir...</option>
                                        {if isset($couleurs)}{foreach from=$couleurs item=c}<option value="{$c}" {if isset($vehicule.couleur) && $vehicule.couleur == $c}selected{/if}>{$c}</option>{/foreach}{else}<option value="Autre">Autre</option>{/if}
                                    </select>
                                </div>
                                <div class="col-6">
                                    <label class="small text-muted ms-1">Places</label>
                                    <input type="number" name="nb_places" class="form-control-custom"
                                        placeholder="Ex: 5" value="{$vehicule.nb_places_totales|default:''}" min="1"
                                        max="9" required>
                                </div>
                                <div class="col-12">
                                    <label class="small text-muted ms-1">Immatriculation</label>
                                    <input type="text" name="immat" class="form-control-custom"
                                        placeholder="AA-123-BB" value="{$vehicule.immatriculation|default:''}"
                                        required maxlength="15" style="text-transform: uppercase;"
                                        oninput="this.value = this.value.toUpperCase()"
                                        pattern="{literal}^([A-Z]{2}[-\s]?\d{3}[-\s]?[A-Z]{2})|(\d{1,4}[-\s]?[A-Z]{2,3}[-\s]?[A-Z]{2})${/literal}"
                                        title="Format accepté : AA-123-BB">
                                </div>
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
                    
                    {foreach from=$historique_trajets item=trajet name=historyLoop}
                        <div class="info-card p-4 {if $smarty.foreach.historyLoop.iteration > 1}d-none history-hidden{/if}">
                            <div class="row">
                                <div class="col-md-7 border-end-md">

                                    <h5 class="fw-bold mb-3">Informations du conducteur</h5>
                                    <div class="d-flex align-items-center mb-4">
                                        <div class="avatar-small">
                                            {if !empty($trajet.conducteur_photo) && $trajet.conducteur_photo != 'default.png'}
                                                <img src="/sae-covoiturage/public/uploads/{$trajet.conducteur_photo}" 
                                                     class="avatar-img"
                                                     onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                                                <i class="bi bi-person-fill" style="display:none; font-size: 1.5rem; color: white;"></i>
                                            {else}
                                                <div class="default-avatar-small">
                                                    <i class="bi bi-person-fill"></i>
                                                </div>
                                            {/if}
                                        </div>
                                        <div>
                                            <div class="fw-bold fs-5">{$trajet.conducteur_nom|default:'Conducteur Inconnu'}
                                            </div>
                                            <div class="small text-muted">{$trajet.conducteur_age|default:'--'} ans</div>
                                        </div>
                                        
                                        {if $trajet.id_conducteur != $user.id_utilisateur}
                                            <a href="/sae-covoiturage/public/avis/laisser/{$trajet.id_trajet}/{$trajet.id_conducteur}"
                                                class="btn-mini-purple ms-3 text-decoration-none">Noter</a>
                                        {/if}
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
                                                    <div class="avatar-mini me-2" style="width: 30px; height: 30px; border-radius: 50%; overflow: hidden; display: inline-block; vertical-align: middle; background: #ccc;">
                                                        {if !empty($passager.photo_profil) && $passager.photo_profil != 'default.png'}
                                                            <img src="/sae-covoiturage/public/uploads/{$passager.photo_profil}" 
                                                                 style="width: 100%; height: 100%; object-fit: cover;"
                                                                 onerror="this.style.display='none'; this.parentNode.innerHTML='<i class=\'bi bi-person-circle fs-4 text-secondary\'></i>';">
                                                        {else}
                                                            <i class="bi bi-person-circle fs-4 text-secondary"></i>
                                                        {/if}
                                                    </div>
                                                    <span class="fw-bold me-2">{$passager.prenom}</span>
                                                    
                                                    {if $passager.id_utilisateur != $user.id_utilisateur}
                                                        <button class="btn-mini-dark me-2">Signaler</button>
                                                        <a href="/sae-covoiturage/public/avis/laisser/{$trajet.id_trajet}/{$passager.id_utilisateur}"
                                                            class="btn-mini-purple text-decoration-none">Noter</a>
                                                    {/if}
                                                </div>
                                            {/foreach}
                                        {else}
                                            <div class="passenger-item">
                                                <i class="bi bi-person-circle fs-4 me-2 text-secondary"></i>
                                                <span class="fw-bold me-2">Passager 1</span>
                                            </div>
                                        {/if}
                                    </div>
                                </div>

                                <div class="col-md-5 d-flex flex-column justify-content-between">
                                    <div>
                                        <h5 class="fw-bold mb-3">Informations véhicule</h5>
                                        <div class="fs-6">
                                            <div>{$trajet.vehicule_places|default:'--'} places disponibles</div>
                                            <div class="mt-1">
                                                {if !empty($trajet.vehicule_marque) || !empty($trajet.vehicule_modele)}
                                                    {$trajet.vehicule_marque|default:''} {$trajet.vehicule_modele|default:''}
                                                {else}
                                                    Véhicule standard
                                                {/if}
                                            </div>
                                            {if !empty($trajet.vehicule_couleur)}
                                                <div>{$trajet.vehicule_couleur}</div>
                                            {/if}
                                        </div>
                                    </div>

                                    <div class="mt-4 text-end">
                                        <a href="/sae-covoiturage/public/messagerie/conversation/{$trajet.id_trajet}" 
                                           class="btn btn-purple w-100 py-2 rounded-pill text-decoration-none" style="display:inline-block; text-align:center;">
                                           Discussion de groupe
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    {/foreach}

                    {if $historique_trajets|@count > 1}
                        <div class="text-center mb-4">
                            <button id="btn-see-more" class="see-more-btn" onclick="toggleHistory()">Voir plus</button>
                        </div>
                    {/if}

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
                    <a href="/sae-covoiturage/public/profil/gestion_mdp" class="settings-item"><span>Mot de
                            passe</span><i class="bi bi-chevron-right"></i></a>
                    <a href="/sae-covoiturage/public/profil/modifier_adresse" class="settings-item"><span>Adresse
                            postale</span><i class="bi bi-chevron-right"></i></a>
                    <a href="/sae-covoiturage/public/profil/mes_signalements" class="settings-item"><span>Mes
                            signalements</span><i class="bi bi-chevron-right"></i></a>
                    <a href="/sae-covoiturage/public/profil/preferences" class="settings-item"><span>Préférences de
                            communication</span><i class="bi bi-chevron-right"></i></a>
                    <a href="/sae-covoiturage/public/mentions_legales" class="settings-item"><span>Informations
                            légales</span><i class="bi bi-chevron-right"></i></a>
                    <a href="/sae-covoiturage/public/deconnexion" class="settings-item"><span>Déconnexion</span><i
                            class="bi bi-chevron-right"></i></a>
                    <a href="#" class="settings-item text-danger-custom" data-bs-toggle="modal"
                        data-bs-target="#modalSuppression">
                        <span>Fermer le compte</span>
                        <i class="bi bi-x-circle"></i>
                    </a>
                </div>
            </div>

            <div class="modal fade" id="modalSuppression" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content p-4 text-center">

                        <button type="button" class="btn-close position-absolute top-0 end-0 m-3"
                            data-bs-dismiss="modal" aria-label="Close"></button>

                        <div id="step-1-content">
                            <div class="mb-3">
                                <i class="bi bi-exclamation-triangle-fill text-warning" style="font-size: 3rem;"></i>
                            </div>
                            <h3 class="fw-bold text-black mb-3">
                                <p>Êtes-vous sûr ?
                            </h3>
                            <p class="text-muted mb-4">
                                Vous êtes sur le point de désactiver votre compte.<br>
                                Vous ne pourrez plus vous connecter.
                            </p>
                            <div class="d-flex justify-content-center gap-2">
                                <button type="button" class="btn btn-secondary px-4"
                                    data-bs-dismiss="modal">Annuler</button>
                                <button type="button" class="btn btn-danger px-4" onclick="showStep2()">Oui,
                                    continuer</button>
                            </div>
                        </div>

                        <div id="step-2-content" class="d-none">
                            <div class="mb-3">
                                <i class="bi bi-emoji-frown-fill text-danger" style="font-size: 3rem;"></i>
                            </div>
                            <h3 class="fw-bold text-danger mb-3">Vraiment sûr ?</h3>
                            <p class="text-muted mb-4">
                                C'est la dernière étape. Confirmez-vous vouloir nous quitter définitivement ?
                            </p>

                            <form action="/sae-covoiturage/public/profil/delete-account" method="POST">
                                <div class="d-flex justify-content-center gap-2">
                                    <button type="button" class="btn btn-outline-secondary"
                                        onclick="showStep1()">Retour</button>
                                    <button type="submit" class="btn btn-danger fw-bold px-4">Supprimer mon
                                        compte</button>
                                </div>
                            </form>
                        </div>

                    </div>
                </div>
            </div>

            <script>
                function showStep2() {
                    document.getElementById('step-1-content').classList.add('d-none'); // Cache étape 1
                    document.getElementById('step-2-content').classList.remove('d-none'); // Affiche étape 2
                }

                function showStep1() {
                    document.getElementById('step-2-content').classList.add('d-none'); // Cache étape 2
                    document.getElementById('step-1-content').classList.remove('d-none'); // Affiche étape 1
                }

                // Réinitialiser le pop-up à l'étape 1 quand on le ferme (pour la prochaine fois)
                var myModalEl = document.getElementById('modalSuppression')
                if (myModalEl) {
                    myModalEl.addEventListener('hidden.bs.modal', function(event) {
                        showStep1();
                    })
                }

                // FONCTION VOIR PLUS / VOIR MOINS
                function toggleHistory() {
                    const hiddenItems = document.querySelectorAll('.history-hidden');
                    const btn = document.getElementById('btn-see-more');
                    
                    if (!hiddenItems.length) return;

                    // On vérifie le premier élément pour savoir l'état actuel
                    const isHidden = hiddenItems[0].classList.contains('d-none');

                    hiddenItems.forEach(item => {
                        if (isHidden) {
                            item.classList.remove('d-none');
                        } else {
                            item.classList.add('d-none');
                        }
                    });

                    // Changer le texte du bouton
                    btn.innerText = isHidden ? "Voir moins" : "Voir plus";
                }
            </script>

        </main>

        {include file='includes/footer.tpl'}
    </div>

    <script src="/sae-covoiturage/public/assets/javascript/js_profil.js"></script>

</body>

</html>