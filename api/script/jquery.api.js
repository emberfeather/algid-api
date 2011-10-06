/**
 * API plugin
 */
(function($) {
	$.api = function(head, body, options) {
		var original;
		var opts = $.extend({}, $.api.defaults, options || {});
		var beforeSend = opts.beforeSend || $.noop;
		
		// We will handle the beforeSend
		delete opts.beforeSend;
		
		// Bring in the data
		opts.data = {
			HEAD: JSON.stringify(head),
			BODY: JSON.stringify(body)
		};
		
		// Add a header for signaling an ajax request
		opts.beforeSend: function(xhr){.
			// Call the original beforeSend
			if(beforeSend) {
				beforeSend.apply(this, arguments);
			}
			
			xhr.setRequestHeader("X-Ajax-Api", "true");
		}
		
		var request = $.ajax( opts );
		
		// Add a callback to the ajax Deferred object
		request.done(function(data, textStatus, XMLHttpRequest) {
			// Trigger the events for api alerts
			if(!data.HEAD.result) {
				$.each(data.HEAD.errors.HEAD, function(index, value) {
					triggerAlert([ value.message, value.detail ], 'errors', opts.triggerElement);
				});
			}
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
