define = vtex.define || define
require = vtex.require || require

define ->
    class Orchestrator
      constructor: (CheckoutMock, addressBookComponent) ->

        @addressBookComponent = addressBookComponent

        @startModule = (addressBookComponent) ->
          console.log("startModule")
          checkout = new CheckoutMock(addressBookComponent);
          checkout.orchestrate();
          @startEventListeners()

        @orchestrate = () ->
          console.log "orchestrate"

        @startEventListeners = ->