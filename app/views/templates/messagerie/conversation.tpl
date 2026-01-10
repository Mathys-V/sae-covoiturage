{include file='includes/header.tpl'}

{* Inclusion de la feuille de style spécifique à la messagerie *}
<link rel="stylesheet" href="/sae-covoiturage/public/assets/css/messagerie/style_conversation.css">

<div class="chat-wrapper" style="height: 85vh; display: flex; flex-direction: column;">
    
    {* EN-TÊTE DE CONVERSATION *}
    <div class="chat-header p-3 border-bottom bg-white d-flex justify-content-between align-items-center">
        <div class="d-flex align-items-center" style="max-width: 80%;">
            
            {* Bouton Retour vers la liste des conversations (ou l'historique selon statut) *}
            <a href="/sae-covoiturage/public/messagerie#{if $trajet.statut_visuel == 'complet'}avenir{else}{$trajet.statut_visuel}{/if}" 
               class="btn btn-light rounded-circle shadow-sm me-3">
               <i class="bi bi-arrow-left text-dark"></i>
            </a>
            
            {* Informations principales du trajet (Villes, Date, Statut) *}
            <div class="text-truncate">
                <h5 class="mb-0 fw-bold" style="white-space: normal; font-size: 1.1rem; line-height: 1.3;">
                    {* Départ *}
                    {if !empty($trajet.rue_depart)}{$trajet.rue_depart}, {/if}{$trajet.code_postal_depart} {$trajet.ville_depart}
                    
                    <i class="bi bi-arrow-right-short text-muted mx-1"></i>
                    
                    {* Arrivée *}
                    {if !empty($trajet.rue_arrivee)}{$trajet.rue_arrivee}, {/if}{$trajet.code_postal_arrivee} {$trajet.ville_arrivee}
                </h5>
                <div class="d-flex align-items-center gap-2 small mt-1">
                    {* Badge de statut (A venir, En cours, Terminé) *}
                    <span class="badge bg-{$trajet.statut_couleur} bg-opacity-10 text-{$trajet.statut_couleur} border border-{$trajet.statut_couleur} rounded-pill px-2">
                        {if $trajet.statut_visuel == 'avenir'}<i class="bi bi-clock me-1"></i>
                        {elseif $trajet.statut_visuel == 'encours'}<i class="bi bi-car-front-fill me-1"></i>
                        {else}<i class="bi bi-check-circle-fill me-1"></i>{/if}
                        {$trajet.statut_libelle}
                    </span>

                    {* Indicateur de temps restant pour les trajets en cours *}
                    {if $trajet.statut_visuel == 'encours' && isset($trajet.temps_restant)}
                        <span class="text-success fw-bold">
                            <i class="bi bi-hourglass-split"></i> Arrivée dans {$trajet.temps_restant}
                        </span>
                        <span class="text-muted mx-1">•</span>
                    {/if}

                    <span class="text-muted">{$trajet.date_fmt}</span>
                </div>
            </div>
        </div>
        
        {* Bouton de signalement (visible s'il y a des participants) *}
        {if $participants|@count > 0}
        <button class="btn btn-outline-danger btn-sm rounded-pill px-3 btn-report" title="Signaler un problème" data-bs-toggle="modal" data-bs-target="#modalSignalement">
            <i class="bi bi-flag"></i>
        </button>
        {/if}
    </div>

    {* ZONE DES MESSAGES (Défilable) *}
    <div class="messages-container p-3" id="messagesArea" style="flex: 1; overflow-y: auto; background-color: #f8f9fa;">
        {if empty($messages)}
            {* Message d'accueil si la conversation est vide *}
            <div class="d-flex flex-column align-items-center justify-content-center h-100 opacity-50">
                <i class="bi bi-chat-dots display-1 text-purple mb-3"></i>
                <p class="fw-bold fs-5">La conversation commence ici.</p>
                <p class="small text-muted">Discutez avec les membres du trajet !</p>
            </div>
        {else}
            {foreach $messages as $msg}
                {* --- Séparateur de date --- *}
                {if $msg.type == 'separator'}
                    <div class="date-divider"><span>{$msg.date}</span></div>
                
                {* --- Messages Système (Fin de trajet, Annulation, Création, Join/Leave) --- *}
                {elseif $msg.type == 'system'}
                    
                    {* CAS 1 : Trajet Terminé (Invite à laisser un avis) *}
                    {if $msg.contenu == '::sys_end::'}
                        <div class="system-msg my-4">
                            <div class="card border-0 shadow-sm p-4 mx-auto" style="max-width: 90%; background-color: #f3f0ff;">
                                <div class="text-center">
                                    <h4 class="fw-bold text-purple mb-2"><i class="bi bi-flag-fill"></i> Trajet terminé !</h4>
                                    <p class="text-muted mb-3">Nous espérons que vous avez fait bon voyage. C'est le moment de laisser un avis.</p>
                                    <a href="/sae-covoiturage/public/avis/choix/{$trajet.id_trajet}" 
                                       class="btn btn-purple rounded-pill px-4 py-2 fw-bold shadow-sm d-inline-flex align-items-center justify-content-center text-nowrap"
                                       style="min-width: 200px;"> <i class="bi bi-star-fill me-2"></i> Noter les participants
                                    </a>
                                </div>
                            </div>
                        </div>

                    {* CAS 2 : Trajet Annulé *}
                    {elseif $msg.contenu|replace:'::sys_cancel::':'' != $msg.contenu}
                        <div class="system-msg my-4">
                            <div class="card border-0 shadow-sm p-4 mx-auto" style="max-width: 90%; background-color: #fff5f5; border-left: 5px solid #dc3545 !important;">
                                <div class="text-center">
                                    <h4 class="fw-bold text-danger mb-2">
                                        <i class="bi bi-exclamation-octagon-fill me-2"></i> Trajet Annulé
                                    </h4>
                                    <p class="text-muted mb-0">
                                        Le conducteur a annulé ce trajet.<br>
                                        Toutes les réservations ont été annulées automatiquement.
                                    </p>
                                </div>
                            </div>
                        </div>

                    {* CAS 3 : Trajet Créé *}
                    {elseif $msg.contenu|replace:'::sys_create::':'' != $msg.contenu}
                        <div class="system-msg my-3 text-center">
                            <span class="badge bg-purple bg-opacity-10 text-purple border border-purple px-3 py-2 rounded-pill shadow-sm">
                                <i class="bi bi-stars me-1"></i> 
                                {$msg.contenu|replace:'::sys_create::':''}
                            </span>
                        </div>

                    {* CAS 4 : Notifications Join / Leave *}
                    {else}
                        <div class="text-center my-3">
                            <small class="text-muted fst-italic">
                                <i class="bi bi-info-circle me-1"></i>
                                {* Affiche le texte formaté par PHP (ex: "X a rejoint le trajet") *}
                                {$msg.text_affiche|default:$msg.contenu}
                            </small>
                        </div>
                    {/if}

                {* --- Messages Utilisateurs (Bulles de chat) --- *}
                {else}
                    <div class="msg-row {if $msg.type == 'self'}self{else}other{/if}">
                        <div class="msg-content shadow-sm">
                            {$msg.contenu|nl2br}
                        </div>
                        <div class="msg-info">
                            {* Lien vers le profil si c'est un autre utilisateur *}
                            {if $msg.type == 'other'}
                                <a href="/sae-covoiturage/public/profil/voir/{$msg.id_expediteur}" 
                                   class="text-decoration-none fw-bold" 
                                   style="color: #6c757d;"
                                   onmouseover="this.style.textDecoration='underline'; this.style.color='#8c52ff';" 
                                   onmouseout="this.style.textDecoration='none'; this.style.color='#6c757d';">
                                    {$msg.nom_affiche}
                                </a>
                            {else}
                                {$msg.nom_affiche}
                            {/if}
                            • {$msg.heure_fmt}
                        </div>
                    </div>
                {/if}
            {/foreach}
        {/if}
    </div>

    {* ZONE DE SAISIE *}
    <div class="chat-footer p-3 bg-white border-top">
        <form id="chatForm" class="d-flex gap-2">
            <input type="text" id="messageInput" class="form-control rounded-pill bg-light border-0 px-4 py-2" placeholder="Écrivez votre message..." required autocomplete="off">
            <input type="hidden" id="trajetId" value="{$trajet.id_trajet}">
            <button type="submit" class="btn btn-purple rounded-circle d-flex align-items-center justify-content-center shadow-sm" style="width: 45px; height: 45px;">
                <i class="bi bi-send-fill fs-5"></i>
            </button>
        </form>
    </div>

</div>

{* MODALE DE SIGNALEMENT *}
<div class="modal fade" id="modalSignalement" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content rounded-4 border-0 shadow-lg">
      <div class="modal-header border-0 pb-0">
        <h5 class="modal-title fw-bold text-danger">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>Signaler ce trajet
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-4">
        <p class="text-muted small mb-4">Merci de nous indiquer la raison de ce signalement. Un modérateur examinera la situation rapidement.</p>
        <form id="formSignalement">
            <div class="mb-3">
                <label class="form-label-bold">Qui concerne ce signalement ?</label>
                <select class="form-select bg-light border-0 py-2" id="userSignalement" required>
                    <option value="" selected disabled>Choisir un utilisateur...</option>
                    {foreach $participants as $p}
                        <option value="{$p.id}">{$p.nom} ({$p.role})</option>
                    {/foreach}
                </select>
            </div>
            <div class="mb-3">
                <label class="form-label-bold">Motif</label>
                <select class="form-select bg-light border-0 py-2" id="motifSignalement" required>
                    <option value="" selected disabled>Choisir un motif...</option>
                    <option value="Comportement dangereux">Comportement dangereux</option>
                    <option value="Absence au rendez-vous">Absence au rendez-vous</option>
                    <option value="Véhicule non conforme">Véhicule non conforme</option>
                    <option value="Propos inappropriés">Propos inappropriés (Chat)</option>
                    <option value="Autre">Autre</option>
                </select>
            </div>
            <div class="mb-4">
                <label class="form-label-bold">Détails supplémentaires</label>
                <textarea class="custom-textarea" id="detailsSignalement" rows="4" placeholder="Décrivez la situation ici..."></textarea>
            </div>
            <div class="d-grid gap-2">
                <button type="submit" class="btn btn-danger rounded-pill fw-bold py-2">Envoyer le signalement</button>
                <button type="button" class="btn btn-light rounded-pill text-muted" data-bs-dismiss="modal">Annuler</button>
            </div>
        </form>
      </div>
    </div>
  </div>
</div>

{* Script JS pour la gestion du chat (envoi AJAX, polling...) *}
<script src="/sae-covoiturage/public/assets/javascript/messagerie/js_conversation.js"></script>

{include file='includes/footer.tpl'}