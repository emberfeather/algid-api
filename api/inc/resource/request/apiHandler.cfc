/**
 * Handles requests that come through for the api
 */
component extends="cf-compendium.inc.resource.base.base" {
	/**
	 * Use the request information to find and call the proper api function.
	 */
	public component function handleRequest( struct transport, component apiRequest ) {
		var apiResponse = '';
		var exception = '';
		
		apiResponse = arguments.transport.theApplication.factories.transient.getResponseForApi();
		
		try {
			apiResponse.setBody({ "testing" = 'Testing handler' });
		} catch( validation exception ) {
			apiResponse.setHead({
				"result" = 0,
				"errors" = {
					"HEAD" = {
						"validation" = {
							"code" = "#exception.errorCode#",
							"message" = "#replace(exception.message, '"', '\"', 'all')#",
							"detail" = "#replace(exception.detail, '"', '\"', 'all')#"
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
							"code" = "#exception.errorCode#",
							"message" = "#replace(exception.message, '"', '\"', 'all')#",
							"detail" = "#replace(exception.detail, '"', '\"', 'all')#"
						}
					}
				}
			});
		}
		
		return apiResponse;
	}
}
