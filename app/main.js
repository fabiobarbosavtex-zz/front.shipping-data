'use strict';

var paths = {
  'example': '/front.shipping-data/js/'
};

_.extend(vtex.curl.configuration.paths, paths);

window.console || (window.console = {
  log: function() {}
});

vtex.curl(vtex.curl.configuration, 
  ['shipping/ShippingData',
   'example/CheckoutMock'],
  function(ShippingData,  CheckoutMock) {

    // Flags
    window.shippingUsingGeolocation = true;
    var mockShippingData = false;
    var _API = mockShippingData ? new CheckoutMock() : window.vtexjs.checkout;

    console.log(_API);
    console.log(ShippingData);

    window.vtex.i18n.init();

    // Start shipping data
    vtexjs.checkout.getOrderForm().done(function(){
      ShippingData.attachTo('#shipping-data',  { API: _API });
    });
  }
);