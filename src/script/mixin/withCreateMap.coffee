define ['shipping/script/module/googleRequiredFields'], (checkRequiredFields) ->
  return ->
    checkRequiredFields = checkRequiredFields

    @createMap = () ->
      if @attr.data.address?.geoCoordinates?.length is 2
        @select('mapCanvasSelector').css('display', 'block')

        if @attr.map
          @attr.map = null
        if @attr.marker
          @attr.marker.setMap(null)
          @attr.marker = null

        location = new google.maps.LatLng(@attr.data.address.geoCoordinates[1], @attr.data.address.geoCoordinates[0])

        mapOptions =
          zoom: 15
          center: location
          streetViewControl: false
          mapTypeControl: false
          zoomControl: true
          zoomControlOptions:
            position: google.maps.ControlPosition.TOP_RIGHT
            style: google.maps.ZoomControlStyle.SMALL
        @attr.map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions)

        markerOptions =
          position: location
          draggable: true
          map: @attr.map
        @attr.marker = new google.maps.Marker(markerOptions)

        @attr.markerListener = google.maps.event.addListener @attr.marker, 'position_changed', _.debounce(( =>
          newPosition = @attr.marker.getPosition()
          @changeMarkerPosition(newPosition)
        ), 1500)

    @changeMarkerPosition = (newPosition) ->
      if !@attr.geocoder
        @attr.geocoder = new google.maps.Geocoder()

      @attr.geocoder.geocode({location: newPosition}, ((results, status) =>
        if status is google.maps.GeocoderStatus.OK
          if results[0]
            countryRules = @getCountryRule()
            googleAddress = results[0]
            postalCodeRegex = countryRules.regexes['postalCode']
            googleDataMap = countryRules.googleDataMap
            fallbackCountry = countryRules.country
            storeAcceptsGeoCoords = ('geoCoords' in @attr.data.logisticsConfiguration?.acceptSearchKeys)

            address = @getAddressFromGoogle(googleAddress, googleDataMap, fallbackCountry)

            @attr.data.requiredGoogleFieldsNotFound = checkRequiredFields(address, googleDataMap, postalCodeRegex, storeAcceptsGeoCoords)
            
            address.postalCodeIsValid = postalCodeRegex.test(address.postalCode)
            address.geoCoordinatesIsValid = address.geoCoordinates.length is 2

            if storeAcceptsGeoCoords or @attr.data.requiredGoogleFieldsNotFound.length is 0 
              @trigger('addressKeysUpdated.vtex', [address])
              @attr.addressKeyMap = address
              @attr.data.address = new Address(address)
              @render()
            else if address.postalCode is '' or not address.postalCode?
              console.log('Incomplete address data!')
              # @select('incompleteAddressData').hide()
              # @select('addressNotDetailed').fadeIn()
            else if not postalCodeRegex.test(address.postalCode)
              console.log('Address not detailed!')
              # @select('addressNotDetailed').hide()
              # @select('incompleteAddressData').fadeIn()
        else
          console.log('Google Maps: '+status)
      ))