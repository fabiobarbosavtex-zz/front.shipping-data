define [], () ->
  ->
    @_mapLogisticsInfo = (logisticsInfo, items, sellers) ->
      newLogisticsInfo = _.map logisticsInfo, (logisticItem) ->
        newLogisticItem =
          itemIndex: logisticItem.itemIndex
          itemId: logisticItem.itemId
          selectedSla: logisticItem.selectedSla
          shipsTo: logisticItem.shipsTo?.slice(0)

        newLogisticItem.slas = _.map logisticItem.slas, (sla) ->
          newSla =
            id: sla.id
            listPrice: sla.listPrice
            name: sla.name
            price: sla.price
            shippingEstimate: sla.shippingEstimate
            shippingEstimateDate: sla.shippingEstimateDate
            deliveryWindow: _.extend({}, sla.deliveryWindow)
            tax: sla.tax

          newSla.availableDeliveryWindows = _.map sla.availableDeliveryWindows, (dw) -> _.extend({}, dw)
          return newSla

        newLogisticItem.item = items[newLogisticItem.itemIndex]

        seller = _.find sellers, (seller) ->
          return String(seller.id) is String(newLogisticItem.item.seller)
        newLogisticItem.seller = seller

        return newLogisticItem
      return newLogisticsInfo

    @_fillSLA = (index, sla, sellerId, selectedSla) ->
      sla.shippingOptionsIndex = index

      if sla.availableDeliveryWindows and sla.availableDeliveryWindows.length > 0
        sla.isScheduled = true
        defaultWindow = sla.availableDeliveryWindows[0]
        sla.hasPriceVariation = _.every(sla.availableDeliveryWindows, (window) ->
          isPriceAndTaxZero = window.price is 0 and window.tax is 0
          isPriceAndTaxEqual = window.price is defaultWindow.price and window.tax is defaultWindow.tax
          return not (isPriceAndTaxZero || isPriceAndTaxEqual)
        )

      sla.businessDays = (sla.shippingEstimate+'').indexOf('bd') isnt -1
      sla.shippingEstimateDays = parseInt((sla.shippingEstimate+'').replace(/bd|d/,''), 10)

      sla.nameAttr = _.plainChars('seller-' + sellerId)
      sla.idAttr = _.plainChars(sla.nameAttr + '-sla-' + sla.id?.replace(/\ /g,''))

      # Caso seja a entrega selecionada
      if sla.id is selectedSla
        sla.isSelected = true
      else
        sla.isSelected = false

      return sla

    @_createPriceLabels = (sla) ->
      if sla.price > 0
        sla.valueLabel = _.intAsCurrency sla.price
      else
        sla.valueLabel = i18n.t('global.free')

      if sla.tax > 0
        sla.taxValueLabel = _.intAsCurrency sla.tax
      else
        sla.taxValueLabel = i18n.t('global.free')

      return sla

    @_fillLogisticsInfo = (logisticsInfoBySeller) ->
      index = 0
      logisticsInfoArray = _.map logisticsInfoBySeller, (logisticsInfo) =>
        composedLogistic =
          items: []
          seller: {}
          selectedSla: ''
          slas: []
          index: index

        _.each(logisticsInfo, (info) =>
          composedLogistic.items.push(info.item)
          composedLogistic.seller = info.seller

          _.each(info.slas, (sla) =>
            # Ve se SLA em questão já está no array de SLAS computados
            composedSla = _.find composedLogistic.slas, (_sla) -> _sla.id is sla.id

            # Caso nao esteja no array de SLAS computados, o SLA será computado pela primeira vez
            if not composedSla
              composedSla = @_fillSLA(index, sla, info.seller.id, info.selectedSla)
              isNewSLA = true
              composedLogistic.slas.push(composedSla)
            else
              # Caso o SLA já tenha sido computado antes, iremos apenas somar o preço e a taxa
              composedSla.price += sla.price
              composedSla.tax += sla.tax
          )

          composedLogistic.slas = _.map(composedLogistic.slas, @_createPriceLabels)

          selectedSla = _.find composedLogistic.slas, (slas) ->
            return slas.id == info.selectedSla

          composedLogistic.selectedSla = selectedSla
        )

        index++
        return composedLogistic

      return logisticsInfoArray

    @_getDeliveryDates = (deliveryWindows) ->
      return _.reduce(deliveryWindows, (deliveryDates, dw) =>
        date = new Date(dw.startDateUtc)
        dateAsArray = @dateAsArray(date)

        # Ve se a data desse deliveryWindow está no array de datas
        dateIsInArray = _.find deliveryDates, (d) ->
          d[0] is dateAsArray[0] and d[1] is dateAsArray[1] and d[2] is dateAsArray[2]

        # Caso a data não tenha sido adicionada, adiciona agora
        if not dateIsInArray
          deliveryDates.push dateAsArray

        return deliveryDates
      , [])

    @_fillScheduled = (logisticsInfoArray) ->
      _.each logisticsInfoArray, (li) =>
        _.each li.slas, (sla) =>
          if not sla.isScheduled
            return
          else
            # Salva as possíveis datas de entrega para ser usado no pickadate
            sla.deliveryDates = @_getDeliveryDates(sla.availableDeliveryWindows)

            # Agrupamos as delivery windows pela suas datas
            sla.deliveryWindows = _.groupBy sla.availableDeliveryWindows, (dw) =>
              return @dateAsString(new Date(dw.startDateUtc))

            # Atualizamos seus preços e labels
            @updateDeliveryWindowsPriceAndLabels(sla)

            # Marcamos a delivery window como selecionada
            if sla.deliveryWindow
              @selectDeliveryWindow(sla, sla.deliveryWindow)

      return logisticsInfoArray

    @getShippingOptionsData = (logisticsInfo, items, sellers) ->
      # Para cada item
      updatedLogisticsInfo = []
      updatedLogisticsInfo = @_mapLogisticsInfo(logisticsInfo, items, sellers)

      # Agrupa os items de logistic info por seller
			# Adiciona "seller" para impedir coercao do objeto em array pelo iOS8 ... JUST WORKS
			# http://stackoverflow.com/questions/28155841/misterious-failure-of-jquery-each-and-underscore-each-on-ios
      logisticsBySeller = _.groupBy updatedLogisticsInfo, (so) -> return "seller" + so.seller.id

      # Vamos massagear todo o logistics info
      logisticsInfoArray = @_fillLogisticsInfo(logisticsBySeller)

      # Computamos informações sobre entrega agendada
      logisticsInfoArray = @_fillScheduled(logisticsInfoArray)

      existsScheduledDelivery = _.find(logisticsInfoArray, (li) =>
        return _.find(li.slas, (sla) =>
          return sla.isScheduled
        )
      )
      @attr.isScheduledDeliveryAvailable = existsScheduledDelivery

      @setCheapestSlaIfNull(logisticsInfoArray)

      return logisticsInfoArray

    @dateAsArray = (date) -> [date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()]
    @dateAsString = (date) -> date.getUTCFullYear() + '/' + (date.getUTCMonth() + 1) + '/' + date.getUTCDate()
    @dateHourMinLabel = (date) -> _.pad(date.getUTCHours(), 2) + ":" + _.pad(date.getUTCMinutes(),2) if date

    @formatDate = (date) ->
      year = date.getUTCFullYear()
      month = date.getUTCMonth() + 1
      day = date.getUTCDate()
      day = ('0'+day) if (parseInt(day, 10) < 10)
      month = ('0'+month) if (parseInt(month, 10) < 10)
      if @attr.locale is 'en'
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
                sla.deliveryEstimateLabel = i18n.t 'shipping.shippingOptions.businessDay',
                  count: sla.shippingEstimateDays
              else
                sla.deliveryEstimateLabel = i18n.t 'shipping.shippingOptions.day',
                  count: sla.shippingEstimateDays
              sla.fullEstimateLabel = sla.name + ' - ' + sla.valueLabel + ' - ' + sla.deliveryEstimateLabel

    @updateDeliveryWindowsPriceAndLabels = (sla) ->
      sla.cheapestValue = sla.cheapestValue or Number.MAX_VALUE
      sla.isFree = i18n.t('global.free')

      # Para cada delivery window, iremos criar/atualizar o seu label e preço
      for key, dateArray of sla.deliveryWindows
        for dw in dateArray
          value = dw.price + sla.price
          if value is 0
            dw.valueLabel = i18n.t('global.free')
          else
            sla.isFree = false
            dw.valueLabel = _.intAsCurrency value

          dw.startDate = new Date(dw.startDateUtc)
          dw.endDate = new Date(dw.endDateUtc)
          dw.dateAsArray = @dateAsArray(dw.startDate)
          dw.dateString = @dateAsString(dw.startDate)
          objTranslation =
            from: @dateHourMinLabel(dw.startDate)
            to: @dateHourMinLabel(dw.endDate)
          dw.label = i18n.t('shipping.shippingOptions.fromToHour', objTranslation) + ' - ' + dw.valueLabel
          dw.timeLabel = i18n.t('shipping.shippingOptions.fromToHour', objTranslation)
          dw.formattedDate = @formatDate(new Date(dw.startDateUtc))
          # Guarda o menor preço de entrega agendada para "a partir de"
          if value < sla.cheapestValue
            sla.cheapestDeliveryWindow = dw
            sla.cheapestValue = value
            sla.cheapestValueLabel = dw.valueLabel
            sla.cheapestEndDate = dw.endDate

      # Reescreve label para entrega agendada
      if sla.isFree
        valueLabel = sla.isFree
      else
        valueLabel = i18n.t('shipping.shippingOptions.priceFrom') + ' ' + sla.cheapestValueLabel

      sla.fullEstimateLabel = sla.name + ' - ' + valueLabel


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
      return

    @updateLogisticsInfoModel = (shippingOption, selectedSla, deliveryWindow) ->
      # Atualiza o logisticsInfo
      for li in @attr.data.logisticsInfo
        # Caso os items do shipping option fale do logistic info em questão
        if _.find(shippingOption.items, (i) -> i.index is li.itemIndex)

          selectedSlaObject = _.find(li.slas, (sla) -> sla.id is selectedSla)
          if selectedSlaObject.availableDeliveryWindows.length > 0
            selectedSlaObject.deliveryWindow = deliveryWindow

          li.selectedSla = selectedSla
          li.deliveryWindow = deliveryWindow

      if shippingOption.selectedSla.availableDeliveryWindows.length > 0 and deliveryWindow
        @selectDeliveryWindow(shippingOption.selectedSla, deliveryWindow)

      @trigger('deliverySelected.vtex', [@attr.data.logisticsInfo, {skipSendAttachment: true}])

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
