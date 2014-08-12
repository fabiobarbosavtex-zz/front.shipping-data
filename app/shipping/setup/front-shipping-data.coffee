
configuration =
  paths:
    'shipping': '/front.shipping-data/shipping/'
    'flight': '//io.vtex.com.br/front-libs/flight/1.1.4-vtex/'
  pluginPath: '//io.vtex.com.br/front-libs/curl/0.8.10-vtex/plugin/'

if vtex.curl.configuration
	_.extend(vtex.curl.configuration.paths, configuration.paths)
else
	vtex.curl.configuration = configuration