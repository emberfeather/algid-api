(function(b){typeof define==="function"&&define.amd?define("plugins/api/script/api",["jquery","/cf-compendium/script/jquery.cookie.js"],b):b(jQuery)})(function(b){function d(a,d,e){a&&a.length&&(b.isArray(a)||(a=[a]),e.trigger("api."+d,[d,a]))}b.api=function(a,g,e){var c=b.extend({},b.api.defaults,e||{}),f=c.beforeSend||b.noop;delete c.beforeSend;c.data={HEAD:JSON.stringify(a),BODY:JSON.stringify(g)};c.beforeSend=function(b){f&&f.apply(this,arguments);b.setRequestHeader("X-Ajax-Api","true")};a=b.ajax(c);
a.done(function(a){a.HEAD.result||b.each(a.HEAD.errors.HEAD,function(a,b){d([b.message,b.detail],"errors",c.triggerElement)});d(a.HEAD.errors,"errors",c.triggerElement);d(a.HEAD.warnings,"warnings",c.triggerElement);d(a.HEAD.successes,"successes",c.triggerElement);d(a.HEAD.messages,"messages",c.triggerElement)});return a};b.api.defaults={dataType:"json",triggerElement:b("body"),type:"post",url:"/api"}});
