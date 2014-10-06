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
      @loading = (ev) ->
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
        agent = navigator.userAgent or navigator.vendor or window.opera
        return (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|android|ipad|playbook|silk|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(agent) or /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(agent.substr(0,4)))

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