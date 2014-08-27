define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/setup/extensions',
        'shipping/models/Address',
        'shipping/mixin/withi18n',
        'shipping/mixin/withValidation'],
  (defineComponent, extensions, Address, withi18n, withValidation) ->
    AddressForm = ->
      @defaultAttrs
        map: false
        marker: false
        circle: false
        currentResponseCoordinates: false
        addressKeyMap: {}
        data:
          address: null
          availableAddresses: []
          disableCityAndState: false
          labelShippingFields: false
          showPostalCode: false
          addressSearchResults: {}
          countryRules: {}
          showGeolocationSearch: false
          requiredGoogleFieldsNotFound: []

        templates:
          form:
            baseName: 'countries/addressForm'

        addressFormSelector: '.address-form-new'
        postalCodeSelector: '.postal-code'
        forceShippingFieldsSelector: '#force-shipping-fields'
        stateSelector: '#ship-state'
        citySelector: '#ship-city'
        cancelAddressFormSelector: '.cancel-address-form a'
        submitButtonSelector: '.submit .btn-success.address-save'
        mapCanvasSelector: '#map-canvas'
        addressInputsSelector: '.box-delivery input'

      # Render this component according to the data object
      @render = ->
        require 'shipping/translation/' + @attr.locale, (translation) =>
          @extendTranslations(translation)
          data = @attr.data
          dust.render @attr.templates.form.name, data, (err, output) =>
            output = $(output).i18n()
            @$node.html(output)

            if not window.vtex.maps.isGoogleMapsAPILoaded and not window.vtex.maps.isGoogleMapsAPILoading and @attr.data.showGeolocationSearch
              @loadGoogleMaps()

            if window.vtex.maps.isGoogleMapsAPILoaded and @attr.data.showGeolocationSearch
              @attr.data.loading = false
              @createMap(new google.maps.LatLng(@attr.data.address.geoCoordinates[1], @attr.data.address.geoCoordinates[0]))

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

            @addressKeysUpdated() # Trigger key updated with initial values

            @select('addressInputsSelector').each ->
              if @value is ''
                @focus()
                return false

      # Helper function to get the current country's rules
      @getCountryRule = ->
        @attr.data.countryRules[@attr.data.address.country]

      @loadGoogleMaps = ->
        if not window.vtex.maps.isGoogleMapsAPILoaded
          window.vtex.maps.isGoogleMapsAPILoading = true
          @loading()
          country = @getCountryRule.abbr
          script = document.createElement("script")
          script.type = "text/javascript"
          script.src = "//maps.googleapis.com/maps/api/js?sensor=false&components=country:#{country}&language=#{@attr.locale}&callback=window.vtex.maps.googleMapsLoadedOnAddressForm"
          document.body.appendChild(script)
          return

      @validateAddress = ->
        valid = @attr.parsley.isValid()
        if valid
          @updateAddress(true)
        else if @attr.data.address.isValid
          @updateAddress(false)
        return valid

      @addressKeysUpdated = (ev) ->
        ev?.preventDefault()
        postalCode = @select('postalCodeSelector').val()
        postalCodeIsValid = @select('postalCodeSelector').parsley().isValid()
        geoCoordinates = @attr.data.address?.geoCoordinates or []
        geoCoordinatesIsValid = geoCoordinates.length is 2

        addressKeyMap =
          postalCode:
            value: postalCode
            valid: postalCodeIsValid
          geoCoordinates:
            value: geoCoordinates
            valid: geoCoordinatesIsValid

        # TODO implementar geocode
        # from valid to invalid
        if @attr.addressKeyMap.postalCode?.valid and not postalCodeIsValid
          @trigger('addressKeysInvalidated.vtex', [addressKeyMap])
        else if postalCodeIsValid # new postal code is valid
          @trigger('addressKeysUpdated.vtex', [addressKeyMap])

        @attr.addressKeyMap = addressKeyMap

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
      @loadCountryRulesAndTemplate = (country) ->
        @attr.templates.form.name = @attr.templates.form.baseName + country
        @attr.templates.form.template = 'shipping/template/' + @attr.templates.form.name

        deps = [@attr.templates.form.template,
                'shipping/rule/Country'+country]

        return require deps, (formTemplate, countryRule) =>
          @attr.data.countryRules[country] = new countryRule()
          @attr.data.states = @attr.data.countryRules[country].states
          @attr.data.regexes = @attr.data.countryRules[country].regexes
          @render.bind(this)

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

        ### if @attr.marker
          @attr.marker.setMap(null)
          @attr.marker = null
        @attr.marker = new google.maps.Marker(position: location)
        @attr.marker.setMap(@attr.map) ###

        circleOptions =
          center: location
          fillColor: '#2cb6d6'
          fillOpacity: 0.3
          strokeColor: '#ff6661'
          strokeOpacity: 0.3
          strokeWeight: 2
          radius: 500

        if @attr.circle
          @attr.circle.setMap(null)
          @attr.circle = null
        @attr.circle = new google.maps.Circle(circleOptions)
        @attr.circle.setMap(@attr.map)

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

      @updateData = (ev, data) ->
        @attr.data.availableAddresses = data.shippingData.availableAddresses ? []
        @attr.data.address = new Address(data.shippingData.address)
        @selectCountry(@attr.data.address.country).then @validate.bind(this)

        address = @attr.data.address
        if address.country is 'BRA'
          @attr.data.labelShippingFields = address.neighborhood isnt '' and address.neighborhood? and
            address.street isnt '' and address.street? and
            address.state isnt '' and address.state? and
            address.city isnt '' and address.city?
          @attr.data.disableCityAndState = address.state isnt '' and address.city isnt ''

      # Handle the initial view of this component
      @enable = (ev, address) ->
        ev?.stopPropagation()
        @attr.data.address = new Address(address)
        @attr.data.showGeolocationSearch = @attr.data.address.geoCoordinates.length > 0

        handleLoadSuccess = =>
          @updateEnables(@attr.data.address)
          @render()

        handleLoadFailure = (reason) ->
          throw reason

        @loadCountryRulesAndTemplate(@attr.data.address.country)
          .then(handleLoadSuccess, handleLoadFailure)

      @handleCountrySelectError = (reason) ->
        console.error("Unable to load country dependencies", reason)

      @disable = (ev) ->
        ev?.stopPropagation()
        # Clear address on disable
        @attr.data.address = new Address(null)
        @$node.html('')

      @updateEnables = ->
        @attr.data.labelShippingFields = @attr.data.address.neighborhood isnt '' and @attr.data.address.neighborhood? and
          @attr.data.address.street isnt '' and @attr.data.address.street? and
          @attr.data.address.state isnt '' and @attr.data.address.state? and
          @attr.data.address.city isnt '' and @attr.data.address.city?
        @attr.data.disableCityAndState = @attr.data.address.state isnt '' and @attr.data.address.city isnt ''
        @render()

      @handleCountrySelectError = ->
        console.log "error on loading country rules"

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on 'loading.vtex', @loading
        @on 'click',
          'forceShippingFieldsSelector': @forceShippingFields
          'cancelAddressFormSelector': @cancelAddressForm
        @on 'change',
          'stateSelector': @onChangeState
          'citySelector': @changePostalCodeByCity
        @on 'keyup',
          'postalCodeSelector': @addressKeysUpdated

        @setValidators [
          @validateAddress
        ]

        window.vtex.maps = window.vtex.maps or {}

        # Called when google maps api is loaded
        window.vtex.maps.googleMapsLoadedOnAddressForm = =>
          @attr.data.loading = false
          window.vtex.maps.isGoogleMapsAPILoaded = true
          window.vtex.maps.isGoogleMapsAPILoading = false
          @render()

    return defineComponent(AddressForm, withi18n, withValidation)
