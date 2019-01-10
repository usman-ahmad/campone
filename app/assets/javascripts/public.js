// This is a manifest file that'll be compiled into public.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.ui.all
//= require turbolinks
//= require bootstrap-sprockets
//= require jquery.easing.min

$(document).on('turbolinks:load', function () {
    //jQuery to collapse the navbar on scroll
    $(window).scroll(function () {
        if ($(".navbar").offset().top > 10) {
            $(".navbar-fixed-top").addClass("top-nav-collapse");
        } else {
            $(".navbar-fixed-top").removeClass("top-nav-collapse");
        }
    });

    $('.page-scroll a').bind('click', function (event) {
        var $anchor = $(this);
        $('html, body').stop().animate({
            scrollTop: $($anchor.attr('href')).offset().top
        }, 1500, 'easeInOutExpo');
        event.preventDefault();
    });

    $('.carousel').carousel({interval: false});

    function initialize_maps() {
        var myLatlng = new google.maps.LatLng(31.482288, 74.395823);
        var map = document.getElementById('map');
        var mapOptions = {
            center: myLatlng,
            zoom: 15,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var map = new google.maps.Map(map, mapOptions);
        var marker = new google.maps.Marker({
            position: myLatlng,
            map: map,
            title: "TEKNUK"
        });
        marker.setMap(map);
    }

    if (document.getElementById('map')) {
        google.maps.event.addDomListener(window, 'load', initialize_maps);
    }
});
