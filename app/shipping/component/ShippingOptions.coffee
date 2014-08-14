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
          deliveryWindows:
            name: 'deliveryWindows'
            template: 'shipping/template/deliveryWindows'

        isScheduledDeliveryAvailable: false
        pickadateFiles: ['shipping/libs/pickadate/picker',
                         'shipping/libs/pickadate/picker-date',
                         'link!shipping/libs/pickadate/classic',
                         'link!shipping/libs/pickadate/classic-date']

        addressBookComponentSelector: '.address-book'
        addressFormSelector: '.address-form-new'
        postalCodeSelector: '#ship-postal-code'
        shippingOptionSelector: '.shipping-option-item'
        pickadateSelector: '.scheduled-sla .datepicker'
        deliveryWindowsSelector: '.delivery-windows-placeholder'

      # Render this component according to the data object
      @render = (options) ->
        data = @attr.data

        requiredFiles = [@attr.templates.shippingOptions.template, @attr.templates.deliveryWindows.template]
        if @attr.isScheduledDeliveryAvailable
          requiredFiles = requiredFiles.concat(@attr.pickadateFiles)

        require requiredFiles, =>
          if options is 'deliveryWindows'
            dust.render @attr.templates.deliveryWindows.name, data, (err, output) =>
              output = $(output).i18n()
              $(@attr.deliveryWindowsSelector).html(output)
          else
            dust.render @attr.templates.shippingOptions.name, data, (err, output) =>
              output = $(output).i18n()
              @$node.html(output)

              # Caso tenha entrega agendada
              if @attr.isScheduledDeliveryAvailable
                # Coloca a tradução correta no pickadate
                $.extend( $.fn.pickadate.defaults, vtex.pickadate[@attr.locale] ) if locale isnt 'en-US'
                # Instancia o picker apenas com as datas possíveis de entrega
                $(@attr.pickadateSelector).pickadate
                  disable: [true].concat(@attr.deliveryDates)
                # Pega a instancia do picker
                picker = $(@attr.pickadateSelector).pickadate('picker')
                # Seleciona a data selecionada
                picker.set 'select',
                  new Date(@attr.data.scheduledSla.deliveryWindow.startDateUtc)
                # Ao selecionar uma data, o evento é disparado
                picker.on 'set', () ->
                  $(window).trigger('newScheduleDateSelected.vtex')


      @updateShippingOptions = (currentShippingOptions) ->
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
        @render()

      @orderFormUpdated = (ev, data) ->
        if data.shippingData
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
            # Cria array de logistics info e shipping options para cada address
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
            @updateShippingOptions(currentAddress.shippingOptions)

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

        # Vamos massagear todo o logistics info
        logisticsInfoArray = _.map logisticsBySeller, (logistic) =>
          composedLogistic =
            items: []
            seller: {}
            selectedSla: ''
            slas: []

          for logi in logistic
            composedLogistic.items.push(logi.item)
            composedLogistic.seller = logi.seller
            for sla, i in logi.slas
              # Ve se SLA em questão já está no array de SLAS computados
              composedSla = _.find composedLogistic.slas, (_sla) -> _sla.id is sla.id

              # Caso nao esteja no array de SLAS computados, o SLA será computado pela primeira vez
              if not composedSla                
                if sla.availableDeliveryWindows and sla.availableDeliveryWindows.length > 0
                  sla.isScheduled = true
                  @attr.isScheduledDeliveryAvailable = true              

                sla.businessDays = (sla.shippingEstimate+'').indexOf('bd') isnt -1
                sla.shippingEstimateDays = parseInt((sla.shippingEstimate+'').replace(/bd|d/,''), 10)
                
                sla.nameAttr = _.plainChars('seller-' + logi.seller.id)
                sla.idAttr = _.plainChars(sla.nameAttr + '-sla-' + sla.id?.replace(/\ /g,''))

                # Caso seja a entrega selecionada
                if sla.id is logi.selectedSla
                  sla.isSelected = true
                  selectedSla = sla

                  if selectedSla.isScheduled
                    deliveryDates = []
                    # Preenche o array de deliveryDates
                    _.each sla.availableDeliveryWindows, (dw) =>
                      date = new Date(dw.startDateUtc)
                      dateAsArray = @dateAsArray(date)

                      # Ve se a data desse deliveryWindow está no array de datas
                      dateIsInArray = _.find deliveryDates, (d) ->
                        d[0] is dateAsArray[0] and d[1] is dateAsArray[1] and d[2] is dateAsArray[2]

                      # Caso a data não tenha sido adicionada, adiciona agora
                      if not dateIsInArray
                        deliveryDates.push dateAsArray

                    # Salva as datas possíveis de entrega para ser usado no render
                    @attr.deliveryDates = deliveryDates

                    # Agrupamos as delivery windows pela suas datas
                    @attr.deliveryWindows = _.groupBy selectedSla.availableDeliveryWindows, (dw) =>
                      return @dateAsString(new Date(dw.startDateUtc))
                    
                    # Atualizamos seus preços e labels
                    @updateDeliveryWindows(sla)

                    # Caso não tenha uma delivery window selecionada
                    if not selectedSla.deliveryWindow
                      # Pegamos a primeira disponível
                      selectedSla.deliveryWindow = @getFirstDeliveryWindow()

                    # Salva a entrega para ser usado no render
                    @attr.data.scheduledSla = selectedSla

                    # Pega as delivery windows para a data selecionada
                    deliveryWindowDate = @dateAsString(new Date(selectedSla.deliveryWindow.startDateUtc))
                    @attr.data.scheduledSla.deliveryWindowsForDate = @attr.deliveryWindows[deliveryWindowDate]                    
              else
                # Caso o SLA já tenha sido computado antes, iremos apenas somar o preço e a taxa
                sla.price += composedSla.price
                sla.tax += composedSla.tax

                if sla.isSelected and sla.isScheduled
                  @updateDeliveryWindows(sla)
                  @attr.data.scheduledSla = selectedSla

              sla.valueLabel = if sla.price > 0 then _.intAsCurrency sla.price else i18n.t('global.free')
              sla.taxValueLabel = if sla.tax > 0 then _.intAsCurrency sla.tax else i18n.t('global.free')

              if not composedSla
                composedLogistic.slas.push(sla)

            composedLogistic.selectedSla = selectedSla

          return composedLogistic

        return logisticsInfoArray

      @dateAsArray = (date) -> [date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()]
      @dateAsString = (date) -> date.getUTCFullYear() + '/' + date.getUTCMonth() + '/' + date.getUTCDate()
      @dateHourMinLabel = (date) -> _.pad(date.getUTCHours(), 2) + ":" + _.pad(date.getUTCMinutes(),2) if date

      @getFirstDeliveryWindow = () ->
        firstDeliveryWindow = null

        # Pegando a primeira delivery window
        for key, dateArray of @attr.deliveryWindows
          for dateWindow in dateArray
            if firstDeliveryWindow is null
              return dateWindow

      @updateDeliveryWindows = (sla) ->
        # Para cada delivery window, iremos criar o seu label e preço
        for key, dateArray of @attr.deliveryWindows
          for dateWindow in dateArray
            if dateWindow.price + sla.price > 0
              dateWindow.valueLabel = _.intAsCurrency dateWindow.price + sla.price
            else
              dateWindow.valueLabel = i18n.t('global.free')

            objTranslation =
              from: @dateHourMinLabel(new Date(dateWindow.startDateUtc))
              to: @dateHourMinLabel(new Date(dateWindow.endDateUtc))
            dateWindow.label = i18n.t('shipping.shippingOptions.fromToHour', objTranslation) + " " + " - " + dateWindow.valueLabel

            if sla.deliveryWindow?.startDateUtc is dateWindow.startDateUtc and
              sla.deliveryWindow.endDateUtc is dateWindow.endDateUtc
                dateWindow.isWindowSelected = true
            else
              dateWindow.isWindowSelected = false


      @newScheduleDateSelected = (ev, data) ->
        date = $(@attr.pickadateSelector).pickadate('get', 'select')?.obj
        deliveryWindowDate = @dateAsString(new Date(date))
        @attr.data.scheduledSla.deliveryWindowsForDate = @attr.deliveryWindows[deliveryWindowDate]
        @render('deliveryWindows')

      @selectShippingOptionHandler = (ev, data) ->
        ev.preventDefault()
        $('input', data.el).attr('value')

      @selectShippingOption = (shippingOption) ->
        console.log 'oi'

      @addressSelected = (ev, address) ->
        currentAddress = _.find @attr.data.availableAddresses, (_address) =>
          _address.addressId == address.addressId

        # Verifica se já tem logistics info e busca na api caso precise
        if not currentAddress.logisticsInfo.length > 0
          @attr.API.sendAttachment "shippingData",
            attachmentId: "shippingData"
            address: currentAddress
            availableAddresses: @attr.data.availableAddresses
            logisticsInfo: @attr.data.logisticsInfo

      @showAddressForm = ->
        @attr.data.showShippingOptions = false
        @render()

      @addressFormCanceled = ->
        @attr.data.showShippingOptions = true
        @render()

      # Bind events
      @after 'initialize', ->
        @on window, 'localeSelected.vtex', @localeUpdate        
        @on window, 'orderFormUpdated.vtex', @orderFormUpdated
        @on @attr.addressBookComponentSelector, 'addressSelected', @addressSelected
        @on window, 'showAddressForm', @showAddressForm
        @on window, 'addressFormCanceled', @addressFormCanceled
        @on window, 'newScheduleDateSelected.vtex', @newScheduleDateSelected
        @on 'click',
          'shippingOptionSelector': @selectShippingOptionHandler

        if vtexjs?.checkout?.orderForm?
          @orderFormUpdated null, vtexjs.checkout.orderForm

    return defineComponent(ShippingOptions, withi18n)