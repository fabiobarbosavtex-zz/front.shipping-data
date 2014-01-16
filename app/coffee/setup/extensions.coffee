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