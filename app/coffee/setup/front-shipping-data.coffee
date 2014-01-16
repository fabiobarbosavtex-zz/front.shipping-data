vtex.curl.config
  baseUrl: '/shipui/'
  paths:
    'component': 'js/component'
    'countries': 'js/component/countries'
    'template': 'js/templates'
    'translation': 'js/translation'
  apiName: 'require'


i18n.init
  lng: window.vtex.i18n.getLocale(),
  load: 'current',
  fallbackLng: false,
  customLoad: (lng, ns, options, loadComplete) ->
    vtex.require('translation/'+lng).then (dictionary) ->
      prop = {}
      prop.messages = dictionary.validation
      window.ParsleyConfig = $.extend true, {}, window.ParsleyConfig, prop
      return loadComplete(null, dictionary)

window.vtex.i18n.setLocale = (locale) ->
  i18n.setLng locale, ->
    window.vtex.i18n.locale = locale
    $('html').i18n()