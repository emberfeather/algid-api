<cfsilent>
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
		locale = transport.theSession.managers.singleton.getSession().getLocale();
		objectSerial = transport.theApplication.managers.singleton.getObjectSerial();
		theURL = transport.theRequest.managers.singleton.getURL();
		apiHandler = transport.theApplication.managers.singleton.getApiHandler();
		
		// Create and store the services manager
		services = transport.theApplication.factories.transient.getManagerService(transport);
		transport.theRequest.managers.singleton.setManagerService(services);
		
		// Create and store the model manager
		models = transport.theApplication.factories.transient.getManagerModel(transport, i18n, locale);
		transport.theRequest.managers.singleton.setManagerModel(models);
		
		// Create and store the api manager
		apis = transport.theApplication.factories.transient.getManagerApi(transport);
		transport.theRequest.managers.singleton.setManagerApi(apis);
		
		profiler.stop('startup');
		
		profiler.start('processing');
		
		apiResponse = apiHandler.handleRequest(transport);
		
		profiler.stop('processing');
	</cfscript>
</cfsilent>
<cfoutput>#apiResponse.getResponse()#</cfoutput>
