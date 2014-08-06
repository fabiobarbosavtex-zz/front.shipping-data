define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component', 'shipping/setup/extensions'],
  (defineComponent, extensions) ->
    ShippingOptions = ->
      @defaultAttrs
        locale: 'pt-BR'
        API: null
        data:
          shippingOptions: []
          loading: false
          multipleSellers: false
          items: []
          logisticsInfo: []
          sellers: []

        templates:
          shippingOptions:
            name: 'shippingOptions'
            template: 'shipping/template/shippingOptions'

        addressFormSelector: '.address-form-new'
        postalCodeSelector: '#ship-postal-code'

      # Render this component according to the data object
      @render = (ev, data) ->
        data = @attr.data if not arguments.slice
        require [@attr.templates.shippingOptions.template], =>
          dust.render @attr.templates.shippingOptions.name, data, (err, output) =>
            output = $(output).i18n()
            @$node.html(output)

      @updateShippingOptions = (_data) ->
        # When an event is triggered with an array as an argument
        # like this: $(foo).trigger(['a', 'b', 'c'])
        # The listener function receives it each element as a separate parameter
        # like this: (eventObj, a, b, c)
        # So here, we are transforming it back to an array, removing the eventObj
        data = _data
        if not data then return

        if data.length > 1
          data.multipleSellers = true

        for shipping in data
          for sla in shipping.slas
            if sla.shippingEstimate isnt undefined and not sla.isScheduled
              if sla.businessDays
                sla.deliveryEstimateLabel = i18n.t 'shipping.shippingOptions.workingDay',
                  count: sla.shippingEstimateDays
              else
                sla.deliveryEstimateLabel = i18n.t 'shipping.shippingOptions.day',
                  count: sla.shippingEstimateDays
              sla.fullEstimateLabel = sla.name + ' - ' + sla.valueLabel + ' - ' + sla.deliveryEstimateLabel

        @attr.data.shippingOptions = data
        # console.log data
        @$node.trigger 'shippingOptionsRender'

      @setLocale = (locale = "pt-BR") ->
        if locale.match('es-')
          @attr.locale = 'es'
        else
          @attr.locale = locale
          $.i18n.setLng(@attr.locale)

      @localeUpdate = (ev, locale) ->
        @setLocale locale
        @render(@attr.data)

      @onOrderFormUpdated = (evt, data) ->
        @attr.data.items = data.items
        @attr.data.logisticsInfo = data.shippingData.logisticsInfo
        @attr.data.sellers = data.sellers
        @updateShippingOptions @getShippingOptionsData()

      @getShippingOptionsData = ->
        logisticsInfo = []

        # PARA CADA ITEM
        for logisticItem in @attr.data.logisticsInfo
          item = @attr.data.items[logisticItem.itemIndex]

          # ENCONTRA O SELLER DO ITEM
          seller = _.find @attr.data.sellers, (seller) ->
            return parseInt(seller.id) is parseInt(item.seller)

          # EXTENDE LOGISTICS INFO COM O SELLER E OS DADOS DO ITEM
          if seller
            newLogisticItem = _.extend({}, logisticItem, {seller:seller}, {item: item})
            logisticsInfo.push(newLogisticItem)

        # AGRUPA OS ITEMS DE LOGISTIC INFO POR SELLER
        logisticsBySeller = _.groupBy logisticsInfo, (so) -> return so.seller.id
        logisticsInfoArray = _.map logisticsBySeller, (logistic) ->
          composedLogistic =
            items: []
            seller: {}
            selectedSla: ''
            slas: []

          for logi in logistic
            composedLogistic.items.push(logi.item)
            composedLogistic.seller = logi.seller
            for sla in logi.slas
              sla.isScheduled = sla.availableDeliveryWindows and sla.availableDeliveryWindows.length > 0
              sla.businessDays = (sla.shippingEstimate+'').indexOf('bd') isnt -1
              sla.shippingEstimateDays = parseInt((sla.shippingEstimate+'').replace(/bd|d/,''), 10)
              sla.isSelected = (sla.id is logi.selectedSla)
              sla.valueLabel = if sla.price > 0 then _.intAsCurrency sla.price else i18n.t('global.free')
              sla.taxValueLabel = if sla.tax > 0 then _.intAsCurrency sla.tax else i18n.t('global.free')
            composedLogistic.slas = logi.slas
            selectedSla = _.find logi.slas, (sla) -> sla.name is logi.selectedSla
            composedLogistic.selectedSla = selectedSla

          return composedLogistic
        return logisticsInfoArray

      @onUpdateShippingOptions = () ->
        @updateShippingOptions @getShippingOptionsData()

      # Bind events
      @after 'initialize', ->
        @on window, 'localeSelected.vtex', @localeUpdate
        @on document, 'shippingOptionsRender', @render
        @on document, 'updateShippingOptions', @onUpdateShippingOptions
        @on window, 'orderFormUpdated.vtex', @onOrderFormUpdated

        # guardar items
        # guardar sellers

        return
    return defineComponent(ShippingOptions)