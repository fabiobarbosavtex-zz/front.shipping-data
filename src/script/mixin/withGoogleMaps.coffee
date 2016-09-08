define ['shipping/script/module/countryISOMap',
        'shipping/script/module/googleRequiredFields',
        'shipping/script/component/ShippingDataStore'], (countryISOMap, checkRequiredFields, ShippingDataStore) ->
  return ->
    countryISOMap = countryISOMap
    checkRequiredFields = checkRequiredFields

    @startGoogleAddressSearch = ->
      options =
        types: ['address']
        componentRestrictions:
          country: @attr.countryRules.abbr

      if @attr.geolocation
        options['bounds'] = @attr.geolocation

      @attr.autocomplete = new google.maps.places.Autocomplete(@select('addressSearchSelector')[0], options)

      if @attr.autocompleteListerner
        @attr.autocompleteListerner.remove()

      @attr.autocompleteListerner = google.maps.event.addListener @attr.autocomplete, 'place_changed', =>
        googleAddress = @attr.autocomplete.getPlace()
        @attr.data.suggestedAddress.raw = googleAddress
        @selectSuggestedAddress()

    getCountry = (googleAddress) ->
      countryInfo =_.find(googleAddress.address_components, (c) -> 'country' in c.types)
      if countryInfo
        return countryISOMap(countryInfo.short_name)
      return null

    @getAddressFromGoogle = (googleAddress, googleDataMap, fallbackCountry) ->
      address = {}

      # Fill address with country mapping
      for rule in googleDataMap
        for component in googleAddress.address_components
          if _.intersection(component.types, rule.types).length > 0
            address[rule.value] = component[rule.length]

      # Get geoCoordinates
      location = googleAddress.geometry.location
      address.geoCoordinates = [
        if _.isFunction(location.lng) then location.lng() else location.lng,
        if _.isFunction(location.lat) then location.lat() else location.lat
      ]

      # Get country
      country = getCountry(googleAddress)
      address.country = if country then country else fallbackCountry

      # Get address query
      address.addressQuery = googleAddress.formatted_address

      return address

    validatePostalCode = (postalCode, postalCodeRegex) ->
      if postalCodeRegex
        return postalCodeRegex.test(postalCode)
      else
        return true

    @selectSuggestedAddress = ->
      @attr.data.invalidFields = []
      countryRules = @attr.countryRules
      googleAddress = @attr.data.suggestedAddress.raw
      postalCodeRegex = countryRules.regexes['postalCode']
      googleDataMap = countryRules.googleDataMap
      fallbackCountry = countryRules.country
      storeAcceptsGeoCoords = ('geoCoords' in @attr.data.logisticsConfiguration?.acceptSearchKeys)

      address = @getAddressFromGoogle(googleAddress, googleDataMap, fallbackCountry)

      # Validate postal code
      address.isPostalCodeValid = validatePostalCode(address.postalCode, postalCodeRegex)

      @attr.data.invalidFields = checkRequiredFields(address, googleDataMap, postalCodeRegex, storeAcceptsGeoCoords)

      if storeAcceptsGeoCoords or @attr.data.invalidFields.length is 0
        @trigger('addressSearchStart.vtex')
        @sendGeoCoords(address)
      else if address.postalCode is '' or not address.postalCode?
        @select('incompleteAddressData').hide()
        @select('addressNotDetailed').fadeIn()
      else if not address.isPostalCodeValid
        @select('addressNotDetailed').hide()
        @select('incompleteAddressData').fadeIn()


    @handleGeolocationError = (error) ->
      switch error.code
        when 1 then console.log("Geolocation: PERMISSION_DENIED")
        when 2 then console.log("Geolocation: POSITION_UNAVAILABLE")
        when 3 then console.log("Geolocation: TIMEOUT")
        else console.log("Geolocation: ERROR")

    @openGeolocationSearch = ->
      @getNavigatorCurrentPosition()
      if window.vtex.maps.isGoogleMapsAPILoading and !window.vtex.maps.isGoogleMapsAPILoaded
        @attr.data.loadingGeolocation = true
        @attr.data.showGeolocationSearch = false
      else
        @attr.data.showGeolocationSearch = true

      if @attr.isEnabled
        @render()

    @getNavigatorCurrentPosition = ->
      if navigator.geolocation
        navigator.geolocation.getCurrentPosition(@setGeolocation.bind(@), @handleGeolocationError.bind(@), {
          enableHighAccuracy: true,
          maximumAge: 120 * 1000,
          timeout: 15 * 1000
        })
      else
        @attr.geolocation = null
      return

    @googleMapsAPILoaded = ->
      @attr.data.loadingGeolocation = false
      @attr.data.showGeolocationSearch = true
      @setAutocompleteBounds()
      if @attr.isEnabled
        @render()

    @onSuggestedAddressLoaded = (response) ->
      if response.status is "OK"
        # Find and store the suggested location address booth in raw and formatted models
        suggestedAddress = @attr.data.suggestedAddress

        suggestedAddress.raw = _.find response.results, (address) ->
          hasPostalCode = _.any address.address_components, (a) -> "postal_code" in a.types
          return address.geometry.location_type is "ROOFTOP" and hasPostalCode

        if suggestedAddress.raw
          googleDataMap = @attr.countryRules.googleDataMap
          fallbackCountry = @attr.countryRules.country
          suggestedAddress.formatted = @getAddressFromGoogle(suggestedAddress.raw, googleDataMap, fallbackCountry)
          # Fills and show the suggestion selector on HTML
          @select('formattedAddressSugestionSelector')
            .text("#{suggestedAddress.formatted.street}, #{suggestedAddress.formatted.number}, #{suggestedAddress.formatted.city}")
          @select('textAddressSuggestionSelector').fadeIn()
        else
          suggestedAddress =
            raw: null
            formatted: null
            position: null
      else if response.status is "OVER_QUERY_LIMIT"
        console.log "OVER_QUERY_LIMIT"
        # todo -> Logar isso em algum lugar

    @onSuggestedAddressError = (error) ->
      console.log "REVERSE GEOCODE ERROR"
      console.log error

    @getSuggestedAddress = (lat, lng) ->
      $.ajax
        url: "//maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{lng}"
        success: @onSuggestedAddressLoaded.bind(@)
        error: @onSuggestedAddressError.bind(@)

    @setAutocompleteBounds = ->
      if @attr.data.suggestedAddress?.position
        coord = new google.maps.LatLng(@attr.data.suggestedAddress.position.coords.latitude, @attr.data.suggestedAddress.position.coords.longitude);
        @attr.geolocation = google.maps.LatLngBounds(coord, coord)
        @attr.autocomplete?.setBounds(@attr.geolocation)

    @setGeolocation = (position) ->
      @attr.data.suggestedAddress.position = position;
      @getSuggestedAddress(position.coords.latitude, position.coords.longitude)
      if window.vtex.maps.isGoogleMapsAPILoaded
        @setAutocompleteBounds()

    @sendGeoCoords = (address) ->
      if @attr.requestSendGeoCoords
        @attr.requestSendGeoCoords.abort()

      # If postal code is not valid we don't send it
      if not address.isPostalCodeValid
        address = _.extend({}, address, {postalCode: null})

      @attr.requestSendGeoCoords = ShippingDataStore.sendAttachment({
        address: address,
        clearAddressIfPostalCodeNotFound: false
      }).then(
        ((orderForm) =>
          @handleAddressSearch(orderForm.shippingData.address)),
        (() =>
          @handleAddressSearchError(address))
      )
