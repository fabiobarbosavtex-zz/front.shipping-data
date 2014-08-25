define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/setup/extensions',
        'shipping/mixin/withi18n',
        'shipping/template/shippingOptions',
        'shipping/template/deliveryWindows'],
  (defineComponent, extensions, withi18n, shippingOptionsTemplate, deliveryWindowsTemplate) ->
    ShippingOptions = ->
      @defaultAttrs
        data:
          shippingOptions: []
          logisticsInfo: []
          loading: false
          multipleSellers: false
          items: []
          sellers: []
          loadingShippingOptions: false

        isScheduledDeliveryAvailable: false
        pickadateFiles: ['shipping/libs/pickadate/picker',
                         'shipping/libs/pickadate/picker-date',
                         'link!shipping/libs/pickadate/classic',
                         'link!shipping/libs/pickadate/classic-date']

        shippingOptionSelector: '.shipping-option-item'
        pickadateSelector: '.datepicker'
        deliveryWindowsSelector: '.delivery-windows'
        deliveryWindowSelector: '.delivery-windows input[type=radio]'

      # Render this component according to the data object
      @render = (options) ->
        data = @attr.data

        requiredFiles = if @attr.isScheduledDeliveryAvailable then @attr.pickadateFiles else []
        require requiredFiles, =>
          if options and options.template is 'deliveryWindows'
            # Pega o sla em questão
            data = @attr.data.shippingOptions[options.index].selectedSla

            dust.render deliveryWindowsTemplate, data, (err, output) =>
              output = $(output).i18n()
              @getDeliveryWindowsSelector(options.index).html(output)
          else
            dust.render shippingOptionsTemplate, data, (err, output) =>
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

      @getShippingOptionsData = (logisticsInfo, items, sellers) ->
        updatedLogisticsInfo = []
        # Para cada item
        for logisticItem in logisticsInfo
          item = items[logisticItem.itemIndex]

          # Encontra o seller do item
          seller = _.find sellers, (seller) ->
            return String(seller.id) is String(item.seller)

          # Extende logistics info com o seller e os dados do item
          if seller
            newLogisticItem = _.extend({}, logisticItem, {seller:seller}, {item: item})
            updatedLogisticsInfo.push(newLogisticItem)

        # Agrupa os items de logistic info por seller
        logisticsBySeller = _.groupBy updatedLogisticsInfo, (so) -> return so.seller.id

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

      @getCheapestDeliveryWindow = (shippingOptions, date) ->
        # Pega o sla em questão
        sla = shippingOptions.selectedSla

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

      @updateLogisticsInfoModel = (shippingOptions, deliveryWindow) ->
        shippingOption = shippingOptions

        # Atualiza o logisticsInfo
        for li in @attr.data.logisticsInfo
          # Caso os items do shipping option fale do logistic info em questão
          if _.find(shippingOption.items, (i) -> i.index is li.itemIndex)
            li.deliveryWindow = deliveryWindow

        @selectDeliveryWindow(shippingOption.selectedSla, deliveryWindow)
        @trigger('logisticsInfoUpdated.vtex', @attr.data.logisticsInfo)

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
        shippingOptions = @attr.data.shippingOptions[index]
        @updateLogisticsInfoModel(shippingOptions, @getCheapestDeliveryWindow(shippingOptions, new Date(date)))

        # Renderizamos as novas delivery windows para a data selecionada
        @render(template: 'deliveryWindows', index: index)

      @deliveryWindowSelected = (ev, data) ->
        # Pega o indice da delivery window
        deliveryWindowIndex = $(data.el).attr('value')
        # Pega shipping option
        shippingOptionIndex = $(data.el).data('shipping-option')
        shippingOptions = @attr.data.shippingOptions[shippingOptionIndex]

        # Pega o sla em questão
        sla = shippingOptions.selectedSla

        # Pega a delivery window através do seu indíce
        deliveryWindow = sla.deliveryWindowsForDate[deliveryWindowIndex]

        # Atualizamos o modelo
        @updateLogisticsInfoModel(shippingOptions, deliveryWindow)

      @selectShippingOptionHandler = (ev, data) ->
        ev.preventDefault()
        selectedSla = $('input', data.el).attr('value')
        shippingOptionIndex = $('input', data.el).data('shipping-option')
        shippingOptions = @attr.data.shippingOptions[shippingOptionIndex]
        @selectShippingOption(shippingOptions, selectedSla)

      @selectShippingOption = (shippingOptions, selectedSla) ->
        # Troca o selected sla
        for li in @attr.data.logisticsInfo
          # Caso os items do shipping option fale do logistic info em questão
          if _.find(shippingOptions.items, (i) -> i.index is li.itemIndex)
            li.selectedSla = selectedSla

        # Atualizamos o modelo
        @attr.data.shippingOptions = @getShippingOptionsData(@attr.data.logisticsInfo, @attr.data.items, @attr.data.sellers)
        @updateShippingOptionsLabels(@attr.data.shippingOptions)
        @render()

      @enable = (ev, logisticsInfo, items, sellers) ->
        ev?.stopPropagation()
        @attr.data.loadingShippingOptions = false

        @attr.data.items = _.map items, (item, i) ->
          item.index = i
          return item

        @attr.data.logisticsInfo = logisticsInfo
        @attr.data.sellers = sellers
        @attr.data.shippingOptions = @getShippingOptionsData(logisticsInfo, @attr.data.items, sellers)
        @updateShippingOptionsLabels(@attr.data.shippingOptions)
        @render()

      @disable = (ev) ->
        ev?.stopPropagation()
        @attr.data.loadingShippingOptions = false
        @$node.html('')

      @startLoadingShippingOptions = (ev) ->
        ev?.stopPropagation()
        @attr.data.loadingShippingOptions = true
        @render()

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on 'scheduleDateSelected.vtex', @scheduleDateSelected
        @on @$node.parent(), 'startLoadingShippingOptions.vtex', @startLoadingShippingOptions
        @on 'click',
          'shippingOptionSelector': @selectShippingOptionHandler
          'deliveryWindowSelector': @deliveryWindowSelected

    return defineComponent(ShippingOptions, withi18n)