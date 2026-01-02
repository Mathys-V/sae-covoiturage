function switchTab(type) {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.getElementById('btn-' + type).classList.add('active');
    document.getElementById('view-cond').style.display = 'none';
    document.getElementById('view-pass').style.display = 'none';
    
    const targetView = document.getElementById('view-' + type);
    targetView.style.display = 'block';
    targetView.style.opacity = '0';
    setTimeout(() => {
        targetView.style.transition = 'opacity 0.3s ease';
        targetView.style.opacity = '1';
    }, 10);
}