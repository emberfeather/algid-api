/**
 * API plugin
 */
;(function($) {
	$.api = function(head, body, options) {
		var opts = $.extend({}, $.api.defaults, options);
		
		opts.data = {
			HEAD: JSON.stringify(head),
			BODY: JSON.stringify(body)
		};
		
		$.ajax( opts );
	};
	
	$.api.defaults = {
		dataType: 'json',
		type: 'post',
		url: $.algid.admin.options.base.url + $.algid.admin.options.base.api
	};
})(jQuery);
