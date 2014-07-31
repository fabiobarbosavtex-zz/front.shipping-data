define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component', 'shipping/setup/extensions'],
  (defineComponent, extensions) ->
    ShippingOptions = ->
      @defaultAttrs
        API: null
        data:
          shippingOptions: []
          loading: false
          multipleSellers: false

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

      @updateShippingOptions = (ev) ->
        # When an event is triggered with an array as an argument
        # like this: $(foo).trigger(['a', 'b', 'c'])
        # The listener function receives it each element as a separate parameter
        # like this: (eventObj, a, b, c)
        # So here, we are transforming it back to an array, removing the eventObj
        data = (Array.prototype.slice.call(arguments)).slice(1)
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

    @localeUpdate = (ev, locale) ->
      @setLocale locale
      @render(@attr.data)

      # Bind events
      @after 'initialize', ->
        @on window, 'localeSelected.vtex', @localeUpdate
        @on document, 'shippingOptionsRender', @render
        @on document, 'updateShippingOptions', @updateShippingOptions

        return
    return defineComponent(ShippingOptions)