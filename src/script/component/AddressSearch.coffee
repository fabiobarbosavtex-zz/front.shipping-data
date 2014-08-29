define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/script/setup/extensions',
        'shipping/script/models/Address',
        'shipping/script/mixin/withi18n',
        'shipping/script/mixin/withValidation',
        'shipping/templates/addressSearch'],
  (defineComponent, extensions, Address, withi18n, withValidation, template) ->
    AddressSearch = ->
      @defaultAttrs
        getAddressInformation: null
        data:
          showBackButton: false
          postalCodeQuery: null
          addressQuery: null
          showGeolocationSearch: false
          requiredGoogleFieldsNotFound: []
          numberOfValidAddressResults: false

        addressFormSelector: '.address-form-new'
        postalCodeQuerySelector: '.postal-code-query'
        cancelAddressFormSelector: '.cancel-address-form a'
        addressSearchSelector: '#ship-address-search'
        mapCanvasSelector: '#map-canvas'
        clearAddressSearchSelector: '.clear-address-search'
        dontKnowPostalCodeSelector: '#dont-know-postal-code'
        knowPostalCodeSelector: '.know-postal-code'
        countryRules: false
        geoSearchTimer = false

      @render = () ->
        require ['shipping/script/translation/' + @attr.locale], (translation) =>
          @extendTranslations(translation)
          dust.render template, @attr.data, (err, output) =>
            output = $(output).i18n()
            @$node.html(output)

            if @attr.data.showGeolocationSearch
              @startGoogleAddressSearch()

            if @attr.data.loading #TODO botar dentro do template
              $('input, select, .btn', @$node).attr('disabled', 'disabled')

            @select('postalCodeQuerySelector').inputmask
              mask: @attr.countryRules.masks.postalCode

            @select('postalCodeQuerySelector').focus()

            window.ParsleyValidator.addValidator('postalcode',
              (val) =>
                  return @attr.countryRules.regexes.postalCode.test(val)
              , 32)

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
        # Clear map postition
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
        if not window.vtex.maps.isGoogleMapsAPILoaded and not window.vtex.maps.isGoogleMapsAPILoading
          window.vtex.maps.isGoogleMapsAPILoading = true
          @loading()
          script = document.createElement("script")
          script.type = "text/javascript"
          script.src = "//maps.googleapis.com/maps/api/js?sensor=true&language=#{@attr.locale}&callback=window.vtex.maps.googleMapsLoadedOnSearch"
          document.body.appendChild(script)
          return

        addressListResponse = []
        @select('addressSearchSelector').typeahead
          minLength: 3,

          highlighter: (addressParam) =>
            googleDataMap = @attr.countryRules.googleDataMap
            googleAddress = _.find addressListResponse, (item) ->
              item.formatted_address is addressParam
            address = @getAddressFromGoogle(googleAddress, googleDataMap)

            formattedAddress = "<span class='search-result-item-street'>" + if address.street then address.street
            if address.street and address.number then formattedAddress += ", "
            if address.number then formattedAddress += address.number
            formattedAddress += "</span>&nbsp;"
            formattedAddress += "<small class='muted'>"
            if address.neighborhood then formattedAddress += address.neighborhood
            if address.neighborhood and address.city then formattedAddress += " - "
            if address.city then formattedAddress += address.city
            if address.city and address.state then formattedAddress += " - "
            if address.state then formattedAddress += address.state
            formattedAddress += "</small>"

          matcher: (address) =>
            hasPostalCode = false
            isPostalCodePrefix = false
            addressObject = _.find addressListResponse, (item) ->
              item.formatted_address is address
            _.each addressObject.address_components, (component) ->
              _.each component.types, (type) ->
                if type is "postal_code"
                  hasPostalCode = true
                if type is 'postal_code_prefix'
                  isPostalCodePrefix = true
            if hasPostalCode and !isPostalCodePrefix
              @attr.data.numberOfValidAddressResults++
              true

          source: (query, process) =>
            if @attr.geoSearchTimer
              window.clearTimeout(@attr.geoSearchTimer)
            @attr.geoSearchTimer = window.setTimeout(=>
              geocoder = new google.maps.Geocoder()
              geoCodeRequest =
                address: query
                componentRestrictions:
                  country: @attr.countryRules.abbr
              geocoder.geocode geoCodeRequest, (response, status) =>
                @attr.data.numberOfValidAddressResults = 0
                if status is "OK" and response.length > 0
                  addressListResponse = response
                  itemsToDisplay = []
                  _.each response, (item) =>
                    if @attr.locale is "pt-BR"
                      item.formatted_address = item.formatted_address.replace(", República Federativa do Brasil", "")
                    itemsToDisplay.push item.formatted_address
                  process(itemsToDisplay)
            , 300);

          updater: (address) =>
            addressObject = _.find addressListResponse, (item) ->
              item.formatted_address is address
            @addressMapper(addressObject)

      @addressMapper = (googleAddress) ->
        # Clean required google fields error and render
        @attr.data.requiredGoogleFieldsNotFound = []
        googleDataMap = @attr.countryRules.googleDataMap
        address = {
          geoCoordinates: [
            googleAddress.geometry.location.lng()
            googleAddress.geometry.location.lat()
          ],
          geometry: googleAddress.geometry
        }
        address.country = @attr.countryRules.country
        address.addressQuery = googleAddress.formatted_address
        address = _.extend(address, @getAddressFromGoogle(googleAddress, googleDataMap))

        _.each googleDataMap, (rule) =>
          if rule.required and not address[rule.value]
            @attr.data.requiredGoogleFieldsNotFound.push(rule.value)

        if @attr.data.requiredGoogleFieldsNotFound.length is 0
          @handleAddressSearch(address)
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
        @attr.data.loading = true
        @render()

      # Handle the initial view of this component
      @enable = (ev, countryRule, postalCodeQuery, useGeolocationSearch) ->
        ev?.stopPropagation()
        @attr.data.showGeolocationSearch = if useGeolocationSearch? then useGeolocationSearch else false
        @attr.countryRules = countryRule
        @attr.data.country = countryRule.country
        # TODO may be google search
        @attr.data.postalCodeQuery = postalCodeQuery ? ''
        @render()

      @disable = (ev) ->
        ev?.stopPropagation()
        @$node.html('')

      @openGeolocationSearch = ->
        @attr.data.showGeolocationSearch = true;
        @render()

      @openZipSearch = ->
        @attr.data.showGeolocationSearch = false;
        @render()

      @stopSubmit = (ev) ->
        ev.preventDefault()

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on 'loading.vtex', @loading
        @on 'click',
          'dontKnowPostalCodeSelector': @openGeolocationSearch
          'knowPostalCodeSelector': @openZipSearch
        @on 'keyup',
          'postalCodeQuerySelector': @validatePostalCode
        @on 'submit',
          'addressFormSelector': @stopSubmit


        @setValidators [
          @validateAddress
        ]

        window.vtex.maps = window.vtex.maps or {}

        # Called when google maps api is loaded
        window.vtex.maps.googleMapsLoadedOnSearch = =>
          @attr.data.loading = false
          window.vtex.maps.isGoogleMapsAPILoaded = true
          window.vtex.maps.isGoogleMapsAPILoading = false
          @render()

    return defineComponent(AddressSearch, withi18n, withValidation)