document.addEventListener('DOMContentLoaded', function() {
    var range = document.getElementById('ba-range');
    var overlay = document.getElementById('ba-overlay');
    var handle = document.getElementById('ba-handle');
    var slider = document.getElementById('ba-slider');

    if (!range || !overlay || !handle || !slider) return;

    var overlayImg = overlay.querySelector('.t-slider-img');

    function update(val) {
        var pct = val + '%';
        overlay.style.width = pct;
        handle.style.left = pct;
        // Keep overlay image full width of container
        if (overlayImg && slider.offsetWidth > 0) {
            overlayImg.style.width = slider.offsetWidth + 'px';
        }
    }

    range.addEventListener('input', function() {
        update(this.value);
    });

    window.addEventListener('resize', function() {
        update(range.value);
    });

    update(range.value);
});
