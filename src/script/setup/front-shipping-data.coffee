
configuration =
  paths:
    'shipping': '/front.shipping-data/'
    'state-machine': '//io.vtex.com.br/front-libs/state-machine/2.3.2-vtex/'
    'flight': '//io.vtex.com.br/front-libs/flight/1.1.4-vtex/'
  pluginPath: '//io.vtex.com.br/front-libs/curl/0.8.10-vtex.2/plugin/'

if vtex.curl.configuration
	_.extend(vtex.curl.configuration.paths, configuration.paths)
	_.extend(vtex.curl.configuration.pluginPath, configuration.pluginPath)
else
	vtex.curl.configuration = configuration
