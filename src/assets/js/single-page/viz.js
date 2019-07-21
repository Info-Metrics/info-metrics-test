    var pictureList = [
    "http://lorempixel.com/400/200/sports/1",
    "http://lorempixel.com/400/200/sports/2",
    "http://lorempixel.com/400/200/sports/3",
    "http://lorempixel.com/400/200/sports/4",
    "http://lorempixel.com/400/200/sports/5", ];

$('#picDD').change(function () {
    var val = parseInt($('#picDD').val());
    alert(val);
    document.renyi_2.src = "{{root}}assets/img/viz/renyi_2_alpha_05.png";
});