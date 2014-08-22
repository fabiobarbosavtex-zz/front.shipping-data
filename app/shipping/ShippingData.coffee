define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/setup/extensions',
        'shipping/component/AddressForm',
        'shipping/component/AddressList',
        'shipping/component/ShippingOptions',
        'shipping/component/ShippingSummary',
        'shipping/template/shippingData',
        'shipping/mixin/withi18n',
        'shipping/mixin/withOrderForm',
        'shipping/mixin/withValidation'],
  (defineComponent, extensions, AddressForm, AddressList, ShippingOptions, ShippingSummary, template, withi18n, withOrderForm, withValidation) ->
    ShippingData = ->
      @defaultAttrs
        API: null
        orderForm: false
        data:
          valid: false
          active: false
          visited: false
          loading: false

        validationResults: # starts as invalid
          addressForm: [new Error("not validated")]
          shippingOptions: [new Error("not validated")]

        stateMachine: StateMachine.create
          initial: 'empty',
          events: [
            name: 'orderForm',  from: 'empty',   to: 'summary'
            name: 'enable',     from: 'empty',   to: 'search'
            name: 'enable',     from: 'summary', to: 'list'
            name: 'failSearch', from: 'search',  to: 'search'
            name: 'doneSearch', from: 'search',  to: 'edit'
            name: 'doneSLA',    from: 'edit',    to: 'editSLA'
            name: 'submit',     from: 'editSLA', to: 'summary'
            name: 'submit',     from: 'list',    to: 'summary'
            name: 'select',     from: 'list',    to: 'list'
            name: 'edit',       from: 'list',    to: 'editSLA'
            name: 'cancelEdit', from: 'editSLA', to: 'list'
            name: 'new',        from: 'list',    to: 'search'
            name: 'cancelNew',  from: 'search',  to: 'list' # only if available addresses > 0
          ]

        goToPaymentButtonSelector: '.btn-go-to-payment'
        editShippingDataSelector: '#edit-shipping-data'
        shippingTitleSelector: '.accordion-shipping-title'
        addressNotFilledSelector: '.address-not-filled-verification'
        shippingStepSelector: '.step'

        shippingSummarySelector: '.shipping-summary-placeholder'
        addressFormSelector: '.address-form-placeholder'
        addressListSelector: '.address-list-placeholder'
        shippingOptionsSelector: '.address-shipping-options'

      # Render would be a deceptive name because it does not replace the entire
      # component DOM. Doing this would force us to re-render the child components.
      # It's best, then, to simply update the needed DOM.
      @updateView = ->
        require 'shipping/translation/' + @attr.locale, (translation) =>
          @extendTranslations(translation)
          if @attr.data.active
            @select('shippingStepSelector').addClass('active', 'visited')
            @select('editShippingDataSelector').hide()
            @select('shippingTitleSelector').addClass('accordion-toggle-active')
            @select('addressNotFilledSelector').hide()
            if @isValid()
              @select('goToPaymentButtonSelector').show()
            else
              @select('goToPaymentButtonSelector').hide()
            @updateValidationClass()
          else
            @select('shippingStepSelector').removeClass('active')
            @select('editShippingDataSelector').show()
            @select('goToPaymentButtonSelector').hide()
            @select('shippingTitleSelector').removeClass('accordion-toggle-active')
            if @attr.orderForm.shippingData?.address
              @select('addressNotFilledSelector').hide()
            else
              @select('addressNotFilledSelector').show()
            @clearValidationClass()

      @updateComponentView = ->
        if @attr.data.active
          if @attr.validationResults.addressForm.length > 0 # Address isnt valid
            @editAddress(null, @attr.orderForm.shippingData.address)
            if @attr.validationResults.shippingOptions.length is 0 # Shipping options is valid
              @select('shippingOptionsSelector').trigger('enable.vtex')
          else
            @showAddressListAndShippingOption()

      @enable = ->
        @attr.data.active = true
        @updateView()
        @updateComponentView()

      @disable = ->
        @select('shippingSummarySelector').trigger('addressUpdated.vtex', @attr.orderForm.shippingData.address)
        @select('shippingSummarySelector').trigger('enable.vtex')
        @select('addressFormSelector').trigger('disable.vtex')
        @select('addressListSelector').trigger('disable.vtex')
        @select('shippingOptionsSelector').trigger('disable.vtex')
        @attr.data.active = false
        @trigger('componentDone.vtex')
        @updateView()
        if @isValid()
          @shippingDataSubmitHandler(@attr.orderForm.shippingData)

      # Handler do envio de ShippingData.
      @shippingDataSubmitHandler = (shippingData) ->
        # Montando dados para send attachment
        attachmentId = 'shippingData'
        attachment = shippingData
        API.sendAttachment(attachmentId, attachment)

      @orderFormUpdated = (ev, orderForm) ->
        @attr.orderForm = _.clone orderForm
        @updateView()
        @updateComponentView()

      # When a new addresses is selected
      # Should call API to get delivery options
      @addressSelected = (ev, address) ->
        ev?.stopPropagation()
        @attr.orderForm.shippingData.logisticsInfo = null
        @addressUpdated(ev, address)
        if address.isValid
          @shippingDataSubmitHandler(@attr.orderForm.shippingData)
          @select('shippingOptionsSelector').trigger('startLoadingShippingOptions.vtex')

      @addressUpdated = (ev, address) ->
        ev.stopPropagation()
        @attr.orderForm.shippingData.address = address
        @updateView()

      @validateAddress = ->
        if @attr.validationResults.addressForm.length > 0
          return "Address invalid"
        return true

      @validateShippingOptions = ->
        if @attr.validationResults.shippingOptions.length >0
          return "Shipping options invalid"
        return true

      @handleAddressValidation = (ev, results) ->
        ev?.stopPropagation()
        @attr.validationResults.addressForm = results
        @validate()

      @handleShippingOptionsValidation = (ev, results) ->
        ev?.stopPropagation()
        @attr.validationResults.shippingOptions = results
        @validate()

      @clearSelectedAddress = (ev) ->
        ev.stopPropagation()
        @select('shippingOptionsSelector').trigger('disable.vtex')

      @editAddress = (ev, data) ->
        ev?.stopPropagation()
        @select('shippingSummarySelector').trigger('disable.vtex')
        @select('addressListSelector').trigger('disable.vtex')
        @select('addressFormSelector').trigger('enable.vtex', data)
        if @attr.validationResults.addressForm.length > 0 # Address isnt valid
          @select('shippingOptionsSelector').trigger('disable.vtex')
        else
          @select('shippingOptionsSelector').trigger('enable.vtex')

      @showAddressListAndShippingOption = (ev) ->
        ev?.stopPropagation()
        @select('shippingSummarySelector').trigger('disable.vtex')
        @select('addressListSelector').trigger('enable.vtex')
        @select('addressFormSelector').trigger('disable.vtex')
        @select('shippingOptionsSelector').trigger('enable.vtex')

      @shippingOptionsUpdated = (ev, logisticsInfo) ->
        ev.stopPropagation()
        @attr.orderForm.shippingData.logisticsInfo = logisticsInfo
        @updateView()

      # Bind events
      @after 'initialize', ->
        require 'shipping/translation/' + @attr.locale, (translation) =>
          @extendTranslations(translation)
          dust.render template, @attr.data, (err, output) =>
            translatedOutput = $(output).i18n()
            @$node.html(translatedOutput)

            # Start the components
            ShippingSummary.attachTo(@attr.shippingSummarySelector, { API: @attr.API })
            AddressForm.attachTo(@attr.addressFormSelector, { API: @attr.API })
            AddressList.attachTo(@attr.addressListSelector, { API: @attr.API })
            ShippingOptions.attachTo(@attr.shippingOptionsSelector, { API: @attr.API })

            # Start event listeners
            @on 'enable.vtex', @enable
            @on 'disable.vtex', @disable
            @on 'addressSelected.vtex', @addressSelected
            @on 'addressUpdated.vtex', @addressUpdated
            @on 'showAddressList.vtex', @showAddressListAndShippingOption
            @on 'editAddress.vtex', @editAddress
            @on 'currentShippingOptions.vtex', @shippingOptionsUpdated
            @on 'clearSelectedAddress.vtex', @clearSelectedAddress
            @on @attr.addressFormSelector, 'componentValidated.vtex', @handleAddressValidation
            @on @attr.shippingOptionsSelector, 'componentValidated.vtex', @handleShippingOptionsValidation
            @on 'click',
              'goToPaymentButtonSelector': @disable
              'editShippingDataSelector': @enable

            @setValidators [
              @validateAddress
              @validateShippingOptions
            ]

    return defineComponent(ShippingData, withi18n, withValidation, withOrderForm)