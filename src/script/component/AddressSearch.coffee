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
        map: false
        getAddressInformation: null
        data:
          showBackButton: false
          country: 'BRA'
          postalCodeQuery: null
          addressQuery: null
          showGeolocationSearch: false
          requiredGoogleFieldsNotFound: []

          countryRules:
            masks:
              postalCode: '99999-999'
            regexes:
              postalCode: /^([\d]{5})\-?([\d]{3})$/

        addressFormSelector: '.address-form-new'
        postalCodeQuerySelector: '.postal-code-query'
        cancelAddressFormSelector: '.cancel-address-form a'
        addressSearchSelector: '#ship-address-search'
        mapCanvasSelector: '#map-canvas'
        clearAddressSearchSelector: '.clear-address-search'
        dontKnowPostalCodeSelector: '#dont-know-postal-code'
        knowPostalCodeSelector: '.know-postal-code'
        countryRule: false

        # Google maps variables
        map = null
        marker = null

      @render = (data = @attr.data) -> require 'shipping/script/translation/' + @attr.locale, (translation) =>
        @extendTranslations(translation)
        dust.render template, data, (err, output) =>
          output = $(output).i18n()
          @$node.html(output)

          if @attr.data.showGeolocationSearch
            @startGoogleAddressSearch()

          if data.loading #TODO botar dentro do template
            $('input, select, .btn', @$node).attr('disabled', 'disabled')

          @select('postalCodeQuerySelector').inputmask
            mask: @getCountryRule().masks.postalCode

          @select('postalCodeQuerySelector').focus()

          window.ParsleyValidator.addValidator('postalcode',
            (val) =>
                return @getCountryRule().regexes.postalCode.test(val)
            , 32)

          @attr.parsley = @select('addressFormSelector').parsley
            errorClass: 'error'
            successClass: 'success'
            errorsWrapper: '<span class="help error error-list"></span>'
            errorTemplate: '<span class="error-description"></span>'

      # Helper function to get the current country's rules
      @getCountryRule = ->
        @attr.data.countryRules

      # Validate the postal code input
      # If successful, this will call the postal code API
      @validatePostalCode = (ev, data) ->
        postalCode = data.el.value
        rules = @getCountryRule()
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
          country = @attr.countryRule.abbr
          script = document.createElement("script")
          script.type = "text/javascript"
          script.src = "//maps.googleapis.com/maps/api/js?sensor=false&components=country:#{country}&language=#{@attr.locale}&callback=window.vtex.maps.googleMapsLoadedOnSearch"
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

      @addressMapper = (googleAddress) ->
        # Clean required google fields error and render
        @attr.data.requiredGoogleFieldsNotFound = []
        googleDataMap = @attr.countryRule.googleDataMap
        address = {
          geoCoordinates: [
            googleAddress.geometry.location.lng()
            googleAddress.geometry.location.lat()
          ]
        }
        address.country = @attr.countryRule.country
        address.addressQuery = googleAddress.formatted_address
        _.each googleDataMap, (rule) =>
          _.each googleAddress.address_components, (component) =>
            if _.intersection(component.types, rule.types).length > 0
              address[rule.value] = component[rule.length]
          if rule.required and not address[rule.value]
            @attr.data.requiredGoogleFieldsNotFound.push(rule.value)

        if @attr.data.requiredGoogleFieldsNotFound.length is 0
          @handleAddressSearch(address)
        else
          @render()

      # Close the form
      @cancelAddressForm = ->
        @trigger('cancelAddressSearch.vtex')

      # Set to a loading state
      # This will disable all fields
      @loading = (ev, data) ->
        @attr.data.loading = true
        @render()

      # Handle the initial view of this component
      @enable = (ev, addressSearch, countryRule) ->
        ev?.stopPropagation()
        @attr.countryRule = countryRule;
        if addressSearch
          @attr.data.postalCodeQuery = addressSearch # TODO may be google search
        else
          @attr.data.postalCodeQuery = null
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
