component extends="cf-compendium.inc.resource.base.base" {
	/**
	 * Use the request information to find and call the proper api function.
	 */
	public component function handleRequest( struct transport ) {
		var apiResponse = '';
		var errorLogger = '';
		var exception = '';
		var isDevelopment = '';
		
		try {
			apiResponse = getApiResponse(arguments.transport);
		} catch( validation exception ) {
			apiResponse = arguments.transport.theApplication.factories.transient.getResponseForApi();
			
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
			getPageContext().getResponse().setStatus(500, 'Internal Server Error');
			
			arguments.transport.theSession.managers.singleton.getErrorLog().log(exception);
			
			apiResponse = arguments.transport.theApplication.factories.transient.getResponseForApi();
			
			isDevelopment = arguments.transport.theApplication.managers.singleton.getApplication().isDevelopment();
			
			apiResponse.setHead({
				"result" = 0,
				"errors" = {
					"HEAD" = {
						"error" = {
							"code" = exception.errorCode,
							"message" = exception.message,
							"detail" = exception.detail,
							"stacktrace" = (isDevelopment ? exception.stacktrace : '' )
						}
					}
				}
			});
		}
		
		return apiResponse;
	}
	
	private component function getApiResponse(required struct transport) {
		var api = '';
		var apiRequest = '';
		var apiRequestTemp = { 'HEAD' = {}, 'BODY' = {} };
		var apiResponse = '';
		var apis = '';
		
		apiRequest = arguments.transport.theApplication.factories.transient.getRequestForApi();
		
		// Check for the head of the request
		if(structKeyExists(arguments.transport.theForm, 'head')) {
			apiRequestTemp.head = deserializeJSON(arguments.transport.theForm.head);
		} else if(structKeyExists(arguments.transport.theUrl, 'head')) {
			apiRequestTemp.head = deserializeJSON(arguments.transport.theUrl.head);
		}
		
		// Check for the body of the request
		if(structKeyExists(arguments.transport.theForm, 'body')) {
			apiRequestTemp.body = deserializeJSON(arguments.transport.theForm.body);
		} else if(structKeyExists(arguments.transport.theUrl, 'body')) {
			apiRequestTemp.body = deserializeJSON(arguments.transport.theUrl.body);
		}
		
		apiRequest.setRequest(apiRequestTemp);
		
		// TODO Use validation object and regex
		// Validate the basic request elements
		if( !structKeyExists(apiRequestTemp.head, 'plugin') || !len(trim(apiRequestTemp.head.plugin)) ) {
			throw(type = 'validation', message = 'Missing plugin', detail = 'The API requires the plugin to be part of the request.');
		}
		
		if( !structKeyExists(apiRequestTemp.head, 'service') || !len(trim(apiRequestTemp.head.service)) ) {
			throw(type = 'validation', message = 'Missing service', detail = 'The API requires the service to be part of the request.');
		}
		
		if( !structKeyExists(apiRequestTemp.head, 'action') || !len(trim(apiRequestTemp.head.action)) ) {
			throw(type = 'validation', message = 'Missing service action', detail = 'The API requires the service action to be part of the request.');
		}
		
		apis = arguments.transport.theRequest.managers.singleton.getManagerApi();
		
		api = apis.get(apiRequestTemp.head.plugin, apiRequestTemp.head.service, apiRequest);
		
		local.args = apiRequestTemp.body;
		
		// Add in the head so that it can be referenced in the handler
		local.args.__head = apiRequestTemp.head;
		
		api.__onRequestStart(argumentCollection = local.args);
		
		apiResponse = api[apiRequestTemp.head.action](argumentCollection = local.args);
		
		api.__onRequestEnd(argumentCollection = local.args);
		
		return apiResponse;
	}
}
