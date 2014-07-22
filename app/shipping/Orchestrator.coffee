define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component'
        'example/CheckoutMock'],
  (defineComponent, CheckoutMock) ->
    Orchestrator = ->
      @orchestrate = () =>
        console.log "orchestrate"
        checkout = new CheckoutMock();
        checkout.orchestrate();

      # Bind events
      @startEventListeners = ->
        @on document, 'checkout.openShippingData', @addCountryRule
        @on document, 'checkout.closeShippingData', @render

      @startEventListeners()
      @orchestrate()

    return defineComponent(Orchestrator)