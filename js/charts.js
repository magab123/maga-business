document.addEventListener('DOMContentLoaded', function() {
    // Animate bars on scroll
    var bars = document.querySelectorAll('.t-bar');
    if (bars.length === 0) return;

    var animated = false;
    var observer = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
            if (entry.isIntersecting && !animated) {
                animated = true;
                bars.forEach(function(bar) {
                    var h = bar.getAttribute('data-height');
                    bar.style.height = h + '%';
                });
                observer.disconnect();
            }
        });
    }, { threshold: 0.3 });

    observer.observe(bars[0].parentElement);

    // Animate SVG line drawing
    var paths = document.querySelectorAll('.t-chart-line');
    paths.forEach(function(path) {
        var length = path.getTotalLength();
        path.style.strokeDasharray = length;
        path.style.strokeDashoffset = length;

        var pathObserver = new IntersectionObserver(function(entries) {
            entries.forEach(function(entry) {
                if (entry.isIntersecting) {
                    path.style.transition = 'stroke-dashoffset 2s ease';
                    path.style.strokeDashoffset = '0';
                    pathObserver.disconnect();
                }
            });
        }, { threshold: 0.3 });

        pathObserver.observe(path.closest('.t-chart-container'));
    });
});
