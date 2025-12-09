<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Covoit IUT</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <style>
        /* --- THÈME VIOLET --- */
        :root { --main-purple: #8c52ff; --hover-purple: #703ccf; }
        .text-purple { color: var(--main-purple); }
        
        /* === CORRECTION FOOTER : STRUCTURE DE LA PAGE === */
        html, body {
            height: 100%; /* La page prend 100% de l'écran */
            margin: 0;
        }
        body {
            display: flex;
            flex-direction: column; /* Organise les éléments verticalement */
            background-color: #f8f9fa; /* Couleur de fond légère pour tout le site */
        }
        /* ================================================ */

        /* BOUTONS NAVIGATION (Largeur Fixe pour le menu) */
        .btn-purple {
            background-color: var(--main-purple); 
            color: white; 
            border: none;
            border-radius: 50px; 
            padding: 8px 10px;
            font-weight: 500;
            transition: background 0.3s, transform 0.1s; 
            text-decoration: none;
            
            /* Largeur fixe pour le menu */
            width: 180px; 
            display: inline-flex; 
            justify-content: center;
            align-items: center;
            white-space: nowrap;
        }
        
        .btn-purple:hover {
            background-color: var(--hover-purple); 
            color: white; 
            transform: translateY(-1px);
        }

        .user-avatar-btn {
            background-color: var(--main-purple); color: white; width: 45px; height: 45px;
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
            cursor: pointer; transition: background 0.3s;
        }
        .user-avatar-btn:hover { background-color: var(--hover-purple); }
        .no-arrow::after { display: none !important; }
        .big-arrow { color: var(--main-purple); cursor: pointer; }
        .big-arrow:hover { color: var(--hover-purple); }
        
        .navbar-brand img { max-height: 50px; width: auto; }

        .mobile-link {
            color: #333; text-decoration: none; padding: 10px 0; display: block; border-bottom: 1px solid #eee; font-weight: 500;
        }
        .mobile-link:hover {
            color: var(--main-purple); background-color: #f9f9f9; padding-left: 10px; transition: all 0.2s;
        }
        .dropdown-item i { width: 20px; display: inline-block; text-align: center; color: var(--main-purple); }
        
        .btn-outline-purple {
            background-color: transparent; color: var(--main-purple); border: 2px solid var(--main-purple);
            border-radius: 50px; padding: 6px 20px; font-weight: 500; transition: all 0.3s;
            text-align: center; text-decoration: none;
        }
        .btn-outline-purple:hover { background-color: var(--main-purple); color: white; }
    </style>
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
        
        <a href="/sae-covoiturage/public/trajet/nouveau" class="btn btn-purple w-100">Proposer un trajet</a>
        <a href="/sae-covoiturage/public/carte" class="btn btn-purple w-100">Carte</a>
        <a href="/sae-covoiturage/public/recherche" class="btn btn-purple w-100">Rechercher</a>
        <a href="/sae-covoiturage/public/reservations" class="btn btn-purple w-100">Reservations</a>

        <div class="vr mx-2 d-none d-lg-block"></div>

        <div class="d-none d-lg-flex align-items-center gap-1">
            <a href="{if isset($user)}/sae-covoiturage/public/profil{else}/sae-covoiturage/public/connexion{/if}" 
               title="{if isset($user)}Mon Profil{else}Se connecter{/if}">
                <div class="user-avatar-btn">
                    {if isset($user) && !empty($user.photo_profil)}
                         <img src="/sae-covoiturage/public/uploads/{$user.photo_profil}" class="rounded-circle" style="width:100%; height:100%; object-fit:cover;">
                    {else}
                         <i class="bi bi-person-fill fs-4"></i>
                    {/if}
                </div>
            </a>
            
            <div class="dropdown">
                <a href="#" class="d-flex align-items-center text-decoration-none no-arrow px-2" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="bi bi-caret-down-fill fs-3 big-arrow"></i>
                </a>
                
                <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2" aria-labelledby="userDropdown" style="min-width: 200px;">
                    <li><a class="dropdown-item py-2" href="{if isset($user)}/sae-covoiturage/public/mes-trajets{else}/sae-covoiturage/public/connexion{/if}"><i class="bi bi-car-front me-2"></i> Mes trajets</a></li>
                    <li><a class="dropdown-item py-2" href="{if isset($user)}/sae-covoiturage/public/messages{else}/sae-covoiturage/public/connexion{/if}"><i class="bi bi-chat-dots me-2"></i> Messages</a></li>
                    <li><a class="dropdown-item py-2" href="{if isset($user)}/sae-covoiturage/public/profil{else}/sae-covoiturage/public/connexion{/if}"><i class="bi bi-person-circle me-2"></i> Profil</a></li>
                    <li><hr class="dropdown-divider"></li>
                    {if isset($user) && isset($user.role) && $user.role == 'admin'}
                        <li><a class="dropdown-item py-2 text-danger fw-bold" href="/sae-covoiturage/public/moderation"><i class="bi bi-shield-exclamation me-2"></i> Modération</a></li>
                        <li><hr class="dropdown-divider"></li>
                    {/if}
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
            <a href="{if isset($user)}/sae-covoiturage/public/mes-trajets{else}/sae-covoiturage/public/connexion{/if}" class="mobile-link"><i class="bi bi-car-front me-2"></i> Mes trajets</a>
            <a href="{if isset($user)}/sae-covoiturage/public/messages{else}/sae-covoiturage/public/connexion{/if}" class="mobile-link"><i class="bi bi-chat-dots me-2"></i> Messages</a>
            <a href="{if isset($user)}/sae-covoiturage/public/profil{else}/sae-covoiturage/public/connexion{/if}" class="mobile-link"><i class="bi bi-person-circle me-2"></i> Mon Profil</a>
            {if isset($user) && isset($user.role) && $user.role == 'admin'}
                <a href="/sae-covoiturage/public/moderation" class="mobile-link text-danger"><i class="bi bi-shield-exclamation me-2"></i> Modération</a>
            {/if}
            {if isset($user)}
                <a href="/sae-covoiturage/public/deconnexion" class="mobile-link text-muted"><i class="bi bi-box-arrow-right me-2"></i> Déconnexion</a>
            {else}
                <a href="/sae-covoiturage/public/connexion" class="mobile-link text-purple fw-bold"><i class="bi bi-box-arrow-in-right me-2"></i> Se connecter</a>
            {/if}
        </div>

      </div>
    </div>
  </div>
</nav>