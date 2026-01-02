{include file='includes/header.tpl'}

<div class="container mt-5 mb-5" style="min-height: 80vh;">
    
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold text-dark"><i class="bi bi-shield-lock-fill text-danger me-2"></i>Administration</h1>
        </div>
        <div class="bg-white px-4 py-2 rounded-pill shadow-sm border">
            <i class="bi bi-person-badge-fill text-purple me-2"></i> Mode Admin
        </div>
    </div>

    <ul class="nav nav-tabs border-bottom-0 mb-3" id="adminTabs" role="tablist">
        <li class="nav-item">
            <button class="nav-link active fw-bold px-4 py-2 rounded-top-4" id="pending-tab" data-bs-toggle="tab" data-bs-target="#pending" type="button">
                <i class="bi bi-inbox-fill me-2"></i> En attente 
                {if $en_attente|@count > 0}<span class="badge bg-danger ms-2">{$en_attente|@count}</span>{/if}
            </button>
        </li>
        <li class="nav-item">
            <button class="nav-link fw-bold px-4 py-2 rounded-top-4" id="history-tab" data-bs-toggle="tab" data-bs-target="#history" type="button">
                <i class="bi bi-clock-history me-2"></i> Historique
            </button>
        </li>
        <li class="nav-item">
            <button class="nav-link fw-bold px-4 py-2 rounded-top-4 text-danger" id="banned-tab" data-bs-toggle="tab" data-bs-target="#banned" type="button">
                <i class="bi bi-slash-circle me-2"></i> Utilisateurs Bannis
            </button>
        </li>
    </ul>

    <div class="tab-content" id="adminTabsContent">
        
        <div class="tab-pane fade show active" id="pending">
            <div class="card border-0 shadow-lg rounded-4 overflow-hidden rounded-top-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="bg-light">
                            <tr>
                                <th class="ps-4">Date</th>
                                <th>Motif</th>
                                <th>Utilisateur signalé</th>
                                <th>Signaleur</th>
                                <th>Détails</th>
                                <th class="text-end pe-4">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {if empty($en_attente)}
                                <tr><td colspan="6" class="text-center py-5 text-muted">Aucun signalement en attente.</td></tr>
                            {else}
                                {foreach $en_attente as $sig}
                                <tr class="bg-white">
                                    <td class="ps-4 text-secondary small">{$sig.date_signalement|date_format:"%d/%m %H:%M"}</td>
                                    <td><span class="badge bg-danger bg-opacity-10 text-danger border border-danger">{$sig.motif}</span></td>
                                    <td>
                                        <div class="fw-bold text-dark">{$sig.nom_signale} {$sig.prenom_signale}</div>
                                        <div class="small text-muted">{$sig.email_signale}</div>
                                    </td>
                                    <td class="small text-secondary">{$sig.prenom_signaleur} {$sig.nom_signaleur}</td>
                                    <td>
                                        <button class="btn btn-sm btn-light border text-purple fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#desc-{$sig.id_signalement}">
                                            <i class="bi bi-eye"></i> Voir
                                        </button>
                                    </td>
                                    <td class="text-end pe-4">
    <button class="btn btn-outline-secondary btn-sm me-2" onclick="classer({$sig.id_signalement})" title="Ne pas sanctionner">
        <i class="bi bi-archive-fill"></i> Classer sans suite
    </button>
    <button class="btn btn-danger btn-sm" onclick="ouvrirModalBan({$sig.id_signalement}, '{$sig.nom_signale} {$sig.prenom_signale}')" title="Sanctionner">
        <i class="bi bi-hammer"></i> Bannir
    </button>
</td>
                                </tr>
                                <tr class="collapse bg-light border-bottom" id="desc-{$sig.id_signalement}">
                                    <td colspan="6" class="p-4">
                                        <div class="d-flex gap-3">
                                            <div class="border-start border-4 border-danger ps-3">
                                                <strong>Description :</strong><br><span class="fst-italic text-secondary">"{$sig.description}"</span>
                                            </div>
                                            {if $sig.ville_depart}
                                                <div class="border-start border-4 border-primary ps-3 ms-4">
                                                    <strong>Trajet :</strong> {$sig.ville_depart} <i class="bi bi-arrow-right"></i> {$sig.ville_arrivee}
                                                </div>
                                            {/if}
                                        </div>
                                    </td>
                                </tr>
                                {/foreach}
                            {/if}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="tab-pane fade" id="history">
            <div class="card border-0 shadow-sm rounded-4 rounded-top-0">
                <div class="card-body p-0">
                    <table class="table table-striped mb-0">
                        <thead class="bg-light">
                            <tr><th class="ps-4">Date</th><th>Motif</th><th>Concernés</th><th>Décision</th></tr>
                        </thead>
                        <tbody>
                            {if empty($historique)}
                                <tr><td colspan="4" class="text-center p-4 text-muted">Historique vide.</td></tr>
                            {else}
                                {foreach $historique as $h}
                                <tr>
                                    <td class="ps-4">{$h.date_signalement|date_format:"%d/%m/%Y"}</td>
                                    <td>{$h.motif}</td>
                                    <td><span class="fw-bold">{$h.nom_signale}</span> <span class="text-muted small">(par {$h.nom_signaleur})</span></td>
                                    <td>
                                        {if $h.statut_code == 'R'}<span class="badge bg-secondary">Classé sans suite</span>
                                        {elseif $h.statut_code == 'J'}<span class="badge bg-dark"><i class="bi bi-hammer"></i> Banni</span>{/if}
                                    </td>
                                </tr>
                                {/foreach}
                            {/if}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="tab-pane fade" id="banned">
            <div class="card border-0 shadow-sm rounded-4 rounded-top-0 border-top border-danger border-3">
                <div class="card-body">
                    <h5 class="fw-bold mb-3 text-danger">Utilisateurs suspendus</h5>
                    
                    {if empty($bannis)}
                        <div class="alert alert-success"><i class="bi bi-emoji-smile fs-4 me-3"></i>Aucun utilisateur banni.</div>
                    {else}
                        <div class="table-responsive">
                            <table class="table align-middle">
                                <thead>
                                    <tr>
                                        <th>Utilisateur</th>
                                        <th>Type de ban</th>
                                        <th>Fin du bannissement</th>
                                        <th class="text-end">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {foreach $bannis as $b}
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="bg-light rounded-circle p-1 border">
                                                    {if !empty($b.photo_profil)}<img src="/sae-covoiturage/public/uploads/{$b.photo_profil}" class="rounded-circle" width="30" height="30">{else}<i class="bi bi-person-fill fs-4"></i>{/if}
                                                </div>
                                                <div>
                                                    <div class="fw-bold">{$b.nom} {$b.prenom}</div>
                                                    <div class="small text-muted">{$b.email}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            {if $b.type_ban == 'Définitif'}
                                                <span class="badge bg-danger">DÉFINITIF</span>
                                            {else}
                                                <span class="badge bg-warning text-dark">TEMPORAIRE</span>
                                            {/if}
                                        </td>
                                        <td>
                                            {if $b.type_ban == 'Définitif'}
                                                <span class="text-muted">Jamais</span>
                                            {else}
                                                <strong class="text-dark">{$b.date_expiration_token|date_format:"%d/%m/%Y à %H:%M"}</strong><br>
                                                <small class="text-muted">(Reste : {$b.temps_restant})</small>
                                            {/if}
                                        </td>
                                        <td class="text-end">
                                            <button class="btn btn-outline-success btn-sm fw-bold" onclick="debannir({$b.id_utilisateur})">
                                                <i class="bi bi-arrow-counterclockwise"></i> Réactiver
                                            </button>
                                        </td>
                                    </tr>
                                    {/foreach}
                                </tbody>
                            </table>
                        </div>
                    {/if}
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalBan" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header bg-danger text-white">
        <h5 class="modal-title fw-bold"><i class="bi bi-hammer me-2"></i>Sanctionner l'utilisateur</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <p>Vous êtes sur le point de bannir <strong id="modalUserName"></strong>.</p>
        <p class="mb-2">Choisissez la durée de la sanction :</p>
        
        <input type="hidden" id="modalSigId">
        
        <div class="list-group">
            <label class="list-group-item">
                <input class="form-check-input me-1" type="radio" name="banDuration" value="1" checked>
                1 Jour (24h)
            </label>
            <label class="list-group-item">
                <input class="form-check-input me-1" type="radio" name="banDuration" value="3">
                3 Jours
            </label>
            <label class="list-group-item">
                <input class="form-check-input me-1" type="radio" name="banDuration" value="7">
                1 Semaine
            </label>
            <label class="list-group-item">
                <input class="form-check-input me-1" type="radio" name="banDuration" value="30">
                1 Mois
            </label>
            <label class="list-group-item list-group-item-danger bg-danger bg-opacity-10">
                <input class="form-check-input me-1" type="radio" name="banDuration" value="definitif">
                <strong>Bannissement DÉFINITIF</strong>
            </label>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Annuler</button>
        <button type="button" class="btn btn-danger" onclick="confirmerBan()">Confirmer la sanction</button>
      </div>
    </div>
  </div>
</div>

<script src="/sae-covoiturage/public/assets/javascript/admin/js_moderation.js"></script>

{include file='includes/footer.tpl'}