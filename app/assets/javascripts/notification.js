$(document).on('turbolinks:load', function(){
  var is_set = false;
  read_notice = function(id){
    if ($('#'+id).hasClass("info") || $('#'+id+ 'notice').hasClass("info")){
      update_notice(id);
      $('#'+id).removeClass("info");
      $('#'+id+ 'notice').removeClass("info");
      $('#'+id+ 'notice' + " > i").css('color', "#008000");
    }
  };

  update_notice = function (id){
    // GS 20161103 why we are sending an array?
    var array = [id];

    $.ajax({
      url : "/notifications/update",
      type : "patch",
      data: {data_value: JSON.stringify(array)}
    }).done(function(data) {
      // Update unread count
      var newUnreadCount = parseInt($('#badge.notification-badge').text()) - data.decreasedUnreadCount;
      $('#badge.notification-badge').text(newUnreadCount > 0 ? newUnreadCount : '')
    });
  };

  $('ul#notificationList').on('click', 'li', function(){
    $(this).removeClass('notification-unread');
    var notificationId = $(this).data('notification-id');
    update_notice(notificationId)
  });

  /*
   $('.dropdown-menu').on('click', function(event){
   //The event won't be propagated to the document NODE and
   // therefore events delegated to document won't be fired
   event.stopPropagation();
   });
   */

//    Notification Slider JS

  var $L = 1200,
    $menu_navigation = $('#main-nav'),
    $cart_trigger = $('#cd-cart-trigger'),
    $hamburger_icon = $('#cd-hamburger-menu'),
    $lateral_cart = $('#cd-cart'),
    $shadow_layer = $('#cd-shadow-layer');

  //open cart
  $cart_trigger.on('click', function (event) {
    event.preventDefault();
    //close lateral menu (if it's open)
    $menu_navigation.removeClass('speed-in');
    toggle_panel_visibility($lateral_cart, $shadow_layer, $('body'));
  });

  //close lateral cart or lateral menu
  $shadow_layer.on('click', function () {
    $shadow_layer.removeClass('is-visible');
    // firefox transitions break when parent overflow is changed, so we need to wait for the end of the trasition to give the body an overflow hidden
    if ($lateral_cart.hasClass('speed-in')) {
      $lateral_cart.removeClass('speed-in').on('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function () {
        $('body').removeClass('overflow-hidden');
      });
      $menu_navigation.removeClass('speed-in');
    } else {
      $menu_navigation.removeClass('speed-in').on('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function () {
        $('body').removeClass('overflow-hidden');
      });
      $lateral_cart.removeClass('speed-in');
    }
  });

  //move #main-navigation inside header on laptop
  //insert #main-navigation after header on mobile
  move_navigation($menu_navigation, $L);
  $(window).on('resize', function () {
    move_navigation($menu_navigation, $L);

    if ($(window).width() >= $L && $menu_navigation.hasClass('speed-in')) {
      $menu_navigation.removeClass('speed-in');
      $shadow_layer.removeClass('is-visible');
      $('body').removeClass('overflow-hidden');
    }

  });
//    End Notification Slider JS
});



$(function() {
  var user_id = $('#user_id').text().replace(/\s+/, "");
  user_id = user_id.replace('.com','');
  PrivatePub.subscribe('/messages/private/'+user_id, function(data) {
    var message = data.message;
    var message_parts = message.split('|');
    var notice_id = message_parts[0];
    var time_ago_in_words = message_parts[1];
    var  notification = message_parts[2];
    $('#badge').text(parseInt($('#badge').text().replace(/\s+/, "")) +1);
    $('#badge').show();
    $('#notification_table tr:first').before('<tr id='+notice_id+' class=info onclick = read_notice('+notice_id+')><td>'+notification+'</td><td>'+time_ago_in_words+' </td></tr>');
    $.notify(notification, "success");
  });

});

// Start Notification Slider Functions
function toggle_panel_visibility($lateral_panel, $background_layer, $body) {
  if ($lateral_panel.hasClass('speed-in')) {
    // firefox transitions break when parent overflow is changed, so we need to wait for the end of the trasition to give the body an overflow hidden
    $lateral_panel.removeClass('speed-in').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function () {
      $body.removeClass('overflow-hidden');
    });
    $background_layer.removeClass('is-visible');

  } else {
    // Load Notifications List from server
    $.ajax({
      url: "/notifications/index.js"
    }).done(function() {
      console.log('Notifications Loaded successfully.')
    });

    $lateral_panel.addClass('speed-in').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function () {
      $body.addClass('overflow-hidden');
    });
    $background_layer.addClass('is-visible');
  }
}

function move_navigation($navigation, $MQ) {
  if ($(window).width() >= $MQ) {
    $navigation.detach();
    $navigation.appendTo('header');
  } else {
    $navigation.detach();
    $navigation.insertAfter('header');
  }
}
// End Notification Slider Functions