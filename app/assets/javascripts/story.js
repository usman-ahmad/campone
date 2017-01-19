$(document).on('turbolinks:load', function () {
    $("#task_tag_list").tagit({
        autocomplete: {
            source: $('#task_tag_list').data('autocomplete-sourse')
        }
    });
});
