var options = {
  valueNames: [ 'name', 'lang', 'keys', 'chaps' ]
};

var codeToc = new List('code-toc', options);

codeToc.sort('chaps', {alphabet: '2345678901'})

$('.langfilter').click(function() {
    myId = $(this).attr('id')
    currentlyActive = ($(this)).hasClass('success')
    $('.langfilter').removeClass('success')
    if(currentlyActive) {
		codeToc.filter()
	}
	else {
		$(this).addClass('success')
		codeToc.filter(function(item) {
			chaps = item.values().lang.split(",")
            console.log(myId)
			return $.inArray(myId, chaps) !== -1;
		})
	}})


$('.chapfilter').click(function() {
	myId = $(this).attr('id')
	currentlyActive = ($(this)).hasClass('success')
	$('.chapfilter').removeClass('success')
	if(currentlyActive) {
		codeToc.filter()
	}
	else {
		$(this).addClass('success')
		codeToc.filter(function(item) {
			chaps = item.values().chaps.split(",")
			return $.inArray(myId, chaps) !== -1;
		})
	}
})
