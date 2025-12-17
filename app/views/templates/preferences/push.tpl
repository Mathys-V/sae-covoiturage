<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$titre}</title>
    <style>
        /* Styles de base identiques */
        :root { --primary-purple: #422875; --accent-purple: #8C52FF; --white: #ffffff; }
        body { margin: 0; font-family: 'Segoe UI', sans-serif; display: flex; flex-direction: column; min-height: 100vh; }
        main { background-color: var(--primary-purple); flex-grow: 1; display: flex; flex-direction: column; align-items: center; padding: 20px; color: white; }

        /* HEADER AVEC RETOUR */
        .header-top { width: 100%; max-width: 600px; display: flex; align-items: center; margin-bottom: 30px; position: relative; }
        .back-btn { 
            text-decoration: none; color: white; border: 1px solid rgba(255,255,255,0.3); 
            border-radius: 50%; width: 40px; height: 40px; display: flex; 
            justify-content: center; align-items: center; font-size: 1.2rem; transition: background 0.3s;
        }
        .back-btn:hover { background: rgba(255,255,255,0.1); }
        h1 { flex-grow: 1; text-align: center; margin: 0; font-size: 1.8rem; padding-right: 40px; }

        /* FORMULAIRE & CHECKBOXES */
        form { width: 100%; max-width: 600px; display: flex; flex-direction: column; gap: 30px; }
        
        .option-row {
            display: flex; gap: 20px; align-items: flex-start;
            padding-bottom: 20px; border-bottom: 1px solid var(--accent-purple);
        }
        /* Checkbox cachée */
        .option-row input[type="checkbox"] { display: none; }
        
        /* Checkbox Custom (Carré) */
        .custom-check {
            width: 24px; height: 24px; border: 2px solid white; border-radius: 6px;
            display: flex; justify-content: center; align-items: center; cursor: pointer; flex-shrink: 0;
            transition: background 0.2s, border-color 0.2s;
        }
        /* État coché */
        .option-row input:checked + .custom-check { background-color: transparent; }
        .option-row input:checked + .custom-check::after {
            content: '✓'; color: white; font-size: 16px;
        }

        .text-content { display: flex; flex-direction: column; cursor: pointer; }
        .label-title { font-size: 1.1rem; font-weight: normal; margin-bottom: 5px; }
        .label-desc { font-size: 0.8rem; color: #ccc; line-height: 1.3; }

        .btn-save {
            background: var(--accent-purple); color: white; border: none; padding: 15px 40px;
            border-radius: 30px; font-size: 1.2rem; font-weight: bold; cursor: pointer;
            align-self: center; margin-top: 20px; transition: background 0.3s;
        }
        .btn-save:hover { background: #7a42ea; }

        /* MODALES (Même code que d'habitude) */
        .overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); display: none; justify-content: center; align-items: center; z-index: 999; }
        .box { background: #E6DFF0; padding: 30px; border-radius: 20px; text-align: center; width: 90%; max-width: 400px; color: black; }
        .box h2 { color: var(--primary-purple); margin-top: 0; }
        .btns { display: flex; justify-content: center; gap: 15px; margin-top: 20px; }
        .btn-ok { background: var(--accent-purple); color: white; padding: 10px 30px; border-radius: 20px; border: none; cursor: pointer; font-weight: bold; }
        .btn-cancel { background: #bbb; color: #333; padding: 10px 30px; border-radius: 20px; border: none; cursor: pointer; font-weight: bold; }
    </style>
</head>
<body>
    {include file='includes/header.tpl'}
    <main>
        <div class="header-top">
            <a href="/sae-covoiturage/public/profil/preferences" class="back-btn">&lsaquo;</a>
            <h1>Notifications push</h1>
        </div>

        <form id="pushForm">
            <label class="option-row">
                <input type="checkbox" id="push_compte">
                <div class="custom-check"></div>
                <div class="text-content">
                    <span class="label-title">Votre compte et vos réservations</span>
                    <span class="label-desc">Recevez des informations importantes sur vos réservations, annulations et paiements</span>
                </div>
            </label>

            <label class="option-row">
                <input type="checkbox" id="push_messages">
                <div class="custom-check"></div>
                <div class="text-content">
                    <span class="label-title">Messages d'autres membres</span>
                    <span class="label-desc">Recevez une notification quand d'autres membres vous contactent au sujet de votre prochain trajet</span>
                </div>
            </label>

            <button type="submit" class="btn-save">Enregistrer</button>
        </form>
    </main>

    <div class="overlay" id="confirmModal">
        <div class="box">
            <h2>Confirmation</h2>
            <p>Voulez-vous enregistrer ces préférences ?</p>
            <div class="btns">
                <button class="btn-cancel" onclick="closeAll()">Non</button>
                <button class="btn-ok" onclick="saveData()">Oui</button>
            </div>
        </div>
    </div>
    <div class="overlay" id="successModal">
        <div class="box">
            <h2>Succès</h2>
            <p>Préférences mises à jour !</p>
            <button class="btn-ok" onclick="closeAll()">Ok</button>
        </div>
    </div>

    {include file='includes/footer.tpl'}

    <script>
        // 1. CHARGEMENT (Mémoire fictive)
        document.addEventListener('DOMContentLoaded', () => {
            if(localStorage.getItem('push_compte') === 'true') document.getElementById('push_compte').checked = true;
            if(localStorage.getItem('push_messages') === 'true') document.getElementById('push_messages').checked = true;
        });

        // 2. GESTION DU SUBMIT
        document.getElementById('pushForm').addEventListener('submit', (e) => {
            e.preventDefault();
            document.getElementById('confirmModal').style.display = 'flex';
        });

        // 3. SAUVEGARDE (LocalStorage)
        function saveData() {
            localStorage.setItem('push_compte', document.getElementById('push_compte').checked);
            localStorage.setItem('push_messages', document.getElementById('push_messages').checked);
            
            document.getElementById('confirmModal').style.display = 'none';
            document.getElementById('successModal').style.display = 'flex';
        }

        function closeAll() {
            document.querySelectorAll('.overlay').forEach(el => el.style.display = 'none');
        }
    </script>
</body>
</html>