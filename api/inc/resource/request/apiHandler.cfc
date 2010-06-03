/**
 * Handles requests that come through for the api
 */
component extends="cf-compendium.inc.resource.base.base" {
	/**
	 * Use the request information to find and call the proper api function.
	 */
	public component function handleRequest( struct transport, component apiRequest ) {
		var apiRequestHead = '';
		var apiResponse = '';
		var apiResponseHead = '';
		var exception = '';
		var result = '';
		
		apiResponse = arguments.transport.theApplication.factories.transient.getResponseForApi();
		
		try {
			apiRequestHead = arguments.apiRequest.getHead();
			
			// Validate the basic request elements
			if( !structKeyExists(apiRequestHead, 'plugin') ) {
				throw('validation', 'Missing plugin', 'The API requires the plugin to be part of the request.');
			}
			
			if( !structKeyExists(apiRequestHead, 'service') ) {
				throw('validation', 'Missing service', 'The API requires the service to be part of the request.');
			}
			
			if( !structKeyExists(apiRequestHead, 'action') ) {
				throw('validation', 'Missing service action', 'The API requires the service action to be part of the request.');
			}
			
			apiResponseHead = {
				"plugin" = apiRequestHead.plugin,
				"service" = apiRequestHead.service,
				"action" = apiRequestHead.action,
				"result" = 1
			};
			
			// Determine the service to use
			result = {
				"testing" = 'Testing handler'
			};
			
			if( isQuery(result) ) {
				apiResponseHead['records'] = result.recordCount
			}
			
			apiResponse.setHead(apiResponseHead);
			apiResponse.setBody(result);
		} catch( validation exception ) {
			apiResponse.setHead({
				"result" = 0,
				"errors" = {
					"HEAD" = {
						"validation" = {
							"code" = exception.errorCode,
							"message" = exception.message,
							"detail" = exception.detail
						}
					}
				}
			});
		} catch( any exception ) {
			// TODO log the error
			
			apiResponse.setHead({
				"result" = 0,
				"errors" = {
					"HEAD" = {
						"error" = {
							"code" = exception.errorCode,
							"message" = exception.message,
							"detail" = exception.detail
						}
					}
				}
			});
		}
		
		return apiResponse;
	}
}
