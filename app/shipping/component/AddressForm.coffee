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

        # Google maps variables
        map = null
        marker = null

      # Render this component according to the data object
      @render = (ev, data) ->
        data = @attr.data if not data
        if data.showSelectCountry or data.showAddressForm
          require 'shipping/translation/' + @attr.locale, (translation) =>
            if data.showSelectCountry
              require [@attr.templates.selectCountry.template], =>
                @extendTranslations(translation)
                dust.render @attr.templates.selectCountry.name, data, (err, output) =>
                  output = $(output).i18n()
                  @$node.html(output)
            else if data.showAddressForm
              rules = @getCurrentRule()
              data.states = rules.states
              data.regexes = rules.regexes
              dust.render @attr.templates.form.name, data, (err, output) =>
                @extendTranslations(translation)
                output = $(output).i18n()
                @$node.html(output)

                if data.loading
                  $('input, select, .btn', @$node).attr('disabled', 'disabled')

                if rules.citiesBasedOnStateChange
                  @changeCities()
                  if data.address.city
                    $(@attr.citySelector, @$node).val(data.address.city)

                if rules.usePostalCode
                  $(@attr.postalCodeSelector, @$node).inputmask
                    mask: rules.masks.postalCode
                  if data.labelShippingFields
                    $(@attr.postalCodeSelector).addClass('success')

                $(@attr.addressFormSelector, @$node).parsley
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

                # Focus on the first empty rqeuired field
                inputs = 'input[type=email].required,' + \
                         'input[type=tel].required,' + \
                         'input[type=text].required'
                $(@$node).find(inputs)
                  .filter ->
                    if($(this).val() == "")
                      return true
                .first()
                @startGoogleAddressSearch()
        else
          @$node.html('')

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
          @attr.data.address.postalCode = postalCode
          @attr.data.loading = true if rules.queryPostalCode
          @render()
          if rules.queryPostalCode
            @getPostalCode postalCode

      # Handle the initial view of this component
      @showAddressForm = (ev, address) ->
        @attr.data.address = new AddressModel(if address then address else null)
        @attr.data.isEditingAddress = true
        if address?.addressType?
          @selectCountry(address.country)
        else if @attr.data.deliveryCountries.length is 1
          country = @attr.data.deliveryCountries[0]
          @selectCountry(country)
        else
          @attr.data.showSelectCountry = true
          @render()

      # Call the postal code API
      @getPostalCode = (data) ->
        country = @attr.data.country
        postalCode = data.replace(/-/g, '')
        @attr.API.getAddressInformation({
          postalCode: postalCode,
          country: country
        }).then((data) =>
          if data
            address = data
            data = @attr.data
            if address.neighborhood isnt '' and address.street isnt '' \
            and address.stateAcronym isnt '' and address.city isnt ''
              data.labelShippingFields = true
            else
              data.labelShippingFields = false
            if address.stateAcronym isnt '' and address.city
              data.disableCityAndState = true
            else
              data.disableCityAndState = false
            data.showDontKnowPostalCode = false
            data.address.city = address.city
            data.address.state = address.stateAcronym
            data.address.street = address.street
            data.address.neighborhood = address.neighborhood
            data.address.geoCoordinates = address.geoCoordinates
            data.address.country = data.country
            data.throttledLoading = false
            data.showAddressForm = true
            data.loading = false
            @trigger('addressFormRender', data)
            @$node.trigger('postalCode', @getCurrentAddress())
        , () =>
          data = @attr.data
          data.throttledLoading = false
          data.showAddressForm = true
          data.labelShippingFields = false
          data.disableCityAndState = false
          data.loading = false
          @trigger('addressFormRender', data)
          @$node.trigger('postalCode', @getCurrentAddress())
        )

      # Able the user to edit the suggested fields
      # filled by the postal code service
      @forceShippingFields = ->
        @attr.data.labelShippingFields = false
        @render()

      # Get the current address typed in the form
      @getCurrentAddress = ->
        disabled = $(@attr.addressFormSelector)
          .find(':input:disabled').removeAttr('disabled')

        serializedForm = $(@attr.addressFormSelector)
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
        if $(@attr.addressFormSelector).parsley('validate')
          @attr.data.address = @getCurrentAddress()
          @trigger 'loading', true
          @attr.showAddressForm = false

          # Cria ID se ele não existir
          if (@attr.data.address.addressId == null || @attr.data.address.addressId == "")
            @attr.data.address.addressId = (new Date().getTime() * -1).toString()
          if (@attr.data.address.addressSearch == null)
            delete @attr.data.address["addressSearch"]

          # Submit address object to API
          @attr.API.sendAttachment("shippingData", { address: @attr.data.address })
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
          require deps, (formTemplate, selectedCountryTemplate, countryRule) =>
            @attr.data.countryRules[country] = new countryRule()
            @render()
        else
          require deps, (formTemplate, selectedCountryTemplate) =>
            @render()

      @addressMapper = (address) ->
        console.log @getCurrentRule()
        _.each(@getCurrentRule().googleDataMap, (rule) =>
          _.each(address.address_components, (component)=>
            if _.intersection(component.types, rule.types).length > 0
              @attr.data[rule.value] = component[rule.length]
          )
        )
        @attr.data.geoCoordinates = [
          address.geometry.location.lng()
          address.geometry.location.lat()
        ]
        console.log(@attr.data)
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

        @attr.marker = new google.maps.Marker({position: location})
        @marker.setMap(@map)
        $('#map-canvas').fadeIn(500)

      @startGoogleAddressSearch = ->
        window.setTimeout( =>
          addressListResponse = []
          $('#addressSearch').typeahead({
            minLength: 3,
            matcher: -> true
            source: (query, process) ->
              geocoder = new google.maps.Geocoder()
              geocoder.geocode( address: query, (response, status) =>
                if status is "OK" and response.length > 0
                  addressListResponse = response
                  itemsToDisplay = []
                  _.each(response, (item) ->
                    itemsToDisplay.push item.formatted_address
                  )
                  process itemsToDisplay
              )
            updater: (address)=>
              addressObject = _.find(addressListResponse, (item)-> item.formatted_address is address)
              @clearAddressData()
              @addressMapper addressObject
              # @createMap(addressObject.geometry.location)
          })
        ,100)

      # Handle the selection event
      @selectedCountry = (ev, data) ->
        @attr.data.address = {}
        @attr.data.postalCode = ''
        country = $(@attr.deliveryCountrySelector, @$node).val()
        @selectCountry country if country

        if window.shippingUsingGeolocation and country is "PER"
          @startGoogleAddressSearch()

      @getDeliveryCountries = (logisticsInfo) =>
        return _.uniq(_.reduceRight(logisticsInfo, (memo, l) ->
          return memo.concat(l.shipsTo)
        , []))

      # Close the form
      @cancelAddressForm = ->
        @attr.data.showAddressForm = false
        @attr.data.showSelectCountry = false
        @attr.data.loading = false
        @render()
        @trigger('addressFormCanceled')

      # Change the city select options when a state is selected
      # citiesBasedOnStateChange should be true in the country's rule
      @changeCities = (ev, data) ->
        rules = @getCurrentRule()
        return if not rules.citiesBasedOnStateChange

        state = $(@attr.stateSelector, @$node).val()
        $(@attr.citySelector, @$node).find('option').remove().end()

        for city of rules.map[state]
          elem = '<option value="'+city+'">'+city+'</option>'
          $(@attr.citySelector, @$node).append(elem)

      # Change postal code according to the state selected
      # postalCodeByState should be true in the country's rule
      @changePostalCodeByState = (ev, data) ->
        rules = @getCurrentRule()
        return if not rules.postalCodeByState

        state = $(@attr.stateSelector, @$node).val()
        for city, postalCode of rules.map[state]
          break

        $(@attr.postalCodeSelector, @$node).val(postalCode)
        @$node.trigger('postalCode', postalCode)

      # Change postal code according to the city selected
      # postalCodeByCity should be true in the country's rule
      @changePostalCodeByCity = (ev, data) ->
        rules = @getCurrentRule()
        return if not rules.postalCodeByCity

        state = $(@attr.stateSelector, @$node).val()
        city = $(@attr.citySelector, @$node).val()
        postalCode = rules.map[state][city]

        $(@attr.postalCodeSelector, @$node).val(postalCode)
        @$node.trigger('postalCode', @getCurrentAddress())

      # Set to a loading state
      # This will disable all fields
      @loading = (ev, data) ->
        @attr.data.loading = true
        @render()
        console.log "loaded"

      # Store new country rules in the data object
      @addCountryRule = (ev, data) ->
        _.extend(@attr.data.countryRules, data)

      # Call two functions for the same event
      @onChangeState = (ev, data) ->
        @changeCities(ev, data)
        @changePostalCodeByState(ev, data)

      @enable = ->

      @disable = ->
        @attr.data.showSelectCountry = false
        @attr.data.showAddressForm = false
        @render()

      @orderFormUpdated = (ev, data) ->
        @attr.data.availableAddresses = if data.shippingData? then data.shippingData.availableAddresses else []
        if data.shippingData
          @attr.data.deliveryCountries = @getDeliveryCountries(data.shippingData.logisticsInfo)

      # Bind events
      @after 'initialize', ->
        @on 'loading', @loading
        @on window, 'enableShippingData.vtex', @enable
        @on window, 'disableShippingData.vtex', @disable
        @on window, 'orderFormUpdated.vtex', @orderFormUpdated
        @on window, 'localeSelected.vtex', @localeUpdate
        @on window, 'newCountryRule', @addCountryRule
        @on window, 'showAddressForm', @showAddressForm
        @on window, 'updateAddresses', @cancelAddressForm
        @on window, 'cancelAddressForm', @cancelAddressForm
        @on window, 'click',
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