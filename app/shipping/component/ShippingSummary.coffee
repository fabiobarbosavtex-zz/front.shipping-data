define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component', 'shipping/setup/extensions', 'shipping/mixin/withi18n'],
(defineComponent, extensions, withi18n) ->
  ShippingSummary = ->
    @defaultAttrs
      API: null
      data:
        address: {}
        currentCountryName: false
        showSummary: false
      templates:
        list:
          name: 'shippingSummary'
          template: 'shipping/template/shippingSummary'

      changeShippingOptionBtSelector: "#change-other-shipping-option"

    # Render this component according to the data object
    @render = () ->
      data = @attr.data
      if data.address
        require [@attr.templates.list.template], =>
          dust.render @attr.templates.list.name, data, (err, output) =>
            output = $(output).i18n()
            $(@$node).html(output)
      else
        $(@$node).html("")

    @orderFormUpdated = (ev, orderForm) ->
      @attr.data.address = orderForm.shippingData?.address
      @attr.data.currentCountryName = "Brasil"
      @render()

    @showShippingSummary = ->
      @attr.data.showSummary = true
      @render()
      
    @hideShippingSummary = ->
      @attr.data.showSummary = false
      @render()

    @changeShippingOption = (ev, data) ->
      @showShippingSummary false
      $(window).trigger('showAddressList.vtex')

    @onDisableShippingData = () ->
      @showShippingSummary null, true

    @onAddressSelected = (ev, data) ->
      @attr.data.address = data
      @render()

    # Bind events
    @after 'initialize', ->
      @on window, 'addressSelected', @onAddressSelected
      @on window, 'orderFormUpdated.vtex', @orderFormUpdated
      @on window, 'showShippingSummary.vtex', @showShippingSummary
      @on window, 'hideShippingSummary.vtex', @hideShippingSummary
      @on window, 'localeSelected.vtex', @localeUpdate
      @on window, 'disableShippingData.vtex', @onDisableShippingData
      @on window, 'click',
        'changeShippingOptionBtSelector': @changeShippingOption

      if vtexjs?.checkout?.orderForm?
        @orderFormUpdated null, vtexjs.checkout.orderForm

  return defineComponent(ShippingSummary, withi18n)