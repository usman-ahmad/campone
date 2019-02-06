$(document).on('turbolinks:load', function () {
    $("#story_tag_list").tagit({
        autocomplete: {
            source: $('#story_tag_list').data('autocomplete-sourse')
        }
    });

    // UA[2019/01/06] project level variables are valid as long as we reload page on project change
    if ($("#story-detail").data('project')) {
        $("#story-detail").data('project').authenticity_token = $('meta[name="csrf-token"]').attr('content');
        $("#story-detail").data('project').members.unshift({"id": "", "name": "Nobody"});
        // $("#story-detail").data('project').priorities.unshift("Please Select");
    }

    getStory(document.location.hash.substring(1));

    $("#stories").on("click", "li[id^=story_]", function () {
        // getStory($(this).attr('id').replace('story_', ''));
        document.location.hash = $(this).attr('id').replace('story_', '');
    });

    $(document).on('change', '#story-detail-attachment #story_detail_attachments', function () {
        $(".attachment-div").removeClass('hidden');
    });

    // UA[2019/01/06] TODO: check project flow, shall user only be allowed to update in edit mode?
    // i.e. Focused Edit mode, not allowed to close, state_action, delete, attachments, comment etc.
    $(document).on('click', '#story-detail .panel-heading i.fa-pencil', function (e) {
        $('.story-props', '#story-detail').html(Handlebars.partials['stories/_form']({
            story: $('#story-detail').data('storyData'),
            project: $('#story-detail').data('project')
        })).find('.description-textarea').trumbowyg({
            resetCss: true,
            removeformatPasted: true,
            btns: [['bold', 'italic'], ['link'], ['unorderedList', 'orderedList'], ['preformatted'], ['horizontalRule']]
        });
        $(this).hide().next().show().parent().attr('title', 'Update');
        e.preventDefault();
    });

    $(document).on('click', '#story-detail .panel-heading i.fa-floppy-o', function (e) {
        var form = $('.story-props form', '#story-detail');
        var oldThis = $(this);
        $('.story-props > form > .alert-danger > ul', '#story-detail').text('');
        $.post(form.attr('action') + '.json', form.serialize(), function (data) {
            $('#story-detail').data('storyData', data);
            data.description = new Handlebars.SafeString(data.description);
            $('.story-props', '#story-detail').html(Handlebars.partials['stories/_details']({
                story: data
            }));
            oldThis.hide().prev().show().parent().attr('title', 'Edit');
        }, 'json').fail(function (jqXHR) {
            $.each(jqXHR.responseJSON, function (i, error) {
                $('.story-props > form > .alert-danger > ul', '#story-detail').append($('<li>').text(error));
            });
            $('.story-props > form > .alert-danger').show();
        });
        e.preventDefault();
    });
});

$(window).bind('hashchange', function () {
    getStory(document.location.hash.substring(1));
});

function getStory(storyId) {
    var storiesPath = $('a.navbar-brand.caret-before').attr('href');
    var element = $('li#story_' + storyId)[0] || $('li[id^=story_]')[0];
    if (!element) return;
    if ($('.story-selected').attr('id') == $(element).attr('id')) return;
    storyId = $(element).attr('id').replace('story_', '');

    $.get(storiesPath + '/' + storyId + '.json', function (data) {
        data.description = new Handlebars.SafeString(data.description);
        var StoryHTML = HandlebarsTemplates['stories/show']({
            story: data
        });
        var container = '#story-detail';
        $(container).html(StoryHTML).data('storyData', data);
    });

    $('.story-selected').removeClass('story-selected');
    $(element).addClass("story-selected");
    document.location.hash = storyId;
}

$(document).on('ajax:success', 'div#story-detail form#new_comment', function (evt, data, status, xhr) {
    console.log('new comment');
    $('.comments-list').append(Handlebars.partials['comments/_show'](data));
    $('textarea#comment_content').trumbowyg('empty');
    $('.comment-action').addClass('hidden');
});

$(document).on('ajax:success', 'div#story-detail form#new_attachment', function (evt, data, status, xhr) {
    $('.attachment-list').html(Handlebars.partials['attachments/_list']({
        attachments: data,
        resource_id: $('.story-selected')[0].id
    }));

    $(".attachment-div").addClass('hidden');
});
