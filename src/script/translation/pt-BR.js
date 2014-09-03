define = vtex.define || window.define;
require = vtex.curl || window.require;

define(function () {
  return {
    "shipping": {
      "title": 'Entrega',
      "goToPayment": 'Ir para o Pagamento',
      "addressList": {
        "header": 'Escolha o endereço de entrega',
        "selected": 'Selecionado',
        "select": 'Selecionar',
        "editSelectedAddress": 'Modificar endereço selecionado',
        "anotherAddress": 'Entregar em outro endereço'
      },
      "addressForm": {
        "header": 'Cadastrar Novo endereço',
        "dontKnowPostalCode": 'Não sei meu CEP',
        "knowPostalCode": 'Buscar pelo meu CEP',
        "searchAnotherAddress": 'Encontrar CEP de outro endereço',
        "postalCodeVerify": 'Encontramos seu CEP. Por favor, verifique se o endereço está correto.',
        "postalCodeBRA": 'CEP',
        "postalCodeUSA": 'ZIP',
        "postalCodeARG": 'Código Postal (CP)',
        "postalCodeURY": 'Código Postal (CP)',
        "postalCode": 'Código Postal',
        "street": 'Endereço',
        "addressLine1": 'Linha 1 do Endereço',
        "addressLine2": 'Linha 2 do Endereço',
        "number": 'Número',
        "complement": 'Complemento e referência',
        "reference": 'Ponto de referência (ex: Próximo ao parque Itú)',
        "district": 'Distrito',
        "neighborhood": 'Bairro',
        "commercial": 'Endereço comercial',
        "city": 'Cidade',
        "locality": 'Localidade ',
        "state": 'Estado ',
        "region": 'Região ',
        "community": 'Comunidade ',
        "direction": 'Direção',
        "department": 'Departamento',
        "municipality": 'Municipalidade',
        "province": "Província",
        "type": 'Tipo do endereço',
        "receiver": 'Destinatário',
        "deliveryCountry": 'País de entrega',
        "cancelEditAddress": 'Cancelar alterações e voltar para a lista de endereços'
      },
      "addressSearch": {
        "address": 'Endereço',
        "addressExampleARG": 'Ex: Cerrito, 1350, Buenos Aires',
        "addressExampleBRA": 'Ex: Av Dr Cardoso de Melo, 1750, São Paulo',
        "addressExampleCHL": 'Ex: Apoquindo, 3039, Santiago',
        "addressExampleCOL": 'Ex: Calle 93 # 14-20, Bogotá',
        "addressExampleECU": 'Ex: Av Amazonas River, N 37-61, Quito',
        "addressExamplePER": 'Ex: Av. José Pardo, 850, Miraflores, Lima',
        "addressExamplePRY": 'Ex: Avenida Eusebio Ayala, 100, Assunção',
        "addressExampleURY": 'Ex: Bulevar Artigas, 1394, Montevidéu',
        "addressExampleUSA": 'Ex: 225 East 41st Street, New York',
        "postalCodeNotFound": 'Ainda não encotramos seu CEP. Informe mais alguns dados do seu endereço.'
      },
      "countrySelect": {
        "chooseDeliveryCountry": 'Escolha o país de entrega',
        "cancelEditAddress": 'Cancelar alterações e voltar para a lista de endereços'
      },
      "shippingOptions": {
        "shippingOptions": 'Escolha as opções de entrega',
        "chooseShippingOption": 'Escolha o tipo da entrega',
        "followingProducts": 'Produtos de',
        "shippingOption": 'Tipo de Entrega',
        "shippingEstimate": 'Estimativa',
        "ofSeller": 'fornecedor ',
        "deliveryDate": 'Data da Entrega',
        "chooseScheduledDate": 'Escolha sua data de entrega',
        "deliveryHour": 'Hora da entrega',
        "workingDay": 'Até __count__ dia útil',
        "workingDay_plural": 'Até __count__ dias úteis',
        "day": 'Até __count__ dia',
        "day_plural": 'Até __count__ dias',
        "fromToHour": 'Das __from__ às __to__',
        "priceFrom": 'a partir de'
      },
      "shippingSummary": {
        "shipping": 'Entrega:',
        "chooseOtherShippingOption": 'Alterar opções de entrega',
        "atAddressOf": 'No endereço de:'
      }
    },
    "validation": {
      "defaultMessage": 'Este campo parece estar inválido.',
      "type": {
        "email": 'Este campo deve ser um e-mail válido.',
        "url": 'Este campo deve ser uma URL válida.',
        "urlstrict": 'Este campo deve ser uma URL válida.',
        "number": 'Este campo deve ser um número válido.',
        "digits": 'Este campo deve ser um dígito válido.',
        "dateIso": 'Este campo deve ser uma data válida (YYYY-MM-DD).',
        "alphanum": 'Este campo deve ser alfanumérico.',
        "phone": 'Este campo deve ser um número telefone válido.'
      },
      "notnull": 'Este campo não deve ser nulo.',
      "notblank": 'Este campo não deve ser branco.',
      "required": 'Este campo é obrigatório.',
      "regexp": 'Este campo parece estar errado.',
      "min": 'Este campo deve ser maior ou igual a %s.',
      "max": 'Este campo deve ser menor ou igual a %s.',
      "range": 'Este campo deve estar entre %s e %s.',
      "minlength": 'Este campo é muito pequeno. Ele deve ter %s caracteres ou mais.',
      "maxlength": 'Este campo é muito grande. Ele deve ter %s caracteres ou menos.',
      "rangelength": 'O tamanho deste campo é inválido. Ele deve possuir entre %s e %s caracteres.',
      "mincheck": 'Você deve selecionar pelo menos %s opções.',
      "maxcheck": 'Você deve selecionar %s opções ou menos.',
      "rangecheck": 'Você deve selecionar entre %s e %s opções.',
      "equalto": 'Este campo deve ser o mesmo.',
      "postalcode": 'Informe um CEP válido.',
      "alphanumponc": 'Digite apenas números, hífens, pontos e barras',
      "minwords": 'Este campo deve possuir no mínimo %s palavras.',
      "maxwords": 'Este campo deve possuir no máximo %s palavras.',
      "rangewords": 'Este campo deve possuir entre %s e %s palavras.',
      "greaterthan": 'Este campo deve ser maior que %s.',
      "lessthan": 'Este campo deve ser menor que %s.',
      "beforedate": 'Esta data deve ser anterior a %s.',
      "afterdate": 'Esta data deve ser posterior a %s.',
      "americandate": 'Esta data deve ser válida (MM/DD/YYYY).'
    },
    "countries": {
      "ARG": 'Argentina',
      "BRA": 'Brasil',
      "CHL": 'Chile',
      "COL": 'Colômbia',
      "ECU": 'Equador',
      "PER": 'Peru',
      "PRY": 'Paraguai',
      "URY": 'Uruguai',
      "USA": 'EUA'
    },
    "global": {
      "free": 'Grátis',
      "cancel": 'Cancelar',
      "loading": 'Carregando',
      "edit": 'Alterar',
      "save": 'Salvar',
      "waiting": 'Aguardando o preenchimento dos dados',
      "notRequired": 'Opcional'
    }
  }
});