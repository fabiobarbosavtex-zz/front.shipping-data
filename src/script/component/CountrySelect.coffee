define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/script/setup/extensions',
        'shipping/script/models/Address',
        'shipping/script/mixin/withi18n',
        'shipping/script/mixin/withValidation'],
(defineComponent, extensions, Address, withi18n, withValidation) ->
  CountrySelect = ->
    @defaultAttrs
      data:
        country: false
        deliveryCountries: []
        showSelectCountry: false

      deliveryCountrySelector: '#ship-country'

    @renderSelectCountry = (data) ->
      dust.render 'selectCountry', data, (err, output) =>
        output = $(output).i18n()
        @$node.html(output)

    # Select a delivery country
    # This will load the country's form and rules
    @selectCountry = (country) ->
      @attr.data.country = country
      @attr.data.showAddressForm = true
      @attr.data.showSelectCountry = false

      @attr.templates.form.name = @attr.templates.form.baseName + country
      @attr.templates.form.template = 'shipping/templates/' + @attr.templates.form.name

      deps = [@attr.templates.form.template,
              'shipping/script/rule/Country'+country]

      return require deps, (formTemplate, countryRule) =>
        @attr.data.countryRules[country] = new countryRule()
        @attr.data.states = @attr.data.countryRules[country].states
        @attr.data.regexes = @attr.data.countryRules[country].regexes
        @attr.data.useGeolocation = @attr.data.countryRules[country].useGeolocation

    # Handle the selection event
    @selectedCountry = ->
      @clearAddressSearch()
      country = @select('deliveryCountrySelector').val()

      if country
        @selectCountry(country).then(@render.bind(this), @handleCountrySelectError.bind(this))

    @getDeliveryCountries = (logisticsInfo) =>
      _.uniq(_.reduceRight(logisticsInfo, (memo, l) ->
        return memo.concat(l.shipsTo)
      , []))

    # Set to a loading state
    # This will disable all fields
    @loading = (ev, data) ->
      @attr.data.loading = true
      @render()

    # Handle the initial view of this component
    @enable = (ev, address) ->
      ev?.stopPropagation()

      if @attr.data.deliveryCountries.length > 1 and @attr.data.isSearchingAddress
        @attr.data.showSelectCountry = true

      @selectCountry(@attr.data.address.country).then(@render.bind(this), @handleCountrySelectError.bind(this))

    @handleCountrySelectError = (reason) ->
      console.error("Unable to load country dependencies", reason)

    @disable = (ev) ->
      ev?.stopPropagation()
      @$node.html('')

    # Bind events
    @after 'initialize', ->
      @on 'enable.vtex', @enable
      @on 'disable.vtex', @disable
      @on 'loading.vtex', @loading
      @on 'change',
        'deliveryCountrySelector': @selectedCountry

      @setValidators [

      ]

  return defineComponent(CountrySelect, withi18n, withValidation)