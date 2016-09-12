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
            @attr.data.address.geoCoordinates = address.geoCoordinates
            @attr.data.address.postalCodeIsValid = postalCodeRegex.test(address.postalCode)
            @attr.data.address.geoCoordinatesIsValid = address.geoCoordinates.length is 2
            @trigger('addressKeysUpdated.vtex', [@attr.data.address])
            @render()
        else
          console.log('Google Maps: '+status)
      ))
