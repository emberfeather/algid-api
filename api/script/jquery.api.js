/**
 * API plugin
 */
(function($) {
	$.api = function(head, body, options) {
		var original;
		var opts = $.extend({}, $.api.defaults, options);
		
		// Save the original functions for later
		original = {
			success: opts.success
		};
		
		// Override the success function
		opts.success = function(data, textStatus, XMLHttpRequest) {
			// Trigger the events for api alerts
			triggerAlert((!data.HEAD.result ? [ data.HEAD.errors.HEAD.error.message, data.HEAD.errors.HEAD.error.detail ] : undefined), 'errors', opts.triggerElement);
			triggerAlert(data.HEAD.errors, 'errors', opts.triggerElement);
			triggerAlert(data.HEAD.warnings, 'warnings', opts.triggerElement);
			triggerAlert(data.HEAD.successes, 'successes', opts.triggerElement);
			triggerAlert(data.HEAD.messages, 'messages', opts.triggerElement);
			
			// Do the original success functionality
			if(original.success){
				original.success(data, textStatus, XMLHttpRequest);
			}
		};
		
		// Bring in the data
		opts.data = {
			HEAD: JSON.stringify(head),
			BODY: JSON.stringify(body)
		};
		
		$.ajax( opts );
	};
	
	$.api.defaults = {
		dataType: 'json',
		triggerElement: $('body'),
		type: 'post',
		url: $.algid.admin.options.base.url + $.algid.admin.options.base.api
	};
	
	function triggerAlert(alerts, type, element) {
		if (alerts && alerts.length) {
			if(!$.isArray(alerts)) {
				alerts = [ alerts ];
			}
			
			element.trigger('api.' + type, [type, alerts]);
		}
	}
}(jQuery));
