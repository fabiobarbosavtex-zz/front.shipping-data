# front.shipping-data

Componente de endereços construído em [Flight](http://flightjs.github.io/).

## Requerimentos

```html
<!-- index.html -->

	<!--[if lt IE 9]>	
	<script src="/shipui/libs/es5-shim/es5-shim.min.js"></script>
	<script src="/shipui/libs/es5-shim/es5-sham.min.js"></script>
	<![endif]-->
	<script src="//io.vtex.com.br/front-libs/jquery/1.8.3/jquery-1.8.3.min.js"></script>
	<script src="//io.vtex.com.br/front-libs/underscore/1.5.2-gentle/underscore-min.js"></script> 
	<script src="//io.vtex.com.br/front-libs/dustjs-linkedin/2.2.2/dust-core-2.2.2.min.js"></script>
	<script src="//io.vtex.com.br/front-libs/dustjs-linkedin-helpers/1.1.1/dust-helpers-1.1.1.js"></script>
	<script src="//io.vtex.com.br/front-libs/flight/1.0.9/flight.min.js"></script>
	
	<script src="//io.vtex.com.br/front-libs/curl/0.8.7-vtex/curl.js"></script>
	
	<!-- Insira a versão que deseja usar aqui -->
	<script src="//io.vtex.com.br/front.shipping-data/1.1.0/js/libs.min.js"></script>
	
	<script src="//io.vtex.com.br/front-libs/front-i18n/0.4.1/vtex-i18n.js"></script>
	
	<!-- Insira a versão que deseja usar aqui -->
	<script src="//io.vtex.com.br/front.shipping-data/1.1.0/js/setup/front-shipping-data.min.js"></script>
```

## Exemplo de uso


```javascript
/* main.js */

'use strict';

// Primeiramente, de require nos componentes
vtex.curl(['component/AddressForm', 'component/AddressList'],
  function(AddressForm, AddressList) {
    // Seletor que engloba os dois componentes
    var addressBookComponent = '.address-book';
    // Seletores onde os componentes serão inseridos
    var addressListComponent = '.address-list-placeholder';
    var addressFormComponent = '.address-form-placeholder';
    
    // Instanciando os componentes
    var addressList = new AddressList(addressListComponent);
    var addressForm = new AddressForm(addressFormComponent);
    
    var checkout = { API: new vtex.checkout.API() };

    // Alimenta componente com endereços da API
    checkout.API.getOrderForm(['shippingData']).done(function(data){
      // Dispara evento (componente é visível a partir deste momento)
      $(addressBookComponent).trigger('updateAddresses', data.shippingData);
    }).fail(function(){
      // Tratamento de erro
    });

    // Escuta eventos
    $(addressBookComponent).on('newAddress addressSelected', function(ev, addressObj){
      // Encapsula em objeto shippingData
      var shippingData = { address: addressObj };
      var serializedAttachment = JSON.stringify(shippingData);
      // Salva na API
      checkout.API.sendAttachment('shippingData', serializedAttachment).done(function(data){
        // Dispara evento com dados atualizados da API
        $(addressBookComponent).trigger('updateAddresses', data.shippingData);
      }).fail(function(){
        // Tratamento de erro
      });;
    });
  }
);
```

## API

A API é baseada em eventos jQuery.

### Eventos Ativos

#### updateAddresses
Dispare este evento para atualizar o objeto shippingData.

### Eventos Passivos

#### newAddress
Este evento é disparado quando o usuário dá submit em um endereço, tanto para casos de novo endereço quanto para casos de edição. O objeto Address é enviado como parâmetro.

#### addressSelected
Este evento é disparado quando o usuário seleciona um endereço da lista de endereços. O objeto Address é enviado como parâmetro.
