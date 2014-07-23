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
    var addressList = AddressList.attachTo('.address-list-placeholder');
    var addressForm = AddressForm.attachTo('.address-form-placeholder');
    window.shippingOptions = ShippingOptions.attachTo('.address-shipping-options');

		// FLAGS
		window.shippingUsingGeolocation = true;
		window.mockShippingData = true;

    if (window.mockShippingData) {
			var orchestrator = new Orchestrator(CheckoutMock);
			orchestrator.startModule();
    }
  }
);