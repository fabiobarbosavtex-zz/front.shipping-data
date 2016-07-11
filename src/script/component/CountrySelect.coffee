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
        hasAvailableAddresses: false
        country: false
        deliveryCountries: []
        showCountrySelect: false

      deliveryCountrySelector: '#ship-country'
      cancelAddressFormSelector: '.cancel-address-form a'

    @render = ->
      dust.render template, @attr.data, (err, output) =>
        output = $(output).i18n()
        @$node.html(output)

    @onSelectCountry = (ev, data) ->
      country = data.el.value
      @trigger('countrySelected.vtex', [country, true])

    @transformCountries = (countries) ->
      newCountries = []
      for country in countries
        newCountries.push({
          code: country,
          name: i18n.t('countries.'+ country)
        })
      return newCountries.sort((a, b) => a.name.localeCompare(b.name))

    # Handle the initial view of this component
    @enable = (ev, deliveryCountries, address, hasAvailableAddresses) ->
      ev?.stopPropagation()
      @attr.data.deliveryCountries = @transformCountries(deliveryCountries)
      @attr.data.hasAvailableAddresses = hasAvailableAddresses

      if @attr.data.deliveryCountries.length > 1
        @attr.data.showCountrySelect = true

      @attr.data.country = if address?.country then address.country else null

      @render()

    @disable = (ev) ->
      ev?.stopPropagation()
      @$node.html('')

    @cancelAddressForm = (ev) ->
      ev.preventDefault()
      @disable()
      @trigger('cancelAddressEdit.vtex')
      @trigger('cancelAddressSearch.vtex')

    # Bind events
    @after 'initialize', ->
      @on 'enable.vtex', @enable
      @on 'disable.vtex', @disable
      @on 'change',
        'deliveryCountrySelector': @onSelectCountry
      @on 'click',
        'cancelAddressFormSelector': @cancelAddressForm

      @setLocalePath 'shipping/script/translation/'

  return defineComponent(CountrySelect, withi18n, withValidation)
