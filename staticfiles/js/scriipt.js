function scrollToTop() {
    window.scrollTo({ top: 0, behavior: 'smooth' });
}
$(document).ready(function(){
    $(".main-carousel").owlCarousel({
        items: 1,
        loop: true,
        autoplay: true,
        autoplayTimeout: 3000, // Change slide every 3 seconds
        nav: true,  // Navigation buttons
        dots: true  // Dot navigation
    });
});
