$(document).ready(function(){
    var is_set = false;
    read_notice = function(id)
    {
        if ($('#'+id).hasClass("info") || $('#'+id+ 'notice').hasClass("info"))
        {
            update_notice(id)
            $('#'+id).removeClass("info");
            $('#'+id+ 'notice').removeClass("info");
            $('#'+id+ 'notice' + " > i").css('color', "#008000");
            var notices_count = $('#badge').text().replace(/\s+/, "")
               if(notices_count > 0)
               {
                   notices_count -= 1
                   $('#badge').text(notices_count)
                   $('#badge').show();
                    if(notices_count==0)
                    {
                        $('#badge').hide();
                    }
               }

        }

    }

    update_notice = function (id)
    {

        var array = [id];

        $.ajax({
            url : "/notifications/update",
            type : "patch",
            data: {data_value: JSON.stringify(array)}
        });
    }

        $('.dropdown-menu').on('click', function(event){
            //The event won't be propagated to the document NODE and
            // therefore events delegated to document won't be fired
            event.stopPropagation();
        });


});



$(function() {
    var user_id = $('#user_id').text().replace(/\s+/, "")
        user_id = user_id.replace('.com','');
      PrivatePub.subscribe('/messages/private/'+user_id, function(data) {
        var message = data.message
        var message_parts = message.split('|')
        var notice_id = message_parts[0]
        var time_ago_in_words = message_parts[1]
        var  notification = message_parts[2]
        $('#badge').text(parseInt($('#badge').text().replace(/\s+/, "")) +1)
        $('#badge').show();
        $('#notification_table tr:first').before('<tr id='+notice_id+' class=info onclick = read_notice('+notice_id+')><td>'+notification+'</td><td>'+time_ago_in_words+' </td></tr>');
          $.notify(notification, "success");
      });

});
