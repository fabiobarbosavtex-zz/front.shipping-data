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
    ###
      Slugify
      Usage:
      {myReference|slugify}
    ###
    dust.filters.slugify = (value) ->
      if not value? then return value

      specialChars = "ąàáäâãåæćęèéëêìíïîłńòóöôõøśùúüûñçżź "
      plain = "aaaaaaaaceeeeeiiiilnoooooosuuuunczz-"
      regex = new RegExp '[' + specialChars + ']', 'g'

      value += ""
      return value.replace(regex, (char) -> plain.charAt (specialChars.indexOf char)).toLowerCase()
