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

      # Set Parsley language
      window.ParsleyConfig = window.ParsleyConfig or {}
      window.ParsleyConfig.i18n = window.ParsleyConfig.i18n or {}
      window.ParsleyConfig.i18n[@attr.locale] = $.extend(window.ParsleyConfig.i18n[@attr.locale] or {}, i18n.t('validation', returnObjectTrees: true ))

      if window.ParsleyValidator?
        window.ParsleyValidator.addCatalog(@attr.locale, window.ParsleyConfig.i18n[@attr.locale], true)
        window.ParsleyValidator.setLocale(@attr.locale)

    @setLocale = (locale = "pt-BR") ->
      if locale.match('es-')
        @attr.locale = 'es'
      else
        @attr.locale = locale

    @localeSelected = (ev, locale) ->
      @setLocale locale
      @render()

    @after 'initialize', ->
      @on window, 'localeSelected.vtex', @localeSelected