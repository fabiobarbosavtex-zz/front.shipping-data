define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class Extensions
    # Register translation files to load
    window.vtex.i18n = {} if not window.vtex.i18n
    window.vtex.i18n.requireLang = [] if not window.vtex.i18n.requireLang
    window.vtex.i18n.requireLang.push('shipping/translation/')

    ###
      Translate a variable
      'prefix' being the prefix of the dicionary and 'text' you key
      Usage:
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
            regex = new RegExp(/^[A-Za-zÀ-ž0-9\/\\\-\.\,\s\(\)\'\#ªº]*$/)
            return regex.test(val)
          priority: 32
      animate: false

    i18n.init
        customLoad: (lng, ns, options, loadComplete) =>

          if vtex.i18n.requireLang and vtex.curl and require
            translationFiles = []
            for requireLang in vtex.i18n.requireLang
              translationFiles.push(requireLang+lng)
            require(translationFiles).then ->
              loadComplete null, vtex.i18n[lng]

          else
            if vtex.i18n[lng]
              loadComplete null, vtex.i18n[lng]
            else
              loadComplete null, vtex.i18n['pt-BR']

        lng: window.vtex.i18n.getLocale()
        load: 'current'
        fallbackLng: 'pt-BR'