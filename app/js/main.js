'use strict';

var paths = {
  'example': '/front.shipping-data/js/'
};

_.extend(vtex.curl.configuration.paths, paths);

vtex.curl(vtex.curl.configuration, 
  ['shipping/ShippingData',
   'example/CheckoutMock',
   'shipping/component/AddressForm'],
  function(ShippingData,  CheckoutMock, AddressForm) {

    // FLAGS
    window.shippingUsingGeolocation = true;
    var mockShippingData = false;
    var _API = mockShippingData ? new CheckoutMock() : window.vtexjs.checkout;

    console.log(_API);
    console.log(ShippingData);

    window.vtex.i18n.init();

    // START SHIPPING DATA
    ShippingData.attachTo('.address-book',  { API: _API });
  }
);