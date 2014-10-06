define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'state-machine/state-machine',
        'shipping/script/setup/extensions',
        'shipping/script/models/Address',
        'shipping/script/component/AddressSearch',
        'shipping/script/component/AddressForm',
        'shipping/script/component/AddressList',
        'shipping/script/component/ShippingOptions',
        'shipping/script/component/ShippingSummary',
        'shipping/script/component/CountrySelect',
        'shipping/script/mixin/withi18n',
        'shipping/script/mixin/withValidation',
        'shipping/script/mixin/withShippingStateMachine',
        'shipping/templates/shippingData',
        'link!shipping/style/style'],
  (defineComponent, FSM, extensions, Address, AddressSearch, AddressForm, AddressList, ShippingOptions, ShippingSummary, CountrySelect, withi18n, withValidation, withShippingStateMachine, template) ->
    ShippingData = ->
      @defaultAttrs
        API: null
        orderForm: false
        data:
          valid: false
          active: false
          visited: false
          loading: false
          deliveryCountries: false
          countryRules: {}
          country: false

        stateMachine: false

        goToPaymentButtonSelector: '.btn-go-to-payment'
        goToPaymentButtonWrapperSelector: '.btn-go-to-payment-wrapper'
        editShippingDataSelector: '#edit-shipping-data'
        shippingTitleSelector: '.accordion-shipping-title'
        addressNotFilledSelector: '.address-not-filled-verification'
        shippingStepSelector: '.step'

        shippingSummarySelector: '.shipping-summary-placeholder'
        addressFormSelector: '.address-form-placeholder'
        addressSearchSelector: '.address-search-placeholder'
        addressListSelector: '.address-list-placeholder'
        shippingOptionsSelector: '.address-shipping-options'
        countrySelectSelector: '.country-select-placeholder'

      #
      # Order form handler
      #

      @orderFormUpdated = (ev, orderForm) ->
        @attr.orderForm = _.clone orderForm
        @setLocale(orderForm.clientPreferencesData?.locale)
        shippingData = @attr.orderForm.shippingData
        unless shippingData?
          if @attr.orderForm.items.length is 0
            @validate() # Caso não haja itens no carrinho, shippingData é null
          return

        @attr.data.deliveryCountries = @getDeliveryCountries(@attr.orderForm)
        @attr.data.hasAvailableAddresses = shippingData.availableAddresses.length > 1
        @attr.data.hasDeliveries = shippingData?.logisticsInfo?.length > 0 and shippingData?.logisticsInfo[0].slas.length > 0

        # Caso data.canEditData ainda nao esteja preenchido, preencha
        if not @attr.data.canEditData?
          @attr.data.canEditData = @attr.orderForm.canEditData

        # Caso o usuario faça login
        if @attr.orderForm.canEditData isnt @attr.data.canEditData
          @attr.data.userIsNowLoggedIn = true

        country = shippingData.address?.country ? @attr.data.deliveryCountries[0]

        @countrySelected(null, country).then =>
          if @attr.stateMachine.current is 'none' or @attr.stateMachine.current is 'empty' or @attr.data.userIsNowLoggedIn
            if @attr.data.active
              if @attr.data.hasAvailableAddresses
                @attr.stateMachine.showList(@attr.orderForm)
                @attr.stateMachine.next()
              else
                @attr.stateMachine.showForm(@attr.orderForm)
                @attr.stateMachine.next()
            else
              @attr.stateMachine.showSummary(@attr.orderForm)
              @attr.stateMachine.next()

          @validate()

      #
      # External events handlers
      #

      @enable = ->
        try
          orderForm = @attr.orderForm

          deliveryCountries = @getDeliveryCountries(orderForm)
          shippingData = orderForm.shippingData
          country = shippingData?.address?.country ? deliveryCountries[0]
          rules = @attr.data.countryRules[country]

          address = new Address(shippingData.address)
          firstTimeBuying = (orderForm.canEditData is true and orderForm.loggedIn is false)
          invalidAddress = (orderForm.canEditData is true and (!shippingData?.address or address.validate(rules) isnt true))
          if invalidAddress or firstTimeBuying
            @attr.stateMachine.showForm(orderForm)
            @attr.stateMachine.next()
          else
            @attr.stateMachine.showList(orderForm)
            @attr.stateMachine.next()
        catch e
          console.log e

      @disable = ->
        if @attr.stateMachine.can('showSummary')
          @attr.stateMachine.showSummary(@attr.orderForm)
          @attr.stateMachine.next()
        if @isValid()
          @attr.API?.sendAttachment('shippingData', @attr.orderForm.shippingData)
            .fail (reason) =>
              @trigger 'componentValidated.vtex', [[reason]]
              @done()

      @profileUpdated = (e, profile) ->
        # Changed when the user makes changes to the profile, before sending the profile to the API and getting a response.
        @attr.profileFromEvent = profile

      #
      # Events from children components
      #

      @tryDone = ->
        if @attr.stateMachine.current is 'addressFormSLA'
          # When the AddressForm is finished validating, ShippingData will also validate due to @addressFormValidated()
          @select('addressFormSelector').one('componentValidated.vtex', (e, errors) => @done() if errors.length is 0)
          @select('addressFormSelector').trigger('validate.vtex')
          return

        if @attr.stateMachine.current is 'listSLA'
          address = new Address(@attr.orderForm.shippingData.address)
          if address.validate(@attr.data.countryRules[address.country]) isnt true
            @attr.stateMachine.showForm(@attr.orderForm)
            @attr.stateMachine.next()
            return

        @done()

      @done = ->
        valid = @validate()
        if valid.length > 0
          @attr.stateMachine.showForm(@attr.orderForm)

        @trigger('componentDone.vtex')

      @addressDefaults = (address) ->
        # Tries to auto fill receiver name from client profile data
        firstName = @attr.orderForm.clientProfileData?.firstName or @attr.profileFromEvent?.firstName
        lastName = @attr.orderForm.clientProfileData?.lastName or @attr.profileFromEvent?.lastName
        if firstName and (address.receiverName is '' or not address.receiverName)
          address.receiverName = firstName + ' ' + lastName

        address.country or= @attr.data.country

        return address

      @addressSearchLoad = (ev) ->
        ev?.stopPropagation()
        @attr.stateMachine.searchAddress()
   
      # An address search has new results.
      # Should call API to get delivery options
      @addressSearchResult = (ev, address) ->
        console.log "address result", address

        @attr.orderForm.shippingData.address = @addressDefaults(address)
        @attr.orderForm.shippingData.address.country = address?.country ? @attr.data.country
        
        @attr.stateMachine.loadAddress(@attr.orderForm)

      # When a new addresses is selected
      @addressSelected = (ev, address) ->
        ev?.stopPropagation()
        address.isValid = true # se foi selecionado da lista, está válido
        @addressUpdated(ev, address)

        if @attr.requestAddressSelected
          @attr.requestAddressSelected.abort()

        @attr.stateMachine.requestSLA()

        @attr.requestAddressSelected = @attr.API?.sendAttachment('shippingData', @attr.orderForm.shippingData)
          .done (orderForm) =>
            hasDeliveries = @attr.data.hasDeliveries
            deliveryCountries = @attr.data.deliveryCountries

            if hasDeliveries
              @attr.stateMachine.loadSLA(orderForm)
            else
              @attr.stateMachine.loadNoSLA(orderForm)

            if @attr.stateMachine.current is 'listLoadSLA'
              if @validateAddress() isnt true
                # If it's invalid, stop here and edit it
                orderForm.shippingData.address = @addressDefaults(orderForm.shippingData.address)
                @attr.stateMachine.showForm(orderForm)
                @attr.stateMachine.next()

              else if not hasDeliveries and not orderForm.canEditData
                $(window).trigger('showMessage.vtex', ['unavailable'])

      # The current address was updated, either selected or in edit
      @addressUpdated = (ev, address) ->
        ev.stopPropagation()
        @attr.orderForm.shippingData.address = address
        @validate()
        if address.isValid
          @select('shippingSummarySelector').trigger('addressSelected.vtex', [address])

      @addressFormValidated = (ev, results) ->
        ev?.stopPropagation()
        @validate()

      @addressKeysUpdated = (ev, address) ->
        # In case it's an address that we already know its logistics info, return
        knownAddress = _.find @attr.orderForm.shippingData?.availableAddresses, (a) ->
            a.addressId is address.addressId and
            a.postalCode?.replace('-', '') is address.postalCode?.replace('-', '') and
            a.geoCoordinates?[0] is address.geoCoordinates?[0] and
            a.geoCoordinates?[1] is address.geoCoordinates?[1]
        if knownAddress then return

        if address.postalCodeIsValid
          # When we start editing, we always start looking for shipping options
          console.log "Getting shipping options for address key", address.postalCode
          @attr.stateMachine.requestSLA()

          country = address.country ? @attr.data.country

          clearAddress = @attr.data.countryRules[country].postalCodeByInput ? true
          # If we are submitting a geoCoordinate address, then don't let the API
          # overwrite the other address fields with the data provided by the postal code
          # service
          if address.geoCoordinatesValid
            clearAddress = false

          # Abort previous call
          if @attr.requestAddressKeys then @attr.requestAddressKeys.abort()
          @attr.requestAddressKeys = @attr.API?.sendAttachment 'shippingData',
                address: address
                clearAddressIfPostalCodeNotFound: clearAddress
            .done( (orderForm) =>
              hasDeliveries = @attr.data.hasDeliveries

              if @attr.stateMachine.can('loadSLA') or @attr.stateMachine.can('loadNoSLA')
                if hasDeliveries
                  @attr.stateMachine.loadSLA(orderForm)
                else
                  @attr.stateMachine.loadNoSLA(orderForm)
            )
            .fail( (reason) =>
              return if reason.statusText is 'abort'
              console.log reason
              @attr.stateMachine.error(@attr.orderForm)
              @attr.stateMachine.next()
            )
        else if address.geoCoordinates
          # TODO implementar com geoCoordinates
          console.log address, "Geo coordinates not implemented!"

      # User cleared address search key and must search again
      @addressKeysInvalidated = (ev, address) ->
        rules = @attr.data.countryRules[address.country]
        hasAvailableAddresses = @attr.data.hasAvailableAddresses
        @attr.stateMachine.showSearch(rules, address, hasAvailableAddresses)

      # User wants to edit or create an address
      @editAddress = (ev, address) ->
        ev?.stopPropagation()

        if not @attr.orderForm.canEditData
          vtexIdOptions =
            returnUrl: window.location.href
            userEmail: vtexjs?.checkout?.orderForm?.clientProfileData?.email
            locale: @attr.locale
          return window.vtexid?.start(vtexIdOptions)

        @attr.stateMachine.showForm(@attr.orderForm)
        @attr.stateMachine.next()

      @newAddress = (ev) ->
        ev.stopPropagation()
        if not @attr.orderForm.canEditData
          vtexIdOptions =
            returnUrl: window.location.href
            userEmail: vtexjs?.checkout?.orderForm?.clientProfileData?.email
            locale: @attr.locale
          return window.vtexid?.start(vtexIdOptions)

        @attr.orderForm.shippingData?.address = {}
        @attr.stateMachine.showForm(@attr.orderForm)
        @attr.stateMachine.next()

      # User cancelled ongoing address edit
      @cancelAddressEdit = (ev) ->
        ev?.stopPropagation()
        if @attr.orderForm.shippingData.availableAddresses.length > 0 # Cuidado: nao é o mesmo que hasAvailableAddresses
          @trigger('addressKeysUpdated.vtex', [@attr.orderForm.shippingData.availableAddresses[0]])

        @attr.stateMachine.showList(@attr.orderForm)
        @attr.stateMachine.next()

      # User chose shipping options
      @deliverySelected = (ev, logisticsInfo) ->
        @attr.orderForm.shippingData.logisticsInfo = logisticsInfo
        @select('shippingSummarySelector').trigger('deliverySelected.vtex', [logisticsInfo, @attr.orderForm.items, @attr.orderForm.sellers])

      @countrySelected = (ev, country) ->
        @attr.data.country = country
        deps = [
          'shipping/script/rule/Country'+country
          'shipping/templates/countries/addressForm'+country
          'shipping/templates/addressSearch'
          'shipping/templates/shippingOptions',
          'shipping/templates/deliveryWindows'
        ]
        require deps, (countryRule) =>
          countryRules = @attr.data.countryRules
          countryRules[country] = new countryRule()
          @attr.data.states = countryRules[country].states
          @attr.data.regexes = countryRules[country].regexes
          @attr.data.geocodingAvailable = countryRules[country].geocodingAvailable
          @loadGoogleMapsAPI(countryRules[country])
          return countryRules[country]

      @loadGoogleMapsAPI = (countryRule) ->
        if (countryRule.geocodingAvailable)
          if not window.vtex.maps.isGoogleMapsAPILoaded and not window.vtex.maps.isGoogleMapsAPILoading
            window.vtex.maps.isGoogleMapsAPILoading = true
            script = document.createElement("script")
            script.type = "text/javascript"
            script.src = "//maps.googleapis.com/maps/api/js?libraries=places&language=#{@attr.locale}&callback=window.vtex.maps.googleMapsAPILoaded"
            document.body.appendChild(script)
        return

      #
      # Helpers
      #
      @getDeliveryCountries = (orderForm) ->
        deliveryCountries = _.uniq(_.reduceRight(orderForm.shippingData.logisticsInfo, ((memo, l) ->
          return memo.concat(l.shipsTo)), []))
        if deliveryCountries.length is 0
          deliveryCountries = [orderForm.storePreferencesData?.countryCode]

        return deliveryCountries

      #
      # Validation
      #

      @validateAddress = ->
        if @attr.orderForm.canEditData
          try
            currentAddress = new Address(@attr.orderForm.shippingData.address)
            return currentAddress.validate(@attr.data.countryRules[currentAddress.country])
          return "Unable to validate address"
        else
          return true

      @validateShippingOptions = ->
        logisticsInfo = @attr.orderForm.shippingData?.logisticsInfo
        return "Logistics info must exist" if logisticsInfo?.length is 0
        return "No selected SLA" if logisticsInfo?[0].selectedSla is undefined
        return true

      @localeSelected = (ev, locale) =>
        @setLocale locale
        @requireLocale().then =>
          @$node.i18n()

      #
      # Initialization
      #

      @after 'initialize', ->
        @attr.stateMachine = @createStateMachine() #from withShippingStateMachine
        @setLocalePath 'shipping/script/translation/'
        # If there is an orderform present, use it for initialization
        @setLocale locale if locale = vtexjs?.checkout?.orderForm?.clientPreferencesData?.locale
        @requireLocale().then =>
          dust.render template, @attr.data, (err, output) =>
            translatedOutput = $(output).i18n()
            @$node.html(translatedOutput)

            # Start the components
            ShippingSummary.attachTo(@attr.shippingSummarySelector)
            CountrySelect.attachTo(@attr.countrySelectSelector)
            AddressSearch.attachTo(@attr.addressSearchSelector, { getAddressInformation: @attr.API.getAddressInformation })
            AddressForm.attachTo(@attr.addressFormSelector)
            AddressList.attachTo(@attr.addressListSelector)
            ShippingOptions.attachTo(@attr.shippingOptionsSelector)

            # Start event listeners
            @on 'enable.vtex', @enable
            @on 'disable.vtex', @disable
            @on 'addressSearchStart.vtex', @addressSearchLoad
            @on 'addressSearchResult.vtex', @addressSearchResult
            @on 'addressSelected.vtex', @addressSelected
            @on 'addressUpdated.vtex', @addressUpdated
            @on 'addressKeysUpdated.vtex', @addressKeysUpdated
            @on 'addressKeysInvalidated.vtex', @addressKeysInvalidated
            @on 'cancelAddressEdit.vtex', @cancelAddressEdit
            @on 'editAddress.vtex', @editAddress
            @on 'newAddress.vtex', @newAddress
            @on 'deliverySelected.vtex', @deliverySelected
            @on 'countrySelected.vtex', @countrySelected
            @on 'addressFormSelector', 'componentValidated.vtex', @addressFormValidated
            @on 'click',
              'goToPaymentButtonSelector': @tryDone
              'editShippingDataSelector': @enable

            @setValidators [
              @validateAddress
              @validateShippingOptions
            ]

            # Set the listener for the orderFormUpdated event
            @on window, 'orderFormUpdated.vtex', @orderFormUpdated

            # If there is an orderform present, use it for initialization
            if vtexjs?.checkout?.orderForm?
              @orderFormUpdated null, vtexjs.checkout.orderForm

            window.vtex.maps = window.vtex.maps or {}

            # Called when google maps api is loaded
            window.vtex.maps.googleMapsAPILoaded = =>
              window.vtex.maps.isGoogleMapsAPILoaded = true
              window.vtex.maps.isGoogleMapsAPILoading = false
              @select('addressFormSelector').trigger('googleMapsAPILoaded.vtex')
              @select('addressSearchSelector').trigger('googleMapsAPILoaded.vtex')

    return defineComponent(ShippingData, withi18n, withValidation, withShippingStateMachine)