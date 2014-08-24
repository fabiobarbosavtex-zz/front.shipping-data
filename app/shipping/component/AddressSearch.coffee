define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/setup/extensions',
        'shipping/models/Address',
        'shipping/mixin/withi18n',
        'shipping/mixin/withValidation',
        'shipping/template/addressSearch'],
  (defineComponent, extensions, Address, withi18n, withValidation, template) ->
    AddressSearch = ->
      @defaultAttrs
        map: false
        API: null
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

        isGoogleMapsAPILoaded: false
        addressFormSelector: '.address-form-new'
        postalCodeSelector: '.postal-code'
        postalCodeQuerySelector: '.postal-code-query'
        cancelAddressFormSelector: '.cancel-address-form a'
        addressSearchSelector: '#address-search'
        mapCanvasSelector: '#map-canvas'
        clearAddressSearchSelector: '.clear-address-search'
        dontKnowPostalCodeSelector: '#dont-know-postal-code'
        knowPostalCodeSelector: '#know-postal-code'

        # Google maps variables
        map = null
        marker = null

      @render = (data = @attr.data) -> require 'shipping/translation/' + @attr.locale, (translation) =>
        @extendTranslations(translation)
        dust.render template, data, (err, output) =>
          output = $(output).i18n()
          @$node.html(output)

          if not @attr.isGoogleMapsAPILoaded and @attr.data.showGeolocationSearch
            @attr.data.loading = true

          if @attr.data.showGeolocationSearch
            @startGoogleAddressSearch()

          if data.loading #TODO botar dentro do template
            $('input, select, .btn', @$node).attr('disabled', 'disabled')

          @select('postalCodeSelector').inputmask
            mask: @getCountryRule().masks.postalCode

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

      @clearAddressSearch = (ev, obj) ->
        ev.preventDefault()

        if $(obj.el).hasClass('postal-code')
          postalCodeQuery = obj.el.value.replace(/-|\_/g, '')
          if postalCodeQuery is @attr.data.address.postalCode
            return
          else
            @attr.data.labelShippingFields = false
        # TODO - Afonso colocar caso do geolocation aqui
        # else if ev.hasClass('map-sei-la')
        #   ...

        @trigger('clearSelectedAddress.vtex')
        address = addressId: @attr.data.address.addressId
        @attr.data.address = new Address(address, @attr.data.deliveryCountries)
        @attr.data.isSearchingAddress = true
        @attr.data.postalCodeQuery = postalCodeQuery ? ''
        @render().then =>
          if postalCodeQuery
            @select('postalCodeQuerySelector').focus()

      # Call the postal code API
      @getPostalCode = (postalCode) ->
        # Clear map postition
        @attr.currentResponseCoordinates = null
        @attr.API.getAddressInformation({
          postalCode: postalCode.replace(/-/g, '')
          country: @attr.data.country
        }).then(@handleAddressSearch.bind(this), @handleAddressSearchError.bind(this))

      @handleAddressSearch = (address) ->
        @attr.data.loading = false
        @trigger('addressSearchResult.vtex', [address])

        # Montando dados para send attachment
        ###attachment =
          address: @attr.data.address,
          clearAddressIfPostalCodeNotFound: @getCountryRule()?.usePostalCode
        @trigger('startLoadingShippingOptions.vtex')
        @attr.ignoreNextEnable = true
        @attr.API?.sendAttachment('shippingData', attachment)###

      @handleAddressSearchError = ->
        @attr.data.loading = false
        @render()

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

      # Close the form
      @cancelAddressForm = ->
        @trigger('cancelAddressSearch.vtex')

      # Set to a loading state
      # This will disable all fields
      @loading = (ev, data) ->
        @attr.data.loading = true
        @render()

      # Handle the initial view of this component
      @enable = (ev, address) ->
        ev?.stopPropagation()
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
          'clearAddressSearchSelector': @clearAddressSearch
          'postalCodeQuerySelector': @validatePostalCode

        @setValidators [
          @validateAddress
        ]

        # Called when google maps api is loaded
        window.vtex.googleMapsLoaded = =>
          @attr.data.loading = false
          @attr.isGoogleMapsAPILoaded = true
          @render()

    return defineComponent(AddressSearch, withi18n, withValidation)
