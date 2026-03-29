$(document).ready(function() {

    const words = ["Бизнесмен", "Лидер", "Визионер", "Предприниматель"];
    const typingSpeed = 70;
    const deletingSpeed = 40;
    const pauseBeforeDelete = 1500;
    const pauseBeforeTyping = 200;

    const $typewriterElement = $('#index-hero-typewriter');
    let wordIndex = 0;
    let charIndex = 0;
    let isDeleting = false;

    function type() {
        const currentWord = words[wordIndex];
        let displayText = '';

        if (isDeleting) {
            displayText = currentWord.substring(0, charIndex - 1);
        } else {
            displayText = currentWord.substring(0, charIndex + 1);
        }

        $typewriterElement.text(displayText);

        if (!isDeleting && charIndex === currentWord.length) {
            isDeleting = true;
            setTimeout(type, pauseBeforeDelete);
            return;
        }

        if (isDeleting && charIndex === 0) {
            isDeleting = false;
            wordIndex = (wordIndex + 1) % words.length;
            setTimeout(type, pauseBeforeTyping);
            return;
        }

        isDeleting ? charIndex-- : charIndex++;

        const speed = isDeleting ? deletingSpeed : typingSpeed;
        setTimeout(type, speed);
    }

    setTimeout(type, 500);

});
