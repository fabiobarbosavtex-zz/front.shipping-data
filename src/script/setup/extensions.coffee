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
      Capitalize
      Usage:
      {@capitalize text=value /}
    ###
    dust.helpers.capitalize = (chunk, ctx, bodies, params) ->
      text = params.text
      return chunk.write(_.capitalizeSentence(text))