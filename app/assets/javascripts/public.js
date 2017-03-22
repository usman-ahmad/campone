$(document).on('turbolinks:load', function () {
    //jQuery to collapse the navbar on scroll
    $(window).scroll(function () {
        if ($(".navbar").offset().top > 10) {
            $(".navbar-fixed-top").addClass("top-nav-collapse");
        } else {
            $(".navbar-fixed-top").removeClass("top-nav-collapse");
        }
    });

    function initialize() {
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

    google.maps.event.addDomListener(window, 'load', initialize);
});
