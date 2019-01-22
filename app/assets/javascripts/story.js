$(document).on('turbolinks:load', function () {
    $("#story_tag_list").tagit({
        autocomplete: {
            source: $('#story_tag_list').data('autocomplete-sourse')
        }
    });

    getStory(document.location.hash.substring(1));

    $("#stories").on("click", "li[id^=story_]", function () {
        // getStory($(this).attr('id').replace('story_', ''));
        document.location.hash = $(this).attr('id').replace('story_', '');
    });

    $(document).on('change', '#story-detail-attachment #story_detail_attachments', function () {
        $(".attachment-div").removeClass('hidden');
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
        $(container).html(StoryHTML);
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
