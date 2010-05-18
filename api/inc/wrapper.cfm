<cfsilent>
	<!--- API calls should not show any debugging information --->
	<cfsetting showdebugoutput="false" />
	
	<cfset profiler = request.managers.singleton.getProfiler() />
	
	<cfset profiler.start('startup') />
	
	<!--- Setup a transport object to transport scopes --->
	<cfset transport = {
			theApplication = application,
			theCGI = cgi,
			theCookie = cookie,
			theForm = form,
			theRequest = request,
			theServer = server,
			theSession = session,
			theUrl = url
		} />
	
	<!--- Retrieve the admin objects --->
	<cfset i18n = transport.theApplication.managers.singleton.getI18N() />
	<cfset objectSerial = transport.theApplication.managers.singleton.getObjectSerial() />
	<cfset theURL = transport.theRequest.managers.singleton.getURL() />
	<cfset response = transport.theApplication.factories.transient.getResponseForApi() />
	
	<cfset profiler.stop('startup') />
	
	<cfset profiler.start('processing') />
	
	<cftry>
		<cfset response.setBody({
				"test" = "Yippee!"
			}) />
		
		<cfcatch>
			<cfset response.setHead(
				{
					"result" = 0,
					"errors" = {
						"HEAD" = {
							"sid" = {
								"code" = "#cfcatch.errorCode#",
								"message" = "#replace(cfcatch.message, '"', '\"', 'all')#"
							}
						}
					}
				}
			) />
		</cfcatch>
	</cftry>
	
	<cfset profiler.stop('processing') />
</cfsilent>
<cfoutput>#response.getResponse()#</cfoutput>
