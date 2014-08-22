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
        isActive: false

    # Render this component according to the data object
    @render = ->
      dust.render template, @attr.data, (err, output) =>
        output = $(output).i18n()
        @$node.html(output)

    @orderFormUpdated = (ev, orderForm) ->
      @attr.data.address = orderForm.shippingData?.address

    @addressUpdated = (ev, data) ->
      ev?.stopPropagation()
      @attr.data.address = data
      if @attr.data.isActive
        @render()
      else
        @$node.html('')

    @enable = (ev) ->
      ev?.stopPropagation()
      @attr.data.isActive = true;
      @render()

    @disable = (ev) ->
      ev?.stopPropagation()
      @attr.data.isActive = false;
      @$node.html('')

    # Bind events
    @after 'initialize', ->
      @on 'enable.vtex', @enable
      @on 'disable.vtex', @disable
      @on @$node.parent(), 'addressSelected.vtex', @addressUpdated
      @on 'addressUpdated.vtex', @addressUpdated

  return defineComponent(ShippingSummary, withi18n, withOrderForm)