var ready = function () {
    $(".anchor-container").click(function () {
        window.location = $(this).data('href');
    });

    $(".anchor-container a").click(function (e) {
        e.stopPropagation();
    });
    $(function() {
        $( "#sortable" ).sortable();
    });
};
$(document).ready(ready);
$(document).on('page:load', ready);

