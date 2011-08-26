{
	"applicationSingletons": {
		"apiHandler": "plugins.api.inc.resource.request.apiHandler"
	},
	"applicationTransients": {
		"managerApi": "plugins.api.inc.resource.manager.api",
		"requestForApi": "algid.inc.resource.request.soapJrRequest",
		"responseForApi": "algid.inc.resource.request.soapJrResponse"
	},
	"i18n": {
		"locales": [
			"en_US"
		]
	},
	"key": "api",
	"path": "api/",
	"plugin": "API",
	"prerequisites": {
		"algid": "0.1.3"
	},
	"rewrite": {
		"isEnabled": false,
		"base": "_base"
	},
	"version": "0.1.6"
}
