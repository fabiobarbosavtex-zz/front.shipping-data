define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/setup/extensions',
        'shipping/mixin/withi18n',
        'shipping/mixin/withValidation',
        'shipping/mixin/withOrderForm'],
  (defineComponent, extensions, withi18n, withValidation, withOrderForm) ->
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
          loadingShippingOptions: false

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

        addressFormSelector: '.address-form-new'
        postalCodeSelector: '#ship-postal-code'
        shippingOptionSelector: '.shipping-option-item'
        pickadateSelector: '.datepicker'
        deliveryWindowsSelector: '.delivery-windows'
        deliveryWindowSelector: '.delivery-windows input[type=radio]'

      # Render this component according to the data object
      @render = (options) ->
        data = @attr.data

        requiredFiles = [@attr.templates.shippingOptions.template, @attr.templates.deliveryWindows.template]
        if @attr.isScheduledDeliveryAvailable
          requiredFiles = requiredFiles.concat(@attr.pickadateFiles)

        require requiredFiles, =>
          if options and options.template is 'deliveryWindows'
            # Pega o sla em questão
            currentAddress = @getCurrentAddress()
            data = currentAddress.shippingOptions[options.index].selectedSla

            dust.render @attr.templates.deliveryWindows.name, data, (err, output) =>
              output = $(output).i18n()
              @getDeliveryWindowsSelector(options.index).html(output)
          else
            dust.render @attr.templates.shippingOptions.name, data, (err, output) =>
              output = $(output).i18n()
              @$node.html(output)

              # Caso tenha entrega agendada
              if @attr.isScheduledDeliveryAvailable
                # Coloca a tradução correta no pickadate
                if locale isnt 'en-US'
                  $.extend( $.fn.pickadate.defaults, vtex.pickadate[@attr.locale] )

                _.each @attr.data.shippingOptions, (so) =>
                  if so.selectedSla.isScheduled and
                    @getPickadateSelector(so.index).length > 0
                      # Instancia o picker apenas com as datas possíveis de entrega
                      @getPickadateSelector(so.index).pickadate
                        disable: [true].concat(so.selectedSla.deliveryDates)
                      # Pega a instancia do picker
                      picker = @getPickadateSelector(so.index).pickadate('picker')
                      # Seleciona a data selecionada
                      picker.set 'select',
                        new Date(so.selectedSla.deliveryWindow.startDateUtc)
                      # Ao selecionar uma data, o evento é disparado
                      picker.on 'set', () =>
                        @trigger('scheduleDateSelected.vtex', [so.index])

      @getDeliveryWindowsSelector = (shippingOptionIndex) ->
        $('.shipping-option-'+shippingOptionIndex + ' ' + @attr.deliveryWindowsSelector)

      @getPickadateSelector = (shippingOptionIndex) ->
        $('.shipping-option-'+shippingOptionIndex + ' ' + @attr.pickadateSelector)

      @updateShippingOptionsLabels = (currentShippingOptions) ->
        # Verifica se existem multiplo sellers
        if currentShippingOptions.length > 1
          @attr.data.multipleSellers = true

        require ['shipping/translation/' + @attr.locale], (translation) =>
          @extendTranslations(translation)
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

      @orderFormUpdated = (ev, data) ->
        return unless data.shippingData
        # Verifica se items ou endereços mudaram
        addressesClone = $.map($.extend(true, {}, @attr.data.availableAddresses), (value) -> [value])
        for add in addressesClone
          delete add["logisticsInfo"]
          delete add["shippingOptions"]
          delete add["firstPart"]
          delete add["secondPart"]

        if (JSON.stringify(@attr.data.items) isnt JSON.stringify(data.items)) or
           (JSON.stringify(addressesClone) isnt JSON.stringify(data.shippingData.availableAddresses))
          @attr.data.items = _.map data.items, (item, i) ->
            item.index = i
            return item

          @attr.data.availableAddresses = data.shippingData.availableAddresses
          # Cria array de logistics info e shipping options para cada address
          for address in @attr.data.availableAddresses
            address.logisticsInfo = []
            address.shippingOptions = []

        @attr.data.logisticsInfo = data.shippingData.logisticsInfo
        @attr.data.address = data.shippingData.address
        @attr.data.sellers = data.sellers

        # Povoa os dados do logistics info do endereço selecionado
        currentAddress = @getCurrentAddress()

        if currentAddress
          currentAddress.logisticsInfo = data.shippingData.logisticsInfo
          currentAddress.shippingOptions = @getShippingOptionsData()
          @updateShippingOptionsLabels(currentAddress.shippingOptions)

        @validate()

      @getCurrentAddress = ->
        _.find @attr.data.availableAddresses, (address) =>
          address.addressId is @attr.data.address.addressId

      @getShippingOptionsData = ->
        logisticsInfo = []
        currentAddress = @getCurrentAddress()

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
        index = 0
        logisticsInfoArray = _.map logisticsBySeller, (logistic) =>
          composedLogistic =
            items: []
            seller: {}
            selectedSla: ''
            slas: []
            index: index
          index++

          for logi in logistic
            composedLogistic.items.push(logi.item)
            composedLogistic.seller = logi.seller
            for sla, i in logi.slas
              # Ve se SLA em questão já está no array de SLAS computados
              composedSla = _.find composedLogistic.slas, (_sla) -> _sla.id is sla.id

              # Caso nao esteja no array de SLAS computados, o SLA será computado pela primeira vez
              if not composedSla
                shouldPushThis = true

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
                else
                  sla.isSelected = false

                composedSla = sla
              else
                # Caso o SLA já tenha sido computado antes, iremos apenas somar o preço e a taxa
                composedSla.price += sla.price
                composedSla.tax += sla.tax

              composedSla.valueLabel = if composedSla.price > 0 then _.intAsCurrency composedSla.price else i18n.t('global.free')
              composedSla.taxValueLabel = if composedSla.tax > 0 then _.intAsCurrency composedSla.tax else i18n.t('global.free')

              if shouldPushThis
                shouldPushThis = false
                composedLogistic.slas.push(composedSla)

            composedLogistic.selectedSla = selectedSla

          return composedLogistic

        _.each logisticsInfoArray, (li) =>
          for sla in li.slas
            if sla.isScheduled
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

              # Salva as possíveis datas de entrega para ser usado no pickadate
              sla.deliveryDates = deliveryDates

              # Agrupamos as delivery windows pela suas datas
              sla.deliveryWindows = _.groupBy sla.availableDeliveryWindows, (dw) =>
                return @dateAsString(new Date(dw.startDateUtc))

              # Atualizamos seus preços e labels
              @updateDeliveryWindowsPriceAndLabels(sla)

              # Caso não tenha uma delivery window selecionada
              if not sla.deliveryWindow
                # Pegamos a mais barata
                deliveryWindow = sla.cheapestDeliveryWindow
              else
                deliveryWindow = sla.deliveryWindow

              # Marcamos a delivery window como selecionada
              @selectDeliveryWindow(sla, deliveryWindow)

        return logisticsInfoArray

      @dateAsArray = (date) -> [date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()]
      @dateAsString = (date) -> date.getUTCFullYear() + '/' + date.getUTCMonth() + '/' + date.getUTCDate()
      @dateHourMinLabel = (date) -> _.pad(date.getUTCHours(), 2) + ":" + _.pad(date.getUTCMinutes(),2) if date

      @getCheapestDeliveryWindow = (index, date) ->
        # Pega o sla em questão
        currentAddress = @getCurrentAddress()
        sla = currentAddress.shippingOptions[index].selectedSla

        # Caso a função receba uma data pegamos a
        # delivery window mais barata deste dia
        if date
          dateAsString = @dateAsString(new Date(date))
          deliveryWindows = sla.deliveryWindows[dateAsString]
          cheapestValue = Number.MAX_VALUE
          cheapestDw = null
          for dw in deliveryWindows
            if dw.price + sla.price < cheapestValue
              cheapestValue = dw.price + sla.price
              cheapestDw = dw
          return cheapestDw
        else
          sla.cheapestDeliveryWindow

      @updateDeliveryWindowsPriceAndLabels = (sla) ->
        sla.cheapestValue = sla.cheapestValue or Number.MAX_VALUE

        # Para cada delivery window, iremos criar/atualizar o seu label e preço
        for key, dateArray of sla.deliveryWindows
          for dw, i in dateArray
            dw.index = i
            dw.startDate = new Date(dw.startDateUtc)
            dw.endDate = new Date(dw.endDateUtc)
            dw.dateAsArray = @dateAsArray(dw.startDate)
            dw.dateString = @dateAsString(dw.startDate)
            dw.valueLabel = if dw.price + sla.price > 0 then _.intAsCurrency dw.price + sla.price else i18n.t('global.free')
            objTranslation =
              from: @dateHourMinLabel(dw.startDate)
              to: @dateHourMinLabel(dw.endDate)
            dw.label = i18n.t('shippingData.fromToHour', objTranslation) + ' ' + ' - ' + dw.valueLabel
            dw.timeLabel = i18n.t('shippingData.fromToHour', objTranslation)
            # Guarda o menor preço de entrega agendada para "a partir de"
            if dw.price + sla.price < sla.cheapestValue
              sla.cheapestDeliveryWindow = dw
              sla.cheapestValue = dw.price + sla.price
              sla.cheapestValueLabel = dw.valueLabel
              sla.cheapestEndDate = dw.endDate

        # Reescreve label para entrega agendada
        sla.fullEstimateLabel = sla.name + ' - ' + sla.cheapestValueLabel + ' - ' + _.dateFormat(sla.cheapestEndDate)

      @updateLogisticsInfoModel = (index, deliveryWindow) ->
        currentAddress = @getCurrentAddress()
        shippingOption = currentAddress.shippingOptions[index]

        # Atualiza o logisticsInfo
        for li in currentAddress.logisticsInfo
          # Caso os items do shipping option fale do logistic info em questão
          if _.find(shippingOption.items, (i) -> i.index is li.itemIndex)
            li.deliveryWindow = deliveryWindow

        @selectDeliveryWindow(shippingOption.selectedSla, deliveryWindow)
        @trigger('currentShippingOptions.vtex', currentAddress.logisticsInfo)
        @validate()

      @selectDeliveryWindow = (sla, deliveryWindow) ->
        sla.deliveryWindow = deliveryWindow

        for key, dateAsArray of sla.deliveryWindows
          for dateWindow in dateAsArray
            # Caso a data max e min sejam iguais, significa que é esta
            # delivery window
            if deliveryWindow.startDateUtc is dateWindow.startDateUtc and
              deliveryWindow.endDateUtc is dateWindow.endDateUtc
                # Marcamos-a como selecionada
                dateWindow.isWindowSelected = true
                # Guardamos a referencia para o array de delivery windows
                # desta data
                sla.deliveryWindowsForDate = dateAsArray
            else
              # Devemos sempre deixar a flag de todas as outras como false
              dateWindow.isWindowSelected = false

      @scheduleDateSelected = (ev, index) ->
        # Pega a data seleciona no pickadate
        date = @getPickadateSelector(index).pickadate('get', 'select')?.obj

        # Por default, pegamos a primeira delivery window para esta data
        @updateLogisticsInfoModel(index, @getCheapestDeliveryWindow(index, new Date(date)))

        # Renderizamos as novas delivery windows para a data selecionada
        @render(template: 'deliveryWindows', index: index)

      @deliveryWindowSelected = (ev, data) ->
        # Pega o indice da delivery window
        deliveryWindowIndex = $(data.el).attr('value')
        # Pega o indice da shipping option
        shippingOptionIndex = $(data.el).data('shipping-option')

        # Pega o sla em questão
        currentAddress = @getCurrentAddress()
        sla = currentAddress.shippingOptions[shippingOptionIndex].selectedSla

        # Pega a delivery window através do seu indíce
        deliveryWindow = sla.deliveryWindowsForDate[deliveryWindowIndex]

        # Atualizamos o modelo
        @updateLogisticsInfoModel(shippingOptionIndex, deliveryWindow)

      @selectShippingOptionHandler = (ev, data) ->
        ev.preventDefault()
        selectedSla = $('input', data.el).attr('value')
        shippingOptionIndex = $('input', data.el).data('shipping-option')
        @selectShippingOption(shippingOptionIndex, selectedSla)

      @selectShippingOption = (shippingOptionIndex, selectedSla) ->
        # Pega o shipping option
        currentAddress = @getCurrentAddress()
        shippingOption = currentAddress.shippingOptions[shippingOptionIndex]

        # Troca o selected sla
        for li in currentAddress.logisticsInfo
          # Caso os items do shipping option fale do logistic info em questão
          if _.find(shippingOption.items, (i) -> i.index is li.itemIndex)
            li.selectedSla = selectedSla

        # Atualizamos o modelo
        currentAddress.shippingOptions = @getShippingOptionsData()
        # Renderizamos
        @updateShippingOptionsLabels(currentAddress.shippingOptions)
        @render()

      @enable = (ev) ->
        ev?.stopPropagation()
        @attr.data.loadingShippingOptions = false
        @render()

      @disable = (ev) ->
        ev?.stopPropagation()
        @attr.data.loadingShippingOptions = false
        @$node.html('')

      @startLoadingShippingOptions = (ev) ->
        ev?.stopPropagation()
        @attr.data.loadingShippingOptions = true
        @render()

      @validateShippingOptions = ->
        logisticsInfo = @attr.data.logisticsInfo
        return "Logistics info must exist" if logisticsInfo?.length is 0
        return "No selected SLA" if logisticsInfo?[0].selectedSla is undefined
        return true

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on 'scheduleDateSelected.vtex', @scheduleDateSelected
        @on @$node.parent(), 'startLoadingShippingOptions.vtex', @startLoadingShippingOptions
        @on 'click',
          'shippingOptionSelector': @selectShippingOptionHandler
          'deliveryWindowSelector': @deliveryWindowSelected

        @setValidators [
          @validateShippingOptions
        ]

    return defineComponent(ShippingOptions, withi18n, withValidation, withOrderForm)