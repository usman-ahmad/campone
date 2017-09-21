$(document).on('turbolinks:load', function () {
    $("#story_tag_list").tagit({
        autocomplete: {
            source: $('#story_tag_list').data('autocomplete-sourse')
        }
    });

    var storyId = document.location.hash.substring(1);
    getStory(storyId || $('li[id^=story]')[0]);

    $("#stories").on("click", "li[id^=story_]", function(event){
        getStory(this)
    });

    $(document).on('change', '#story-detail-attachment #story_detail_attachments',function () {
        $(".attachment-div").removeClass('hidden');
    });
});


function getStory(storyIdOrElement){
    if(storyIdOrElement === undefined){
        return false;
    }

    var element = storyIdOrElement;
    if(typeof storyIdOrElement === 'string'){
        element = $('#story_'+storyIdOrElement)[0];
    }

    var storyId = element.id.split('_').slice(-1)[0];
    var storiesPath = $('.caret-before').attr('href');
    console.log('storiesPath ', storiesPath );

    $.get(storiesPath + '/'+ storyId +'.json', function (data) {
        var StoryHTML = HandlebarsTemplates['stories/show']({
            story: data
        });
        var container = '#story-detail';
        $(container).html(StoryHTML);
    });

    $('.story-selected').removeClass('story-selected');
    $(element).addClass( "story-selected" );
    document.location.hash = storyId;
}

$(document).on('ajax:success', 'div#story-detail form#new_comment', function(evt, data, status, xhr){
    console.log('new comment');
    $('.comments-list').append(Handlebars.partials['comments/_show'](data));
    $('form#new_comment #comment_content').val('');
});

$(document).on('ajax:success', 'div#story-detail form#new_attachment', function(evt, data, status, xhr){
    $('.attachment-list').html(Handlebars.partials['attachments/_list']({attachments: data}));
    $(".attachment-div").addClass('hidden');
});

$(window).bind('hashchange', function (e) {
    var storyId = document.location.hash.substring(1);
    getStory(storyId);
});

