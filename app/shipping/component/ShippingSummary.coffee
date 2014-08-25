define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/setup/extensions',
        'shipping/mixin/withi18n',
        'shipping/mixin/withLogisticsInfo',
        'shipping/template/shippingSummary'],
(defineComponent, extensions, withi18n, withLogisticsInfo, template) ->
  ShippingSummary = ->
    @defaultAttrs
      data:
        address: {}
        multipleSellers: false

    # Render this component according to the data object
    @render = ->
      dust.render template, @attr.data, (err, output) =>
        output = $(output).i18n()
        @$node.html(output)

    @enable = (ev, shippingData, items, sellers, rules) ->
      ev?.stopPropagation()

      @attr.data.isUsingPostalCode = rules.usePostalCode
      @attr.data.address = shippingData.address
      @attr.data.logisticsInfo = shippingData.logisticsInfo
      @attr.data.shippingOptions = @getShippingOptionsData(shippingData.logisticsInfo, items, sellers)
      @updateShippingOptionsLabels(@attr.data.shippingOptions).then =>
        @render()

    @disable = (ev) ->
      ev?.stopPropagation()
      @$node.html('')

    # Bind events
    @after 'initialize', ->
      @on 'enable.vtex', @enable
      @on 'disable.vtex', @disable

  return defineComponent(ShippingSummary, withi18n, withLogisticsInfo)