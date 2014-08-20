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

      templates:
        list:
          name: 'shippingSummary'
          template: 'shipping/template/shippingSummary'

      changeShippingOptionBtSelector: "#change-other-shipping-option"

    # Render this component according to the data object
    @render = () ->
      data = @attr.data
      require [@attr.templates.list.template], =>
        dust.render @attr.templates.list.name, data, (err, output) =>
          output = $(output).i18n()
          $(@$node).html(output)

    @orderFormUpdated = (ev, orderForm) ->
      @attr.data.address = orderForm.shippingData?.address
      @attr.data.currentCountryName = "Brasil"

    @changeShippingOption = (ev, data) ->
      @trigger('showAddressList.vtex')

    @addressSelected = (ev, data) ->
      @attr.data.address = data
      @render()

    @enable = (ev) ->
      if ev then ev.stopPropagation()
      @render()

    @disable = (ev) ->
      if ev then ev.stopPropagation()
      @$node.html('')

    # Bind events
    @after 'initialize', ->
      @on 'enable.vtex', @enable
      @on 'disable.vtex', @disable
      @on window, 'addressSelected', @addressSelected
      @on window, 'orderFormUpdated.vtex', @orderFormUpdated
      @on window, 'localeSelected.vtex', @localeUpdate
      @on window, 'click',
        'changeShippingOptionBtSelector': @changeShippingOption

      if vtexjs?.checkout?.orderForm?
        @orderFormUpdated null, vtexjs.checkout.orderForm

  return defineComponent(ShippingSummary, withi18n)