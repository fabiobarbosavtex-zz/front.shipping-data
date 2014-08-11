define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component', 'shipping/setup/extensions', 'shipping/mixin/withi18n'],
  (defineComponent, extensions, withi18n) ->
    ShippingOptions = ->
      @defaultAttrs
        API: null
        data:
          address: false
          shippingOptions: []
          availableAddresses: []
          logisticsInfo: []
          loading: false
          multipleSellers: false
          items: []
          sellers: []
          showShippingOptions: true

        templates:
          shippingOptions:
            name: 'shippingOptions'
            template: 'shipping/template/shippingOptions'

        addressBookComponentSelector: '.address-book'
        addressFormSelector: '.address-form-new'
        postalCodeSelector: '#ship-postal-code'

      # Render this component according to the data object
      @render = (ev, data) ->
        data = @attr.data if not arguments.slice
        require [@attr.templates.shippingOptions.template], =>
          dust.render @attr.templates.shippingOptions.name, data, (err, output) =>
            output = $(output).i18n()
            @$node.html(output)

      @updateShippingOptions = () ->
        currentShippingOptions = _.find(@attr.data.availableAddresses, (address) =>
          address.addressId == @attr.data.address.addressId
        ).shippingOptions

        # Verifica se existem multiplo sellers
        if currentShippingOptions.length > 1
          currentShippingOptions.multipleSellers = true

        for shipping in currentShippingOptions
          for sla in shipping.slas
            if sla.shippingEstimate isnt undefined and not sla.isScheduled
              require ['shipping/translation/' + @attr.locale], (translation) =>
                @extendTranslations(translation)
                if sla.businessDays
                  sla.deliveryEstimateLabel = i18n.t 'shipping.shippingOptions.workingDay',
                    count: sla.shippingEstimateDays
                else
                  sla.deliveryEstimateLabel = i18n.t 'shipping.shippingOptions.day',
                    count: sla.shippingEstimateDays
                sla.fullEstimateLabel = sla.name + ' - ' + sla.valueLabel + ' - ' + sla.deliveryEstimateLabel

        @attr.data.shippingOptions = currentShippingOptions
        @$node.trigger 'shippingOptionsRender'

      @onOrderFormUpdated = (ev, data) ->
        if (data.shippingData)

          # Verifica se items ou endereços mudaram
          addressesClone = $.map($.extend(true, {}, @attr.data.availableAddresses), (value) -> [value])
          for add in addressesClone
            delete add["logisticsInfo"]
            delete add["shippingOptions"]
            delete add["firstPart"]
            delete add["secondPart"]

          if (JSON.stringify(@attr.data.items) isnt JSON.stringify(data.items)) or
             (JSON.stringify(addressesClone) isnt JSON.stringify(data.shippingData.availableAddresses))
            @attr.data.items = data.items
            @attr.data.availableAddresses = data.shippingData.availableAddresses
            # Cria array de logistics info  e shipping options para cada address
            for address in @attr.data.availableAddresses
              address.logisticsInfo = []
              address.shippingOptions = []

          @attr.data.logisticsInfo = data.shippingData.logisticsInfo
          @attr.data.address = data.shippingData.address
          @attr.data.sellers = data.sellers

          # Povoa os dados do logistics info do endereço selecionado
          currentAddress = _.find @attr.data.availableAddresses, (address) =>
            address.addressId == @attr.data.address.addressId

          if currentAddress
            currentAddress.logisticsInfo = data.shippingData.logisticsInfo
            currentAddress.shippingOptions = @getShippingOptionsData()
            @updateShippingOptions()

      @getShippingOptionsData = ->
        logisticsInfo = []
        currentAddress = _.find @attr.data.availableAddresses, (address) =>
          address.addressId == @attr.data.address.addressId

        # Para cada item
        for logisticItem in currentAddress.logisticsInfo
          item = @attr.data.items[logisticItem.itemIndex]

          # Encontra o seller do item
          seller = _.find @attr.data.sellers, (seller) ->
            return String(seller.id) is String(item.seller)

          # Extende logistics info com o seller e os dados do item
          if seller
            newLogisticItem = _.extend({}, logisticItem, {seller:seller}, {item: item})
            logisticsInfo.push(newLogisticItem)

        # Agrupa os items de logistic info por seller
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

      @onAddressSelected = (evt, address) ->
        currentAddress = _.find @attr.data.availableAddresses, (_address) =>
          _address.addressId == address.addressId

        # Verifica se já tem logistics info e busca na api caso precise
        if not currentAddress.logisticsInfo.length > 0
          @attr.API.sendAttachment "shippingData",
            attachmentId: "shippingData"
            address: currentAddress
            availableAddresses: @attr.data.availableAddresses
            logisticsInfo: @attr.data.logisticsInfo

      @onShowAddressForm = ->
        @attr.data.showShippingOptions = false
        @render()

      @onAddressFormCanceled = ->
        @attr.data.showShippingOptions = true
        @render()

      # Bind events
      @after 'initialize', ->
        @on window, 'localeSelected.vtex', @localeUpdate
        @on window, 'shippingOptionsRender', @render
        @on window, 'orderFormUpdated.vtex', @onOrderFormUpdated
        @on @attr.addressBookComponentSelector, 'addressSelected', @onAddressSelected
        @on window, 'showAddressForm', @onShowAddressForm
        @on window, 'addressFormCanceled', @onAddressFormCanceled

        return
    return defineComponent(ShippingOptions, withi18n)