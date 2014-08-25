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

      maskedInfoSelector: '.client-masked-info'

    # Render this component according to the data object
    @render = ->
      dust.render template, @attr.data, (err, output) =>
        output = $(output).i18n()
        @$node.html(output)

    @enable = (ev, shippingData, items, sellers, rules, canEditData) ->
      ev?.stopPropagation()

      @attr.data.canEditData = canEditData
      @attr.data.isUsingPostalCode = rules.usePostalCode
      @attr.data.address = shippingData.address
      @attr.data.logisticsInfo = shippingData.logisticsInfo
      @attr.data.shippingOptions = @getShippingOptionsData(shippingData.logisticsInfo, items, sellers)
      @updateShippingOptionsLabels(@attr.data.shippingOptions).then =>
        @render()

    @disable = (ev) ->
      ev?.stopPropagation()
      @$node.html('')

    @showMaskedInfoMessage = (ev) ->
      ev.preventDefault()
      vtex.checkout?.MessageUtils?.showMaskedInfoMessage()

    # Bind events
    @after 'initialize', ->
      @on 'enable.vtex', @enable
      @on 'disable.vtex', @disable
      @on 'click',
        maskedInfoSelector: @showMaskedInfoMessage

  return defineComponent(ShippingSummary, withi18n, withLogisticsInfo)