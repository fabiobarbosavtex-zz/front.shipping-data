define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component', 'shipping/setup/extensions'],
(defineComponent, extensions) ->
  ShippingSummary = ->
    @defaultAttrs
      API: null
      data:
        address: {}
        currentCountryName: false
        showSummary: false
      templates:
        list:
          name: 'shippingSummary'
          template: 'shipping/template/shippingSummary'

      changeShippingOptionBtSelector: "#change-other-shipping-option"

    # Render this component according to the data object
    @render = (data) ->
      if data.address
        require [@attr.templates.list.template], =>
          dust.render @attr.templates.list.name, data, (err, output) =>
            output = $(output).i18n()
            $(@$node).html(output)
      else
        $(@$node).html("")

    @orderFormUpdated = (evt, orderForm) ->
      @attr.data.address = orderForm.shippingData?.address
      @attr.data.currentCountryName = "Brasil"
      @render(@attr.data)

    @showShippingSummary = (evt, data) ->
      @attr.data.showSummary = data
      @render(@attr.data)

    @setLocale = (locale = "pt-BR") ->
      if locale.match('es-')
        @attr.locale = 'es'
      else
        @attr.locale = locale

    @localeUpdate = (ev, locale) ->
      @setLocale locale
      @render(@attr.data)

    @changeShippingOption = (evt, data) ->
      @showShippingSummary false
      $(document).trigger('showAddressList.vtex')

    @onDisableShippingData = () ->
      @showShippingSummary null, true

    @onAddressSelected = (evt, data) ->
      @attr.data.address = data
      @render(@attr.data)

    # Bind events
    @after 'initialize', ->
      @on document, 'addressSelected', @onAddressSelected
      @on document, 'orderFormUpdated.vtex', @orderFormUpdated
      @on document, 'showShippingSummary.vtex', @showShippingSummary
      @on document, 'localeSelected.vtex', @localeUpdate
      @on document, 'disableShippingData.vtex', @onDisableShippingData
      @on document, 'click',
        'changeShippingOptionBtSelector': @changeShippingOption
      return

  return defineComponent(ShippingSummary)