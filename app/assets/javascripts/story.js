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

    // UA[2019/02/13] TODO : change selector for .on( and check #story-detail-attachment #story_detail_attachments
    $(document).on('change', '#story-detail-attachment #story_detail_attachments', function () {
        $(".attachment-div").removeClass('hidden');
    });

    $('#story-detail').on('click', '.panel-heading i.fa-pencil', function (e) {
        $('#story-detail').html(HandlebarsTemplates['stories/edit']({
            story: $('#story-detail').data('storyData'),
            project: $('#story-detail').data('project')
        })).find('.description-textarea').trumbowyg({
            resetCss: true,
            removeformatPasted: true,
            btns: [['bold', 'italic'], ['link'], ['unorderedList', 'orderedList'], ['preformatted'], ['horizontalRule']]
        });
        e.preventDefault();
    });

    $('#story-detail').on('submit', '> form', function (e) {
        var form = $(this);
        form.find('.alert-danger > ul').text('');
        $.post(form.attr('action') + '.json', form.serialize(), function (data) {
            showStory(data);
        }, 'json').fail(function (jqXHR) {
            $.each(jqXHR.responseJSON, function (i, error) {
                form.find('.alert-danger > ul').append($('<li>').text(error));
            });
            form.find('.alert-danger').show();
        });
        e.preventDefault();
    });

    $('#story-detail').on('click', '.panel-heading i.fa-times, .panel-footer button.btn-default', function (e) {
        showStory($('#story-detail').data('storyData'));
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
        showStory(data);
    });
    $('.story-selected').removeClass('story-selected');
    $(element).addClass("story-selected");
    document.location.hash = storyId;
}

function showStory(storyData) {
    storyData.description = new Handlebars.SafeString(storyData.description);
    $('#story-detail').html(HandlebarsTemplates['stories/show']({
        story: storyData
    })).data('storyData', storyData);
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
