define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/setup/extensions',
        'shipping/mixin/withi18n',
        'shipping/mixin/withOrderForm',
        'shipping/template/shippingSummary'],
(defineComponent, extensions, withi18n, withOrderForm, template) ->
  ShippingSummary = ->
    @defaultAttrs
      API: null
      data:
        address: {}

    # Render this component according to the data object
    @render = ->
      dust.render template, @attr.data, (err, output) =>
        output = $(output).i18n()
        @$node.html(output)

    @orderFormUpdated = (ev, orderForm) ->
      @attr.data.address = orderForm.shippingData?.address

    @addressSelected = (ev, data) ->
      @attr.data.address = data
      @render()

    @enable = (ev) ->
      ev?.stopPropagation()
      @render()

    @disable = (ev) ->
      ev?.stopPropagation()
      @$node.html('')

    # Bind events
    @after 'initialize', ->
      @on 'enable.vtex', @enable
      @on 'disable.vtex', @disable
      @on @$node.parent(), 'addressSelected.vtex', @addressSelected

  return defineComponent(ShippingSummary, withi18n, withOrderForm)