var ready = function () {
    $(".project").click(function () {
        window.location = $(this).data('href');
    });

    $(".project a").click(function (e) {
        e.stopPropagation();
    });
};
$(document).ready(ready);
$(document).on('page:load', ready);

