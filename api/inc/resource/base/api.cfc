component extends="cf-compendium.inc.resource.base.base" {
	/* required datasource */
	/* required transport */
	/* required apiRequest */
	public component function init(struct datasource, struct transport, component apiRequest) {
		super.init();
		
		variables.datasource = arguments.datasource;
		variables.transport = arguments.transport;
		variables.apiRequest = arguments.apiRequest;
		variables.apiRequestHead = arguments.apiRequest.getHead();
		variables.apiRequestBody = arguments.apiRequest.getBody();
		variables.apiResponse = variables.transport.theApplication.factories.transient.getResponseForApi();
		variables.apiResponseHead = {};
		variables.apiResponseBody = {};
		
		return this;
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
		
		variables.apiResponse.setHead(variables.apiResponseHead);
		variables.apiResponse.setBody(variables.apiResponseBody);
		
		return variables.apiResponse;
	}
}
