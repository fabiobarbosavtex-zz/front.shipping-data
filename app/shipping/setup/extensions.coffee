define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class Extensions

    window.ParsleyConfig = $.extend true, {}, window.ParsleyConfig or {},
      validationThreshold: 1
      animate: false

    window.ParsleyValidator.addValidator('alphanumponc',
      (val) ->
        regex = new RegExp(/^[A-Za-zÀ-ž0-9\/\\\-\.\,\s\(\)\'\#ªº]*$/)
        return regex.test(val)
      , 32)

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