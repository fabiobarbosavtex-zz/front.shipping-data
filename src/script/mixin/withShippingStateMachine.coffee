define ['state-machine/state-machine',
        'shipping/script/models/Address'], (SM, Address) ->
  ->
    stateMachineEvents = [
      { name: 'showList',           from: 'none',              to: '_list' }
      { name: 'showForm',           from: 'none',              to: '_form' }
      { name: 'showSummary',        from: 'none',              to: '_summary' }

      { name: 'showListWithSLA',    from: '_list',             to: 'listSLA' }
      { name: 'showListUnavailable',from: '_list',             to: 'listNoSLA' }
      { name: 'showListCantEdit',   from: '_list',             to: 'anonListSLA' }
      { name: 'showListCantEditUnavailable', from: '_list',    to: 'anonListNoSLA' }
      { name: 'requestSLA',         from: 'listLoadSLA',       to: 'listLoadSLA' }
      { name: 'loadSLA',            from: 'listLoadSLA',       to: 'listSLA' }
      { name: 'loadNoSLA',          from: 'listLoadSLA',       to: 'listNoSLA' }
      { name: 'requestSLA',         from: 'listSLA',           to: 'listLoadSLA' }
      { name: 'requestSLA',         from: 'listNoSLA',         to: 'listLoadSLA' }
      { name: 'requestSLA',         from: 'anonListSLA',       to: 'anonListLoadSLA' }
      { name: 'requestSLA',         from: 'anonListNoSLA',     to: 'anonListLoadSLA' }
      { name: 'requestSLA',         from: 'anonListLoadSLA',   to: 'anonListLoadSLA' }
      { name: 'loadSLA',            from: 'anonListLoadSLA',   to: 'anonListSLA' }
      { name: 'loadNoSLA',          from: 'anonListLoadSLA',   to: 'anonListNoSLA' }
      { name: 'refresh',            from: 'anonListSLA',       to: 'listSLA' }
      { name: 'refresh',            from: 'anonListNoSLA',     to: 'listNoSLA' }
      { name: 'showList',           from: 'anonListSLA',       to: '_list' }
      { name: 'showList',           from: 'anonListNoSLA',     to: '_list' }
      { name: 'showForm',           from: 'anonListSLA',       to: '_form' }
      { name: 'showForm',           from: 'anonListNoSLA',     to: '_form' }
      { name: 'showForm',           from: 'listSLA',           to: '_form' }
      { name: 'showForm',           from: 'listLoadSLA',       to: '_form' }
      { name: 'showForm',           from: 'listNoSLA',         to: '_form' }
      { name: 'showSummary',        from: 'listSLA',           to: '_summary' }
      { name: 'showSummary',        from: 'anonListSLA',       to: '_summary' }

      { name: 'showSearch',         from: '_form',             to: 'search' }
      { name: 'editAddressSLA',     from: '_form',             to: 'addressFormSLA' }
      { name: 'editAddressNoSLA',   from: '_form',             to: 'addressFormNoSLA' }
      { name: 'newAddress',         from: '_form',             to: 'addressForm' }
      { name: 'searchAddress',      from: 'search',            to: 'addressFormLoad' }
      { name: 'loadAddress',        from: 'addressFormLoad',   to: 'addressForm' }
      { name: 'requestSLA',         from: 'addressForm',       to: 'addressFormLoadSLA' }
      { name: 'requestSLA',         from: 'addressFormSLA',    to: 'addressFormLoadSLA' }
      { name: 'requestSLA',         from: 'addressFormLoadSLA',to: 'addressFormLoadSLA' }
      { name: 'requestSLA',         from: 'addressFormNoSLA',  to: 'addressFormLoadSLA' }
      { name: 'loadSLA',            from: 'addressFormLoadSLA',to: 'addressFormSLA' }
      { name: 'loadNoSLA',          from: 'addressFormLoadSLA',to: 'addressFormNoSLA' }
      { name: 'showSearch',         from: 'addressForm',       to: 'search' }
      { name: 'showSearch',         from: 'addressFormSLA',    to: 'search' }
      { name: 'showSearch',         from: 'addressFormNoSLA',  to: 'search' }
      { name: 'showSearch',         from: 'addressFormLoadSLA',to: 'search' }
      { name: 'showForm',           from: 'search',            to: '_form' }
      { name: 'showForm',           from: 'addressForm',       to: '_form' }
      { name: 'showForm',           from: 'addressFormLoad',   to: '_form' }
      { name: 'showForm',           from: 'addressFormLoadSLA',to: '_form' }
      { name: 'showForm',           from: 'addressFormSLA',    to: '_form' }
      { name: 'showForm',           from: 'addressFormNoSLA',  to: '_form' }
      { name: 'showList',           from: 'search',            to: '_list' }
      { name: 'showList',           from: 'addressForm',       to: '_list' }
      { name: 'showList',           from: 'addressFormLoad',   to: '_list' }
      { name: 'showList',           from: 'addressFormLoadSLA',to: '_list' }
      { name: 'showList',           from: 'addressFormSLA',    to: '_list' }
      { name: 'showList',           from: 'addressFormNoSLA',  to: '_list' }
      { name: 'showSummary',        from: 'addressFormSLA',    to: '_summary' }

      { name: 'showSummary',        from: '_summary',          to: 'summary' }
      { name: 'showEmpty',          from: '_summary',          to: 'empty' }
      { name: 'showList',           from: 'empty',             to: '_list' }
      { name: 'showForm',           from: 'empty',             to: '_form' }
      { name: 'showSummary',        from: 'empty',             to: '_summary' }
      { name: 'showList',           from: 'summary',           to: '_list' }
      { name: 'showForm',           from: 'summary',           to: '_form' }
      { name: 'showSummary',        from: 'summary',           to: '_summary' }
    ]

    @createStateMachine = ->
      return StateMachine.create
        events: stateMachineEvents
        callbacks:
          on_list:                   @on_List.bind(this)
          onlistSLA:                 @onListSLA.bind(this)
          onlistNoSLA:               @onListNoSLA.bind(this)
          onlistLoadSLA:             @onListLoadSLA.bind(this)
          onleaveListLoadSLA:        @onLeaveListLoadSLA.bind(this)
          onanonListSLA:             @onAnonListSLA.bind(this)
          onanonListNoSLA:           @onAnonListNoSLA.bind(this)
          onanonListLoadSLA:         @onAnonListLoadSLA.bind(this)
          onLeaveAnonListLoadSLA:    @onLeaveAnonListLoadSLA.bind(this)

          on_form:                   @on_Form.bind(this)
          onsearch:                  @onSearch.bind(this)
          onaddressForm:             @onAddressForm.bind(this)
          onaddressFormLoad:         @onAddressFormLoad.bind(this)
          onleaveaddressFormLoad:    @onLeaveAddressFormLoad.bind(this)
          onaddressFormSLA:          @onAddressFormSLA.bind(this)
          onleaveaddressFormSLA:     @onLeaveAddressFormSLA.bind(this)
          onaddressFormNoSLA:        @onAddressFormNoSLA.bind(this)
          onaddressFormLoadSLA:      @onAddressFormLoadSLA.bind(this)

          on_summary:                @on_Summary.bind(this)
          onsummary:                 @onSummary.bind(this)
          onleavesummary:            @onLeaveSummary.bind(this)
          onempty:                   @onEmpty.bind(this)
          onleaveempty:              @onLeaveEmpty.bind(this)

          onafterevent:              @onAfterEvent.bind(this)

    #
    # Changed state events (FINITE STATE MACHINE)
    #
    @onBeforeEvent = (event, from, to) ->
      console.log "Enter "+to

    @onAfterEvent = ->
      if @attr.data.active
        @select('shippingStepSelector').addClass('active', 'visited')
        @select('shippingStepTitleSelector').addClass('accordion-toggle-active')
      else
        @select('shippingStepSelector').removeClass('active')
        @select('shippingStepTitleSelector').removeClass('accordion-toggle-active')

    @on_Summary = (event, from, to, orderForm) ->
      @attr.data.active = false

      # Disable other components
      @select('addressListSelector').trigger('disable.vtex')
      @select('countrySelectSelector').trigger('disable.vtex')
      @select('addressFormSelector').trigger('disable.vtex')
      @select('shippingOptionsSelector').trigger('disable.vtex')
      @select('addressNotFilledSelector').hide()
      @select('goToPaymentButtonWrapperSelector').hide()

      if @isValid()
        locale = @attr.locale
        rules = @attr.data.countryRules[@attr.orderForm.shippingData.address?.country]
        @attr.stateMachine.next = =>
          @attr.stateMachine.showSummary(orderForm, locale, rules)
      else
        @attr.stateMachine.next = =>
          @attr.stateMachine.showEmpty()

    @onEmpty = (event, from, to) ->
      # Disable other components
      @select('addressListSelector').trigger('disable.vtex')
      @select('countrySelectSelector').trigger('disable.vtex')
      @select('addressFormSelector').trigger('disable.vtex')
      @select('shippingOptionsSelector').trigger('disable.vtex')
      @select('shippingSummarySelector').trigger('disable.vtex')

      @select('addressNotFilledSelector').show()

    @onLeaveEmpty = (event, from, to) ->
      @select('addressNotFilledSelector').hide()

    @onSummary = (event, from, to, orderForm, locale, rules) ->
      @select('shippingSummarySelector').trigger('enable.vtex', [locale, orderForm.shippingData, orderForm.items, orderForm.sellers, rules, orderForm.canEditData, orderForm.giftRegistryData])
      @select('editShippingDataSelector').show()

    @onLeaveSummary = (event, from, to) ->
      @select('editShippingDataSelector').hide()

    @on_List = (event, from, to, orderForm) ->
      @attr.data.active = true

      # Disable other components
      @select('addressFormSelector').trigger('disable.vtex')
      @select('countrySelectSelector').trigger('disable.vtex')
      @select('addressSearchSelector').trigger('disable.vtex', null)
      @select('shippingOptionsSelector').trigger('disable.vtex')
      @select('shippingSummarySelector').trigger('disable.vtex')
      @select('goToPaymentButtonWrapperSelector').hide()

      hasDeliveries = @attr.data.hasDeliveries

      if orderForm.canEditData
        if hasDeliveries
          @attr.stateMachine.next = =>
            @attr.stateMachine.showListWithSLA(orderForm)
        else
          @attr.stateMachine.next = =>
            @attr.stateMachine.showListUnavailable(orderForm)
      else
        if hasDeliveries
          @attr.stateMachine.next = =>
            @attr.stateMachine.showListCantEdit(orderForm)
        else
          @attr.stateMachine.next = =>
            @attr.stateMachine.showListCantEditUnavailable(orderForm)

    @onListSLA = (event, from, to, orderForm) ->
      deliveryCountries = @attr.data.deliveryCountries

      @select('addressListSelector').trigger('enable.vtex', [deliveryCountries, orderForm.shippingData, orderForm.giftRegistryData])
      @select('shippingOptionsSelector').trigger('enable.vtex', [orderForm.shippingData?.logisticsInfo, orderForm.items, orderForm.sellers])
      @select('goToPaymentButtonWrapperSelector').fadeIn("fast")

    @onListNoSLA = (event, from, to, orderForm) ->
      deliveryCountries = @attr.data.deliveryCountries

      $(window).trigger('showMessage.vtex', ['unavailable'])

      @select('addressListSelector').trigger('enable.vtex', [deliveryCountries, orderForm.shippingData, orderForm.giftRegistryData])
      @select('shippingOptionsSelector').trigger('disable.vtex')
      @select('goToPaymentButtonWrapperSelector').fadeOut("fast")

    @onAnonListSLA = (event, from, to, orderForm) ->
      deliveryCountries = @attr.data.deliveryCountries

      @select('addressListSelector').trigger('enable.vtex', [deliveryCountries, orderForm.shippingData, orderForm.giftRegistryData])
      @select('shippingOptionsSelector').trigger('enable.vtex', [orderForm.shippingData?.logisticsInfo, orderForm.items, orderForm.sellers])
      @select('goToPaymentButtonWrapperSelector').fadeIn("fast")

    @onAnonListNoSLA = (event, from, to, orderForm) ->
      deliveryCountries = @attr.data.deliveryCountries

      $(window).trigger('showMessage.vtex', ['unavailable'])

      @select('addressListSelector').trigger('enable.vtex', [deliveryCountries, orderForm.shippingData, orderForm.giftRegistryData])
      @select('shippingOptionsSelector').trigger('disable.vtex')
      @select('goToPaymentButtonWrapperSelector').fadeOut("fast")

    @onListLoadSLA = (event, from, to) ->
      @select('addressListSelector').trigger('startLoading.vtex')
      @select('shippingOptionsSelector').trigger('startLoading.vtex')
      @select('goToPaymentButtonWrapperSelector').fadeOut("fast")

    @onLeaveListLoadSLA = (event, from, to) ->
      @select('addressListSelector').trigger('stopLoading.vtex')
      @select('shippingOptionsSelector').trigger('stopLoading.vtex')

    @onAnonListLoadSLA = (event, from, to) ->
      @select('addressListSelector').trigger('startLoading.vtex')
      @select('shippingOptionsSelector').trigger('startLoading.vtex')
      @select('goToPaymentButtonWrapperSelector').fadeOut("fast")

    @onLeaveAnonListLoadSLA = (event, from, to) ->
      @select('addressListSelector').trigger('stopLoading.vtex')
      @select('shippingOptionsSelector').trigger('stopLoading.vtex')

    @on_Form = (event, from, to, orderForm) ->
      @attr.data.active = true

       # Disable other components
      @select('addressFormSelector').trigger('disable.vtex')
      @select('countrySelectSelector').trigger('disable.vtex')
      @select('addressSearchSelector').trigger('disable.vtex', null)
      @select('shippingOptionsSelector').trigger('disable.vtex')
      @select('shippingSummarySelector').trigger('disable.vtex')
      @select('addressListSelector').trigger('disable.vtex')
      @select('goToPaymentButtonWrapperSelector').hide()

      deliveryCountries = @attr.data.deliveryCountries
      hasAvailableAddresses = @attr.data.hasAvailableAddresses
      hasDeliveries = @attr.data.hasDeliveries
      logisticsConfiguration = @attr.data.logisticsConfiguration
      storeAcceptsPostalCode = ('postalCode' in @attr.data.logisticsConfiguration?.acceptSearchKeys)
      storeAcceptsGeoCoords = ('geoCoords' in @attr.data.logisticsConfiguration?.acceptSearchKeys)

      apiCallError = @attr.orderForm.apiCallError
      @attr.orderForm.apiCallError = null
      address = orderForm.shippingData?.address
      country = address?.country ? @attr.data.country ? deliveryCountries[0]
      rules = @attr.data.countryRules[country]
      rules = @attr.data.countryRules[deliveryCountries[0]] unless rules

      if @attr.stateMachine.from is 'listLoadSLA'
        requestingSLA = true

      postalCodeIsValid = address and rules.regexes?.postalCode and rules.regexes.postalCode.test(address.postalCode)
      geoCoordinatesIsValid = address and address.geoCoordinates?.length is 2
      if (!storeAcceptsGeoCoords and rules.queryByPostalCode and !postalCodeIsValid) or (storeAcceptsGeoCoords and !geoCoordinatesIsValid)
        @attr.stateMachine.next = =>
          @attr.stateMachine.showSearch(rules, address, hasAvailableAddresses, deliveryCountries, logisticsConfiguration)
        return

      addressObj = new Address(address) if address
      if !apiCallError and (address and addressObj?.validate(rules) is true or addressObj?.postalCode? or addressObj?.geoCoordinates?.length is 2)
        if hasDeliveries
          @attr.stateMachine.next = =>
            @attr.stateMachine.editAddressSLA(orderForm)
            if requestingSLA
              @attr.stateMachine.requestSLA()
        else
          @attr.stateMachine.next = =>
            @attr.stateMachine.editAddressNoSLA(orderForm)
            if requestingSLA
              @attr.stateMachine.requestSLA()
      else
        orderForm.shippingData.address = address = {country: country}
        address = @addressDefaults(address)
        if rules.queryByPostalCode or storeAcceptsGeoCoords
          @attr.stateMachine.next = =>
            @attr.stateMachine.showSearch(rules, address, hasAvailableAddresses, deliveryCountries, logisticsConfiguration)
        else
          @attr.stateMachine.next = =>
            @attr.stateMachine.newAddress(orderForm)

    @onSearch = (event, from, to, rules, address, hasAvailableAddresses, deliveryCountries, logisticsConfiguration) ->
      # Disable other components
      @select('addressFormSelector').trigger('disable.vtex')
      @select('shippingOptionsSelector').trigger('disable.vtex')

      preferencedCountry = @attr.data.country
      @select('countrySelectSelector').trigger('enable.vtex', [deliveryCountries, address, hasAvailableAddresses, preferencedCountry])
      @select('addressSearchSelector').trigger('enable.vtex', [rules, address, logisticsConfiguration])

    @onLeaveSearch = (event, from, to) ->
      @select('addressSearchSelector').trigger('disable.vtex', null)

    @onAddressForm = (event, from, to, orderForm) ->
      address = orderForm.shippingData?.address
      hasAvailableAddresses = @attr.data.hasAvailableAddresses
      deliveryCountries = @attr.data.deliveryCountries
      logisticsConfiguration = @attr.data.logisticsConfiguration
      preferencedCountry = @attr.data.country

      @select('countrySelectSelector').trigger('enable.vtex', [deliveryCountries, address, hasAvailableAddresses, preferencedCountry])
      @select('addressSearchSelector').trigger('disable.vtex')
      @select('addressFormSelector').trigger('enable.vtex', [address, logisticsConfiguration])
      @select('shippingOptionsSelector').trigger('disable.vtex')

    @onAddressFormLoad = (event, from, to) ->
      return

    @onLeaveAddressFormLoad = (event, from, to) ->
      return

    @onAddressFormSLA = (event, from, to, orderForm) ->
      address = orderForm.shippingData?.address
      hasAvailableAddresses = @attr.data.hasAvailableAddresses
      deliveryCountries = @attr.data.deliveryCountries
      logisticsConfiguration = @attr.data.logisticsConfiguration
      preferencedCountry = @attr.data.country

      @select('countrySelectSelector').trigger('enable.vtex', [deliveryCountries, address, hasAvailableAddresses, preferencedCountry])
      @select('addressSearchSelector').trigger('disable.vtex')
      if event isnt 'loadSLA'
        @select('addressFormSelector').trigger('enable.vtex', [address, logisticsConfiguration])
      @select('shippingOptionsSelector').trigger('enable.vtex', [orderForm.shippingData?.logisticsInfo, orderForm.items, orderForm.sellers])
      @select('goToPaymentButtonWrapperSelector').fadeIn("fast")

    @onLeaveAddressFormSLA = (event, from, to) ->
      @select('goToPaymentButtonWrapperSelector').hide()

    @onAddressFormNoSLA = (event, from, to, orderForm) ->
      address = orderForm.shippingData?.address
      hasAvailableAddresses = @attr.data.hasAvailableAddresses
      deliveryCountries = @attr.data.deliveryCountries
      logisticsConfiguration = @attr.data.logisticsConfiguration
      preferencedCountry = @attr.data.country

      $(window).trigger('showMessage.vtex', ['unavailable'])

      @select('countrySelectSelector').trigger('enable.vtex', [deliveryCountries, address, hasAvailableAddresses, preferencedCountry])
      if event isnt 'loadNoSLA'
        @select('addressFormSelector').trigger('enable.vtex', [address, logisticsConfiguration])
      @select('shippingOptionsSelector').trigger('disable.vtex')

    @onAddressFormLoadSLA = (event, from, to) ->
      @select('shippingOptionsSelector').trigger('startLoading.vtex')

    return stateMachineEvents
