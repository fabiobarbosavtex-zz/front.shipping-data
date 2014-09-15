define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/script/setup/extensions',
        'shipping/script/models/Address',
        'shipping/script/mixin/withi18n',
        'shipping/script/mixin/withValidation'],
  (defineComponent, extensions, Address, withi18n, withValidation) ->
    AddressForm = ->
      @defaultAttrs
        map: false
        marker: false
        addressKeyMap: {}
        data:
          address: null
          availableAddresses: []
          disableCityAndState: false
          labelShippingFields: false
          addressSearchResults: {}
          countryRules: {}
          hasGeolocationData: false
          contractedShippingFieldsForGeolocation: false
          addressQuery: false
          comeFromGeoSearch: false

        templates:
          form:
            baseName: 'countries/addressForm'

        addressFormSelector: '.address-form-new'
        postalCodeSelector: '.postal-code'
        forceShippingFieldsSelector: '#force-shipping-fields'
        stateSelector: '#ship-state'
        citySelector: '#ship-city'
        neighborhoodSelector: '#ship-neighborhood'
        basedOnStateChange: 'select[data-based-state-change="true"]'
        cancelAddressFormSelector: '.cancel-address-form a'
        submitButtonSelector: '.submit .btn-success.address-save'
        mapCanvasSelector: '#map-canvas'
        addressInputsSelector: '.box-delivery input'
        findAPostalCodeForAnotherAddressSelector: '.find-a-postal-code-for-another-address'

      # Render this component according to the data object
      @render = ->
        data = @attr.data
        dust.render @attr.templates.form.name, data, (err, output) =>
          output = $(output).i18n()
          @$node.html(output)
          if not window.vtex.maps.isGoogleMapsAPILoaded and not window.vtex.maps.isGoogleMapsAPILoading and @attr.data.hasGeolocationData
            @loadGoogleMaps()

          if window.vtex.maps.isGoogleMapsAPILoaded and @attr.data.hasGeolocationData
            @attr.data.loading = false
            @createMap()

          if @attr.data.loading
            $('input, select, .btn', @$node).attr('disabled', 'disabled')

          rules = @getCountryRule()

          if rules.postalCodeByInput
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

          if @attr.data.address.validate(rules) is true
            @attr.parsley.validate()
          else
            @select('addressInputsSelector').each ->
              if @value is ''
                @focus()
                return false
              else
                @blur()

      # Helper function to get the current country's rules
      @getCountryRule = ->
        @attr.data.countryRules[@attr.data.address.country]

      @loadGoogleMaps = ->
        if not window.vtex.maps.isGoogleMapsAPILoaded
          window.vtex.maps.isGoogleMapsAPILoading = true
          @loading()
          country = @getCountryRule().abbr
          script = document.createElement("script")
          script.type = "text/javascript"
          script.src = "//maps.googleapis.com/maps/api/js?libraries=places&sensor=false&components=country:#{country}&language=#{@attr.locale}&callback=window.vtex.maps.googleMapsLoadedOnAddressForm"
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
        addressKeyMap = @getCurrentAddress()

        if @getCountryRule().postalCodeByInput
          addressKeyMap.postalCodeIsValid = @select('postalCodeSelector').parsley().isValid()
        else
          addressKeyMap.postalCodeIsValid = true

        addressKeyMap.geoCoordinatesIsValid = addressKeyMap.geoCoordinates.length is 2
        addressKeyMap.useGeolocationSearch = false # force use of postal code on future search

        # TODO implementar geocode
        # from valid to invalid
        if @attr.addressKeyMap.postalCodeIsValid and not addressKeyMap.postalCodeIsValid
          @trigger('addressKeysInvalidated.vtex', [addressKeyMap])
        else if addressKeyMap.postalCodeIsValid # new postal code is valid
          @trigger('addressKeysUpdated.vtex', [addressKeyMap])

        @attr.addressKeyMap = addressKeyMap

      @findAnotherPostalCode = ->
        addressKeyMap =
          addressId: @attr.data.address?.addressId
          useGeolocationSearch: true # force to not use of postal code on future search
          postalCode:
            value: null
            valid: false
          geoCoordinates:
            value: []
            valid: false
        @trigger('addressKeysInvalidated.vtex', [addressKeyMap])

      # Able the user to edit the suggested fields
      # filled by the postal code service
      @forceShippingFields = ->
        @attr.data.labelShippingFields = false
        @attr.data.hasGeolocationData = false
        @attr.data.addressQuery = false
        @clearGeolocationContractedFields()
        @render()

      @clearGeolocationContractedFields = ->
        @attr.data.contractedShippingFieldsForGeolocation.street = false
        @attr.data.contractedShippingFieldsForGeolocation.number = false
        @attr.data.contractedShippingFieldsForGeolocation.neighborhood = false
        @attr.data.contractedShippingFieldsForGeolocation.city = false
        @attr.data.contractedShippingFieldsForGeolocation.state = false
        @attr.data.contractedShippingFieldsForGeolocation.postalCode = false

      # Get the current address typed in the form
      @getCurrentAddress = ->
        disabled = @select('addressFormSelector')
          .find(':input:disabled').removeAttr('disabled')

        serializedForm = @select('addressFormSelector')
          .find('select,textarea,input').serializeArray()

        disabled.attr 'disabled', 'disabled'
        addressObj = {}
        $.each serializedForm, ->
          addressObj[@name] = if (@value? and (@value isnt "")) then @value else null

        if addressObj.addressTypeCommercial
          addressObj.addressType = 'commercial'
        else
          addressObj.addressType = 'residential'

        if addressObj.postalCode
          addressObj.postalCode = addressObj.postalCode.replace(/\-/, '')

        addressObj.geoCoordinates = @attr.data.address.geoCoordinates or []

        # If country use postal code, don't send geoCoordinates
        if @getCountryRule().deliveryOptionsByPostalCode
          addressObj.geoCoordinates = []

        return addressObj

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
        @attr.templates.form.template = 'shipping/templates/' + @attr.templates.form.name

        deps = [@attr.templates.form.template,
                'shipping/script/rule/Country'+country]

        return require deps, (formTemplate, countryRule) =>
          @attr.data.countryRules[country] = new countryRule()
          @attr.data.states = @attr.data.countryRules[country].states
          @attr.data.regexes = @attr.data.countryRules[country].regexes

      @createMap = () ->
        location = new google.maps.LatLng(@attr.data.address.geoCoordinates[1], @attr.data.address.geoCoordinates[0])
        @select('mapCanvasSelector').css('display', 'block')
        mapOptions =
          zoom: 15
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

      # Close the form
      @cancelAddressForm = ->
        @disable()
        @trigger('cancelAddressEdit.vtex')

      # Fill the cities array for the selected state
      @getCitiesData = () ->
        rules = @getCountryRule()
        if not rules.cities then return

        state = @attr.data.address?.state ? rules.states[0]
        @attr.data.cities = rules.cities[state]

      # Call two functions for the same event
      @changeState = (ev, state) ->
        state = state?.el?.value ? null
        @changeCities(state)
        @changePostalCodeByState()

      # Change the city select options when a state is selected
      # basedOnStateChange should be true in the country's rule
      @changeCities = (state) ->
        rules = @getCountryRule()
        if not rules.basedOnStateChange then return

        state = state ? rules.states[0]

        @select('basedOnStateChange').find('option').remove().end()

        elem = '<option></option>'
        @select('basedOnStateChange').append(elem)
        for value in rules.cities[state]
          elem = '<option value="'+value+'">'+value+'</option>'
          @select('basedOnStateChange').append(elem)

        @select('basedOnStateChange').val('')

      # Change postal code according to the state selected
      # postalCodeByState should be true in the country's rule
      @changePostalCodeByState = (ev, data) ->
        rules = @getCountryRule()
        return if not rules.postalCodeByState

        state = @select('stateSelector').val()
        for city, postalCode of rules.map[state]
          break

        @select('postalCodeSelector').val(postalCode)
        @addressKeysUpdated()

      # Change postal code according to the city selected
      # postalCodeByCity should be true in the country's rule
      @changePostalCodeByCity = (ev, data) ->
        rules = @getCountryRule()
        return if not rules.postalCodeByCity

        state = @select('stateSelector').val()
        value = @select('basedOnStateChange').val()
        stateCapitalize = _.find rules.states, (s) -> s.value is state
        postalCode = rules.map[stateCapitalize.label][value]

        @select('postalCodeSelector').val(postalCode)
        @addressKeysUpdated()

      # Set to a loading state
      # This will disable all fields
      @loading = (ev, data) ->
        ev?.stopPropagation()
        @attr.data.loading = true
        @getCitiesData()
        @render()

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
        # when the address has an address query, the address was searched with geolocation
        @attr.data.addressQuery = if address.addressQuery? then address.addressQuery else false
        @attr.data.hasGeolocationData = @attr.data.address.geoCoordinates.length > 0
        @attr.data.comeFromGeoSearch = address.addressQuery?

        handleLoadSuccess = =>
          @clearGeolocationContractedFields()
          @updateEnables(@attr.data.address)
          @getCitiesData()
          @render().then =>
            # For the countries that use postal code, we must trigger
            # an addressKeysUpdated, so it can search for the SLAs
            if @getCountryRule().queryByPostalCode || @getCountryRule().queryByGeocoding
              @addressKeysUpdated()

        handleLoadFailure = (reason) ->
          throw reason

        @loadCountryRulesAndTemplate(@attr.data.address.country)
          .then(handleLoadSuccess, handleLoadFailure)

      @disable = (ev) ->
        ev?.stopPropagation()
        @$node.html('')

      @stopSubmit = (ev) ->
        ev.preventDefault()

      @updateEnables = ->
        @attr.data.contractedShippingFieldsForGeolocation =
          neighborhood: @attr.data.address.neighborhood isnt '' and @attr.data.address.neighborhood?
          street: @attr.data.address.street isnt '' and @attr.data.address.street?
          city: @attr.data.address.city isnt '' and @attr.data.address.city?
          state: @attr.data.address.state isnt '' and @attr.data.address.state?
          number: @attr.data.address.number isnt '' and @attr.data.address.number?
          postalCode: @attr.data.address.postalCode isnt '' and @attr.data.address.postalCode? and @attr.data.addressQuery

        if @getCountryRule().queryByPostalCode
          @attr.data.labelShippingFields = @attr.data.address.neighborhood isnt '' and @attr.data.address.neighborhood? and
            @attr.data.address.street isnt '' and @attr.data.address.street? and
            @attr.data.address.state isnt '' and @attr.data.address.state? and
            @attr.data.address.city isnt '' and @attr.data.address.city?

          @attr.data.disableCityAndState = @attr.data.address.state and @attr.data.address.city

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on 'startLoading.vtex', @loading
        @on 'click',
          'forceShippingFieldsSelector': @forceShippingFields
          'cancelAddressFormSelector': @cancelAddressForm
          'findAPostalCodeForAnotherAddressSelector': @findAnotherPostalCode
        @on 'change',
          'stateSelector': @changeState
          'basedOnStateChange': @changePostalCodeByCity
        @on 'keyup',
          'postalCodeSelector': @addressKeysUpdated
        @on 'submit',
          'addressFormSelector': @stopSubmit

        @setValidators [
          @validateAddress
        ]

        @setLocalePath 'shipping/script/translation/'

        window.vtex.maps = window.vtex.maps or {}

        # Called when google maps api is loaded
        window.vtex.maps.googleMapsLoadedOnAddressForm = =>
          @attr.data.loading = false
          window.vtex.maps.isGoogleMapsAPILoaded = true
          window.vtex.maps.isGoogleMapsAPILoading = false
          @getCitiesData()
          @render()

    return defineComponent(AddressForm, withi18n, withValidation)
