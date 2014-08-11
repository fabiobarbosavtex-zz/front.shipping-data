define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class Extensions
    window.ParsleyConfig = window.ParsleyConfig or {}

    window.ParsleyConfig = $.extend true, {}, window.ParsleyConfig,
      validators:
        alphanumponc: ->
          validate: (val) ->
            regex = new RegExp(/^[A-Za-zÀ-ž0-9\/\\\-\.\,\s\(\)\'\#ªº]*$/)
            return regex.test(val)
          priority: 32
      animate: false

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