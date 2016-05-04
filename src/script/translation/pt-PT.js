(function(){
var define = vtex.define || window.define;

define(['shipping/script/translation/pt-BR'], function (ptBRTranslation) {
  return $.extend(true, {}, ptBRTranslation, {
    "shipping": {
      "addressForm": {
        "addressLine1": 'Morada Linha 1',
        "addressLine2": 'Morada Linha 2',
      },
      "addressSearch": {
        "dontKnowPostalCode": 'Não sei meu código postal',
        "knowPostalCode": 'Buscar pelo meu código postal'
      }
    },
    "validation": {
      "postalcode": 'Informe um código postal válido.'
    }
  });
});
})();
