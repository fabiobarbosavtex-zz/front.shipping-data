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

        @attr.data.deliveryCountries = _.uniq(_.reduceRight(shippingData.logisticsInfo, ((memo, l) ->
          return memo.concat(l.shipsTo)), []))
        if @attr.data.deliveryCountries.length is 0
          @attr.data.deliveryCountries = [orderForm.storePreferencesData?.countryCode]
        country = shippingData.address?.country ? @attr.data.deliveryCountries[0]

        @countrySelected(null, country).then =>
          hasAvailableAddresses = shippingData.availableAddresses.length > 1

          if @attr.stateMachine.current is 'none'
            if @attr.data.active
              if hasAvailableAddresses
                @attr.stateMachine.showList(@attr.orderForm)
              else
                @attr.stateMachine.showForm(@attr.orderForm)
            else
              @attr.stateMachine.showSummary(@attr.orderForm)

          @validate()

      #
      # External events handlers
      #

      @enable = ->
        try
          orderForm = @attr.orderForm

          deliveryCountries = _.uniq(_.reduceRight(orderForm.shippingData.logisticsInfo, ((memo, l) ->
            return memo.concat(l.shipsTo)), []))
          if deliveryCountries.length is 0
            deliveryCountries = [orderForm.storePreferencesData?.countryCode]

          shippingData = orderForm.shippingData
          country = shippingData?.address?.country ? deliveryCountries[0]
          rules = @attr.data.countryRules[country]

          address = new Address(shippingData.address)
          if not shippingData?.address or address.validate(rules) isnt true
            @attr.stateMachine.showForm(orderForm)
            @attr.stateMachine.next()
          else
            @attr.stateMachine.showList(orderForm)
            @attr.stateMachine.next()
        catch e
          console.log e

      @disable = ->
        if @attr.stateMachine.can('showSummary')
          @attr.stateMachine.showSummary(orderForm)

	  @profileUpdated = (e, profile) ->
        # Changed when the user makes changes to the profile, before sending the profile to the API and getting a response.
        @attr.profileFromEvent = profile

      #
      # Events from children components
      #

      @done = ->
        valid = @validate()
        if valid.length > 0 and @attr.stateMachine.can('editNoSLA')
          hasAvailableAddresses = @attr.orderForm.shippingData.availableAddresses.length > 1
          @attr.stateMachine.editNoSLA(@attr.orderForm.shippingData?.address, hasAvailableAddresses)

        @trigger('componentDone.vtex')

      @addressDefaults = (address) ->
        # Tries to auto fill receiver name from client profile data
        firstName = @attr.orderForm.clientProfileData?.firstName or @attr.profileFromEvent?.firstName
        lastName = @attr.orderForm.clientProfileData?.lastName or @attr.profileFromEvent?.lastName
        if firstName and (address.receiverName is '' or not address.receiverName)
          address.receiverName = firstName + ' ' + lastName

        address.country or= @attr.data.country

        return address

      # An address search has new results.
      # Should call API to get delivery options
      @addressSearchResult = (ev, address) ->
        console.log "address result", address

        address = @addressDefaults(address)

        hasAvailableAddresses = @attr.orderForm.shippingData.availableAddresses.length > 1
        @attr.stateMachine.doneSearch(address, hasAvailableAddresses)

      # When a new addresses is selected
      @addressSelected = (ev, address) ->
        ev?.stopPropagation()
        address.isValid = true # se foi selecionado da lista, está válido
        @addressUpdated(ev, address)

        if @attr.stateMachine.current is 'list' or @attr.stateMachine.current is 'listNoSLA' or
            (@attr.stateMachine.current is 'loadList' and @attr.requestAddressSelected)

          if @attr.requestAddressSelected
            @attr.requestAddressSelected.abort()
          else
            @attr.stateMachine.loadList(@attr.data.deliveryCountries, @attr.orderForm)

          @attr.requestAddressSelected = @attr.API?.sendAttachment('shippingData', @attr.orderForm.shippingData)
            .done (orderForm) =>
              li = orderForm.shippingData.logisticsInfo
              hasDeliveries = li?.length > 0 and li[0].slas.length > 0
              if @validateAddress() isnt true and @attr.stateMachine.can("invalidAddress")
                # If it's invalid, stop here and edit it
                orderForm.shippingData.address = @addressDefaults(orderForm.shippingData.address)
                @attr.stateMachine.invalidAddress(orderForm.shippingData.address, orderForm.shippingData.logisticsInfo, orderForm.items, orderForm.sellers)
              else if not hasDeliveries and not orderForm.canEditData
                $(window).trigger('showMessage.vtex', ['unavailable'])
                @attr.stateMachine.cantEdit(@attr.data.deliveryCountries, orderForm)
              else if @attr.stateMachine.can("select")
                @attr.stateMachine.select(@attr.data.deliveryCountries, orderForm)

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
          # If the country doesn't query for postal code, the postal code is changes are
          # triggered by the changes made in the address' state or city
          if not @attr.data.countryRules[address.country].queryByPostalCode
            @attr.stateMachine.loadSLA()

          # When we start editing, we always start looking for shipping options
          console.log "Getting shipping options for address key", address.postalCode
          @select('shippingOptionsSelector').trigger('startLoading.vtex')
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
              li = orderForm.shippingData.logisticsInfo
              hasDeliveries = li?.length > 0 and li[0].slas.length > 0
              hasAvailableAddresses = orderForm.shippingData.availableAddresses.length > 1
              # If we are editing and we received logistics info
              if hasDeliveries
                if @attr.stateMachine.can('doneSLA')
                  @attr.stateMachine.doneSLA(null, hasAvailableAddresses, orderForm.shippingData.logisticsInfo, @attr.orderForm.items, @attr.orderForm.sellers)
              else
                if @attr.data.countryRules[country].queryByPostalCode and @attr.stateMachine.can('clearSearch')
                  @attr.stateMachine.clearSearch(address, hasAvailableAddresses)
                else
                  @select('shippingOptionsSelector').trigger('disable.vtex')
                $(window).trigger('showMessage.vtex', ['unavailable'])
            )
            .fail( (reason) =>
              return if reason.statusText is 'abort'
              console.log reason
              hasAvailableAddresses = @attr.orderForm.shippingData.availableAddresses.length > 1
              if @attr.data.countryRules[country].queryByPostalCode and @attr.stateMachine.can('clearSearch')
                @attr.stateMachine.clearSearch(address, hasAvailableAddresses)
              else
                @attr.stateMachine.editNoSLA(@attr.orderForm.shippingData?.address, hasAvailableAddresses)
            )
        else if address.geoCoordinates
          # TODO implementar com geoCoordinates
          console.log address, "Geo coordinates not implemented!"

      # User cleared address search key and must search again
      @addressKeysInvalidated = (ev, address) ->
        if @attr.stateMachine.can('clearSearch')
          hasAvailableAddresses = @attr.orderForm.shippingData.availableAddresses.length > 1
          @attr.stateMachine.clearSearch(address, hasAvailableAddresses)

      # User wants to edit or create an address
      @editAddress = (ev, address) ->
        if not @attr.orderForm.canEditData
          vtexIdOptions =
            returnUrl: window.location.href
            userEmail: vtexjs?.checkout?.orderForm?.clientProfileData?.email
            locale: @attr.locale
          return window.vtexid?.start(vtexIdOptions)

        ev?.stopPropagation()
        hasAvailableAddresses = @attr.orderForm.shippingData.availableAddresses.length > 1
        if address and
            @attr.orderForm.shippingData.address?.addressId is address.addressId and
            @attr.stateMachine.can('editWithSLA')
          # Estamos editanto o endereço atual, use o seu logistics info
          @attr.stateMachine.editWithSLA(address, hasAvailableAddresses, @attr.orderForm.shippingData.logisticsInfo,
            @attr.orderForm.items, @attr.orderForm.sellers)
        if address and @attr.stateMachine.can('editNoSLA')
          address = @addressDefaults(address)
          @attr.stateMachine.editNoSLA(address, hasAvailableAddresses)
        else if @attr.stateMachine.can('new')
          country = @attr.data.country
          rules = @attr.data.countryRules[country]
          if rules.queryByPostalCode or rules.queryByGeocoding
            @attr.stateMachine.new({}, hasAvailableAddresses)
          else
            @attr.orderForm.shippingData?.address = {country: country}
            @attr.orderForm.shippingData?.address = @addressDefaults(@attr.orderForm.shippingData?.address)
            @attr.stateMachine.editNoSLA(@attr.orderForm.shippingData?.address, hasAvailableAddresses)

      # User cancelled ongoing address edit
      @cancelAddressEdit = (ev) ->
        ev?.stopPropagation()
        if @attr.orderForm.shippingData.availableAddresses.length > 0
          @trigger('addressKeysUpdated.vtex', [@attr.orderForm.shippingData.availableAddresses[0]])

        if @attr.stateMachine.can('cancelNew')
          @attr.stateMachine.cancelNew(@attr.data.deliveryCountries, @attr.orderForm)
        if @attr.stateMachine.can('cancelEdit')
          @attr.stateMachine.cancelEdit(@attr.data.deliveryCountries, @attr.orderForm)

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
            script.src = "//maps.googleapis.com/maps/api/js?libraries=places&sensor=true&language=#{@attr.locale}&callback=window.vtex.maps.googleMapsAPILoaded"
            document.body.appendChild(script)
        return

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
            @on 'addressSearchResult.vtex', @addressSearchResult
            @on 'addressSelected.vtex', @addressSelected
            @on 'addressUpdated.vtex', @addressUpdated
            @on 'addressKeysUpdated.vtex', @addressKeysUpdated
            @on 'addressKeysInvalidated.vtex', @addressKeysInvalidated
            @on 'cancelAddressEdit.vtex', @cancelAddressEdit
            @on 'editAddress.vtex', @editAddress
            @on 'deliverySelected.vtex', @deliverySelected
            @on 'countrySelected.vtex', @countrySelected
            @on 'addressFormSelector', 'componentValidated.vtex', @addressFormValidated
			@on window, 'profileUpdated', @profileUpdated
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