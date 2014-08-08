define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component', 'shipping/setup/extensions'],
  (defineComponent, extensions) ->
    ShippingOptions = ->
      @defaultAttrs
        addressBookComponent: '.address-book'
        locale: 'pt-BR'
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
        ).shippingOptions;

        # VERIFICA SE EXISTEM MULTIPLO SELLERS
        if currentShippingOptions.length > 1
          currentShippingOptions.multipleSellers = true


        for shipping in currentShippingOptions
          for sla in shipping.slas
            if sla.shippingEstimate isnt undefined and not sla.isScheduled
              if sla.businessDays
                sla.deliveryEstimateLabel = i18n.t 'shipping.shippingOptions.workingDay',
                  count: sla.shippingEstimateDays
              else
                sla.deliveryEstimateLabel = i18n.t 'shipping.shippingOptions.day',
                  count: sla.shippingEstimateDays
              sla.fullEstimateLabel = sla.name + ' - ' + sla.valueLabel + ' - ' + sla.deliveryEstimateLabel

        @attr.data.shippingOptions = currentShippingOptions
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
        if (data.shippingData)

          # VERIFICA SE ITEMS OU ENDEREÇOS MUDARAM
          addressesClone = $.map($.extend(true, {}, @attr.data.availableAddresses), (value) -> [value]);
          for add in addressesClone
            delete add["logisticsInfo"]
            delete add["shippingOptions"]
            delete add["firstPart"]
            delete add["secondPart"]

          if ((JSON.stringify(@attr.data.items) isnt JSON.stringify(data.items)) or (JSON.stringify(addressesClone) isnt JSON.stringify(data.shippingData.availableAddresses)))
            @attr.data.items = data.items
            @attr.data.availableAddresses = data.shippingData.availableAddresses
            # CRIA ARRAY DE LOGISTICS INFO  E SHIPPING OPTIONS PARA CADA ADDRESS
            for address in @attr.data.availableAddresses
              address.logisticsInfo = []
              address.shippingOptions = []

          @attr.data.logisticsInfo = data.shippingData.logisticsInfo
          @attr.data.address = data.shippingData.address
          @attr.data.sellers = data.sellers

          # POVOA OS DADOS DO LOGISTICS INFO DO ENDEREÇO SELECIONADO
          currentAddress = _.find(@attr.data.availableAddresses, (address) =>
            address.addressId == @attr.data.address.addressId
          )

          if currentAddress
            currentAddress.logisticsInfo = data.shippingData.logisticsInfo
            currentAddress.shippingOptions = @getShippingOptionsData()
            @updateShippingOptions()

      @getShippingOptionsData = ->
        logisticsInfo = []
        currentAddress = _.find(@attr.data.availableAddresses, (address) =>
          address.addressId == @attr.data.address.addressId
        )

        # PARA CADA ITEM
        for logisticItem in currentAddress.logisticsInfo
          item = @attr.data.items[logisticItem.itemIndex]

          # ENCONTRA O SELLER DO ITEM
          seller = _.find @attr.data.sellers, (seller) ->
            return String(seller.id) is String(item.seller)

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

      @onAddressSelected = (evt, address) ->
        currentAddress = _.find(@attr.data.availableAddresses, (_address) => _address.addressId == address.addressId)
        # VERIFICA SE JÁ TEM LOGISTICS INFO E BUSCA NA API CASO PRECISE
        if (not currentAddress.logisticsInfo.length > 0)
          @attr.API.sendAttachment("shippingData", {
            attachmentId: "shippingData"
            address: currentAddress
            availableAddresses: @attr.data.availableAddresses
            logisticsInfo: @attr.data.logisticsInfo
          });

      @onShowAddressForm = ->
        @attr.data.showShippingOptions = false
        @render()

      @onAddressFormCanceled = ->
        @attr.data.showShippingOptions = true
        @render()

      # Bind events
      @after 'initialize', ->
        @on window, 'localeSelected.vtex', @localeUpdate
        @on document, 'shippingOptionsRender', @render
        @on window, 'orderFormUpdated.vtex', @onOrderFormUpdated
        @on @attr.addressBookComponent, 'addressSelected', @onAddressSelected
        @on document, 'showAddressForm', @onShowAddressForm
        @on document, 'addressFormCanceled', @onAddressFormCanceled

        return
    return defineComponent(ShippingOptions)