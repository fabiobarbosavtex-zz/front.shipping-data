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
          if shippingData.address? # If a current address exists
            hasDeliveries = shippingData.logisticsInfo[0].slas.length > 0
            hasAvailableAddresses = shippingData.availableAddresses.length > 1
            if not hasDeliveries
              if not orderForm.canEditData
                @attr.stateMachine.cantEdit(@attr.data.deliveryCountries, @attr.orderForm)
              else if @attr.stateMachine.can("unavailable")
                $(window).trigger('showMessage.vtex', ['unavailable'])
                @attr.stateMachine.unavailable(shippingData.address, hasAvailableAddresses)
                @trigger 'componentValidated.vtex', [[new Error("SLA array is empty")]]
                @done()
            else if @attr.stateMachine.can('orderform')
                rules = @attr.data.countryRules[shippingData.address.country]
                # If we call the event 'orderForm' and it is already on the state
                # 'summary', nothing will happen, because it will try to change to the
                # same state, so it doesn't do anything. We must trigger the 'enable'
                # event directly to the component, so it can update with the new orderform
                if @attr.stateMachine.current is 'summary'
                  @select('shippingSummarySelector').trigger('enable.vtex', [@attr.locale, orderForm.shippingData, orderForm.items, orderForm.sellers, rules, orderForm.canEditData, orderForm.giftRegistryData])
                else
                  @attr.stateMachine.orderform(@attr.locale, orderForm, rules)
            else
              # When a user cannot edit data, opens VTEX ID and logs in, if
              # he's in the list state, nothing will happen (for the same reasons
              # stated in the comment above) so we update it's values manually
              if @attr.stateMachine.current is 'list'
                @select('addressListSelector').trigger('enable.vtex', [@attr.data.deliveryCountries, orderForm.shippingData, orderForm.giftRegistryData])

          @validate()

      #
      # External events handlers
      #

      @enable = ->
        try
          country = @attr.data.country
          rules = @attr.data.countryRules[country]
          hasDeliveries = @attr.orderForm.shippingData.logisticsInfo[0].slas.length > 0
          hasAvailableAddresses = @attr.orderForm.shippingData.availableAddresses.length > 1
          if @attr.orderForm.shippingData?.address is null
            if rules.queryByPostalCode or rules.queryByGeocoding
              @attr.stateMachine.search(@attr.orderForm)
            else
              @attr.orderForm.shippingData?.address = {country: country}
              @attr.orderForm.shippingData?.address = @setProfileNameIfNull(@attr.orderForm.shippingData?.address)
              @attr.stateMachine.editNoSLA(@attr.orderForm.shippingData?.address, hasAvailableAddresses)
          else if @validateAddress() isnt true
            orderForm = @attr.orderForm
            orderForm.shippingData.address = @setProfileNameIfNull(orderForm.shippingData.address)
            @attr.stateMachine.invalidAddress(orderForm.shippingData.address, hasAvailableAddresses, orderForm.shippingData.logisticsInfo, orderForm.items, orderForm.sellers)
          else if not hasDeliveries and not @attr.orderForm.canEditData
            @attr.stateMachine.cantEdit(@attr.data.deliveryCountries, @attr.orderForm)
          else
            @attr.stateMachine.list(@attr.data.deliveryCountries, @attr.orderForm)
        catch e
          console.log e

      @disable = ->
        if @attr.stateMachine.can('submit') and @isValid()
          @attr.data.active = false
          rules = @attr.data.countryRules[@attr.orderForm.shippingData.address?.country]
          @attr.stateMachine.submit(@attr.locale, @attr.orderForm, rules)
          @attr.API?.sendAttachment('shippingData', @attr.orderForm.shippingData)
            .fail (reason) =>
              orderForm = @attr.orderForm
              hasAvailableAddresses = orderForm.shippingData.availableAddresses.length > 1
              console.log "Could not send shipping data", reason
              @attr.stateMachine.apiError(orderForm.shippingData.address, hasAvailableAddresses, orderForm.shippingData.logisticsInfo, orderForm.items, orderForm.sellers)
              @trigger 'componentValidated.vtex', [[reason]]
              @done()
        else if @attr.orderForm.shippingData?.availableAddresses.length is 0 or @attr.orderForm.shippingData?.logisticsInfo?[0].slas.length is 0
          if @attr.stateMachine.can('cancelFirst')
            @attr.stateMachine.cancelFirst()
        else if @attr.stateMachine.can('cancelOther')
            @attr.stateMachine.cancelOther(@attr.locale, @attr.orderForm, @attr.data.countryRules[@attr.data.country])

      #
      # Events from children components
      #

      @done = ->
        valid = @validate()
        if valid.length > 0 and @attr.stateMachine.can('editNoSLA')
          hasAvailableAddresses = @attr.orderForm.shippingData.availableAddresses.length > 1
          @attr.stateMachine.editNoSLA(@attr.orderForm.shippingData?.address, hasAvailableAddresses)

        @trigger('componentDone.vtex')

      @setProfileNameIfNull = (address) ->
        # Tries to auto fill receiver name from client profile data
        profile = @attr.orderForm.clientProfileData
        if profile?.firstName and (address.receiverName is '' or not address.receiverName)
          address.receiverName = profile.firstName + ' ' + profile.lastName
        return address

      # An address search has new results.
      # Should call API to get delivery options
      @addressSearchResult = (ev, address) ->
        console.log "address result", address

        address = @setProfileNameIfNull(address)
        address.country = address?.country ? @attr.data.country

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
              hasDeliveries = orderForm.shippingData.logisticsInfo[0].slas.length > 0
              if @validateAddress() isnt true and @attr.stateMachine.can("invalidAddress")
                # If it's invalid, stop here and edit it
                orderForm.shippingData.address = @setProfileNameIfNull(orderForm.shippingData.address)
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
        if address.isValid
          @select('shippingSummarySelector').trigger('addressSelected.vtex', [address])

      @addressFormValidated = (ev, results) ->
        ev?.stopPropagation()
        @validate()

      @addressKeysUpdated = (ev, address) ->
        # In case it's an address that we already know its logistics info, return
        knownAddress = _.find @attr.orderForm.shippingData?.availableAddresses, (a) ->
            a.addressId is address.addressId and a.postalCode is address.postalCode and
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
              hasDeliveries = orderForm.shippingData.logisticsInfo[0].slas.length > 0
              hasAvailableAddresses = orderForm.shippingData.availableAddresses.length > 1
              # If we are editing and we received logistics info
              if hasDeliveries
                if @attr.stateMachine.can('doneSLA')
                  @attr.stateMachine.doneSLA(null, hasAvailableAddresses, orderForm.shippingData.logisticsInfo, @attr.orderForm.items, @attr.orderForm.sellers)
              else
                if @attr.data.countryRules[country].queryByPostalCode and @attr.stateMachine.can('clearSearch')
                  @attr.stateMachine.clearSearch(address.postalCode)
                else
                  @select('shippingOptionsSelector').trigger('disable.vtex')
                $(window).trigger('showMessage.vtex', ['unavailable'])
            )
            .fail( (reason) =>
              return if reason.statusText is 'abort'
              console.log reason
              hasAvailableAddresses = @attr.orderForm.shippingData.availableAddresses.length > 1
              if @attr.data.countryRules[country].queryByPostalCode and @attr.stateMachine.can('clearSearch')
                @attr.stateMachine.clearSearch(address.postalCode)
              else
                @attr.stateMachine.editNoSLA(@attr.orderForm.shippingData?.address, hasAvailableAddresses)
            )
        else if address.geoCoordinates
          # TODO implementar com geoCoordinates
          console.log address, "Geo coordinates not implemented!"

      # User cleared address search key and must search again
      @addressKeysInvalidated = (ev, address) ->
        if @attr.stateMachine.can('clearSearch')
          @attr.stateMachine.clearSearch(address?.postalCode, address?.useGeolocationSearch)

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
          address = @setProfileNameIfNull(address)
          @attr.stateMachine.editNoSLA(address, hasAvailableAddresses)
        else if @attr.stateMachine.can('new')
          country = @attr.data.country
          rules = @attr.data.countryRules[country]
          if rules.queryByPostalCode or rules.queryByGeocoding
            @attr.stateMachine.new()
          else
            @attr.orderForm.shippingData?.address = {country: country}
            @attr.orderForm.shippingData?.address = @setProfileNameIfNull(@attr.orderForm.shippingData?.address)
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
          return countryRules[country]

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
        @attr.stateMachine.start()
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
            @on 'click',
              'goToPaymentButtonSelector': @done
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

    return defineComponent(ShippingData, withi18n, withValidation, withShippingStateMachine)