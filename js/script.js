$(document).ready(() => {
    $('.t-collapsible-trigger').on('click', function() {
        $(this).next('.t-collapsible-content').toggleClass("t-collapsible-open");
    });
    let isZoomed = false;
    $(".zoom-on-click").each((i, elem) => {
        const $elem = $(elem);
        $elem.on("click", e => {
            if (!isZoomed) {
                $elem.addClass("zoomed-media");
                isZoomed = true;
            } else if (e.target.tagName !== "IMG") {
                $elem.removeClass("zoomed-media")
                isZoomed = false;
            }
        })
    })
})
