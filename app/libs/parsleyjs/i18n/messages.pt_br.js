window.ParsleyConfig = window.ParsleyConfig || {};

(function ($) {
  window.ParsleyConfig = $.extend( true, {}, window.ParsleyConfig, {
    messages: {
      // parsley //////////////////////////////////////
        defaultMessage: "Este campo parece estar inválido."
      , type: {
          email:      "Este campo deve ser um e-mail válido."
        , url:        "Este campo deve ser uma URL válida."
        , urlstrict:  "Este campo deve ser uma URL válida."
        , number:     "Este campo deve ser um número válido."
        , digits:     "Este campo deve ser um dígito válido."
        , dateIso:    "Este campo deve ser uma data válida (YYYY-MM-DD)."
        , alphanum:   "Este campo deve ser alfanumérico."
        , phone:      "Este campo deve ser um número telefone válido."
      }
      , notnull:        "Este campo não deve ser nulo."
      , notblank:       "Este campo não deve ser branco."
      , required:       "Este campo é obrigatório."
      , regexp:         "Este campo parece estar inválido."
      , min:            "Este campo deve ser maior ou igual a %s."
      , max:            "Este campo deve ser menor ou igual a %s."
      , range:          "Este campo deve estar entre %s e %s."
      , minlength:      "Este campo é muito pequeno. Ele deve ter %s caracteres ou mais."
      , maxlength:      "Este campo é muito grande. Ele deve ter %s caracteres ou menos."
      , rangelength:    "O tamanho deste campo é inválido. Ele deve possuir entre %s e %s caracteres."
      , mincheck:       "Você deve selecionar pelo menos %s opções."
      , maxcheck:       "Você deve selecionar %s opções ou menos."
      , rangecheck:     "Você deve selecionar entre %s e %s opções."
      , equalto:        "Este campo deve ser o mesmo."
      // parsley.extend ///////////////////////////////
      , minwords:       "Este campo deve possuir no mínimo %s palavras."
      , maxwords:       "Este campo deve possuir no máximo %s palavras."
      , rangewords:     "Este campo deve possuir entre %s e %s palavras."
      , greaterthan:    "Este campo deve ser maior que %s."
      , lessthan:       "Este campo deve ser menor que %s."
      , beforedate:     "Esta data deve ser anterior a %s."
      , afterdate:      "Esta data deve ser posterior a %s."
    }
  });
}(window.jQuery || window.Zepto));
