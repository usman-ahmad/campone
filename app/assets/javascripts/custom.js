$(document).on('turbolinks:load', function() {
    var click_on_anchor = false;
    $(".anchor-container").click(function () {
        if (click_on_anchor == true) {
            click_on_anchor = false
        } else {
            window.location = $(this).data('href');
        }
    });

    $(".anchor-container a").click(function (e) {
        click_on_anchor = true;
    });
    $(function () {
        $(".sortable").sortable({
            update: function (event, ui) {
                $.post($(this).data('update-url'), $(this).sortable('serialize'));
            }
        });

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
});