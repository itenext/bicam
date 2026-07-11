function scrollToTop() {
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

document.addEventListener('DOMContentLoaded', function () {
    const currentPath = window.location.pathname;
    document.querySelectorAll('.nav-link').forEach(function (link) {
        const linkPath = new URL(link.href, window.location.origin).pathname;
        if (linkPath === currentPath || (currentPath.startsWith(linkPath) && linkPath !== '/')) {
            link.classList.add('active');
        }
    });

    const modal = document.getElementById('medicineModal');
    if (!modal) {
        return;
    }

    modal.addEventListener('show.bs.modal', function (event) {
        const button = event.relatedTarget;
        if (!button) {
            return;
        }

        const name = button.getAttribute('data-name') || 'Product';
        const image = button.getAttribute('data-image') || '';
        const detailUrl = button.getAttribute('data-detail-url') || '#';

        document.getElementById('medicineModalLabel').textContent = name;
        document.getElementById('modal-image').src = image;
        document.getElementById('modal-image').alt = name;
        document.getElementById('modal-title').textContent = button.getAttribute('data-title') || 'Details available on request.';
        document.getElementById('modal-ingredients').textContent = button.getAttribute('data-ingredients') || 'Available on request.';
        document.getElementById('modal-dose').textContent = button.getAttribute('data-dose') || 'Please contact Bichem Laboratories for dosage guidance.';
        document.getElementById('modal-indications').textContent = button.getAttribute('data-indications') || 'Available on request.';
        document.getElementById('modal-detail-link').href = detailUrl;
        document.getElementById('modal-whatsapp-link').href = 'https://wa.me/918083748742?text=' + encodeURIComponent('I want details for ' + name);
    });
});
