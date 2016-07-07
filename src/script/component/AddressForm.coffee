define ['flight/lib/component',
        'shipping/script/setup/extensions',
        'shipping/script/models/Address',
        'shipping/script/mixin/withi18n',
        'shipping/script/mixin/withValidation',
        'shipping/script/mixin/withImplementedCountries'],
  (defineComponent, extensions, Address, withi18n, withValidation, withImplementedCountries) ->
    AddressForm = ->
      @defaultAttrs
        map: false
        marker: false
        addressKeyMap: {}
        reRenderUniversalPostalCode: false
        data:
          address: null
          disableCityAndState: false
          labelShippingFields: false
          addressSearchResults: {}
          countryRules: {}
          hasGeolocationData: false
          contractedShippingFieldsForGeolocation: false
          addressQuery: false
          comeFromGeoSearch: false
          isUniversalUsingPostalCode: true

        templates:
          universalPostalCode:
            name: 'universalPostalCode'
            path: 'shipping/templates/universalPostalCode'
          form:
            baseName: 'countries/addressForm'


        addressFormSelector: '.address-form-new'
        postalCodeSelector: '.postal-code'
        forceShippingFieldsSelector: '#force-shipping-fields'
        stateSelector: '#ship-state'
        citySelector: '#ship-city'
        neighborhoodSelector: '#ship-neighborhood'
        basedOnStateChange: 'select[data-based-state-change="true"]'
        basedOnCityChange: 'select[data-based-city-change="true"]'
        selectizeSelect: 'select[data-selectize="true"]'
        submitButtonSelector: '.submit .btn-success.address-save'
        mapCanvasSelector: '#map-canvas'
        addressInputsSelector: '.box-delivery input'
        findAPostalCodeForAnotherAddressSelector: '.find-a-postal-code-for-another-address'
        universalPostalCodePlaceholderSelector: '.ship-postal-code-uni-container'
        universalPostalCodeSelector: '.postal-code-UNI'
        usePostalCodeSelector: '.ship-use-postal-code'
        dontUsePostalCodeSelector: '.ship-dont-use-postal-code'

      # Render this component according to the data object
      @render = ->
        data = @attr.data

        if @attr.reRenderUniversalPostalCode
          @attr.reRenderUniversalPostalCode = false
          return dust.render @attr.templates.universalPostalCode.name, data, (err, output) =>
            output = $(output).i18n()
            @select('universalPostalCodePlaceholderSelector').html(output)

        dust.render @attr.templates.form.name, data, (err, output) =>
          output = $(output).i18n()
          @$node.html(output)

          if not window.vtex.maps.isGoogleMapsAPILoaded and window.vtex.maps.isGoogleMapsAPILoading and @attr.data.hasGeolocationData
            @loading()

          if window.vtex.maps.isGoogleMapsAPILoaded and @attr.data.hasGeolocationData
            @attr.data.loading = false
            @createMap()

          if @attr.data.loading
            $('input, select, .btn', @$node).attr('disabled', 'disabled')

          rules = @getCountryRule()

          if rules.postalCodeByInput and data.labelShippingFields
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

          @attr.parsley.subscribe 'parsley:field:validated', =>
            valid = @attr.parsley.isValid()
            @updateAddress(valid)

          selectizeSelects = @select('selectizeSelect')
          for select in selectizeSelects
            if $(select).data('selectize-create')
              selectOptionCreate = true
            else
              selectOptionCreate = false

            $(select).selectize?({
              create: selectOptionCreate,
              render:
                option_create: (data, escape) =>
                  addString = window.i18n.t('global.add')
                  return '<div class="create">' + addString + ' <strong>' + escape(data.input) + '</strong>&hellip;</div>'
            });

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

      @validateAddress = ->
        valid = @attr.parsley.validate()
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
          addressKeyMap.postalCodeIsValid = addressKeyMap.postalCode isnt null

        addressKeyMap.geoCoordinatesIsValid = addressKeyMap.geoCoordinates.length is 2
        addressKeyMap.useGeolocationSearch = false # force use of postal code on future search

        # TODO implementar geocode
        # from valid to invalid
        if @attr.addressKeyMap.postalCodeIsValid and not addressKeyMap.postalCodeIsValid
          if @getCountryRule().queryByPostalCode || @getCountryRule().queryByGeocoding
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
        @attr.data.labelFields = null
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

        if !addressObj.number and (addressObj.country is 'USA' or addressObj.country is 'CAN')
          addressObj.number = 'N/A'

        return addressObj

      # Trigger address updated event
      @updateAddress = (isValid) ->
        currentAddress = @getCurrentAddress()
        currentAddress.isValid = isValid

        # limpa campo criado para busca do google
        if currentAddress.addressSearch is null
          delete currentAddress["addressSearch"]

        # Submit address object
        @attr.data.address = new Address(currentAddress);
        @trigger('addressUpdated.vtex', [@attr.data.address])

        return @attr.data.address

      # Select a delivery country
      # This will load the country's form and rules
      @loadCountryRulesAndTemplate = (country) ->
        deps = []
        isImplemented = @isCountryImplemented(country)

        if isImplemented
          countryTemplate = country
          @attr.templates.form.name = @attr.templates.form.baseName + country
        else
          countryTemplate = 'UNI'
          @attr.templates.form.name = @attr.templates.form.baseName + 'UNI'

        deps.push('shipping/script/rule/Country'+countryTemplate)
        deps.push('shipping/templates/' + @attr.templates.form.name)
        if !isImplemented
          deps.push(@attr.templates.universalPostalCode.path)

        return vtex.curl deps, (countryRule) =>
          @attr.data.countryRules[country] = new countryRule()
          @attr.data.states = @attr.data.countryRules[country].states
          @attr.data.regexes = @attr.data.countryRules[country].regexes
          @attr.data.dontKnowPostalCodeURL = @attr.data.countryRules[country].dontKnowPostalCodeURL

      @createMap = () ->
        if @attr.data.address?.geoCoordinates?.length is 2
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

      # Fill the cities array for the selected state
      @fillCitySelect = () ->
        rules = @getCountryRule()
        if not rules.basedOnStateChange then return

        state = @attr.data.address?.state

        if state and rules.cities[state]
          @attr.data.cities = rules.cities[state]

      # Fill the neighborhoods array for the selected city
      @fillNeighborhoodSelect = () ->
        rules = @getCountryRule()
        if not rules.basedOnCityChange then return

        state = @attr.data.address?.state
        stateCapitalize = _.find rules.states, (s) -> s.value is state
        city = @attr.data.address?.city

        if city and stateCapitalize and rules.map[stateCapitalize.label][city]
          @attr.data.neighborhoods = _.keys(rules.map[stateCapitalize.label][city])

      # Call two functions for the same event
      @changedStateHandler = (ev, state) ->
        state = state?.el?.value ? null
        @changedState(state)

      @changedState = (state) ->
        if @getCountryRule().basedOnStateChange and state
          @changeCities(state)
        @changePostalCodeByState()

      @changedCityHandler = (ev, city) ->
        city = city?.el?.value ? null
        @changedCity(city)

      @changedCity = (city) ->
        if @getCountryRule().basedOnCityChange
          @changeNeighborhoods(city)
        @changePostalCodeByNeighborhood()

      # Change the city select options when a state is selected
      # basedOnStateChange should be true in the country's rule
      @changeCities = (state) ->
        rules = @getCountryRule()

        # Retira todos as cidades do select
        @select('basedOnStateChange').find('option').remove().end()

        if rules.basedOnCityChange
          # Retira todos os neighborhoods do select
          @select('basedOnCityChange').find('option').remove().end()

        # Caso state seja vazio, não preenchemos o select de city
        if state is "" then returnfalse

        if @select('basedOnStateChange')?.data('selectize')
          selectize = @select('basedOnStateChange')[0].selectize
          selectize.clearOptions()
          options = _.map(rules.cities[state.toUpperCase()], (city) -> return { value: city, text: city })
          selectize.addOption(options)
          selectize.refreshOptions()
        else
          elem = '<option></option>'
          @select('basedOnStateChange').append(elem)
          for value in rules.cities[state.toUpperCase()]
            elem = '<option value="'+value+'">'+value+'</option>'
            @select('basedOnStateChange').append(elem)

      # Change the neighborhood select options when a city is selected
      # basedOnCityChange should be true in the country's rule
      @changeNeighborhoods = (city) ->
        rules = @getCountryRule()

        # Retira todos os neighborhoods do select
        @select('basedOnCityChange').find('option').remove().end()

        state = @select('stateSelector').val()
        stateCapitalize = _.find rules.states, (s) -> s.value is state

        # Caso state ou city seja vazio, não preenchemos o select de neighborhood
        if state is "" or city is "" then return

        if @select('basedOnCityChange')?.data('selectize')
          selectize = @select('basedOnCityChange')[0].selectize
          selectize.clearOptions()
          options = _.map(_.keys(rules.map[stateCapitalize.label][city]), (neigh) -> return { value: neigh, text: neigh })
          selectize.addOption(options)
          selectize.refreshOptions()
        else
          elem = '<option></option>'
          @select('basedOnCityChange').append(elem)
          for value in _.keys(rules.map[stateCapitalize.label][city])
            elem = '<option value="'+value+'">'+value+'</option>'
            @select('basedOnCityChange').append(elem)

      # Change postal code according to the state selected
      # postalCodeByState should be true in the country's rule
      @changePostalCodeByState = (ev, data) ->
        rules = @getCountryRule()
        return if not rules.postalCodeByState

        state = @select('stateSelector').val()
        stateCapitalize = _.find rules.states, (s) -> s.value is state

        for city, postalCode of rules.map[stateCapitalize.label]
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

        if not stateCapitalize or value is "" then return
        postalCode = rules.map[stateCapitalize.label][value]

        @select('postalCodeSelector').val(postalCode)
        @addressKeysUpdated()

      @changePostalCodeByNeighborhood = (ev, data) ->
        rules = @getCountryRule()
        return if not rules.postalCodeByNeighborhood

        state = @select('stateSelector').val()
        stateCapitalize = _.find rules.states, (s) -> s.value is state
        city = @select('basedOnStateChange').val()
        neighborhood = @select('basedOnCityChange').val()

        if not stateCapitalize or city is "" or neighborhood is "" then return
        postalCode = rules.map[stateCapitalize.label][city][neighborhood]

        @select('postalCodeSelector').val(postalCode)
        @addressKeysUpdated()

      # Set to a loading state
      # This will disable all fields
      @loading = (ev, data) ->
        ev?.stopPropagation()
        @attr.data.loading = true
        @fillCitySelect()
        @fillNeighborhoodSelect()
        @render()

      @profileUpdated = (e, profile) ->
        # Changed when the user makes changes to the profile, before sending the profile to the API and getting a response.
        @attr.profileFromEvent = profile

      # Handle the initial view of this component
      @enable = (ev, address) ->
        ev?.stopPropagation()
        firstName = window.vtexjs.checkout.orderForm?.clientProfileData?.firstName or @attr.profileFromEvent?.firstName
        lastName = window.vtexjs.checkout.orderForm?.clientProfileData?.lastName or @attr.profileFromEvent?.lastName
        if firstName and (address.receiverName is '' or not address.receiverName)
          address.receiverName = firstName + ' ' + lastName

        if address.neighborhoods or (address.neighborhood and address.neighborhood.indexOf(';') isnt -1)
          neighborhoods = if address.neighborhoods then address.neighborhoods else address.neighborhood
          address.neighborhood = ''
          @attr.data.neighborhoods = []
          for neighborhood in neighborhoods.split(';')
            if neighborhood.length > 0
              @attr.data.neighborhoods.push({
                value: neighborhood
                label: neighborhood
              })
        else
          @attr.data.neighborhoods = null

        if address.cities or (address.city and address.city.indexOf(';') isnt -1)
          cities = if address.cities then address.cities else address.city
          address.city = ''
          @attr.data.cities = []
          for city in cities.split(';')
            if city.length > 0
              @attr.data.cities.push({
                value: city
                label: city
              })
              console.log(@attr.data.cities)
        else
          @attr.data.cities = null
        @attr.data.address = new Address(address)
        # when the address has an address query, the address was searched with geolocation
        @attr.data.addressQuery = if address.addressQuery? then address.addressQuery else false
        @attr.data.hasGeolocationData = @attr.data.address.geoCoordinates.length > 0
        @attr.data.comeFromGeoSearch = address.addressQuery?

        handleLoadSuccess = =>
          rules = @getCountryRule()
          if rules?.postalCodeByInput and rules?.masks?.postalCode and @attr.data.address.postalCode and @attr.data.address.postalCode.length > 0
            @attr.data.address.postalCode = _.maskString(@attr.data.address.postalCode, rules.masks.postalCode)
          if rules.country is 'UNI' and @attr.data.address.postalCode is '0'
            @attr.data.isUniversalUsingPostalCode = false

          @clearGeolocationContractedFields()
          @updateEnables(@attr.data.address)
          @fillCitySelect()
          @fillNeighborhoodSelect()
          @render().then =>
            countryRule = @getCountryRule()
            # For the countries that use postal code, we must trigger
            # an addressKeysUpdated, so it can search for the SLAs
            if countryRule.queryByPostalCode ||
               countryRule.queryByGeocoding ||
               countryRule.country is 'UNI'
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
        @trigger('addressFormSubmit.vtex')

      @updateEnables = ->
        if @getCountryRule().geocodingAvailable and @attr.data.address.geoCoordinates.length is 2
          @attr.data.contractedShippingFieldsForGeolocation =
            neighborhood: @attr.data.address.neighborhood isnt '' and @attr.data.address.neighborhood?
            street: @attr.data.address.street isnt '' and @attr.data.address.street?
            city: @attr.data.address.city isnt '' and @attr.data.address.city?
            state: @attr.data.address.state isnt '' and @attr.data.address.state?
            postalCode: @attr.data.address.postalCode isnt '' and @attr.data.address.postalCode? and @attr.data.addressQuery

        if @getCountryRule().queryByPostalCode
          @attr.data.labelShippingFields = @attr.data.address.neighborhood isnt '' and @attr.data.address.neighborhood? and
            @attr.data.address.street isnt '' and @attr.data.address.street? and
            @attr.data.address.state isnt '' and @attr.data.address.state? and
            @attr.data.address.city isnt '' and @attr.data.address.city?

          @attr.data.labelFields =
            state: @attr.data.address.state isnt '' and @attr.data.address.state?
            city: @attr.data.address.city isnt '' and @attr.data.address.city?
            neighborhood: @attr.data.address.neighborhood isnt '' and @attr.data.address.neighborhood?

          if _.all(@attr.data.labelFields, (f) -> f is false)
            @attr.data.labelFields = null

          @attr.data.disableCityAndState = @attr.data.address.state and @attr.data.address.city

      @googleMapsAPILoaded = ->
        @attr.data.loading = false
        @createMap()

      @universalUsePostalCode = (e) ->
        e.preventDefault()
        @attr.data.isUniversalUsingPostalCode = true
        @attr.reRenderUniversalPostalCode = true
        @render()

      @universalDontUsePostalCode = (e) ->
        e.preventDefault()
        @attr.data.isUniversalUsingPostalCode = false
        @attr.reRenderUniversalPostalCode = true
        @render().then(()=> @addressKeysUpdated())

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on 'startLoading.vtex', @loading
        @on 'googleMapsAPILoaded.vtex', @googleMapsAPILoaded
        @on window, 'profileUpdated', @profileUpdated
        @on 'click',
          'forceShippingFieldsSelector': @forceShippingFields
          'findAPostalCodeForAnotherAddressSelector': @findAnotherPostalCode
          'usePostalCodeSelector': @universalUsePostalCode,
          'dontUsePostalCodeSelector': @universalDontUsePostalCode
        @on 'change',
          'stateSelector': @changedStateHandler
          'citySelector': @changedCityHandler
          'basedOnStateChange': @changePostalCodeByCity
          'basedOnCityChange': @changePostalCodeByNeighborhood
        @on 'keyup',
          'postalCodeSelector': @addressKeysUpdated
        @on 'submit',
          'addressFormSelector': @stopSubmit

        @$node.on 'blur', @attr.universalPostalCodeSelector, @addressKeysUpdated.bind(this)

        @setValidators [
          @validateAddress
        ]

        @setLocalePath 'shipping/script/translation/'

    return defineComponent(AddressForm, withi18n, withValidation, withImplementedCountries)
