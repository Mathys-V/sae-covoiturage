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
        :root {
            --main-purple: #8c52ff;
            --hover-purple: #703ccf;
        }

        .text-purple { color: var(--main-purple); }
        
        /* BOUTONS NAVIGATION */
        .btn-purple {
            background-color: var(--main-purple);
            color: white;
            border: none;
            border-radius: 50px;
            padding: 8px 20px;
            font-weight: 500;
            transition: background 0.3s, transform 0.1s;
            text-align: center;
        }
        .btn-purple:hover {
            background-color: var(--hover-purple);
            color: white;
            transform: translateY(-1px);
        }

        /* AVATAR & FLÈCHE (PC) */
        .user-avatar-btn {
            background-color: var(--main-purple);
            color: white;
            width: 45px;
            height: 45px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }
        .no-arrow::after { display: none !important; }
        .big-arrow { color: var(--main-purple); cursor: pointer; }
        .big-arrow:hover { color: var(--hover-purple); }

        .navbar-brand img { max-height: 50px; width: auto; }

        /* LIENS MOBILE (Menu à plat) */
        .mobile-link {
            color: #333;
            text-decoration: none;
            padding: 10px 0;
            display: block;
            border-bottom: 1px solid #eee;
            font-weight: 500;
        }
        .mobile-link:hover {
            color: var(--main-purple);
            background-color: #f9f9f9;
            padding-left: 10px;
            transition: all 0.2s;
        }

        /* Petit ajustement pour les icones dans le dropdown PC */
        .dropdown-item i {
            width: 20px; /* Pour bien aligner les textes même si les icones ont des largeurs différentes */
            display: inline-block;
            text-align: center;
            color: var(--main-purple); /* On met les icones en violet aussi sur PC */
        }
    </style>
</head>
<nav class="navbar navbar-expand-lg bg-white shadow-sm py-3">
  <div class="container-fluid px-4">
    
    <a class="navbar-brand d-flex align-items-center gap-2" href="../connexion.tpl">
        <img src="assets/img/logo.png" alt="Logo">
        <span class="fw-bold fs-4" style="color: #8c52ff;">monCovoitJV</span>
    </a>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse justify-content-end" id="navbarContent">
      
      <div class="d-flex flex-column flex-lg-row align-items-stretch align-items-lg-center gap-2 mt-3 mt-lg-0">
        
        <a href="/trajet/nouveau" class="btn btn-purple w-100 w-lg-auto">Proposer un trajet</a>
        <a href="/carte" class="btn btn-purple w-100 w-lg-auto">Carte</a>
        <a href="/recherche" class="btn btn-purple w-100 w-lg-auto">Rechercher</a>
        <a href="/reservations" class="btn btn-purple w-100 w-lg-auto">Reservations</a>

        <div class="vr mx-2 d-none d-lg-block"></div>

        <div class="d-none d-lg-flex align-items-center gap-1">
            <a href="/profil" title="Mon Profil"><div class="user-avatar-btn"><i class="bi bi-person-fill fs-4"></i></div></a>
            
            <div class="dropdown">
                <a href="#" class="d-flex align-items-center text-decoration-none no-arrow px-2" id="userDropdown" data-bs-toggle="dropdown">
                    <i class="bi bi-caret-down-fill fs-3 big-arrow"></i>
                </a>
                
                <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2" aria-labelledby="userDropdown">
                    <li>
                        <a class="dropdown-item py-2" href="/mes-trajets">
                            <i class="bi bi-car-front me-2"></i> Mes trajets
                        </a>
                    </li>
                    <li>
                        <a class="dropdown-item py-2" href="/messages">
                            <i class="bi bi-chat-dots me-2"></i> Messages
                        </a>
                    </li>
                    <li>
                        <a class="dropdown-item py-2" href="/profil">
                            <i class="bi bi-person-circle me-2"></i> Profil
                        </a>
                    </li>
                    <li><hr class="dropdown-divider"></li>
                    <li>
                        <a class="dropdown-item py-2" href="/deconnexion">
                            <i class="bi bi-box-arrow-right me-2"></i> Déconnexion
                        </a>
                    </li>
                    
                    {if isset($user) && $user.role == 'admin'}
                        <li><hr class="dropdown-divider"></li>
                        <li>
                            <a class="dropdown-item py-2 text-danger fw-bold" href="/moderation">
                                <i class="bi bi-shield-exclamation me-2"></i> Modération
                            </a>
                        </li>
                    {/if}
                </ul>
            </div>
        </div>

        <div class="d-lg-none mt-3 pt-3 border-top">
            <p class="text-muted small fw-bold text-uppercase mb-2">Mon Compte</p>
            
            <a href="/mes-trajets" class="mobile-link"><i class="bi bi-car-front me-2"></i> Mes trajets</a>
            <a href="/messages" class="mobile-link"><i class="bi bi-chat-dots me-2"></i> Messages</a>
            <a href="/profil" class="mobile-link"><i class="bi bi-person-circle me-2"></i> Mon Profil</a>
            
            {if isset($user) && $user.role == 'admin'}
                <a href="/moderation" class="mobile-link text-danger"><i class="bi bi-shield-exclamation me-2"></i> Modération</a>
            {/if}

            <a href="/deconnexion" class="mobile-link text-muted"><i class="bi bi-box-arrow-right me-2"></i> Déconnexion</a>
        </div>

      </div>
    </div>
  </div>
</nav>