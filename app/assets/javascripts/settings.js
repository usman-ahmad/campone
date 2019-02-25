$(document).on('turbolinks:load', function () {
    $('a.initials').click(function (e) {
        $(this).hide().parents('tr:first').children('td.initials').hide().next().show();
        e.preventDefault();
    });

    $('a.role').click(function (e) {
        $(this).hide().parents('tr:first').children('td.role').hide().next().show();
        e.preventDefault();
    });
});
