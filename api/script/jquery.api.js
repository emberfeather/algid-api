/**
 * API plugin
 */
(function($) {
	$.api = function(head, body, options) {
		var original;
		var opts = $.extend({}, $.api.defaults, options || {});
		
		// Bring in the data
		opts.data = {
			HEAD: JSON.stringify(head),
			BODY: JSON.stringify(body)
		};
		
		var request = $.ajax( opts );
		
		// Add a callback to the ajax Deferred object
		request.done(function(data, textStatus, XMLHttpRequest) {
			// Trigger the events for api alerts
			triggerAlert((!data.HEAD.result ? [ data.HEAD.errors.HEAD.error.message, data.HEAD.errors.HEAD.error.detail ] : undefined), 'errors', opts.triggerElement);
			triggerAlert(data.HEAD.errors, 'errors', opts.triggerElement);
			triggerAlert(data.HEAD.warnings, 'warnings', opts.triggerElement);
			triggerAlert(data.HEAD.successes, 'successes', opts.triggerElement);
			triggerAlert(data.HEAD.messages, 'messages', opts.triggerElement);
		});
		
		return request;
	};
	
	$.api.defaults = {
		dataType: 'json',
		triggerElement: $('body'),
		type: 'post',
		url: '/api'
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
