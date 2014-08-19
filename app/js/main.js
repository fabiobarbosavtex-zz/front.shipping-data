'use strict';

var paths = {
  'example': '/front.shipping-data/js/'
};

_.extend(vtex.curl.configuration.paths, paths);

vtex.curl(vtex.curl.configuration, 
  ['shipping/ShippingData',
   'example/CheckoutMock',
   'shipping/component/AddressForm',
   'link!shipping/css/main'],
  function(ShippingData,  CheckoutMock, AddressForm) {

    // FLAGS
    window.shippingUsingGeolocation = true;
    var mockShippingData = false;
    var _API = mockShippingData ? new CheckoutMock() : window.vtexjs.checkout;

    console.log(_API);
    console.log(ShippingData);

    window.vtex.i18n.init();

    // START SHIPPING DATA
    vtexjs.checkout.getOrderForm().done(function(){
      ShippingData.attachTo('#shipping-data',  { API: _API });
    });
  }
);