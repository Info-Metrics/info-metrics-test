    var pictureList = [
    "http://lorempixel.com/400/200/sports/1",
    "http://lorempixel.com/400/200/sports/2",
    "http://lorempixel.com/400/200/sports/3",
    "http://lorempixel.com/400/200/sports/4",
    "http://lorempixel.com/400/200/sports/5", ];

$('#picDD').change(function () {
    var val = parseInt($('#picDD').val());
    if (val == 1);
    	document.renyi_2.src = "/assets/img/viz/renyi_2_alpha_05.png";
    	document.renyi_3.src = "/assets/img/viz/renyi_3_alpha_20.png"
    if (val == 2)
    	document.renyi_2.src = "/assets/img/viz/renyi_2_alpha_20.png";
    	document.renyi_3.src = "/assets/img/viz/renyi_3_alpha_20.png";
});