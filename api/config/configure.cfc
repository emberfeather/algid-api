<cfcomponent extends="algid.inc.resource.plugin.configure" output="false">
	<cffunction name="inApi" access="public" returntype="boolean" output="false">
		<cfargument name="theApplication" type="struct" required="true" />
		<cfargument name="targetPage" type="string" required="true" />
		
		<cfset var path = '' />
		
		<!--- Get the path to the base --->
		<cfset path = arguments.theApplication.managers.singleton.getApplication().getPath()
			& arguments.theApplication.managers.plugin.getApi().getPath() />
		
		<!--- Only pages in the root of the path qualify --->
		<cfreturn reFind('^' & path & '[a-zA-Z0-9-\.]*.cfm$', arguments.targetPage) GT 0 />
	</cffunction>
<cfscript>
	public void function onRequestStart(required struct theApplication, required struct theSession, required struct theRequest, required string targetPage) {
		var app = '';
		var plugin = '';
		var temp = '';
		
		// Only do the following if in the admin area
		if (inApi( arguments.theApplication, arguments.targetPage )) {
			// Create a profiler object
			temp = arguments.theApplication.factories.transient.getProfiler(not arguments.theApplication.managers.singleton.getApplication().isProduction());
			
			arguments.theRequest.managers.singleton.setProfiler( temp );
			
			// Default base
			if ( !structKeyExists(url, '_base') ) {
				url['_base'] = '/index';
			}
			
			// Create the URL object for all the admin requests
			app = arguments.theApplication.managers.singleton.getApplication();
			plugin = arguments.theApplication.managers.plugin.getApi();
			temp = arguments.theApplication.factories.transient.getUrlForApi(arguments.theUrl, { start = app.getPath() & plugin.getPath() & '?' });
			
			arguments.theRequest.managers.singleton.setUrl( temp );
		}
	}
</cfscript>
</cfcomponent>
