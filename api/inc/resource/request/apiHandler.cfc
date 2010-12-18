<cfcomponent extends="cf-compendium.inc.resource.base.base" output="false">
	<cfscript>
	/**
	 * Use the request information to find and call the proper api function.
	 */
	public component function handleRequest( struct transport ) {
		var apiResponse = '';
		var exception = '';
		
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
			// TODO log the error
			
			apiResponse = arguments.transport.theApplication.factories.transient.getResponseForApi();
			
			apiResponse.setHead({
				"result" = 0,
				"errors" = {
					"HEAD" = {
						"error" = {
							"code" = exception.errorCode,
							"message" = exception.message,
							"detail" = exception.detail,
							"stacktrace" = exception.stacktrace
						}
					}
				}
			});
		}
		
		return apiResponse;
	}
	</cfscript>
	
	<cffunction name="getApiResponse" access="private" returntype="component" output="false">
		<cfargument name="transport" type="struct" required="true" />
		
		<cfscript>
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
			throw('validation', 'Missing plugin', 'The API requires the plugin to be part of the request.');
		}
		
		if( !structKeyExists(apiRequestTemp.head, 'service') || !len(trim(apiRequestTemp.head.service)) ) {
			throw('validation', 'Missing service', 'The API requires the service to be part of the request.');
		}
		
		if( !structKeyExists(apiRequestTemp.head, 'action') || !len(trim(apiRequestTemp.head.action)) ) {
			throw('validation', 'Missing service action', 'The API requires the service action to be part of the request.');
		}
		
		apis = arguments.transport.theRequest.managers.singleton.getManagerApi();
		
		api = apis.get(apiRequestTemp.head.plugin, apiRequestTemp.head.service, apiRequest);
		</cfscript>
		
		<cfinvoke component="#api#" method="#apiRequestTemp.head.action#" argumentcollection="#apiRequestTemp.body#" returnvariable="apiResponse" />
		
		<cfreturn apiResponse />
	</cffunction>
</cfcomponent>
