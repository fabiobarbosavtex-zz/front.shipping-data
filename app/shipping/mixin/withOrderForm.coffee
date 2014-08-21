define = vtex.define || window.define
require = vtex.curl || window.require

define [], () ->
  ->
    @after 'initialize', ->
      # Nothing to do if the user has not defined a handler function
      if typeof @orderFormUpdated isnt 'function'
        return console.warn?('orderFormUpdated not defined and withOrderForm mixin applied.')

      # Set the listener for the orderFormUpdated event
      @on window, 'orderFormUpdated.vtex', @orderFormUpdated

      # If there is an orderform present, use it for initialization
      if vtexjs?.checkout?.orderForm?
        @orderFormUpdated null, vtexjs.checkout.orderForm
