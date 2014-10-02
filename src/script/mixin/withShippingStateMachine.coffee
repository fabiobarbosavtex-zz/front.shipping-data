define = vtex.define || window.define
require = vtex.curl || window.require

define ['shipping/script/models/Address'], (Address) ->
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
      { name: 'loadSLA',            from: 'anonListLoadSLA',   to: 'anonListSLA' }
      { name: 'loadNoSLA',          from: 'anonListLoadSLA',   to: 'anonListNoSLA' }
      { name: 'refresh',            from: 'anonListSLA',       to: 'listSLA' }
      { name: 'refresh',            from: 'anonListNoSLA',     to: 'listNoSLA' }
      { name: 'showForm',           from: 'listSLA',           to: '_form' }
      { name: 'showForm',           from: 'listLoadSLA',       to: '_form' }
      { name: 'showForm',           from: 'listNoSLA',         to: '_form' }
      { name: 'showSummary',        from: 'listSLA',           to: '_summary' }
      { name: 'showSummary',        from: 'anonListSLA',       to: '_summary' }

      { name: 'showSearch',         from: '_form',             to: 'search' }
      { name: 'editAddressSLA',     from: '_form',             to: 'addressFormSLA' }
      { name: 'editAddressNoSLA',   from: '_form',             to: 'addressFormNoSLA' }
      { name: 'newAddress',         from: '_form',             to: 'addressForm' }
      { name: 'newAddressSLA',      from: '_form',             to: 'addressFormSLA' }
      { name: 'searchAddress',      from: 'search',            to: 'addressFormLoad' }
      { name: 'loadAddress',        from: 'addressFormLoad',   to: 'addressForm' }
      { name: 'requestSLA',         from: 'addressForm',       to: 'addressFormLoadSLA' }
      { name: 'requestSLA',         from: 'addressFormSLA',    to: 'addressFormLoadSLA' }
      { name: 'requestSLA',         from: 'addressFormNoSLA',  to: 'addressFormLoadSLA' }
      { name: 'loadSLA',            from: 'addressFormLoadSLA',to: 'addressFormSLA' }
      { name: 'loadNoSLA',          from: 'addressFormLoadSLA',to: 'addressFormNoSLA' }
      { name: 'showSearch',         from: 'addressFormSLA',    to: 'search' }
      { name: 'showSearch',         from: 'addressFormNoSLA',  to: 'search' }
      { name: 'showList',           from: 'addressForm',       to: '_list' }
      { name: 'showList',           from: 'addressFormSLA',    to: '_list' }
      { name: 'showList',           from: 'addressFormNoSLA',  to: '_list' }
      { name: 'showSummary',        from: 'addressFormSLA',    to: '_summary' }

      { name: 'showSummary',        from: '_summary',          to: 'summary' }
      { name: 'showEmpty',          from: '_summary',          to: 'empty' }
      { name: 'showList',           from: 'empty',             to: '_list' }
      { name: 'showForm',           from: 'empty',             to: '_form' }
      { name: 'showList',           from: 'summary',           to: '_list' }
      { name: 'showForm',           from: 'summary',           to: '_form' }
    ]

    @createStateMachine = ->
      StateMachine.create
        events: stateMachineEvents
        callbacks:
          on_list:                   @on_List.bind(this)
          onlistSLA:                 @onListSLA.bind(this)
          onlistNoSLA:               @onListNoSLA.bind(this)
          onlistLoadSLA:             @onListLoadSLA.bind(this)
          onleaveListLoadSLA:        @onLeaveListLoadSLA.bind(this)
          onanonlistSLA:             @onAnonListSLA.bind(this)
          onanonlistNoSLA:           @onAnonListNoSLA.bind(this)
          onanonlistLoadSLA:         @onAnonListLoadSLA.bind(this)
          onLeaveAnonListLoadSLA:    @onLeaveAnonListLoadSLA.bind(this)

          on_form:                   @on_Form.bind(this)
          onsearch:                  @onSearch.bind(this)
          onaddressForm:             @onAddressForm.bind(this)
          onaddressFormLoad:         @onAddressFormLoad.bind(this)
          onleaveaddressFormLoad:    @onLeaveAddressFormLoad.bind(this)
          onaddressFormSLA:          @onAddressFormSLA.bind(this)
          onleaveaddressFormSLA:     @onLeaveAddressFormSLA.bind(this)
          onaddressFormnoSLA:        @onAddressFormNoSLA.bind(this)
          onaddressFormLoadSLA:      @onAddressFormLoadSLA.bind(this)

          on_summary:                @on_Summary.bind(this)
          onsummary:                 @onSummary.bind(this)
          onleavesummary:            @onLeaveSummary.bind(this)
          onempty:                   @onEmpty.bind(this)
          onleaveempty:              @onLeaveEmpty.bind(this)

    #
    # Changed state events (FINITE STATE MACHINE)
    #
    @onBeforeEvent = (event, from, to) ->
      console.log "Enter "+to

    @onAfterEvent = ->
      if @attr.data.active
        @select('shippingStepSelector').addClass('active', 'visited')
      else
        @select('shippingStepSelector').removeClass('active')

    @on_Summary = (event, from, to, orderForm) ->      
      @attr.data.active = false

      # Disable other components
      @select('addressListSelector').trigger('disable.vtex')
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
      @select('addressFormSelector').trigger('disable.vtex')
      @select('shippingOptionsSelector').trigger('disable.vtex')

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
      @select('addressSearchSelector').trigger('disable.vtex', null)
      @select('shippingOptionsSelector').trigger('disable.vtex')
      @select('shippingSummarySelector').trigger('disable.vtex')
      @select('goToPaymentButtonWrapperSelector').hide()

      deliveryCountries = _.uniq(_.reduceRight(orderForm.shippingData.logisticsInfo, ((memo, l) ->
        return memo.concat(l.shipsTo)), []))
      if deliveryCountries.length is 0
        deliveryCountries = [orderForm.storePreferencesData?.countryCode]

      hasDeliveries = orderForm.shippingData?.logisticsInfo?.length > 0 and orderForm.shippingData?.logisticsInfo[0].slas.length > 0
      canEditData = orderForm.canEditData

      if canEditData
        if hasDeliveries
          @attr.stateMachine.next = =>
            @attr.stateMachine.showListWithSLA(orderForm, deliveryCountries)
        else
          @attr.stateMachine.next = =>
            @attr.stateMachine.showListUnavailable(orderForm, deliveryCountries)
      else
        if hasDeliveries
          @attr.stateMachine.next = =>
            @attr.stateMachine.showListCantEdit(orderForm, deliveryCountries)
        else
          @attr.stateMachine.next = =>
            @attr.stateMachine.showListCantEditUnavailable(orderForm, deliveryCountries)

    @onListSLA = (event, from, to, orderForm, deliveryCountries) ->
      @select('addressListSelector').trigger('enable.vtex', [deliveryCountries, orderForm.shippingData, orderForm.giftRegistryData])
      @select('shippingOptionsSelector').trigger('enable.vtex', [orderForm.shippingData?.logisticsInfo, orderForm.items, orderForm.sellers])
      @select('goToPaymentButtonWrapperSelector').show()

    @onListNoSLA = (event, from, to, orderForm, deliveryCountries) ->
      @select('addressListSelector').trigger('enable.vtex', [deliveryCountries, orderForm.shippingData, orderForm.giftRegistryData])
      @select('shippingOptionsSelector').trigger('disable.vtex')
      @select('goToPaymentButtonWrapperSelector').hide()

    @onAnonListSLA = (event, from, to, orderForm, deliveryCountries) ->
      @select('addressListSelector').trigger('enable.vtex', [deliveryCountries, orderForm.shippingData, orderForm.giftRegistryData])
      @select('shippingOptionsSelector').trigger('enable.vtex', [orderForm.shippingData?.logisticsInfo, orderForm.items, orderForm.sellers])
      @select('goToPaymentButtonWrapperSelector').show()

    @onAnonListNoSLA = (event, from, to, orderForm, deliveryCountries) ->
      @select('addressListSelector').trigger('enable.vtex', [deliveryCountries, orderForm.shippingData, orderForm.giftRegistryData])
      @select('shippingOptionsSelector').trigger('disable.vtex')
      @select('goToPaymentButtonWrapperSelector').hide()

    @onListLoadSLA = (event, from, to) ->
      @select('shippingOptionsSelector').trigger('startLoading.vtex')

    @onLeaveListLoadSLA = (event, from, to) ->
      @select('shippingOptionsSelector').trigger('stopLoading.vtex')

    @onAnonListLoadSLA = (event, from, to) ->
      @select('shippingOptionsSelector').trigger('startLoading.vtex')

    @onLeaveAnonListLoadSLA = (event, from, to) ->
      @select('shippingOptionsSelector').trigger('stopLoading.vtex')  

    @on_Form = (event, from, to, orderForm) ->
      @attr.data.active = true

       # Disable other components
      @select('addressFormSelector').trigger('disable.vtex')
      @select('addressSearchSelector').trigger('disable.vtex', null)
      @select('shippingOptionsSelector').trigger('disable.vtex')
      @select('addressListSelector').trigger('disable.vtex')
      @select('goToPaymentButtonWrapperSelector').hide()

      deliveryCountries = _.uniq(_.reduceRight(orderForm.shippingData.logisticsInfo, ((memo, l) ->
        return memo.concat(l.shipsTo)), []))
      if deliveryCountries.length is 0
        deliveryCountries = [orderForm.storePreferencesData?.countryCode]

      address = orderForm.shippingData?.address
      country = address?.country ? deliveryCountries[0]
      rules = @attr.data.countryRules[country]
      hasAvailableAddresses = orderForm.shippingData?.availableAddresses.length > 1
      hasDeliveries = orderForm.shippingData?.logisticsInfo?.length > 0 and orderForm.shippingData?.logisticsInfo[0].slas.length > 0

      if @attr.stateMachine.from is 'listLoadSLA'
        requestingSLA = true

      if address and (not rules.regexes.postalCode.test(address.postalCode) and rules.queryByPostalCode) or
        (rules.queryByGeocoding and address.geoCoordinates.length isnt 2)
          @attr.stateMachine.next = =>
            @attr.stateMachine.showSearch(rules, address.postalCode, rules.queryByGeocoding, hasAvailableAddresses)
          return

      addressObj = new Address(address) if address
      if address and addressObj?.validate(rules) is true or addressObj?.postalCode?
        if hasDeliveries
          @attr.stateMachine.next = =>
            @attr.stateMachine.editAddressSLA(orderForm, address, hasAvailableAddresses)
            if requestingSLA
              @attr.stateMachine.requestSLA()
        else
          @attr.stateMachine.next = =>
            @attr.stateMachine.editAddressNoSLA(orderForm, address, hasAvailableAddresses)
            if requestingSLA
              @attr.stateMachine.requestSLA()
      else
        address = {country: country}
        address = @addressDefaults(address)
        if rules.queryByPostalCode or rules.queryByGeocoding
          @attr.stateMachine.next = =>
            @attr.stateMachine.showSearch(rules, address.postalCode, rules.queryByGeocoding, hasAvailableAddresses)
        else if hasDeliveries
          @attr.stateMachine.next = =>
            @attr.stateMachine.newAddressSLA(orderForm, address, hasAvailableAddresses)
        else
          @attr.stateMachine.next = =>
            @attr.stateMachine.newAddress(orderForm, address, hasAvailableAddresses)

    @onSearch = (event, from, to, rules, postalCodeQuery, useGeolocationSearch, hasAvailableAddresses) ->
      # Disable other components
      @select('addressFormSelector').trigger('disable.vtex')
      @select('shippingOptionsSelector').trigger('disable.vtex')
      
      @select('addressSearchSelector').trigger('enable.vtex', [rules, postalCodeQuery, useGeolocationSearch, hasAvailableAddresses])

    @onLeaveSearch = (event, from, to) ->
      @select('addressSearchSelector').trigger('disable.vtex', null)

    @onAddressForm = (event, from, to, orderForm, address, hasAvailableAddresses) ->
      @select('addressSearchSelector').trigger('disable.vtex')
      @select('addressFormSelector').trigger('enable.vtex', [address, hasAvailableAddresses])
      @select('shippingOptionsSelector').trigger('disable.vtex')

    @onAddressFormLoad = (event, from, to) ->
      return

    @onLeaveAddressFormLoad = (event, from, to) ->
      return

    @onAddressFormSLA = (event, from, to, orderForm, address, hasAvailableAddresses) ->
      @select('addressSearchSelector').trigger('disable.vtex')
      if event isnt 'loadSLA'
        @select('addressFormSelector').trigger('enable.vtex', [address, hasAvailableAddresses])
      @select('shippingOptionsSelector').trigger('enable.vtex', [orderForm.shippingData?.logisticsInfo, orderForm.items, orderForm.sellers])
      @select('goToPaymentButtonWrapperSelector').show()

    @onLeaveAddressFormSLA = (event, from, to) ->
      @select('goToPaymentButtonWrapperSelector').hide()

    @onAddressFormNoSLA = (event, from, to, orderForm, address, hasAvailableAddresses) ->
      $(window).trigger('showMessage.vtex', ['unavailable'])
      if event isnt 'loadNoSLA'
        @select('addressFormSelector').trigger('enable.vtex', [address, hasAvailableAddresses])
      @select('shippingOptionsSelector').trigger('disable.vtex')

    @onAddressFormLoadSLA = (event, from, to) ->
      @select('shippingOptionsSelector').trigger('startLoading.vtex')

    return stateMachineEvents