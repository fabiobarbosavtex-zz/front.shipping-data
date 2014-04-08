
vtex.preload = [] if not vtex.preload
vtex.preload.push('/shipui/shipping/setup/extensions')

configuration =
  paths:
    'shipping': '/shipui/shipping/'
  preloads:
    vtex.preload

if vtex.curl.configuration
	_.extend(vtex.curl.configuration, configuration)
else
	vtex.curl.configuration = configuration