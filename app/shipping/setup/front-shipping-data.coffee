
configuration =
  paths:
    'shipping': '/shipui/shipping/'
    'flight': '//walmartv5.vtexlocal.com.br/shipui/libs/flight/'
  pluginPath: '//walmartv5.vtexlocal.com.br/shipui/libs/curl/plugin/'

if vtex.curl.configuration
	paths = _.extend({}, vtex.curl.configuration.paths, configuration.paths)
	configuration['paths'] = paths
	_.extend({}, vtex.curl.configuration, configuration)
else
	vtex.curl.configuration = configuration