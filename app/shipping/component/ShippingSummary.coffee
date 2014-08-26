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
        active: false
        address: {}
        multipleSellers: false

      maskedInfoSelector: '.client-masked-info'

    # Render this component according to the data object
    @render = ->
      dust.render template, @attr.data, (err, output) =>
        output = $(output).i18n()
        @$node.html(output)

    @enable = (ev, shippingData, items, sellers, rules, canEditData) ->
      @attr.data.active = true
      ev?.stopPropagation()

      @attr.data.items = items
      @attr.data.sellers = sellers
      @attr.data.canEditData = canEditData
      @attr.data.isUsingPostalCode = rules.usePostalCode
      @attr.data.address = shippingData.address
      @attr.data.logisticsInfo = shippingData.logisticsInfo
      @attr.data.shippingOptions = @getShippingOptionsData(shippingData.logisticsInfo, items, sellers)
      @updateShippingOptionsLabels(@attr.data.shippingOptions).then =>
        @render()

    @disable = (ev) ->
      @attr.data.active = false
      ev?.stopPropagation()
      @$node.html('')

    @addressSelected = (ev, address) ->
      ev?.stopPropagation()
      @attr.data.address = address
      @render() if @attr.data.active

    @deliverySelected = (ev, logisticsInfo, items, sellers) ->
      ev?.stopPropagation()
      @attr.data.logisticsInfo = logisticsInfo
      @attr.data.shippingOptions = @getShippingOptionsData(logisticsInfo, items, sellers)
      @render() if @attr.data.active

    @showMaskedInfoMessage = (ev) ->
      ev.preventDefault()
      vtex.checkout?.MessageUtils?.showMaskedInfoMessage()

    # Bind events
    @after 'initialize', ->
      @on 'enable.vtex', @enable
      @on 'disable.vtex', @disable
      @on 'addressSelected.vtex', @addressSelected
      @on 'deliverySelected.vtex', @deliverySelected
      @on 'click',
        maskedInfoSelector: @showMaskedInfoMessage

  return defineComponent(ShippingSummary, withi18n, withLogisticsInfo)