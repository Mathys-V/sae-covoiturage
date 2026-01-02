document.addEventListener("DOMContentLoaded", function() {
    // Si l'URL contient une ancre (ex: #avenir)
    if(window.location.hash) {
        // On cherche le bouton qui cible cet ID (ex: data-bs-target="#avenir")
        var trigger = document.querySelector('button[data-bs-target="' + window.location.hash + '"]');
        // Si on le trouve, on simule un clic dessus pour changer l'onglet
        if(trigger) {
            trigger.click();
        }
    }
});