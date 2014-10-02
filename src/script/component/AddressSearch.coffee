define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/script/setup/extensions',
        'shipping/script/models/Address',
        'shipping/script/mixin/withi18n',
        'shipping/script/mixin/withValidation',
        'shipping/templates/addressSearch'
        ],
  (defineComponent, extensions, Address, withi18n, withValidation, template) ->
    AddressSearch = ->
      @defaultAttrs
        getAddressInformation: null
        data:
          hasAvailableAddresses: false
          postalCodeQuery: null
          addressQuery: null
          showGeolocationSearch: false
          requiredGoogleFieldsNotFound: []
          postalCodeByInput: false
          suggestedAddress:
            raw: null
            formatted: null
            position: null

        addressFormSelector: '.address-form-new'
        postalCodeQuerySelector: '.postal-code-query'
        cancelAddressFormSelector: '.cancel-address-form a'
        addressSearchSelector: '#ship-address-search'
        mapCanvasSelector: '#map-canvas'
        clearAddressSearchSelector: '.clear-address-search'
        dontKnowPostalCodeSelector: '.dont-know-postal-code-geocoding'
        knowPostalCodeSelector: '.know-postal-code'
        incompleteAddressData: '.incomplete-address-data'
        addressNotDetailed: '.address-not-detailed'
        incompleteAddressLink: '.incomplete-address-data-link'
        addressSuggestionLinkSelector: '#address-suggestion-link'
        textAddressSuggestionSelector: '.text-address-suggestion'
        formattedAddressSugestionSelector: '.formatted-address-sugestion'
        countryRules: false
        geoSearchTimer = false

      @render = ->
        dust.render template, @attr.data, (err, output) =>
          output = $(output).i18n()
          @$node.html(output)

          if @attr.data.showGeolocationSearch
            @startGoogleAddressSearch()
            @select('addressSearchSelector').focus()
          else
            @attr.autocomplete = null
            if not @isMobile()
              @select('postalCodeQuerySelector').inputmask
                mask: @attr.countryRules.masks.postalCode

            window.ParsleyValidator.addValidator('postalcode',
              (val) =>
                  return @attr.countryRules.regexes.postalCode.test(val)
              , 32)

          if not (@attr.data.loading or @attr.data.loadingGeolocation or @attr.data.showGeolocationSearch)
            @select('postalCodeQuerySelector').focus()

          @attr.parsley = @select('addressFormSelector').parsley
            errorClass: 'error'
            successClass: 'success'
            errorsWrapper: '<span class="help error error-list"></span>'
            errorTemplate: '<span class="error-description"></span>'

      # Validate the postal code input
      # If successful, this will call the postal code API
      @validatePostalCode = (ev, data) ->
        postalCode = data.el.value
        rules = @attr.countryRules
        if rules.regexes.postalCode.test(postalCode)
          @attr.data.postalCodeQuery = postalCode
          @attr.data.loading = true
          @render()
          @getPostalCode postalCode

      # Call the postal code API
      @getPostalCode = (postalCode) ->
        # Clear map position
        @attr.getAddressInformation({
          postalCode: postalCode.replace(/-/g, '')
          country: @attr.data.country
        }).then(@handleAddressSearch.bind(this), @handleAddressSearchError.bind(this))

      @handleAddressSearch = (address) ->
        @attr.data.loading = false
        address.addressId = @attr.data.addressId
        @trigger('addressSearchResult.vtex', [address])

      @handleAddressSearchError = ->
        @attr.data.loading = false
        @render()

      @startGoogleAddressSearch = ->
        options =
          types: ['address']
          componentRestrictions:
            country: @attr.countryRules.abbr

        if @attr.geolocation
          options['bounds'] = @attr.geolocation

        @attr.autocomplete = new google.maps.places.Autocomplete(@select('addressSearchSelector')[0], options)

        google.maps.event.addListener @attr.autocomplete, 'place_changed', =>
          googleAddress = @attr.autocomplete.getPlace()
          @addressMapper(googleAddress)

      @addressMapper = (googleAddress) ->
        # Clean required google fields error and render
        @attr.data.requiredGoogleFieldsNotFound = []
        googleDataMap = @attr.countryRules.googleDataMap
        location = googleAddress.geometry.location
        address =
          geoCoordinates: [
            if _.isFunction(location.lng) then location.lng() else location.lng,
            if _.isFunction(location.lat) then location.lat() else location.lat
          ]
        address.country = @attr.countryRules.country
        address.addressQuery = googleAddress.formatted_address
        address = _.extend(address, @getAddressFromGoogle(googleAddress, googleDataMap))

        _.each googleDataMap, (rule) =>
          if rule.required and not address[rule.value] or
            (rule.value is "postalCode" and not @attr.countryRules.regexes[rule.value].test(address[rule.value]))
              @attr.data.requiredGoogleFieldsNotFound.push(rule.value)

        if @attr.data.requiredGoogleFieldsNotFound.length is 0
          @handleAddressSearch(address)
        else
          if @attr.countryRules.deliveryOptionsByPostalCode
            if address.postalCode is '' or not address.postalCode?
              @select('incompleteAddressData').hide()
              @select('addressNotDetailed').fadeIn()
            else if not @attr.countryRules.regexes.postalCode.test(address.postalCode)
              @select('addressNotDetailed').hide()
              @select('incompleteAddressData').fadeIn()
          else
            @render()

      @getAddressFromGoogle = (googleAddress, googleDataMap) ->
        address = {}
        _.each googleDataMap, (rule) =>
          _.each googleAddress.address_components, (component) =>
            if _.intersection(component.types, rule.types).length > 0
              address[rule.value] = component[rule.length]
        return address

      # Close the form
      @cancelAddressForm = ->
        @trigger('cancelAddressSearch.vtex')

      # Set to a loading state
      # This will disable all fields
      @loading = (ev, data) ->
        ev?.stopPropagation()
        @attr.data.loading = true
        @render()

      # Handle the initial view of this component
      @enable = (ev, countryRule, address, hasAvailableAddresses) ->
        ev?.stopPropagation()
        @attr.countryRules = countryRule
        @attr.data.dontKnowPostalCodeURL = countryRule.dontKnowPostalCodeURL
        @attr.data.geocodingAvailable = countryRule.geocodingAvailable
        @attr.data.country = countryRule.country
        @attr.data.postalCodeByInput = countryRule.postalCodeByInput
        @attr.data.showGeolocationSearch = address?.useGeolocationSearch
        @attr.data.addressId = address?.addressId
        @attr.data.hasAvailableAddresses = hasAvailableAddresses

        if countryRule.queryByPostalCode
          @attr.data.postalCodeQuery = address?.postalCode ? ''
          @render()
        if countryRule.queryByGeocoding or @attr.data.showGeolocationSearch
          @openGeolocationSearch()
        else if @isMobile()
          @getNavigatorCurrentPosition()

      @disable = (ev) ->
        ev?.stopPropagation()
        @$node.html('')

      @getSuggestedAddress = (lat, lng) ->
        $.ajax
          url: "//maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{lng}"
          success: @onSuggestedAddressLoaded.bind(@)

      @onSuggestedAddressLoaded = (response) ->
        if response.status is "OK"
          # Find and store the suggested location address booth in raw and formatted models
          suggestedAddress = @attr.data.suggestedAddress
          suggestedAddress.raw = _.find response.results, (address) ->
            hasPostalCode = _.any address.address_components, (a) -> "postal_code" in a.types
            return address.geometry.location_type is "ROOFTOP" and hasPostalCode
          if suggestedAddress.raw
            suggestedAddress.formatted = @getAddressFromGoogle(suggestedAddress.raw, @attr.countryRules.googleDataMap)
            # Fills and show the suggestion selector on HTML
            @select('formattedAddressSugestionSelector')
              .text("#{suggestedAddress.formatted.street}, #{suggestedAddress.formatted.number}, #{suggestedAddress.formatted.neighborhood}")
            @select('textAddressSuggestionSelector').fadeIn()
          else
            suggestedAddress =
              raw: null
              formatted: null
              position: null

      @selectSuggestedAddress = ->
        @addressMapper(@attr.data.suggestedAddress.raw)

      @setGeolocation = (position) ->
        @attr.data.suggestedAddress.position = position;
        @getSuggestedAddress(position.coords.latitude, position.coords.longitude)
        if window.vtex.maps.isGoogleMapsAPILoaded
          @setAutocompleteBounds()

      @handleGeolocationError = (error) ->
        switch error.code
          when 1 then console.log("PERMISSION_DENIED")
          when 2 then console.log("POSITION_UNAVAILABLE")
          when 3 then console.log("TIMEOUT")
          else console.log("GENERIC_EROR")

      @setAutocompleteBounds = ->
        if @attr.data.suggestedAddress.position
          coord = new google.maps.LatLng(@attr.data.suggestedAddress.position.coords.latitude, @attr.data.suggestedAddress.position.coords.longitude);
          @attr.geolocation = google.maps.LatLngBounds(coord, coord)
          @attr.autocomplete?.setBounds(@attr.geolocation)

      @openGeolocationSearch = ->
        @getNavigatorCurrentPosition()
        if not window.vtex.maps.isGoogleMapsAPILoaded and not window.vtex.maps.isGoogleMapsAPILoading
          @attr.data.loadingGeolocation = true
          @attr.data.showGeolocationSearch = false
          @render()
        else
          @attr.data.showGeolocationSearch = true
          @render()

      @getNavigatorCurrentPosition = ->
        if navigator.geolocation
          navigator.geolocation.getCurrentPosition(@setGeolocation.bind(@), @handleGeolocationError.bind(@), { enableHighAccuracy: true, maximumAge: 120 * 1000, timeout: 15 * 1000 })
        else
          @attr.geolocation = null
        return

      @openPostalCodeSearch = ->
        @attr.data.showGeolocationSearch = false
        @render()
        if @isMobile()
          @getNavigatorCurrentPosition()

      @cancelAddressSearch = (ev) ->
        ev.preventDefault();
        @disable()
        @trigger('cancelAddressEdit.vtex')

      @stopSubmit = (ev) ->
        ev.preventDefault()

      @isMobile = ->
        return (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent))

      @googleMapsAPILoaded = ->
        @attr.data.loadingGeolocation = false
        @attr.data.showGeolocationSearch = true
        @setAutocompleteBounds()

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on 'startLoading.vtex', @loading
        @on 'googleMapsAPILoaded.vtex', @googleMapsAPILoaded
        @on 'click',
          'dontKnowPostalCodeSelector': @openGeolocationSearch
          'knowPostalCodeSelector': @openPostalCodeSearch
          'incompleteAddressLink': @openPostalCodeSearch
          'addressSuggestionLinkSelector': @selectSuggestedAddress
          'cancelAddressFormSelector': @cancelAddressSearch
        @on 'keyup',
          'postalCodeQuerySelector': @validatePostalCode
        @on 'submit',
          'addressFormSelector': @stopSubmit

        @setValidators [
          @validateAddress
        ]

        @setLocalePath 'shipping/script/translation/'

    return defineComponent(AddressSearch, withi18n, withValidation)