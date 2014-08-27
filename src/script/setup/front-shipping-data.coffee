
configuration =
  paths:
    'shipping': '/front.shipping-data/'
    'state-machine': '//io.vtex.com.br/front-libs/state-machine/2.3.2/'
    'flight': '//io.vtex.com.br/front-libs/flight/1.1.4-vtex/'
  pluginPath: '//io.vtex.com.br/front-libs/curl/0.8.10-vtex/plugin/'

if vtex.curl.configuration
	_.extend(vtex.curl.configuration.paths, configuration.paths)
else
	vtex.curl.configuration = configuration