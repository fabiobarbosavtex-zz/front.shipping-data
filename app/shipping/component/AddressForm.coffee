define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/setup/extensions',
        'shipping/models/Address',
        'shipping/mixin/withi18n',
        'shipping/mixin/withValidation',
        'shipping/template/selectCountry'],
  (defineComponent, extensions, Address, withi18n, withValidation, selectCountryTemplate) ->
    AddressForm = ->
      @defaultAttrs
        map: false
        marker: false
        circle: false
        currentResponseCoordinates: false
        data:
          address: null
          availableAddresses: []
          country: false
          postalCode: ''
          deliveryCountries: []
          disableCityAndState: false
          labelShippingFields: false
          showPostalCode: false
          showAddressForm: false
          showSelectCountry: false
          addressSearchResults: {}
          countryRules: {}
          showGeolocationSearch: false
          requiredGoogleFieldsNotFound: []

        templates:
          form:
            baseName: 'countries/addressForm'

        isGoogleMapsAPILoaded: false
        addressFormSelector: '.address-form-new'
        postalCodeSelector: '.postal-code'
        forceShippingFieldsSelector: '#force-shipping-fields'
        stateSelector: '#ship-state'
        citySelector: '#ship-city'
        deliveryCountrySelector: '#ship-country'
        cancelAddressFormSelector: '.cancel-address-form a'
        submitButtonSelector: '.submit .btn-success.address-save'
        mapCanvasSelector: '#map-canvas'
        clearAddressSearchSelector: '.clear-address-search'

        # Google maps variables
        map = null
        marker = null

      @renderSelectCountry = (data) ->
        dust.render 'selectCountry', data, (err, output) =>
          output = $(output).i18n()
          @$node.html(output)

      @renderAddressForm = (data) ->
        dust.render @attr.templates.form.name, data, (err, output) =>
          output = $(output).i18n()
          @$node.html(output)

          if not @attr.isGoogleMapsAPILoaded and @attr.data.showGeolocationSearch
            @attr.data.loading = true

          if @attr.data.showGeolocationSearch
            @startGoogleAddressSearch()

          if data.loading
            $('input, select, .btn', @$node).attr('disabled', 'disabled')

          rules = @getCountryRule()

          if rules.citiesBasedOnStateChange
            @changeCities()
            if data.address.city
              @select('citySelector').val(data.address.city)

          if rules.usePostalCode
            @select('postalCodeSelector').inputmask
              mask: rules.masks.postalCode
            if data.labelShippingFields
              @select('postalCodeSelector').addClass('success')

          if @attr.currentResponseCoordinates
            @createMap(@attr.currentResponseCoordinates)

          window.ParsleyValidator.addValidator('postalcode',
            (val) =>
                rules = @getCountryRule()
                return rules.regexes.postalCode.test(val)
            , 32)

          @attr.parsley = @select('addressFormSelector').parsley
            errorClass: 'error'
            successClass: 'success'
            errorsWrapper: '<span class="help error error-list"></span>'
            errorTemplate: '<span class="error-description"></span>'

          @attr.parsley.subscribe 'parsley:field:validated', () =>
            @validate()

      # Render this component according to the data object
      @render = ->
        require 'shipping/translation/' + @attr.locale, (translation) =>
          @extendTranslations(translation)
          if @attr.data.showSelectCountry
            @renderSelectCountry(@attr.data)
          else if @attr.data.showAddressForm
            @renderAddressForm(@attr.data)

      # Helper function to get the current country's rules
      @getCountryRule = ->
        @attr.data.countryRules[@attr.data.address.country]

      @validateAddress = ->
        valid = @attr.parsley.isValid()
        if valid
          @updateAddress(true)
        else if @attr.data.address.isValid
          @updateAddress(false)
        return valid

      @clearAddressSearch = (ev) ->
        ev.preventDefault()
        @trigger('clearAddressSearch.vtex')

      # Able the user to edit the suggested fields
      # filled by the postal code service
      @forceShippingFields = ->
        @attr.data.labelShippingFields = false
        @render()

      # Get the current address typed in the form
      @getCurrentAddress = ->
        disabled = @select('addressFormSelector')
          .find(':input:disabled').removeAttr('disabled')

        serializedForm = @select('addressFormSelector')
          .find('select,textarea,input').serializeArray()

        disabled.attr 'disabled', 'disabled'
        addressObj = {}
        $.each serializedForm, ->
          #addressObj[@name] = @value
          addressObj[@name] = if (@value? and (@value isnt "")) then @value else null

        if addressObj.addressTypeCommercial
          addressObj.addressType = 'commercial'
        else
          addressObj.addressType = 'residential'

        addressObj.geoCoordinates = @attr.data.geoCoordinates

        return addressObj

      @updateAddressHandler = (ev) ->
        @updateAddress(@attr.parsley.isValid())

      # Trigger address updated event
      @updateAddress = (isValid) ->
        ev?.preventDefault()

        @attr.data.address = @getCurrentAddress()
        @attr.data.address.isValid = isValid

        # limpa campo criado para busca do google
        if @attr.data.address.addressSearch is null
          delete @attr.data.address["addressSearch"]

        # Submit address object
        @trigger('addressUpdated.vtex', @attr.data.address)

      # Select a delivery country
      # This will load the country's form and rules
      @selectCountry = (country) ->
        @attr.data.country = country
        @attr.data.showAddressForm = true
        @attr.data.showSelectCountry = false

        @attr.templates.form.name = @attr.templates.form.baseName + country
        @attr.templates.form.template = 'shipping/template/' + @attr.templates.form.name

        deps = [@attr.templates.form.template,
                'shipping/rule/Country'+country]

        return require deps, (formTemplate, countryRule) =>
          @attr.data.countryRules[country] = new countryRule()
          @attr.data.states = @attr.data.countryRules[country].states
          @attr.data.regexes = @attr.data.countryRules[country].regexes
          @attr.data.useGeolocation = @attr.data.countryRules[country].useGeolocation

      @createMap = (location) ->
        @select('mapCanvasSelector').css('display', 'block')
        mapOptions =
          zoom: 14
          center: location
          streetViewControl: false
          mapTypeControl: false
          zoomControl: true
          zoomControlOptions:
            position: google.maps.ControlPosition.TOP_RIGHT
            style: google.maps.ZoomControlStyle.SMALL

        if @attr.map
          @attr.map = null
        @attr.map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions)

        if @attr.marker
          @attr.marker.setMap(null)
          @attr.marker = null
        @attr.marker = new google.maps.Marker(position: location)
        @attr.marker.setMap(@attr.map)

        circleOptions =
          center: location
          fillColor: '#2cb6d6'
          fillOpacity: 0.3
          strokeColor: '#ff6661'
          strokeOpacity: 0.8
          strokeWeight: 4
          radius: 600

        if @attr.circle
          @attr.circle.setMap(null)
          @attr.circle = null
        @attr.circle = new google.maps.Circle(circleOptions)
        @attr.circle.setMap(@attr.map)

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

      # Close the form
      @cancelAddressForm = ->
        @disable()
        @trigger('cancelAddressEdit.vtex')

      # Change the city select options when a state is selected
      # citiesBasedOnStateChange should be true in the country's rule
      @changeCities = (ev, data) ->
        rules = @getCountryRule()
        return if not rules.citiesBasedOnStateChange

        state = @select('stateSelector').val()
        @select('citySelector').find('option').remove().end()

        for city of rules.map[state]
          elem = '<option value="'+city+'">'+city+'</option>'
          @select('citySelector').append(elem)

      # Change postal code according to the state selected
      # postalCodeByState should be true in the country's rule
      @changePostalCodeByState = (ev, data) ->
        rules = @getCountryRule()
        return if not rules.postalCodeByState

        state = @select('stateSelector').val()
        for city, postalCode of rules.map[state]
          break

        @select('postalCodeSelector').val(postalCode)
        @trigger('postalCode.vtex', postalCode)

      # Change postal code according to the city selected
      # postalCodeByCity should be true in the country's rule
      @changePostalCodeByCity = (ev, data) ->
        rules = @getCountryRule()
        return if not rules.postalCodeByCity

        state = @select('stateSelector').val()
        city = @select('citySelector').val()
        postalCode = rules.map[state][city]

        @select('postalCodeSelector').val(postalCode)
        @trigger('postalCode.vtex', @getCurrentAddress())

      # Set to a loading state
      # This will disable all fields
      @loading = (ev, data) ->
        @attr.data.loading = true
        @render()

      # Store new country rules in the data object
      @addCountryRule = (ev, data) ->
        _.extend(@attr.data.countryRules, data)

      # Call two functions for the same event
      @onChangeState = (ev, data) ->
        @changeCities(ev, data)
        @changePostalCodeByState(ev, data)

      # Handle the initial view of this component
      @enable = (ev, address) ->
        ev?.stopPropagation()

        if address
          @attr.data.labelShippingFields = address.neighborhood isnt '' and address.neighborhood? and
            address.street isnt '' and address.street? and
            address.state isnt '' and address.state? and
            address.city isnt '' and address.city?
          @attr.data.disableCityAndState = address.state isnt '' and address.city isnt ''

        @attr.data.address = new Address(address, @attr.data.deliveryCountries)

        if @attr.data.deliveryCountries.length > 1 and @attr.data.isSearchingAddress
          @attr.data.showSelectCountry = true

        @selectCountry(@attr.data.address.country).then(@render.bind(this), @handleCountrySelectError.bind(this))

      @handleCountrySelectError = (reason) ->
        console.error("Unable to load country dependencies", reason)

      @disable = (ev) ->
        ev?.stopPropagation()
        # Clear address on disable
        @attr.data.address = new Address(null, @attr.data.deliveryCountries)
        @$node.html('')

      @openGeolocationSearch = ->
        @attr.data.showGeolocationSearch = true;
        @render()

      @openZipSearch = ->
        @attr.data.showGeolocationSearch = false;
        @render()

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on 'loading.vtex', @loading
        @on window, 'newCountryRule', @addCountryRule # TODO -> MELHORAR AQUI
        @on 'click',
          'forceShippingFieldsSelector': @forceShippingFields
          'cancelAddressFormSelector': @cancelAddressForm
          'submitButtonSelector': @updateAddressHandler
        @on 'change',
          'postalCodeSelector': @clearAddressSearch
          'deliveryCountrySelector': @selectedCountry
          'stateSelector': @onChangeState
          'citySelector': @changePostalCodeByCity
        @on 'keyup',
          'clearAddressSearchSelector': @clearAddressSearch

        @setValidators [
          @validateAddress
        ]

        # Called when google maps api is loaded
        window.vtex.googleMapsLoaded = =>
          @attr.data.loading = false
          @attr.isGoogleMapsAPILoaded = true
          @render()

    return defineComponent(AddressForm, withi18n, withValidation)
