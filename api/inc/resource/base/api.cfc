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
	 * Adds a message to the response header.
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
			
			variables.apiResponseBody = convertQuery(variables.apiResponseBody);
		} else if( isArray(variables.apiResponseBody) ) {
			variables.apiResponseHead['records'] = arrayLen(variables.apiResponseBody);
		}
		
		variables.apiResponse.setHead(variables.apiResponseHead);
		variables.apiResponse.setBody(variables.apiResponseBody);
		
		return variables.apiResponse;
	}
	
	private array function convertQuery( query originalResults ) {
		var i = '';
		var j = '';
		var results = [];
		var resultKeys = '';
		
		resultKeys = listToArray(structKeyList(arguments.originalResults));
		
		// Convert the query to a better format for json
		variables.apiResponseBody = [];
		
		for ( i = 1; i <= arguments.originalResults.recordCount; i++ ) {
			results[i] = {}
			
			for ( j = 1; j <= arrayLen(resultKeys); j++ ) {
				results[i][resultKeys[j]] = toString(arguments.originalResults[resultKeys[j]][i]);
			}
		}
		
		return results;
	}
}
