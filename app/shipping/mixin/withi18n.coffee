define = vtex.define || window.define
require = vtex.curl || window.require

define [], () ->
  ->
    @defaultAttrs
      locale: 'pt-BR'

    @extendTranslations = (translation) ->
      if window.vtex.i18n[@attr.locale]
        window.vtex.i18n[@attr.locale] = _.extend(translation, window.vtex.i18n[@attr.locale])
        i18n.addResourceBundle(@attr.locale, 'translation', window.vtex.i18n[@attr.locale])
      else
        i18n.addResourceBundle(@attr.locale, 'translation', translation)

    @setLocale = (locale = "pt-BR") ->
      if locale.match('es-')
        @attr.locale = 'es'
      else
        @attr.locale = locale

    @localeUpdate = (ev, locale) ->
      @setLocale locale
      @render(@attr.data)