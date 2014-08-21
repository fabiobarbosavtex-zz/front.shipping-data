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
        'shipping/mixin/withValidation'],
  (defineComponent, extensions, AddressForm, AddressList, ShippingOptions, ShippingSummary, template, withi18n, withValidation) ->
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
          addressForm: [false]
          shippingOptions: [false]

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
          if not @validateAddress()
            @editAddress(null, @attr.orderForm.shippingData.address)
            if @attr.orderForm.shippingData.logisticsInfo.length > 0
              @select('shippingOptionsSelector').trigger('enable.vtex')
          else
            @showAddressListAndShippingOption()

          @extendTranslations(translation)
          if @attr.data.active
            @select('shippingStepSelector').addClass('active', 'visited')
            @select('editShippingDataSelector').hide()
            @select('shippingTitleSelector').addClass('accordion-toggle-active')
            @select('addressNotFilledSelector').hide()
            if @attr.orderForm?.shippingData?.address?.postalCode
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

      @enable = ->
        @attr.data.active = true
        @updateView()

      @disable = ->
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
        @attr.orderForm = orderForm
        @updateView()

      # When a new addresses is selected
      # Should call API to get delivery options
      @addressSelected = (ev, addressObj) ->
        @attr.orderForm.shippingData.address = addressObj
        @attr.orderForm.shippingData.logisticsInfo = null
        @shippingDataSubmitHandler(@attr.orderForm.shippingData)
        @select('shippingOptionsSelector').trigger('startLoadingShippingOptions.vtex')

      @validateAddress = ->
        @attr.validationResults.addressForm.length is 0

      @validateShippingOptions = ->
        @attr.validationResults.shippingOptions.length is 0

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
        @select('shippingOptionsSelector').trigger('disable.vtex')

      @showAddressListAndShippingOption = (ev) ->
        ev?.stopPropagation()
        @select('shippingSummarySelector').trigger('disable.vtex')
        @select('addressListSelector').trigger('enable.vtex')
        @select('addressFormSelector').trigger('disable.vtex')
        @select('shippingOptionsSelector').trigger('enable.vtex')

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
            @on window, 'orderFormUpdated.vtex', @orderFormUpdated
            @on 'showAddressList.vtex', @showAddressListAndShippingOption
            @on 'editAddress.vtex', @editAddress
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

            if vtexjs?.checkout?.orderForm?
              @orderFormUpdated null, vtexjs.checkout.orderForm

    return defineComponent(ShippingData, withi18n, withValidation)