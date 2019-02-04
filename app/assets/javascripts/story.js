$(document).on('turbolinks:load', function () {
    $("#story_tag_list").tagit({
        autocomplete: {
            source: $('#story_tag_list').data('autocomplete-sourse')
        }
    });

    $("#story-detail").data('project').members.unshift({"id": "", "name": "Nobody"});
    // $("#story-detail").data('project').priorities.unshift("Please Select");

    getStory(document.location.hash.substring(1));

    $("#stories").on("click", "li[id^=story_]", function () {
        // getStory($(this).attr('id').replace('story_', ''));
        document.location.hash = $(this).attr('id').replace('story_', '');
    });

    $(document).on('change', '#story-detail-attachment #story_detail_attachments', function () {
        $(".attachment-div").removeClass('hidden');
    });

    $(document).on('click', '#story-detail .panel-heading a[data-action=edit]', function (e) {
        var container = $('#story-detail');
        var partial;
        if ($(this).attr('title') == 'Edit') {
            partial = 'stories/_form';
            $(this).attr('title', 'Update');
            $(this).find('i.fa-pencil').hide().next().show();
        } else {
            partial = 'stories/_details';
            $(this).attr('title', 'Edit');
            $(this).find('i.fa-pencil').show().next().hide();
        }
        var storyDetail = Handlebars.partials[partial]({
            story: container.data('storyData'),
            project: container.data('project')
        });
        container.find('.story-props').html(storyDetail);
        container.find('.story-props .description-textarea').trumbowyg({
            resetCss: true,
            removeformatPasted: true,
            btns: [['bold', 'italic'], ['link'], ['unorderedList', 'orderedList'], ['preformatted'], ['horizontalRule']]
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
