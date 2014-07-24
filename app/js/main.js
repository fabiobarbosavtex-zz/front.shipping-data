'use strict';

var paths = {
    'example': '/shipui/js/'
};

_.extend(vtex.curl.configuration.paths, paths);

vtex.curl(vtex.curl.configuration, 
  ['shipping/ShippingData',
   'example/CheckoutMock'],
  function(ShippingData,  CheckoutMock) {

		// FLAGS
		window.shippingUsingGeolocation = true;
		var mockShippingData = true;

		// START SHIPPING DATA
		var shippingData = new ShippingData(mockShippingData ? CheckoutMock : window.vtexjs.checkout);
  }
);