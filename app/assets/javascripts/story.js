$(document).on('turbolinks:load', function () {
    $("#story_tag_list").tagit({
        autocomplete: {
            source: $('#story_tag_list').data('autocomplete-sourse')
        }
    });

    // Show detail for first story
    firsStory = $('li[id^=story]')[0];
    if (firsStory !== undefined) {
        getStory(firsStory);
    }

    $("#stories").on("click", "li[id^=story_]", function(event){
        getStory(this)
    });

    $(document).on('change', '#story-detail-attachment #story_detail_attachments',function () {
        $(".attachment-div").removeClass('hidden');
    });
});


function getStory(element){
    storyId = element.id.split('_').slice(-1)[0];

    $.get('stories/'+ storyId +'.json', function (data) {
        StoryHTML = HandlebarsTemplates['stories/show']({
            story: data
        });
        container = '#story-detail';
        $(container).html(StoryHTML);
    });

    $('.story-selected').removeClass('story-selected');
    $(element).addClass( "story-selected" );
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
