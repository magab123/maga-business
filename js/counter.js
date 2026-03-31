document.addEventListener('DOMContentLoaded', function() {
    const el = document.getElementById('balance-counter');
    if (!el) return;

    const target = 1247853;
    const duration = 3000;
    const startTime = performance.now();
    const startVal = 127;

    function easeOutExpo(t) {
        return t === 1 ? 1 : 1 - Math.pow(2, -10 * t);
    }

    function formatMoney(n) {
        return '$' + n.toLocaleString('en-US');
    }

    function animate(now) {
        const elapsed = now - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const eased = easeOutExpo(progress);
        const current = Math.floor(startVal + (target - startVal) * eased);
        el.textContent = formatMoney(current);
        if (progress < 1) {
            requestAnimationFrame(animate);
        }
    }

    // Start animation when element is visible
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
            if (entry.isIntersecting) {
                requestAnimationFrame(animate);
                observer.disconnect();
            }
        });
    }, { threshold: 0.5 });

    observer.observe(el);
});
