<!--- API calls should not show any debugging information --->
<cfsetting showdebugoutput="false" />

<cfscript>
	profiler = request.managers.singleton.getProfiler();
	
	profiler.start('startup');
	
	// Setup a transport object to transport scopes
	transport = {
			theApplication = application,
			theCGI = cgi,
			theCookie = cookie,
			theForm = form,
			theRequest = request,
			theServer = server,
			theSession = session,
			theUrl = url
		};
	
	// Retrieve the admin objects
	i18n = transport.theApplication.managers.singleton.getI18N();
	objectSerial = transport.theApplication.managers.singleton.getObjectSerial();
	theURL = transport.theRequest.managers.singleton.getURL();
	apiHandler = transport.theApplication.managers.singleton.getApiHandler();
	apiRequest = transport.theApplication.factories.transient.getRequestForApi();
	
	profiler.stop('startup');
	
	profiler.start('setup');
	
	// TODO Remove
	tempRequest = {
		"HEAD" = {
			"plugin" = "content",
			"service" = "content",
			"action" = "getPaths"
		}
	};
	
	// Check for the head of the request
	if(structKeyExists(transport.theUrl, 'head')) {
		tempRequest.head = deserializeJSON(transport.theUrl.head);
	} else if(structKeyExists(transport.theForm, 'head')) {
		tempRequest.head = deserializeJSON(transport.theForm.head);
	}
	
	// Check for the body of the request
	if(structKeyExists(transport.theUrl, 'body')) {
		tempRequest.head = deserializeJSON(transport.theUrl.body);
	} else if(structKeyExists(transport.theForm, 'body')) {
		tempRequest.head = deserializeJSON(transport.theForm.body);
	}
	
	apiRequest.setRequest(tempRequest);
	
	profiler.stop('setup');
	
	profiler.start('processing');
	
	apiResponse = apiHandler.handleRequest(transport, apiRequest);
	
	profiler.stop('processing');
</cfscript>
<cfoutput>#apiResponse.getResponse()#</cfoutput>
