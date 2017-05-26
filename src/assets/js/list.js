/**
 * @description determine if an array contains one or more items from another array.
 * @param {array} haystack the array to search.
 * @param {array} arr the array providing items to check for in the haystack.
 * @return {boolean} true|false if haystack contains at least one item from arr.
 */
var findOne = function (haystack, arr) {
    return arr.some(function (v) {
        return haystack.indexOf(v) >= 0;
    });
};

var options = {
  valueNames: [ 'name', 'lang', 'keys', 'chaps' ]
};

var codeToc = new List('code-toc', options);

codeToc.sort('name')

$('.langfilter').click(function() {
    myId = $(this).attr('id')
    currentlyActive = ($(this)).hasClass('btn-success')
    $('.langfilter').removeClass('btn-success')
    if(currentlyActive) {
		codeToc.filter()
	}
	else {
		$(this).addClass('btn-success')
		codeToc.filter(function(item) {
			chaps = item.values().lang.split(",")
            console.log(myId)
			return $.inArray(myId, chaps) !== -1;
		})
	}
/*	if(($(this)).hasClass('active')) {
		$(this).removeClass('active').removeClass('btn-success').addClass('btn-danger')
	}
	else {
		$(this).addClass('active').removeClass('btn-danger').addClass('btn-success')
	}
 	filters = [];
	 ['Stata', 'SAS', 'Python', 'GAMS', 'Limdep','Matlab','Excel'].forEach(function(x) {
	 	if($('#' + x).hasClass('active')) {
	 		filters.push(x);
	 	}
	 })
	codeToc.filter(function(item) {
		return($.inArray(item.values().lang, filters)!==-1);
	});
*/})


$('.chapfilter').click(function() {
	myId = $(this).attr('id')
	currentlyActive = ($(this)).hasClass('btn-success')
	$('.chapfilter').removeClass('btn-success')
	if(currentlyActive) {
		codeToc.filter()
	}
	else {
		$(this).addClass('btn-success')
		codeToc.filter(function(item) {
			chaps = item.values().chaps.split(",")
			return $.inArray(myId, chaps) !== -1;
		})
	}
})
