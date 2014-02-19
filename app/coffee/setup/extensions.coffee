define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class Extensions
    i18n.init
      lng: window.vtex.i18n.getLocale(),
      load: 'current',
      fallbackLng: false,
      customLoad: (lng, ns, options, loadComplete) ->
        dic = require('translation/'+lng)
        if dic.then
          dic.then (dictionary) ->
            prop = {}
            prop.messages = dictionary.validation
            window.ParsleyConfig = $.extend true, {}, window.ParsleyConfig, prop
            return loadComplete(null, dictionary)
        else
          prop = {}
          prop.messages = dic.validation
          window.ParsleyConfig = $.extend true, {}, window.ParsleyConfig, prop
          return loadComplete(null, dic)
        return

    window.vtex.i18n.setLocale = (locale) ->
      i18n.setLng locale, ->
        window.vtex.i18n.locale = locale
        $('html').i18n()

    ###
      Tradução de uma variável
      Sendo prefix o prefixo do dicionário e text a sua chave
      Uso:
      {@i18n prefix="countries." text=country /}
    ###
    dust.helpers.i18n = (chunk, ctx, bodies, params) ->
      prefix = params.prefix
      text = params.text
      return chunk.write(i18n.t(prefix+text))

    window.ParsleyConfig = window.ParsleyConfig or {}

    window.ParsleyConfig = $.extend true, {}, window.ParsleyConfig,
      validators:
        alphanumponc: ->
          validate: (val) ->
            regex = new RegExp(/^[A-Za-zÀ-ú0-9\/\\\-\.\,\s\(\)\'\#]*$/)
            return regex.test(val)
          priority: 32