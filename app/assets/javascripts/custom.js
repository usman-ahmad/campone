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

    $('.commentTextbox').on('input', function () {
        var hideComment = $('.hide-comment');
        var commentBoxValLength = $(this).val().length;
        if (commentBoxValLength >= 1) {
            $(this).trumbowyg({
                resetCss: true,
                removeformatPasted: true,
                btns: [['bold', 'italic'], ['link'], ['unorderedList', 'orderedList'], ['horizontalRule']]
            });
            $(this).parent().find('.trumbowyg-editor').focus();
            hideComment.removeClass('hidden');
        }
    });

    $('#close-todo').click(function () {
        $('.add-todo-container').find("input[type=text], textarea").val("");
        $('#hide-todo').addClass('customHideEvent');
    });

    $('.description-textarea').trumbowyg({
        resetCss: true,
        removeformatPasted: true,
        btns: [['bold', 'italic'], ['link'], ['unorderedList', 'orderedList'], ['preformatted'], ['horizontalRule']]
    }).on('tbwchange', function () {
        $('.comment-action').removeClass('hidden');
    });

    // UA[2016/12/06] - for "attachments/browse_attachments" affects [stories, discussions, comments]
    // $('.attachment-array').on('input:file').change(function () {
    $(document).on('change', 'input:file.attachment-array', function () {
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
    $('#story-detail-attachment #attachments_array_').change(function () {
        $(".attachment-div").removeClass('hidden');
    });

    $('.carousel').carousel({interval: false});

    $(".modal-wide").on("show.bs.modal", function() {
        var height = $(window).height() - 200;
        $(this).find(".modal-body").css("max-height", height);
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

    $('.page-scroll a').bind('click', function(event) {
        var $anchor = $(this);
        $('html, body').stop().animate({
            scrollTop: $($anchor.attr('href')).offset().top
        }, 1500, 'easeInOutExpo');
        event.preventDefault();
    });


    $('#assign_story_to').change(function () {
        $.ajax({
          url: $('#assign_story_to').data('url'),
          type: "PATCH",
          data: {owner_id: $('#assign_story_to option:selected').val()},
          success: function(result){
            $('span#owner').fadeOut(100).text(result.owner).fadeIn(500);
          }
        });
    });

    if ($(window).width() < 841) {
        $('.collapse-span').each(function () {
            $(this).attr('data-toggle', 'collapse');
        })
    }
});

// $('.modal_div').on('show.bs.modal', function (event) {
$(document).on('show.bs.modal', '.modal_div', function(event, data, status, xhr){
    var url_init, url_slid;

    url_init = $(this).find(".item.active").data("url");
    $(".modal-title")
        .html($(this).find(".item.active").data("title"));
    $(".modal-url").attr('href', url_init);

    $('.carousel_div').bind('slid.bs.carousel', function (e) {
        url_slid = $(this).find(".item.active").data("url");
        $(".modal-title")
            .html($(this).find(".item.active").data("title"));
        $(".modal-url").attr('href', url_slid);
    });
});