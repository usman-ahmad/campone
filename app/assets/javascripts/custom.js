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

    $('[data-toggle="tooltip"]').tooltip();


    // TODO: improve this.
    // for now converting active record errors to string.
    // We can highlight input labels or fields
    function prettyErrors(data){
      var errors;
      for(var key in data){
        errors = key + " : " + data[key].join() + '<br />';
      }
      return errors;
    }

    $('form#new_discussion').on('ajax:complete', function(event, xhr, response){
      console.log('event',event);
      console.log('xhr',xhr);
      console.log('settings',response);

      if(response == 'success'){
        location.reload();
      } else {
        $('#errorMessages').html(prettyErrors(xhr.responseJSON));
      }
    });

});

