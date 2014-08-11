define = vtex.define || window.define
require = vtex.curl || window.require

define [], () ->
  withi18n = ->
    @defaultAttrs
      locale: 'pt-BR'    

    @extendTranslations = (translation) ->
      if window.vtex.i18n[@attr.locale]
        window.vtex.i18n[@attr.locale] = _.extend(translation, window.vtex.i18n[@attr.locale])
        i18n.addResourceBundle(@attr.locale, 'translation', window.vtex.i18n[@attr.locale])
      else
        i18n.addResourceBundle(@attr.locale, 'translation', translation)