define ['flight/lib/component',
        'shipping/script/setup/extensions',
        'shipping/script/models/Address',
        'shipping/script/mixin/withi18n',
        'shipping/script/mixin/withValidation',
        'shipping/templates/countrySelect'
        ],
(defineComponent, extensions, Address, withi18n, withValidation, template) ->
  CountrySelect = ->
    @defaultAttrs
      data:
        country: false
        deliveryCountries: []
        showCountrySelect: false

      deliveryCountrySelector: '#ship-country'

    @render = ->
      dust.render template, @attr.data, (err, output) =>
        output = $(output).i18n()
        @$node.html(output)

    @onSelectCountry = (ev, data) ->
      country = data.el.value
      @trigger('countrySelected.vtex', [country, true])

    # Handle the initial view of this component
    @enable = (ev, deliveryCountries, address) ->
      ev?.stopPropagation()
      @attr.data.deliveryCountries = deliveryCountries

      if @attr.data.deliveryCountries.length > 1
        @attr.data.showCountrySelect = true

      @attr.data.country = if address?.country then address.country else null

      @render()

    @disable = (ev) ->
      ev?.stopPropagation()
      @$node.html('')

    # Bind events
    @after 'initialize', ->
      @on 'enable.vtex', @enable
      @on 'disable.vtex', @disable
      @on 'change',
        'deliveryCountrySelector': @onSelectCountry

      @setLocalePath 'shipping/script/translation/'

  return defineComponent(CountrySelect, withi18n, withValidation)
