var options = {
  valueNames: [ 'name', 'lang', 'keys', 'chaps' ]
};

var codeToc = new List('code-toc', options);

codeToc.sort('chaps', {alphabet: '2345678901'})

var myfilter = function (item) {
    active_lang_filter = $('.langfilter.success').attr('id')
    active_chap_filter = $('.chapfilter.success').attr('id')
    lang = item.values().lang.split(",")
    chaps = item.values().chaps.split(",")
    if (active_lang_filter == null && active_chap_filter == null) {
        return true
    }
    else if(active_lang_filter && active_chap_filter) {
        return ($.inArray(active_lang_filter, lang) !== -1) && ($.inArray(active_chap_filter, chaps) !== -1);
    }
    else if (active_lang_filter) {
        return ($.inArray(active_lang_filter, lang) !== -1)
    }
    else if (active_chap_filter) {
        return $.inArray(active_chap_filter, chaps) !== -1
    }
}

$('.langfilter').click(function() {
    currentlyActive = ($(this)).hasClass('success')
    $('.langfilter').removeClass('success')
    if(!currentlyActive) {
        $(this).addClass('success')
	}
    codeToc.filter(myfilter)
})


$('.chapfilter').click(function() {
	currentlyActive = ($(this)).hasClass('success')
	$('.chapfilter').removeClass('success')
	if(!currentlyActive) {
        $(this).addClass('success')
	}
    codeToc.filter(myfilter)
})
