define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/setup/extensions',
        'shipping/models/Address',
        'shipping/libs/state-machine.js'
        'shipping/component/AddressSearch',
        'shipping/component/AddressForm',
        'shipping/component/AddressList',
        'shipping/component/ShippingOptions',
        'shipping/component/ShippingSummary',
        'shipping/component/CountrySelect',
        'shipping/template/shippingData',
        'shipping/mixin/withi18n',
        'shipping/mixin/withValidation',
        'shipping/mixin/withShippingStateMachine',
        'link!shipping/css/shipping-data'],
  (defineComponent, extensions, Address, FSM, AddressSearch, AddressForm, AddressList, ShippingOptions, ShippingSummary, CountrySelect, template, withi18n, withValidation, withShippingStateMachine) ->
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
        shippingData = @attr.orderForm.shippingData ? {}
        @attr.data.deliveryCountries = _.uniq(_.reduceRight(shippingData.logisticsInfo, ((memo, l) ->
          return memo.concat(l.shipsTo)), []))
        country = @attr.orderForm.shippingData.address?.country ? @attr.data.deliveryCountries[0]
        @countrySelected(null, country).then =>
          if shippingData.address? # If a current address exists
            if @validateAddress() isnt true and @attr.stateMachine.can("invalidAddress")
              # If it's invalid, stop here and edit it
              @attr.stateMachine.invalidAddress(shippingData.address, shippingData.logisticsInfo, orderForm.items, orderForm.sellers)
            else if @attr.stateMachine.can("orderform")
              # If it's valid, show it on summary
              @attr.stateMachine.orderform(orderForm, @attr.data.countryRules[shippingData.address.country])
            else if @attr.stateMachine.current is 'summary'
              @select('shippingSummarySelector').trigger('enable.vtex', [shippingData, orderForm.items,
                                                                         orderForm.sellers, @attr.data.countryRules[shippingData.address.country]])
          @validate()

      #
      # External events handlers
      #

      @enable = ->
        try
          @attr.stateMachine.enable(@attr.orderForm)
        catch e
          console.log e

      @disable = ->
        # TODO Clear incomplete state, like editing address
        if @attr.stateMachine.can('submit') and @isValid()
          @attr.data.active = false
          @attr.API?.sendAttachment('shippingData', @attr.orderForm.shippingData)
          rules = @attr.data.countryRules[@attr.orderForm.shippingData.address?.country]
          @attr.stateMachine.submit(@attr.orderForm, rules)

      #
      # Events from children components
      #

      @done = ->
        @trigger('componentDone.vtex')

      # An address search has new results.
      # Should call API to get delivery options
      @addressSearchResult = (ev, address) ->
        console.log "address result", address
        @attr.stateMachine.doneSearch(address)

      # When a new addresses is selected
      @addressSelected = (ev, address) ->
        ev?.stopPropagation()
        @addressUpdated(ev, address)

      # The current address was updated, either selected or in edit
      @addressUpdated = (ev, address) ->
        ev.stopPropagation()
        @attr.orderForm.shippingData.address = address
        if address.isValid
          @select('goToPaymentButtonSelector').removeAttr('disabled')
          @select('shippingSummarySelector').trigger('addressSelected.vtex', [address])
        else
          @select('goToPaymentButtonSelector').attr('disabled', 'disabled')

      @addressKeysUpdated = (ev, addressKeyMap) ->
        if addressKeyMap.postalCode and addressKeyMap.postalCode.valid
          # When we start editing, we always start looking for shipping options
          console.log "Getting shipping options for address key", addressKeyMap.postalCode.value
          @select('shippingOptionsSelector').trigger('startLoadingShippingOptions.vtex')
          items = @attr.orderForm.items
          postalCode = addressKeyMap.postalCode.value
          country = @attr.orderForm.shippingData.address?.country ? @attr.data.country
          @attr.API?.simulateShipping(items, postalCode, country)
            .done( (simulation) =>
              # If we are editing and we received logistics info
              if @attr.stateMachine.can("doneSLA")
                @attr.stateMachine.doneSLA(null, simulation.logisticsInfo, @attr.orderForm.items, @attr.orderForm.sellers)
            )
            .fail( (reason) ->
              # TODO: handle simulation failure
              throw reason
            )
        else if addressKeyMap.geoCoordinates
          # TODO implementar com geoCoordinates
          console.log addressKeyMap, "Geo coordinates not implemented!"

      # User cleared address search key and must search again
      # addressSearch may be, for example, a new postal code
      @addressKeysInvalidated = (ev, addressKeyMap) ->
        if @attr.stateMachine.can('clearSearch')
          @attr.stateMachine.clearSearch(addressKeyMap.postalCode?.value)

      # User wants to edit or create an address
      @editAddress = (ev, address) ->
        if not @attr.orderForm.canEditData
          vtexIdOptions =
            returnUrl: window.location.href
            userEmail: vtexjs?.checkout?.orderForm?.clientProfileData?.email
            locale: @attr.locale
          return window.vtexid?.start(vtexIdOptions)

        ev?.stopPropagation()
        if (address and @attr.stateMachine.can('edit'))
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
        require 'shipping/rule/Country'+country, (countryRule) =>
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
        require 'shipping/translation/' + @attr.locale, (translation) =>
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