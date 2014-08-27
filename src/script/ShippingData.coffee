define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'state-machine/state-machine-vtex',
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
        shippingData = @attr.orderForm.shippingData ? {}
        @attr.data.deliveryCountries = _.uniq(_.reduceRight(shippingData.logisticsInfo, ((memo, l) ->
          return memo.concat(l.shipsTo)), []))
        if @attr.data.deliveryCountries.length is 0
          @attr.data.deliveryCountries = [orderForm.storePreferencesData?.countryCode]
        country = @attr.orderForm.shippingData.address?.country ? @attr.data.deliveryCountries[0]
        @countrySelected(null, country).then =>
          if shippingData.address? # If a current address exists
            if shippingData.logisticsInfo[0].slas.length == 0
              @attr.stateMachine.unavailable(shippingData.address)
              @trigger 'componentValidated.vtex', [[new Error("SLA array is empty")]]
              @done()
            else if @attr.stateMachine.can('orderform')
              @attr.stateMachine.orderform(@attr.locale, orderForm, @attr.data.countryRules[shippingData.address.country])
          @validate()

      #
      # External events handlers
      #

      @enable = ->
        try
          country = @attr.orderForm.shippingData.address?.country ? @attr.data.deliveryCountries[0]
          rules = @attr.data.countryRules[country]
          if @attr.orderForm.shippingData?.address is null
            if rules.queryPostalCode
              @attr.stateMachine.search(@attr.orderForm, rules)
            else
              @attr.orderForm.shippingData?.address = {country: country}
              @attr.orderForm.shippingData?.address = @setProfileNameIfNull(@attr.orderForm.shippingData?.address)
              @attr.stateMachine.edit(@attr.orderForm.shippingData?.address)
          else if @validateAddress() isnt true
            orderForm = @attr.orderForm
            @attr.stateMachine.invalidAddress(orderForm.shippingData.address, orderForm.shippingData.logisticsInfo, orderForm.items, orderForm.sellers)
          else
            @attr.stateMachine.list(@attr.orderForm)
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
              console.log "Could not send shipping data", reason
              @attr.stateMachine.apiError(orderForm.shippingData.address, orderForm.shippingData.logisticsInfo, orderForm.items, orderForm.sellers)
              @trigger 'componentValidated.vtex', [[reason]]
              @done()

      #
      # Events from children components
      #

      @done = ->
        @validate()
        @trigger('componentDone.vtex')

      # An address search has new results.
      # Should call API to get delivery options
      @addressSearchResult = (ev, address) ->
        console.log "address result", address

        # Tries to auto fill receiver name from client profile data
        profile = @attr.orderForm.clientProfileData
        if profile?.firstName and (address.receiverName is '' or not address.receiverName)
          address.receiverName = profile.firstName + ' ' + profile.lastName

        @attr.stateMachine.doneSearch(address)

      # When a new addresses is selected
      @addressSelected = (ev, address) ->
        ev?.stopPropagation()
        address.isValid = true # se foi selecionado da lista, está válido
        @addressUpdated(ev, address)
        if @attr.stateMachine.current is 'list'
          @select('shippingOptionsSelector').trigger('startLoadingShippingOptions.vtex')
          @attr.API?.sendAttachment('shippingData', @attr.orderForm.shippingData).done (orderForm) =>
            if @validateAddress() isnt true and @attr.stateMachine.can("invalidAddress")
              # If it's invalid, stop here and edit it
              @attr.stateMachine.invalidAddress(orderForm.shippingData.address, orderForm.shippingData.logisticsInfo, orderForm.items, orderForm.sellers)
            else if @attr.stateMachine.can("select")
              @attr.stateMachine.select(orderForm)

      # The current address was updated, either selected or in edit
      @addressUpdated = (ev, address) ->
        ev.stopPropagation()
        @attr.orderForm.shippingData.address = address
        if address.isValid
          @select('goToPaymentButtonSelector').removeAttr('disabled')
          @select('shippingSummarySelector').trigger('addressSelected.vtex', [address])
        else
          @select('goToPaymentButtonSelector').attr('disabled', 'disabled')

      @addressFormValidated = (ev, results) ->
        ev?.stopPropagation()
        @validate()

      @addressKeysUpdated = (ev, addressKeyMap) ->
        if addressKeyMap.postalCode and addressKeyMap.postalCode.valid and @attr.stateMachine.current isnt 'editSLA'
          # When we start editing, we always start looking for shipping options
          console.log "Getting shipping options for address key", addressKeyMap.postalCode.value
          @select('shippingOptionsSelector').trigger('startLoadingShippingOptions.vtex')
          postalCode = addressKeyMap.postalCode.value
          country = @attr.orderForm.shippingData.address?.country ? @attr.data.country
          @attr.API?.sendAttachment('shippingData', {address: {addressId: addressKeyMap.addressId, postalCode: postalCode, country: country}})
            .done( (orderForm) =>
              # If we are editing and we received logistics info
              if @attr.stateMachine.can("doneSLA")
                @attr.stateMachine.doneSLA(null, orderForm.shippingData.logisticsInfo, @attr.orderForm.items, @attr.orderForm.sellers)
            )
            .fail( (reason) =>
              console.log reason
              if @attr.stateMachine.can('clearSearch')
                @attr.stateMachine.clearSearch(addressKeyMap.postalCode?.value)
            )
        else if addressKeyMap.geoCoordinates
          # TODO implementar com geoCoordinates
          console.log addressKeyMap, "Geo coordinates not implemented!"

      # User cleared address search key and must search again
      # addressSearch may be, for example, a new postal code
      @addressKeysInvalidated = (ev, addressKeyMap) ->
        if @attr.stateMachine.can('clearSearch')
          @attr.stateMachine.clearSearch(addressKeyMap.postalCode?.value, if addressKeyMap.usePostalCodeSearch? then addressKeyMap.usePostalCodeSearch else true)

      # User wants to edit or create an address
      @editAddress = (ev, address) ->
        if not @attr.orderForm.canEditData
          vtexIdOptions =
            returnUrl: window.location.href
            userEmail: vtexjs?.checkout?.orderForm?.clientProfileData?.email
            locale: @attr.locale
          return window.vtexid?.start(vtexIdOptions)

        ev?.stopPropagation()
        if address and
            @attr.orderForm.shippingData.address?.addressId is address.addressId and
            @attr.stateMachine.can('editSLA')
          # Estamos editanto o endereço atual, use o seu logistics info
          @attr.stateMachine.editSLA(address, @attr.orderForm.shippingData.logisticsInfo,
            @attr.orderForm.items, @attr.orderForm.sellers)
        if address and @attr.stateMachine.can('edit')
          @attr.stateMachine.edit(address)
        else if @attr.stateMachine.can('new')
          @attr.stateMachine.new()

      # User cancelled ongoing address edit
      @cancelAddressEdit = (ev) ->
        ev?.stopPropagation()
        if @attr.stateMachine.can('cancelNew')
          @attr.stateMachine.cancelNew()
        if @attr.stateMachine.can('cancelEdit')
          @attr.stateMachine.cancelEdit()

      # User chose shipping options
      @deliverySelected = (ev, logisticsInfo) ->
        @attr.orderForm.shippingData.logisticsInfo = logisticsInfo
        @select('shippingSummarySelector').trigger('deliverySelected.vtex', [logisticsInfo, @attr.orderForm.items, @attr.orderForm.sellers])

      @countrySelected = (ev, country) ->
        @attr.data.country = country
        require 'shipping/script/rule/Country'+country, (countryRule) =>
          countryRules = @attr.data.countryRules
          countryRules[country] = new countryRule()
          @attr.data.states = countryRules[country].states
          @attr.data.regexes = countryRules[country].regexes
          @attr.data.useGeolocation = countryRules[country].useGeolocation
          return countryRules[country]

      #
      # Validation
      #

      @validateAddress = ->
        if @attr.orderForm.canEditData
          currentAddress = new Address(@attr.orderForm.shippingData.address)
          return currentAddress.validate(@attr.data.countryRules[currentAddress.country])
        else
          return true

      @validateShippingOptions = ->
        logisticsInfo = @attr.orderForm.shippingData.logisticsInfo
        return "Logistics info must exist" if logisticsInfo?.length is 0
        return "No selected SLA" if logisticsInfo?[0].selectedSla is undefined
        return true

      #
      # Initialization
      #

      @after 'initialize', ->
        @attr.stateMachine = @createStateMachine() #from withShippingStateMachine
        @attr.stateMachine.start()
        require 'shipping/script/translation/' + @attr.locale, (translation) =>
          @extendTranslations(translation)
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