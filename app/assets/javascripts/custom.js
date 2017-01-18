$(document).on('turbolinks:load', function () {

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

    $(function () {
        $(".dragable").sortable({
            update: function (event, ui) {
                $.post($(this).data('update-url'), $(this).sortable('serialize'));
            }
        });
    });

    $('#myTextbox').on('input', function () {
        var hide_todo = $('#hide-todo');
        if ($(this).val().length >= 1) {
            hide_todo.removeClass('customHideEvent');
        }
    });

    $('#close-todo').click(function () {
        $('.add-todo-container').find("input[type=text], textarea").val("");
        $('#hide-todo').addClass('customHideEvent');
    });

    $('.description-textarea').trumbowyg({
        resetCss: true,
        removeformatPasted: true,
        btns: [['bold', 'italic'], ['link'], ['unorderedList', 'orderedList'], ['horizontalRule']]
    });

    $('.description-textarea').on('tbwchange', function () {
        $('.comment-action').removeClass('hidden');
    });

    // UA[2016/12/06] - for "attachments/browse_attachments" affects [tasks, discussions, comments]
    $('.attachment-array').on('input:file').change(function () {
        //console.log('activated....');
        if ($(this).val().length >= 1) {
            $(this).next(".attachment-array-value").text($(this).val());
            $(this).parents('.form-group:first')
                .find('input#add_files_to_project,label[data-myID]').show();
        }
    });

    $('[data-toggle="tooltip"]').tooltip();


    // UA[`2016/11/29`] - Now Not Using this anywhere
    //// for now converting active record errors to string.
    //// We can highlight input labels or fields
    //function prettyErrors(data){
    //  var errors;
    //  for(var key in data){
    //    errors = key + " : " + data[key].join() + '<br />';
    //  }
    //  return errors;
    //}

    // UA[2016/11/29] - evaluate pros/cons of simple ajax call from here as compared to "remote: true" option
    $('form#new_discussion').on('ajax:complete', function (event, xhr, response) {
        //console.log('event', event);
        //console.log('xhr', xhr);
        //console.log('settings', response);
        if (response == 'success') {
            location.reload();
        } else {
            $('#errorMessages').html(xhr.responseJSON.join('<br />'));
        }
    });

    // display browser button with file info when user selected file
    $('#task-detail-attachment #attachments_array_').change(function () {
        $(".attachment-div").removeClass('hidden');
    });

    // TODO: No need any where. Check & Remove it
    //$("div.custom-tab-menu>div.list-group>a").click(function (e) {
    //    e.preventDefault();
    //    $(this).siblings('a.active').removeClass("active");
    //    $(this).addClass("active");
    //    var index = $(this).index();
    //    $("div.custom-tab>div.custom-tab-content").removeClass("active");
    //    $("div.custom-tab>div.custom-tab-content").eq(index).addClass("active");
    //});
});
