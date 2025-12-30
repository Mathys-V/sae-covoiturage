{include file='includes/header.tpl'}
<style>
    .rating { display: flex; flex-direction: row-reverse; justify-content: center; gap: 10px; }
    .rating input { display: none; }
    .rating label { font-size: 2.5rem; color: #ddd; cursor: pointer; transition: color 0.2s; }
    .rating input:checked ~ label, .rating label:hover, .rating label:hover ~ label { color: #ffc107; }
</style>

<div class="container mt-5" style="max-width: 600px;">
    <div class="card border-0 shadow-lg rounded-4 p-4">
        <div class="text-center mb-4">
            <img src="/sae-covoiturage/public/uploads/{$destinataire.photo_profil}" class="rounded-circle mb-3 shadow-sm" width="80" height="80" style="object-fit:cover;">
            <h3 class="fw-bold">Notez {$destinataire.prenom}</h3>
            <p class="text-muted">Comment s'est passé le voyage ?</p>
        </div>

        <form action="/sae-covoiturage/public/avis/ajouter" method="POST">
            <input type="hidden" name="id_trajet" value="{$id_trajet}">
            <input type="hidden" name="id_destinataire" value="{$id_dest}">

            <div class="mb-4 text-center">
                <div class="rating">
                    <input type="radio" name="note" id="star5" value="5" required><label for="star5" title="Excellent"><i class="bi bi-star-fill"></i></label>
                    <input type="radio" name="note" id="star4" value="4"><label for="star4" title="Très bien"><i class="bi bi-star-fill"></i></label>
                    <input type="radio" name="note" id="star3" value="3"><label for="star3" title="Bien"><i class="bi bi-star-fill"></i></label>
                    <input type="radio" name="note" id="star2" value="2"><label for="star2" title="Moyen"><i class="bi bi-star-fill"></i></label>
                    <input type="radio" name="note" id="star1" value="1"><label for="star1" title="Mauvais"><i class="bi bi-star-fill"></i></label>
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label fw-bold">Commentaire</label>
                <textarea name="commentaire" class="form-control bg-light border-0" rows="4" placeholder="Conduite agréable, ponctuel..." required></textarea>
            </div>

            <div class="d-grid">
                <button type="submit" class="btn btn-purple rounded-pill py-2 fw-bold">Publier l'avis</button>
            </div>
        </form>
    </div>
</div>
{include file='includes/footer.tpl'}