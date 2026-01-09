<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Covoit IUT</title>
    
    <link rel="icon" type="image/png" href="/sae-covoiturage/public/assets/img/logo_MonCovoitJV.png">
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <link rel="stylesheet" href="/sae-covoiturage/public/assets/css/includes/style_header.css">
</head>
<body>

<nav class="navbar navbar-expand-lg bg-white shadow-sm py-3">
  <div class="container-fluid px-4">
    
    <a class="navbar-brand d-flex align-items-center gap-2" href="/sae-covoiturage/public/">
        <img src="/sae-covoiturage/public/assets/img/logo.png" alt="Logo">
        <span class="fw-bold fs-4" style="color: #8c52ff;">monCovoitJV</span>
    </a>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse justify-content-end" id="navbarContent">
      
      <div class="d-flex flex-column flex-lg-row align-items-stretch align-items-lg-center gap-3 mt-3 mt-lg-0">
        
        {if isset($user) && $user.admin_flag == 'Y'}
            <a href="/sae-covoiturage/public/moderation" class="btn btn-danger fw-bold">
                <i class="bi bi-shield-lock-fill"></i> Espace Admin
            </a>
            <div class="vr mx-2 d-none d-lg-block"></div>
        {/if}

        <a href="{if isset($user)}/sae-covoiturage/public/trajet/nouveau{else}/sae-covoiturage/public/connexion{/if}" 
           class="btn btn-purple w-100"
           {if !isset($user)}onclick="return confirm('Vous devez être connecté pour proposer un trajet.\n\nCliquez sur OK pour vous connecter.');"{/if}>
           Proposer un trajet
        </a>

        <a href="/sae-covoiturage/public/carte" class="btn btn-purple w-100">Carte</a>

        <a href="/sae-covoiturage/public/recherche" class="btn btn-purple w-100">Rechercher</a>

        <a href="{if isset($user)}/sae-covoiturage/public/mes_reservations{else}/sae-covoiturage/public/connexion{/if}" 
            class="btn btn-purple w-100"
        {if !isset($user)}onclick="return confirm('Vous devez être connecté pour voir vos réservations.\n\nCliquez sur OK pour vous connecter.');"{/if}>
        Mes réservations
        </a>

        <div class="vr mx-2 d-none d-lg-block"></div>

        <div class="d-none d-lg-flex align-items-center gap-2">
            {if !isset($user)}
                <a href="/sae-covoiturage/public/inscription" class="btn btn-outline-purple me-2">
                    S'inscrire
                </a>
            {/if}
            <a href="{if isset($user)}/sae-covoiturage/public/profil{else}/sae-covoiturage/public/connexion{/if}" 
            title="{if isset($user)}Mon Profil{else}Se connecter{/if}"
            {if !isset($user)}onclick="return confirm('Vous devez être connecté pour accéder à votre profil.\n\nCliquez sur OK pour vous connecter.');"{/if}
            class="text-decoration-none">
                
                <div class="user-avatar-btn position-relative">
                    {if isset($user) && !empty($user.photo_profil)}
                        <img src="/sae-covoiturage/public/uploads/{$user.photo_profil}" class="rounded-circle" style="width:100%; height:100%; object-fit:cover;">
                    {else}
                        <i class="bi bi-person-fill fs-4"></i>
                    {/if}

                    {if isset($nb_notifs) && $nb_notifs > 0}
                        <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light">
                            {$nb_notifs}
                            <span class="visually-hidden">messages non lus</span>
                        </span>
                    {/if}
                </div>

            </a>
            
            <div class="dropdown">
                <a href="#" class="d-flex align-items-center text-decoration-none no-arrow px-2" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="bi bi-caret-down-fill fs-3 big-arrow"></i>
                </a>
                
                <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2" aria-labelledby="userDropdown" style="min-width: 200px;">
                    
                    {if isset($user) && $user.admin_flag == 'Y'}
                        <li>
                            <a class="dropdown-item py-2 text-danger fw-bold" href="/sae-covoiturage/public/moderation">
                                <i class="bi bi-shield-exclamation me-2"></i> Espace Admin
                            </a>
                        </li>
                        <li><hr class="dropdown-divider"></li>
                    {/if}

                    <li>
                        <a class="dropdown-item py-2" href="{if isset($user)}/sae-covoiturage/public/mes_trajets{else}/sae-covoiturage/public/connexion{/if}"
                        {if !isset($user)}onclick="return confirm('Vous devez être connecté pour voir vos trajets.\n\nCliquez sur OK pour vous connecter.');"{/if}>
                            <i class="bi bi-car-front me-2"></i> Mes trajets
                        </a>
                    </li>

                    <li>
                        <a class="dropdown-item py-2 d-flex justify-content-between align-items-center" href="{if isset($user)}/sae-covoiturage/public/messagerie{else}/sae-covoiturage/public/connexion{/if}"
                        {if !isset($user)}onclick="return confirm('Vous devez être connecté pour voir vos messages.\n\nCliquez sur OK pour vous connecter.');"{/if}>
                            <div><i class="bi bi-chat-dots me-2"></i> Messages</div>
                            {if isset($nb_notifs) && $nb_notifs > 0}
                                <span class="badge bg-danger rounded-pill">{$nb_notifs}</span>
                            {/if}
                        </a>
                    </li>

                    <li>
                        <a class="dropdown-item py-2" href="{if isset($user)}/sae-covoiturage/public/profil{else}/sae-covoiturage/public/connexion{/if}"
                        {if !isset($user)}onclick="return confirm('Vous devez être connecté pour accéder à votre profil.\n\nCliquez sur OK pour vous connecter.');"{/if}>
                            <i class="bi bi-person-circle me-2"></i> Profil
                        </a>
                    </li>

                    <li><hr class="dropdown-divider"></li>

                    <li>
                        {if isset($user)}
                            <a class="dropdown-item py-2" href="/sae-covoiturage/public/deconnexion"><i class="bi bi-box-arrow-right me-2"></i> Déconnexion</a>
                        {else}
                            <a class="dropdown-item py-2 fw-bold text-purple" href="/sae-covoiturage/public/connexion"><i class="bi bi-box-arrow-in-right me-2"></i> Se connecter</a>
                        {/if}
                    </li>
                </ul>
            </div>
        </div>

        <div class="d-lg-none mt-3 pt-3 border-top">
            <p class="text-muted small fw-bold text-uppercase mb-2">Mon Compte</p>
            
            {if isset($user) && $user.admin_flag == 'Y'}
                <a href="/sae-covoiturage/public/moderation" class="mobile-link text-danger fw-bold">
                    <i class="bi bi-shield-lock-fill me-2"></i> Espace Admin
                </a>
            {/if}

            <a href="{if isset($user)}/sae-covoiturage/public/mes-trajets{else}/sae-covoiturage/public/connexion{/if}" 
            class="mobile-link"
            {if !isset($user)}onclick="return confirm('Vous devez être connecté pour voir vos trajets.\n\nCliquez sur OK pour vous connecter.');"{/if}>
                <i class="bi bi-car-front me-2"></i> Mes trajets
            </a>

            <a href="{if isset($user)}/sae-covoiturage/public/messagerie{else}/sae-covoiturage/public/connexion{/if}" 
                class="mobile-link d-flex justify-content-between align-items-center"
                {if !isset($user)}onclick="return confirm('Vous devez être connecté pour voir vos messages.\n\nCliquez sur OK pour vous connecter.');"{/if}>
                <span><i class="bi bi-chat-dots me-2"></i> Messages</span>
                {if isset($nb_notifs) && $nb_notifs > 0}
                    <span class="badge bg-danger rounded-pill">{$nb_notifs}</span>
                {/if}
            </a>

            <a href="{if isset($user)}/sae-covoiturage/public/profil{else}/sae-covoiturage/public/connexion{/if}" 
                class="mobile-link"
                {if !isset($user)}onclick="return confirm('Vous devez être connecté pour accéder à votre profil.\n\nCliquez sur OK pour vous connecter.');"{/if}>
                <i class="bi bi-person-circle me-2"></i> Mon Profil
            </a>

            {if isset($user)}
                <a href="/sae-covoiturage/public/deconnexion" class="mobile-link text-muted"><i class="bi bi-box-arrow-right me-2"></i> Déconnexion</a>
            {else}
                {* NOUVEAU : Lien S'inscrire mobile *}
                <a href="/sae-covoiturage/public/inscription" class="mobile-link text-purple">
                    <i class="bi bi-person-plus-fill me-2"></i> S'inscrire
                </a>
                <a href="/sae-covoiturage/public/connexion" class="mobile-link text-purple fw-bold">
                    <i class="bi bi-box-arrow-in-right me-2"></i> Se connecter
                </a>
            {/if}
        </div>

    </div>
    </div>
  </div>
</nav>

{if isset($flash_success)}
    <div class="flash-message-container">
        <div class="alert alert-success alert-dismissible fade show shadow-lg border-0" role="alert" style="border-left: 5px solid #198754; background-color: #d1e7dd; color: #0f5132;">
            <div class="d-flex align-items-center">
                <i class="bi bi-check-circle-fill fs-4 me-3 text-success"></i>
                <div><strong>Succès !</strong> {$flash_success}</div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </div>
    <script>
        setTimeout(function() {
            let alert = document.querySelector('.alert');
            if(alert) { let bsAlert = new bootstrap.Alert(alert); bsAlert.close(); }
        }, 4000);
    </script>
{/if}
{if isset($flash_error)}
    <div class="flash-message-container">
        <div class="alert alert-danger alert-dismissible fade show shadow-lg border-0" role="alert" style="border-left: 5px solid #dc3545; background-color: #f8d7da; color: #842029;">
            <div class="d-flex align-items-center">
                <i class="bi bi-exclamation-triangle-fill fs-4 me-3 text-danger"></i>
                <div><strong>Attention !</strong> {$flash_error}</div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </div>
    <script>
        setTimeout(function() {
            let alert = document.querySelector('.alert-danger');
            if(alert) { let bsAlert = new bootstrap.Alert(alert); bsAlert.close(); }
        }, 10000);
    </script>
{/if}