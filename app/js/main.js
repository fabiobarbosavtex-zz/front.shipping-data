'use strict';

var paths = {
    'example': '/shipui/js/'
};

_.extend(vtex.curl.configuration.paths, paths);

vtex.curl(vtex.curl.configuration, 
  ['shipping/component/AddressForm',
   'shipping/component/AddressList',
   'shipping/component/ShippingOptions',
	 'shipping/Orchestrator',
   'example/CheckoutMock',
   'link!shipping/css/main'],
  function(AddressForm, AddressList, ShippingOptions, Orchestrator,  CheckoutMock) {
		var addressBookComponent = '.address-book';
    var addressList = AddressList.attachTo('.address-list-placeholder');
    var addressForm = AddressForm.attachTo('.address-form-placeholder');
    window.shippingOptions = ShippingOptions.attachTo('.address-shipping-options');

		console.log(Orchestrator);
		console.log(CheckoutMock);

		// GEOLOCATION
		window.shippingUsingGeolocation = true;

		// MOCK
		window.mockShippingData = true;

    if (window.mockShippingData) {
			var orchestrator = new Orchestrator(CheckoutMock, addressBookComponent);
			orchestrator.startModule();
    } else {

      var checkout = { API: new vtex.checkout.API() };
      checkout.API.getOrderForm().done(function(data){
        var shippingData = data.shippingData;
        if (shippingData) {
          shippingData.deliveryCountries = _.uniq(_.reduceRight(
            shippingData.logisticsInfo,
            function(memo, l) {
              return memo.concat(l.shipsTo);
            }, []
          ));
          $(addressBookComponent).trigger('updateAddresses', shippingData);
        }

      }).fail(function(){
        // Tratamento de erro
      });

      $(addressBookComponent).on('newAddress addressSelected', function(ev, addressObj){
        var shippingData = { address: addressObj };
        var serializedAttachment = JSON.stringify(shippingData);
        checkout.API.sendAttachment('shippingData', serializedAttachment).done(function(data){
          $(addressBookComponent).trigger('updateAddresses', data.shippingData);
        }).fail(function(){
          // Tratamento de erro
        });
      });

      $(addressBookComponent).trigger('shippingOptionsRender', true);
    }
  }
);