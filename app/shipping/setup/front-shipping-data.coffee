
configuration =
  paths:
    'shipping': '/shipui/shipping/'
    'flight': '//walmartv5.vtexlocal.com.br/shipui/libs/flight/'

if vtex.curl.configuration
	_.extend(vtex.curl.configuration, configuration)
else
	vtex.curl.configuration = configuration