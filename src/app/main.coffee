paths = example: "/front.shipping-data/app/mock/"
_.extend vtex.curl.configuration.paths, paths
window.console or= log: ->
vtex.curl vtex.curl.configuration, [
  "shipping/script/ShippingData"
  "example/CheckoutMock"
], (ShippingData, CheckoutMock) ->
  # Flags
  window.shippingUsingGeolocation = true
  mockShippingData = true
  _API = (if mockShippingData then new CheckoutMock() else window.vtexjs.checkout)
  console.log _API
  console.log ShippingData
  window.vtex.i18n.init()

  # Start shipping data
  vtexjs.checkout.getOrderForm().done ->
    ShippingData.attachTo "#shipping-data",
      API: _API