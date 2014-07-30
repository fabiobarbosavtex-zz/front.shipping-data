define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component', 'shipping/setup/extensions'],
(defineComponent, extensions) ->
  ShippingSummary = ->
    @defaultAttrs
      API: null
      data:
        address: {}
        showSummary: false

      templates:
        list:
          name: 'shippingSummary'
          template: 'shipping/template/shippingSummary'

    # Render this component according to the data object
    @render = (data) ->
      require [@attr.templates.list.template], =>
        dust.render @attr.templates.list.name, data, (err, output) =>
          output = $(output).i18n()
          $(@$node).html(output)

    @orderFormUpdated = (evt, orderForm) ->
      @attr.data.address = orderForm.shippingData.address;
      @render(@attr.data)

    @showShippingSummary = (evt, data) ->
      @attr.data.showSummary = data
      @render(@attr.data)

    # Bind events
    @after 'initialize', ->
      @on window, 'orderFormUpdated.vtex', @orderFormUpdated
      @on window, 'showShippingSummary.vtex', @showShippingSummary
      return

  return defineComponent(ShippingSummary)