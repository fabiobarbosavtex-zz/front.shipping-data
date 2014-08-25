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
        'shipping/template/shippingData',
        'shipping/mixin/withi18n',
        'shipping/mixin/withValidation',
        'shipping/mixin/withShippingStateMachine',
        'link!shipping/css/shipping-data'],
  (defineComponent, extensions, Address, FSM, AddressSearch, AddressForm, AddressList, ShippingOptions, ShippingSummary, template, withi18n, withValidation, withShippingStateMachine) ->
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
          @validate()
          if shippingData.address? and @attr.stateMachine.can("orderform")
            @attr.stateMachine.orderform(shippingData)
          if shippingData.logisticsInfo? and shippingData.logisticsInfo.length > 0 and @attr.stateMachine.can("doneSLA")
            @attr.stateMachine.doneSLA(shippingData.logisticsInfo, orderForm.items, orderForm.sellers)

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
          @trigger('componentDone.vtex')
          API.sendAttachment('shippingData', @attr.orderForm.shippingData)
          @attr.stateMachine.submit()

      #
      # Events from children components
      #

      # An address search has new results.
      # Should call API to get delivery options
      @addressSearchResult = (ev, address) ->
        console.log "address result", address
        @attr.stateMachine.doneSearch(address)

      # When a new addresses is selected
      @addressSelected = (ev, address) ->
        ev?.stopPropagation()
        @attr.orderForm.shippingData.logisticsInfo = null
        @addressUpdated(ev, address)

      # The current address was updated, either selected or in edit
      @addressUpdated = (ev, address) ->
        ev.stopPropagation()
        @attr.orderForm.shippingData.address = address
        if address.isValid
          @select('goToPaymentButtonSelector').removeAttr('disabled')
          @select('shippingSummarySelector').trigger('addressUpdated.vtex', address)
        else
          @select('goToPaymentButtonSelector').attr('disabled', 'disabled')

      # User wants to edit or create an address
      @editAddress = (ev, address) ->
        return window.vtexid?.start(window.location.href) unless @attr.orderForm.canEditData

        ev?.stopPropagation()
        if (address and @attr.stateMachine.can('edit'))
          @attr.stateMachine.edit(address)
        else if @attr.stateMachine.can('new')
          @attr.stateMachine.new()

      # User cleared address search key and must search again
      @clearAddressSearch = (ev) ->
        if @attr.stateMachine.can('clearSearch')
          @attr.stateMachine.clearSearch()

      # User cancelled ongoing address edit
      @cancelAddressEdit = (ev) ->
        ev?.stopPropagation()
        if @attr.stateMachine.can('cancelNew')
          @attr.stateMachine.cancelNew()
        if @attr.stateMachine.can('cancelEdit')
          @attr.stateMachine.cancelEdit()

      # User chose shipping options
      @deliverySelected = (ev, logisticsInfo) ->
        ev.stopPropagation()
        @attr.orderForm.shippingData.logisticsInfo = logisticsInfo
        @select('shippingSummarySelector').trigger('deliverySelected.vtex', logisticsInfo)

      @countrySelected = (ev, country) ->
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
        currentAddress = new Address(@attr.orderForm.shippingData.address, @attr.data.deliveryCountries)
        return currentAddress.validate(@attr.data.countryRules[currentAddress.country])

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
            @on 'clearAddressSearch.vtex', @clearAddressSearch
            @on 'cancelAddressEdit.vtex', @cancelAddressEdit
            @on 'editAddress.vtex', @editAddress
            @on 'deliverySelected.vtex', @deliverySelected
            @on 'countrySelected.vtex', @countrySelected
            @on 'click',
              'goToPaymentButtonSelector': @disable
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