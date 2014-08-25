define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/setup/extensions',
        'shipping/mixin/withi18n',
        'shipping/mixin/withLogisticsInfo',
        'shipping/template/shippingOptions',
        'shipping/template/deliveryWindows'],
  (defineComponent, extensions, withi18n, withLogisticsInfo, shippingOptionsTemplate, deliveryWindowsTemplate) ->
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

      @updateLogisticsInfoModel = (shippingOptions, deliveryWindow) ->
        shippingOption = shippingOptions

        # Atualiza o logisticsInfo
        for li in @attr.data.logisticsInfo
          # Caso os items do shipping option fale do logistic info em questão
          if _.find(shippingOption.items, (i) -> i.index is li.itemIndex)
            li.deliveryWindow = deliveryWindow

        @selectDeliveryWindow(shippingOption.selectedSla, deliveryWindow)
        @trigger('deliverySelected.vtex', @attr.data.logisticsInfo)

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
        @updateShippingOptionsLabels(@attr.data.shippingOptions).then =>
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
        @updateShippingOptionsLabels(@attr.data.shippingOptions).then =>
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
        @on 'startLoadingShippingOptions.vtex', @startLoadingShippingOptions
        @on 'click',
          'shippingOptionSelector': @selectShippingOptionHandler
          'deliveryWindowSelector': @deliveryWindowSelected

    return defineComponent(ShippingOptions, withi18n, withLogisticsInfo)