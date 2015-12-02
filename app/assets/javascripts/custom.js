var ready = function () {
    $(".anchor-container").click(function () {
        window.location = $(this).data('href');
    });

    $(".anchor-container a").click(function (e) {
        e.stopPropagation();
    });
    $(function () {
        $("#sortable").sortable();
    });
    function showGroupFieldsfiles() {
        var hideField_discussion = $('#hideField-files');
        var showField_discussion = $('#showField-files');
        $('.newgroup_icon').click(function () {
            showField_discussion.hide();
            hideField_discussion.removeClass('hide');
        });
    }

    showGroupFieldsfiles();
};
$(document).ready(ready);
$(document).on('page:load', ready);

