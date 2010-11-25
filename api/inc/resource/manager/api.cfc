<cfcomponent extends="algid.inc.resource.base.manager" output="false">
<cfscript>
	public component function init( required struct transport ) {
		super.init();
		
		variables.transport = arguments.transport;
		variables.datasource = variables.transport.theApplication.managers.singleton.getApplication().getDSUpdate();
		
		return this;
	}
</cfscript>
	<cffunction name="get" access="public" returntype="component" output="false">
		<cfargument name="plugin" type="string" required="true" />
		<cfargument name="api" type="string" required="true" />
		<cfargument name="apiRequest" type="component" required="true" />
		
		<cfset var hasTransient = '' />
		<cfset var temp = '' />
		
		<cfset arguments.api = ucase(left(arguments.api, 1)) & right(arguments.api, len(arguments.api) - 1) />
		
		<!--- Use the transient definitions over the convention --->
		<cfinvoke component="#variables.transport.theApplication.factories.transient#" method="hasApi#arguments.api#for#arguments.plugin#" returnvariable="hasTransient" />
		
		<cfif hasTransient>
			<cfinvoke component="#variables.transport.theApplication.factories.transient#" method="getApi#arguments.api#for#arguments.plugin#" returnvariable="temp">
				<cfinvokeargument name="datasource" value="#variables.datasource#" />
				<cfinvokeargument name="transport" value="#variables.transport#" />
				<cfinvokeargument name="apiRequest" value="#arguments.apiRequest#" />
			</cfinvoke>
			
			<cfreturn temp />
		<cfelseif fileExists('/plugins/' & arguments.plugin & '/extend/api/api/api' & arguments.api & '.cfc')>
			<cfinvoke component="#variables.transport.theApplication.factories.transient#" method="setApi#arguments.api#for#arguments.plugin#">
				<cfinvokeargument name="transport" value="plugins.#arguments.plugin#.extend.api.api.api#arguments.api#" />
			</cfinvoke>
			
			<cfreturn createObject('component', 'plugins.' & arguments.plugin & '.extend.api.api.api' & arguments.api).init(variables.datasource, variables.transport, arguments.apiRequest) />
		<cfelse>
			<cfthrow message="Missing Api" detail="Could not find the #arguments.api# api for the #arguments.plugin# plugin" />
		</cfif>
	</cffunction>
</cfcomponent>
