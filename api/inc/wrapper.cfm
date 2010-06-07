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
	
	profiler.stop('startup');
	
	profiler.start('processing');
	
	apiResponse = apiHandler.handleRequest(transport);
	
	profiler.stop('processing');
</cfscript>
<cfoutput>#apiResponse.getResponse()#</cfoutput>
