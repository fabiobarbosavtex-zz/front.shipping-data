define = vtex.define || define
require = vtex.require || require

define ->
    class Orchestrator
      constructor: (CheckoutMock) ->

        @addressBookComponent = '.address-book'
        @checkout = null

        @startModule = () ->
          console.log("startModule")
          @checkout = new CheckoutMock(@addressBookComponent);
          @checkout.orchestrate()
          @orchestrate();
          @startEventListeners()

        @orchestrate = () ->

        @startEventListeners = ->