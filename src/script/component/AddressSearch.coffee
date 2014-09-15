define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/script/setup/extensions',
        'shipping/script/models/Address',
        'shipping/script/mixin/withi18n',
        'shipping/script/mixin/withValidation',
        'shipping/templates/addressSearch',
        'shipping/script/libs/typeahead/typeahead.jquery'
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

        google.maps.event.addListener @attr.autocomplete, 'place_changed', (ev, data) =>
          googleAddress = @attr.autocomplete.getPlace()
          @addressMapper(googleAddress, @attr.countryRules.googleDataMap)

      @addressMapper = (googleAddress) ->
        # Clean required google fields error and render
        @attr.data.requiredGoogleFieldsNotFound = []
        googleDataMap = @attr.countryRules.googleDataMap
        address = {
          geoCoordinates: [
            googleAddress.geometry.location.lng()
            googleAddress.geometry.location.lat()
          ]
        }
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
      @enable = (ev, countryRule, postalCodeQuery, useGeolocationSearch) ->
        ev?.stopPropagation()
        @attr.data.showGeolocationSearch = if useGeolocationSearch? then useGeolocationSearch else false
        @attr.countryRules = countryRule
        @attr.data.dontKnowPostalCodeURL = countryRule.dontKnowPostalCodeURL
        @attr.data.geocodingAvailable = countryRule.geocodingAvailable
        @attr.data.country = countryRule.country
        @attr.data.postalCodeByInput = countryRule.postalCodeByInput

        if countryRule.queryByPostalCode
          @attr.data.postalCodeQuery = postalCodeQuery ? ''
          @render()
        if countryRule.queryByGeocoding
          @openGeolocationSearch()

      @disable = (ev) ->
        ev?.stopPropagation()
        @$node.html('')

      @setGeolocation = (position) ->
        coord = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
        @attr.geolocation = google.maps.LatLngBounds(coord, coord)

        if @attr.autocomplete
          @attr.autocomplete.setBounds(@attr.geolocation)
        else
          @openGeolocationSearch()

      @openGeolocationSearch = ->
        if navigator.geolocation
          navigator.geolocation.getCurrentPosition(@setGeolocation.bind(@))
        else
          @attr.geolocation = null

        if not window.vtex.maps.isGoogleMapsAPILoaded and not window.vtex.maps.isGoogleMapsAPILoading
          window.vtex.maps.isGoogleMapsAPILoading = true
          script = document.createElement("script")
          script.type = "text/javascript"
          script.src = "//maps.googleapis.com/maps/api/js?libraries=places&sensor=true&language=#{@attr.locale}&callback=window.vtex.maps.googleMapsLoadedOnSearch"
          document.body.appendChild(script)
          @attr.data.loadingGeolocation = true
          @attr.data.showGeolocationSearch = false
          @render()
          return
        else
          @attr.data.showGeolocationSearch = true
          @render()

      @openPostalCodeSearch = ->
        @attr.data.showGeolocationSearch = false
        @render()

      @stopSubmit = (ev) ->
        ev.preventDefault()

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on 'startLoading.vtex', @loading
        @on 'click',
          'dontKnowPostalCodeSelector': @openGeolocationSearch
          'knowPostalCodeSelector': @openPostalCodeSearch
          'incompleteAddressLink': @openPostalCodeSearch
        @on 'keyup',
          'postalCodeQuerySelector': @validatePostalCode
        @on 'submit',
          'addressFormSelector': @stopSubmit

        @setValidators [
          @validateAddress
        ]

        @setLocalePath 'shipping/script/translation/'

        window.vtex.maps = window.vtex.maps or {}

        # Called when google maps api is loaded
        window.vtex.maps.googleMapsLoadedOnSearch = =>
          @attr.data.loadingGeolocation = false
          @attr.data.showGeolocationSearch = true
          window.vtex.maps.isGoogleMapsAPILoaded = true
          window.vtex.maps.isGoogleMapsAPILoading = false
          @render()

    return defineComponent(AddressSearch, withi18n, withValidation)