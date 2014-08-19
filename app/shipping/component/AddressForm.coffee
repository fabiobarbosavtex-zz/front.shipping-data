define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/setup/extensions',
        'shipping/models/Address',
        'shipping/mixin/withi18n'],
  (defineComponent, extensions, AddressModel, withi18n) ->
    AddressForm = ->
      @defaultAttrs
        API: null
        data:
          address: new AddressModel({})
          availableAddresses: []
          country: false
          postalCode: ''
          deliveryCountries: ['BRA', 'ARG', 'CHL', 'COL', 'PER', 'ECU', 'PRY', 'URY', 'USA']
          disableCityAndState: false
          labelShippingFields: false
          showPostalCode: false
          showAddressForm: false
          showDontKnowPostalCode: true
          showSelectCountry: false
          currentSearch: false
          addressSearchResults: {}
          countryRules: {}
          useGeolocation:
            'BRA': false
            'ARG': false
            'CHL': false
            'COL': false
            'PER': false
            'ECU': false
            'PRY': false
            'URY': false
            'USA': false

        templates:
          form:
            baseName: 'countries/addressForm'
          selectCountry:
            name: 'selectCountry'
            template: 'shipping/template/selectCountry'

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

        # Google maps variables
        map = null
        marker = null

      # Render this component according to the data object
      @render = (data) ->
        data = @attr.data if not data

        deps = [
          'shipping/translation/' + @attr.locale,
          @attr.templates.selectCountry.template
        ]
        require deps, (translation) =>
          if data.showSelectCountry
            @extendTranslations(translation)
            dust.render @attr.templates.selectCountry.name, data, (err, output) =>
              output = $(output).i18n()
              @$node.html(output)
              @addFormListeners()

          else if data.showAddressForm
            rules = @getCurrentRule()
            data.statesForm = rules.states
            data.regexes = rules.regexes
            data.useGeolocation = rules.useGeolocation

            dust.render @attr.templates.form.name, data, (err, output) =>
              @extendTranslations(translation)
              output = $(output).i18n()
              @$node.html(output)
              @addFormListeners()

              if data.loading
                $('input, select, .btn', @$node).attr('disabled', 'disabled')

              if rules.citiesBasedOnStateChange
                @changeCities()
                if data.address.city
                  @select('citySelector').val(data.address.city)

              if rules.usePostalCode
                @select('postalCodeSelector').inputmask
                  mask: rules.masks.postalCode
                if data.labelShippingFields
                  @select('postalCodeSelector').addClass('success')

              @select('addressFormSelector').parsley
                errorClass: 'error'
                successClass: 'success'
                errors:
                  errorsWrapper: '<div class="help error-list"></div>'
                  errorElem: '<span class="help error"></span>'
                validators:
                  postalcode: =>
                    validate: (val) =>
                      rules = @attr.data.countryRules[@attr.data.country]
                      return rules.regexes.postalCode.test(val)
                    priority: 32

              @startGoogleAddressSearch()

      # Helper function to get the current country's rules
      @getCurrentRule = ->
        @attr.data.countryRules[@attr.data.country]

      # Validate the postal code input
      # If successful, this will call the postal code API
      @validatePostalCode = (ev, data) ->
        postalCode = data.el.value
        rules = @getCurrentRule()
        if rules.regexes.postalCode.test(postalCode)
          @attr.data.throttledLoading = true
          @attr.data.postalCode = postalCode
          @attr.data.address?.postalCode = postalCode
          @attr.data.loading = true if rules.queryPostalCode
          @render()
          if rules.queryPostalCode
            @getPostalCode postalCode

      # Call the postal code API
      @getPostalCode = (data) ->
        country = @attr.data.country
        postalCode = data.replace(/-/g, '')
        @attr.data.currentSearch = postalCode
        @attr.API.getAddressInformation({
          postalCode: postalCode,
          country: country
        }).then((data) =>
          if data
            address = data
            # ATUALIZA O MAPA DE RESPOSTAS DE POSTAL CODE
            @attr.data.addressSearchResults[@attr.data.currentSearch] = address
            if address.neighborhood isnt '' and address.street isnt '' \
            and address.state isnt '' and address.city isnt ''
              @attr.data.labelShippingFields = true
            else
              @attr.data.labelShippingFields = false
            if address.state isnt '' and address.city
              @attr.data.disableCityAndState = true
            else
              @attr.data.disableCityAndState = false
            @attr.data.showDontKnowPostalCode = false
            @attr.data.address.city = address.city
            @attr.data.address.state = address.state
            @attr.data.address.street = address.street
            @attr.data.address.neighborhood = address.neighborhood
            @attr.data.address.geoCoordinates = address.geoCoordinates
            @attr.data.address.country = data.country
            @attr.data.throttledLoading = false
            @attr.data.showAddressForm = true
            @attr.data.loading = false
            @render()
            @trigger('postalCode.vtex', @getCurrentAddress())
            @trigger('addressSelected.vtex', @attr.data.address)
        , () =>
          @attr.data.throttledLoading = false
          @attr.data.showAddressForm = true
          @attr.data.labelShippingFields = false
          @attr.data.disableCityAndState = false
          @attr.data.loading = false
          @render()
          @trigger('postalCode.vtex', @getCurrentAddress())
        )

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

      # Submit address to the server
      @submitAddress = (ev) ->
        if @select('addressFormSelector').parsley('validate')
          @attr.data.address = @getCurrentAddress()
          @trigger 'loading.vtex', true
          @attr.showAddressForm = false

          # Cria ID se ele não existir
          if @attr.data.address.addressId is null or @attr.data.address.addressId is ""
            @attr.data.address.addressId = (new Date().getTime() * -1).toString()
          if @attr.data.address.addressSearch == null
            delete @attr.data.address["addressSearch"]

          # Submit address object to API
          @attr.API.sendAttachment("shippingData", address: @attr.data.address)
        ev.preventDefault()

      # Select a delivery country
      # This will load the country's form and rules
      @selectCountry = (country) ->
        @attr.data.country = country
        @attr.data.showAddressForm = true
        @attr.data.showSelectCountry = false

        @attr.templates.form.name =
          @attr.templates.form.baseName + country
        @attr.templates.form['template'] =
          'shipping/template/' + @attr.templates.form.name

        deps = [@attr.templates.form.template,
                @attr.templates.selectCountry.template]

        if not @attr.data.countryRules[country]
          deps.push('shipping/rule/Country'+country)
          return require deps, (formTemplate, selectedCountryTemplate, countryRule) =>
            @attr.data.countryRules[country] = new countryRule()
            @render()
        else
          return require deps, (formTemplate, selectedCountryTemplate) =>
            @render()

      @addressMapper = (address) ->
        _.each @getCurrentRule().googleDataMap, (rule) =>
          _.each address.address_components, (component) =>
            if _.intersection(component.types, rule.types).length > 0
              @attr.data[rule.value] = component[rule.length]

        @attr.data.geoCoordinates = [
          address.geometry.location.lng()
          address.geometry.location.lat()
        ]

        @render()

      @clearAddressData = ->
        @attr.data.addressId = null
        @attr.data.addressType = null
        @attr.data.postalCode = ""
        @attr.data.number = ""
        @attr.data.street = ""
        @attr.data.neighborhood = ""
        @attr.data.state = ""
        @attr.data.city = ""
        @attr.data.complement = ""
        @attr.data.receiverName = ""
        @attr.data.reference = ""
        @attr.data.geoCoordinates = []

      @createMap = (location) ->
        mapOptions =
          zoom: 14
          center: location

        if not @attr.map?
          @attr.map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions)

        @attr.map.panTo(location)
        @attr.map.setZoom(14)

        if @attr.marker?
          @attr.marker.setMap(null)
          @attr.marker = null

        @attr.marker = new google.maps.Marker(position: location)
        @marker.setMap(@map)
        @select('mapCanvasSelector').fadeIn(500)

      @startGoogleAddressSearch = ->
        window.setTimeout( =>
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
              @clearAddressData()
              @addressMapper(addressObject)
              @createMap(addressObject.geometry.location)          
        , 100)

      # Handle the selection event
      @selectedCountry = (ev, data) ->
        @attr.data.address = {}
        @attr.data.postalCode = ''
        country = @select('deliveryCountrySelector').val()

        if country
          @selectCountry(country).done ->
            rule = @getCurrentRule()
            if rule.useGeolocation
              @startGoogleAddressSearch()

      @getDeliveryCountries = (logisticsInfo) =>
        _.uniq(_.reduceRight(logisticsInfo, (memo, l) ->
          return memo.concat(l.shipsTo)
        , []))

      # Close the form
      @cancelAddressForm = ->
        @attr.data.showAddressForm = false
        @attr.data.showSelectCountry = false
        @attr.data.loading = false
        @render()
        @trigger('showAddressList.vtex')

      # Change the city select options when a state is selected
      # citiesBasedOnStateChange should be true in the country's rule
      @changeCities = (ev, data) ->
        rules = @getCurrentRule()
        return if not rules.citiesBasedOnStateChange

        state = @select('stateSelector').val()
        @select('citySelector').find('option').remove().end()

        for city of rules.map[state]
          elem = '<option value="'+city+'">'+city+'</option>'
          @select('citySelector').append(elem)

      # Change postal code according to the state selected
      # postalCodeByState should be true in the country's rule
      @changePostalCodeByState = (ev, data) ->
        rules = @getCurrentRule()
        return if not rules.postalCodeByState

        state = @select('stateSelector').val()
        for city, postalCode of rules.map[state]
          break

        @select('postalCodeSelector').val(postalCode)
        @trigger('postalCode.vtex', postalCode)

      # Change postal code according to the city selected
      # postalCodeByCity should be true in the country's rule
      @changePostalCodeByCity = (ev, data) ->
        rules = @getCurrentRule()
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
        @attr.data.availableAddresses = if data.shippingData? then data.shippingData.availableAddresses else []
        @attr.data.address = if data.shippingData? then data.shippingData.address else @attr.data.address
        if data.shippingData
          @attr.data.deliveryCountries = @getDeliveryCountries(data.shippingData.logisticsInfo)

      @addFormListeners = () ->
        # Escuta por qualquer mudança no form
        @select('addressFormSelector').on 'change', =>
          @attr.data.address = @getCurrentAddress()
          @trigger('addressSelected.vtex', @attr.data.address)

      # Handle the initial view of this component
      @enable = (ev, address) ->
        if ev then ev.stopPropagation()
        @attr.data.address = new AddressModel(if address then address else null)
        @attr.data.isEditingAddress = true
        if address?.country?
          @selectCountry(address.country)
        else if @attr.data.deliveryCountries.length is 1
          country = @attr.data.deliveryCountries[0]
          @selectCountry(country)
        else
          @attr.data.showSelectCountry = true
          @render()

      @disable = (ev) ->
        if ev then ev.stopPropagation()
        @$node.html('')

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on 'loading.vtex', @loading
        @on window, 'orderFormUpdated.vtex', @orderFormUpdated
        @on window, 'localeSelected.vtex', @localeUpdate
        @on window, 'newCountryRule', @addCountryRule # TODO -> MELHORAR AQUI
        @on 'updateAddresses.vtex', @cancelAddressForm
        @on 'cancelAddressForm.vtex', @cancelAddressForm
        @on 'click',
          'forceShippingFieldsSelector': @forceShippingFields
          'cancelAddressFormSelector': @cancelAddressForm
          'submitButtonSelector': @submitAddress
          'addressSearchBtSelector': @searchAddress
        @on 'change',
          'deliveryCountrySelector': @selectedCountry
          'stateSelector': @onChangeState
          'citySelector': @changePostalCodeByCity
        @on 'keyup',
          'postalCodeSelector': @validatePostalCode

        if vtexjs?.checkout?.orderForm?
          @orderFormUpdated null, vtexjs.checkout.orderForm

    return defineComponent(AddressForm, withi18n)