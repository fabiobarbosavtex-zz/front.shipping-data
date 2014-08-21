define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/setup/extensions',
        'shipping/models/Address',
        'shipping/mixin/withi18n',
        'shipping/mixin/withValidation',
        'shipping/mixin/withOrderForm',
        'shipping/template/selectCountry'],
  (defineComponent, extensions, Address, withi18n, withValidation, withOrderForm, selectCountryTemplate) ->
    AddressForm = ->
      @defaultAttrs
        API: null
        map: false
        marker: false
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
        postalCodeSelector: '#ship-postal-code'
        forceShippingFieldsSelector: '#force-shipping-fields'
        stateSelector: '#ship-state'
        citySelector: '#ship-city'
        deliveryCountrySelector: '#ship-country'
        cancelAddressFormSelector: '.cancel-address-form a'
        submitButtonSelector: '.submit .btn-success.address-save'
        addressSearchBtSelector: '.address-search-bt'
        addressSearchSelector: '#address-search'
        mapCanvasSelector: '#map-canvas'
        clearAddressSearchSelector: '.clear-address-search'
        dontKnowPostalCodeSelector: '#dont-know-postal-code'
        knowPostalCodeSelector: '#know-postal-code'

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
            errorsWrapper: '<div class="help error-list"></div>'
            errorTemplate: '<span class="help error"></span>'

          if not @attr.data.isSearchingAddress
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

      # Validate the postal code input
      # If successful, this will call the postal code API
      @validatePostalCode = (ev, data) ->
        postalCode = data.el.value
        rules = @getCountryRule()
        if rules.regexes.postalCode.test(postalCode)
          @attr.data.throttledLoading = true
          @attr.data.postalCodeQuery = postalCode
          @attr.data.address?.postalCode = postalCode
          @attr.data.loading = true if rules.queryPostalCode
          @render()
          if rules.queryPostalCode
            @getPostalCode postalCode

      @validateAddress = ->
        address = @attr.data.address
        if @select('addressFormSelector') and @attr.parsley
          valid = @attr.parsley.isValid()
          if valid
            @submitAddress(true)
          else if @attr.data.address.isValid
            @submitAddress(false)
          return valid
        else
          return address.validate(@getCountryRule())

      @clearAddressSearch = (ev) ->
        ev.preventDefault()
        @trigger('clearSelectedAddress.vtex')
        @attr.data.address = new Address(null, @attr.data.deliveryCountries)
        @attr.data.isSearchingAddress = true
        @attr.data.postalCodeQuery = null
        @render()

      # Call the postal code API
      @getPostalCode = (postalCode) ->
        # Clear map postition
        @attr.currentResponseCoordinates = null
        @attr.API.getAddressInformation({
          postalCode: postalCode.replace(/-/g, '')
          country: @attr.data.country
        }).then(@handleAddressSearch.bind(this), @handleAddressSearchError.bind(this))

      @handleAddressSearch = (address) ->
        @attr.data.throttledLoading = false
        @attr.data.loading = false
        @attr.data.showAddressForm = true
        @attr.data.isSearchingAddress = false
        @attr.data.labelShippingFields = address.neighborhood isnt '' and address.neighborhood? and
          address.street isnt '' and address.street? and
          address.state isnt '' and address.state? and
          address.city isnt '' and address.city?
        @attr.data.disableCityAndState = address.state isnt '' and address.city isnt ''
        @attr.data.address = new Address(address, @attr.data.deliveryCountries)
        @render()

        # Montando dados para send attachment
        attachment =
          address: @attr.data.address,
          clearAddressIfPostalCodeNotFound: @getCountryRule()?.usePostalCode
        @trigger('startLoadingShippingOptions.vtex')
        @attr.API?.sendAttachment('shippingData', attachment)

      @handleAddressSearchError = ->
        @attr.data.isSearchingAddress = false
        @attr.data.throttledLoading = false
        @attr.data.showAddressForm = true
        @attr.data.labelShippingFields = false
        @attr.data.disableCityAndState = false
        @attr.data.loading = false
        @render()

        # Montando dados para send attachment
        attachment =
          address: @attr.data.address,
          clearAddressIfPostalCodeNotFound: @getCountryRule()?.usePostalCode
        @attr.API?.sendAttachment('shippingData', attachment)

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

      @submitAddressHandler = (ev) ->
        @submitAddress(@attr.parsley.isValid())

      # Submit address to the server
      @submitAddress = (isValid) ->
        ev?.preventDefault()

        @attr.data.address = @getCurrentAddress()
        @attr.data.address.isValid = isValid

        # limpa campo criado para busca do google
        if @attr.data.address.addressSearch is null
          delete @attr.data.address["addressSearch"]

        # Submit address object
        @trigger('currentAddress.vtex', @attr.data.address)

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

      @addressMapper = (googleAddress) ->
        # Clean required google fields error and render
        @attr.data.requiredGoogleFieldsNotFound = []
        googleDataMap = @getCountryRule().googleDataMap
        address = {
          geoCoordinates: [
            googleAddress.geometry.location.lng()
            googleAddress.geometry.location.lat()
          ]
        }
        _.each googleDataMap, (rule) =>
          _.each googleAddress.address_components, (component) =>
            if _.intersection(component.types, rule.types).length > 0
              address[rule.value] = component[rule.length]
          if rule.required and not address[rule.value]
            @attr.data.requiredGoogleFieldsNotFound.push(rule.value)

        if @attr.data.requiredGoogleFieldsNotFound.length is 0
          @attr.currentResponseCoordinates = googleAddress.geometry.location
          @handleAddressSearch(address)
        else
          @render()

      @createMap = (location) ->
        @select('mapCanvasSelector').css('display', 'block')
        mapOptions =
          zoom: 14
          center: location

        if @attr.map
          @attr.map = null
        @attr.map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions)

        if @attr.marker
          @attr.marker.setMap(null)
          @attr.marker = null
        @attr.marker = new google.maps.Marker(position: location)
        @attr.marker.setMap(@attr.map)

      @startGoogleAddressSearch = ->
        if not @attr.isGoogleMapsAPILoaded
          script = document.createElement("script")
          script.type = "text/javascript"
          script.src = "//maps.googleapis.com/maps/api/js?sensor=false&callback=vtex.googleMapsLoaded"
          document.body.appendChild(script)
          return

        addressListResponse = []
        @select('addressSearchSelector').typeahead
          minLength: 3,
          matcher: -> true
          source: (query, process) ->
            geocoder = new google.maps.Geocoder()
            geocoder.geocode address: query, (response, status) =>
              if status is "OK" and response.length > 0
                addressListResponse = response
                itemsToDisplay = []
                _.each response, (item) ->
                  itemsToDisplay.push item.formatted_address
                process(itemsToDisplay)

          updater: (address) =>
            addressObject = _.find addressListResponse, (item) ->
              item.formatted_address is address
            @addressMapper(addressObject)

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
        @trigger('showAddressList.vtex')

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

      @orderFormUpdated = (ev, data) ->
        return unless data.shippingData
        @attr.data.availableAddresses = data.shippingData.availableAddresses ? []
        @attr.data.deliveryCountries = @getDeliveryCountries(data.shippingData.logisticsInfo)
        @attr.data.address = new Address(data.shippingData.address, @attr.data.deliveryCountries)
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

        @attr.data.isSearchingAddress = not address
        @attr.data.postalCodeQuery = null
        @attr.data.address = new Address(address, @attr.data.deliveryCountries)

        if @attr.data.deliveryCountries.length > 1 and @attr.data.isSearchingAddress
          @attr.data.showSelectCountry = true

        @selectCountry(@attr.data.address.country).then(@render.bind(this), @handleCountrySelectError.bind(this))

      @handleCountrySelectError = (reason) ->
        console.error("Unable to load country dependencies", reason)

      @disable = (ev) ->
        ev?.stopPropagation()
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
          'submitButtonSelector': @submitAddressHandler
          'addressSearchBtSelector': @searchAddress
          'clearAddressSearchSelector': @clearAddressSearch
          'dontKnowPostalCodeSelector': @openGeolocationSearch
          'knowPostalCodeSelector': @openZipSearch
        @on 'change',
          'deliveryCountrySelector': @selectedCountry
          'stateSelector': @onChangeState
          'citySelector': @changePostalCodeByCity
        @on 'keyup',
          'postalCodeSelector': @validatePostalCode

        @setValidators [
          @validateAddress
        ]

        # Called when google maps api is loaded
        window.vtex.googleMapsLoaded = =>
          @attr.data.loading = false
          @attr.isGoogleMapsAPILoaded = true
          @render()

    return defineComponent(AddressForm, withi18n, withValidation, withOrderForm)
