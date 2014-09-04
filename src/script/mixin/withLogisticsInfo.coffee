define = vtex.define || window.define
require = vtex.curl || window.require

define [], () ->
  ->
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

      @setCheapestSlaIfNull(logisticsInfoArray)

      return logisticsInfoArray

    @dateAsArray = (date) -> [date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()]
    @dateAsString = (date) -> date.getUTCFullYear() + '/' + date.getUTCMonth() + '/' + date.getUTCDate()
    @dateHourMinLabel = (date) -> _.pad(date.getUTCHours(), 2) + ":" + _.pad(date.getUTCMinutes(),2) if date

    @formatDate = (date) ->
      year = date.getFullYear()
      month = date.getMonth()
      day = date.getDate()
      month = ('0'+month) if (parseInt(month) < 10)
      if @attr.locale is 'en-US'
        return month + '/' + day + '/' + year
      else
        return day + '/' + month + '/' + year

    @updateShippingOptionsLabels = (currentShippingOptions) ->
      # Verifica se existem multiplo sellers
      if currentShippingOptions.length > 1
        @attr.data.multipleSellers = true

      @requireLocale().then =>
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
          dw.label = i18n.t('shippingData.fromToHour', objTranslation) + ' - ' + dw.valueLabel
          dw.timeLabel = i18n.t('shippingData.fromToHour', objTranslation)
          dw.formattedDate = @formatDate(new Date(dw.startDateUtc))
          # Guarda o menor preço de entrega agendada para "a partir de"
          if dw.price + sla.price < sla.cheapestValue
            sla.cheapestDeliveryWindow = dw
            sla.cheapestValue = dw.price + sla.price
            sla.cheapestValueLabel = dw.valueLabel
            sla.cheapestEndDate = dw.endDate

      # Reescreve label para entrega agendada
      sla.fullEstimateLabel = sla.name + ' - ' + sla.cheapestValueLabel + ' - ' + _.dateFormat(sla.cheapestEndDate)

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

              # Copiamos alguns atributos usados no shippingSummary
              deliveryWindow.formattedDate = dateWindow.formattedDate
              deliveryWindow.label = dateWindow.label

              # Guardamos a referencia para o array de delivery windows
              # desta data
              sla.deliveryWindowsForDate = dateAsArray
          else
            # Devemos sempre deixar a flag de todas as outras como false
            dateWindow.isWindowSelected = false

    @updateLogisticsInfoModel = (shippingOption, selectedSla, deliveryWindow) ->
      # Atualiza o logisticsInfo
      for li in @attr.data.logisticsInfo
        # Caso os items do shipping option fale do logistic info em questão
        if _.find(shippingOption.items, (i) -> i.index is li.itemIndex)
          li.deliveryWindow = deliveryWindow
          li.selectedSla = selectedSla

      if deliveryWindow
        @selectDeliveryWindow(shippingOption.selectedSla, deliveryWindow)
      @trigger('deliverySelected.vtex', [@attr.data.logisticsInfo])

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

    @getCheapestSla = (so) ->
      cheapestValue = Number.MAX_VALUE
      cheapestSla = null
      for sla in so.slas
        if sla.price < cheapestValue
          cheapestSla = sla
          cheapestValue = sla.price

      return cheapestSla

    @setCheapestSlaIfNull = (shippingOptions) ->
      for so in shippingOptions
        if not so.selectedSla?
          cheapestSla = @getCheapestSla(so)
          if not cheapestSla then return
          so.selectedSla = cheapestSla
          @updateLogisticsInfoModel(so, so.selectedSla.id)
