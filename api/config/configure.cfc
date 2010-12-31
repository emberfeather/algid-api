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
		var options = '';
		var plugin = '';
		var rewrite = '';
		var temp = '';
		var theUrl = '';
		
		// Only do the following if in the admin area
		if (inApi( arguments.theApplication, arguments.targetPage )) {
			// Create a profiler object
			temp = arguments.theApplication.factories.transient.getProfiler(arguments.theApplication.managers.singleton.getApplication().isDevelopment());
			
			arguments.theRequest.managers.singleton.setProfiler( temp );
			
			// Default base
			if ( !structKeyExists(url, '_base') ) {
				url['_base'] = '/index';
			}
			
			// Create the URL object for all the admin requests
			app = arguments.theApplication.managers.singleton.getApplication();
			plugin = arguments.theApplication.managers.plugin.getApi();
			
			arguments.theRequest.webRoot =  app.getPath();
			arguments.theRequest.requestRoot =  plugin.getPath();
			
			options = { start = arguments.theRequest.webRoot & arguments.theRequest.requestRoot };
			
			rewrite = plugin.getRewrite();
			
			if(rewrite.isEnabled) {
				options.rewriteBase = rewrite.base;
				
				theUrl = arguments.theApplication.factories.transient.getUrlRewrite(arguments.theUrl, options);
			} else {
				theUrl = arguments.theApplication.factories.transient.getUrl(arguments.theUrl, options);
			}
			
			arguments.theRequest.managers.singleton.setUrl( theUrl );
		}
	}
</cfscript>
</cfcomponent>
