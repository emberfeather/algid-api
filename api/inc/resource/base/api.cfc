component extends="cf-compendium.inc.resource.base.base" {
	public component function init(required struct datasource, required struct transport, required component apiRequest) {
		super.init();
		
		variables.datasource = arguments.datasource;
		variables.transport = arguments.transport;
		variables.services = arguments.transport.theRequest.managers.singleton.getManagerService();
		variables.apiRequest = arguments.apiRequest;
		variables.apiRequestHead = arguments.apiRequest.getHead();
		variables.apiRequestBody = arguments.apiRequest.getBody();
		variables.apiResponse = variables.transport.theApplication.factories.transient.getResponseForApi();
		variables.apiResponseHead = {};
		variables.apiResponseBody = {};
		
		return this;
	}
	
	/**
	 * Adds a notification to the response header.
	 * 
	 * Can also be used for errors, warnings, successes, etc.
	 **/
	public void function addNotifications(required any messages, string type = 'message') {
		var i = 0;
		
		if(not structKeyExists(variables.apiResponseHead, arguments.type) || !isArray(variables.apiResponseHead[arguments.type])) {
			variables.apiResponseHead[arguments.type] = [];
		}
		
		if(not isArray(arguments.messages)) {
			arguments.messages = [ arguments.messages ];
		}
		
		for( i = 1; i <= arrayLen(arguments.messages); i++) {
			arrayAppend(variables.apiResponseHead[arguments.type], arguments.messages[i]);
		}
	}
	
	/**
	 * Generate the response object to send back
	 */
	public component function getApiResponse() {
		variables.apiResponseHead['plugin'] = variables.apiRequestHead.plugin;
		variables.apiResponseHead['service'] = variables.apiRequestHead.service;
		variables.apiResponseHead['action'] = variables.apiRequestHead.action;
		variables.apiResponseHead['result'] = 1;
		
		// Check for a record count
		if( isQuery(variables.apiResponseBody) ) {
			variables.apiResponseHead['records'] = variables.apiResponseBody.recordCount;
		} else if( isArray(variables.apiResponseBody) ) {
			variables.apiResponseHead['records'] = arrayLen(variables.apiResponseBody);
		}
		
		// Convert any nexted queries
		if(!isSimpleValue(variables.apiResponseBody)) {
			variables.apiResponseBody = convertQuery(variables.apiResponseBody);
		}
		
		variables.apiResponse.setHead(variables.apiResponseHead);
		variables.apiResponse.setBody(variables.apiResponseBody);
		
		return variables.apiResponse;
	}
	
	public void function __onRequestStart( required struct __head ) {
		// Do nothing
	}
	
	public void function __onRequestEnd( required struct __head ) {
		// Do nothing
	}
	
	public any function convertQuery( any original ) {
		if(isQuery(arguments.original)) {
			local.results = [];
			local.resultKeys = listToArray(structKeyList(arguments.original));
			
			// Convert the query to a better format for json
			for ( local.i = 1; i <= arguments.original.recordCount; local.i++ ) {
				local.results[local.i] = {}
				
				for ( j = 1; j <= arrayLen(resultKeys); j++ ) {
					if(isDate(arguments.original[resultKeys[j]][i])) {
						local.results[local.i][resultKeys[j]] = getHttpTimeString(arguments.original[resultKeys[j]][i]);
					} else {
						local.results[local.i][resultKeys[j]] = toString(arguments.original[resultKeys[j]][i]);
					}
				}
			}
			
			return local.results;
		} else if (isStruct(arguments.original)) {
			local.keys = listToArray(structKeyList(arguments.original));
			
			for(local.i = 1; local.i <= arrayLen(local.keys); local.i++) {
				local.item = arguments.original[local.keys[local.i]];
				
				if(isQuery(local.item) || isStruct(local.item)) {
					arguments.original[local.keys[local.i]] = convertQuery(local.item);
				}
			}
			
			return arguments.original;
		} else if (isArray(arguments.original)) {
			for(local.i = 1; local.i <= arrayLen(arguments.original); local.i++) {
				local.item = arguments.original[local.i];
				
				if(isQuery(local.item) || isStruct(local.item)) {
					arguments.original[local.i] = convertQuery(local.item);
				}
			}
			
			return arguments.original;
		}
		
		return arguments.original;
	}
}
