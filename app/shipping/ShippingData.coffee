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
        'shipping/mixin/withValidation',
        'link!shipping/css/main'],
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

        goToPaymentButtonSelector: '.btn-go-to-payment'
        editShippingDataSelector: '#edit-shipping-data'
        shippingTitleSelector: '.accordion-shipping-title'
        addressNotFilledSelector: '.address-not-filled-verification'

      # Render would be a deceptive name because it does not replace the entire
      # component DOM. Doing this would force us to re-render the child components.
      # It's best, then, to simply update the needed DOM.
      @updateView = ->
        require 'shipping/translation/' + @attr.locale, (translation) =>
          @extendTranslations(translation)
          if @attr.data.active
            @$node.addClass('active', 'visited')
            @select('editShippingDataSelector').hide()
            @select('goToPaymentButtonSelector').show()
            @select('shippingTitleSelector').addClass('accordion-toggle-active')
            @select('addressNotFilledSelector').hide()
            @updateValidationClass()
          else
            @$node.removeClass('active')
            @select('editShippingDataSelector').show()
            @select('goToPaymentButtonSelector').hide()
            @select('shippingTitleSelector').removeClass('accordion-toggle-active')
            if !@attr.orderForm.shippingData?.address?
              @select('addressNotFilledSelector').show()
            @clearValidationClass()

      @enable = ->
        @attr.data.active = true
        @updateView()

        if @attr.orderForm.shippingData?.address?
          @trigger('showAddressList.vtex')
        else
          @trigger('showAddressForm')

        @trigger('hideShippingSummary.vtex')

      @disable = ->
        @attr.data.active = false
        @updateView()

        @trigger('showShippingSummary.vtex')
        @trigger('hideAddressList.vtex')

      @commit = ->

      @revert = ->

      @update = =>

      @submit = =>
        console.log 'submit'

      @orderFormUpdated = (ev, orderForm) ->
        @attr.orderForm = orderForm
        @validate() # Trigger componentValidated event
        @updateView()

      # When a new addresses is selected
      # Should call API to get delivery options
      @onAddressSelected = (ev, addressObj) ->
        console.log (addressObj)

      @onPostalCodeLoaded = (ev, addressObj) ->
        console.log (addressObj)

      @goToPayment = ->
        console.log 'goToPayment'
        if (@isValid())
          console.log 'valid'
        else
          console.log 'invalid'

      # When a new addresses is saved
      @onAddressSaved = (ev, addressObj) ->
        # Do an AJAX to save in your API
        # When you're done, update with the new data
#        updated = false
#        for address in @attr.orderForm.shippingData.availableAddresses
#          if address.addressId is addressObj.addressId
#            address = _.extend(address, addressObj)
#            updated = true
#            break;
#
#        if not updated
#          @attr.orderForm.shippingData.availableAddresses.push(addressObj)
#
#        @attr.orderForm.shippingData.address = addressObj
#        @$node.trigger('updateAddresses', @attr.orderForm.shippingData)

      ###
      Validations
      ###

      @validateAddress = ->
        address = @attr.orderForm.shippingData?.address
        address isnt undefined

      @validateShippingOptions = ->
        logisticsInfo = @attr.orderForm.shippingData?.logisticsInfo
        logisticsInfo?.length > 0 and logisticsInfo?[0].selectedSla isnt undefined

      # Bind events
      @after 'initialize', ->
        require 'shipping/translation/' + @attr.locale, (translation) =>
          @extendTranslations(translation)
          dust.render template, @attr.data, (err, output) =>
            translatedOutput = $(output).i18n()
            @$node.html(translatedOutput)

            # Start the components
            ShippingSummary.attachTo('.shipping-summary-placeholder', { API: @attr.API })
            AddressForm.attachTo('.address-form-placeholder', { API: @attr.API })
            AddressList.attachTo('.address-list-placeholder', { API: @attr.API })
            ShippingOptions.attachTo('.address-shipping-options', { API: @attr.API })

            # Start event listeners
            @on 'newAddress', @onAddressSaved
            @on 'addressSelected', @onAddressSelected
            @on 'postalCode', @onPostalCodeLoaded
            @on window, 'orderFormUpdated.vtex', @orderFormUpdated
            @on window, 'enableShippingData.vtex', @enable
            @on window, 'disableShippingData.vtex', @disable
            @on 'click',
              'goToPaymentButtonSelector': @goToPayment
              'editShippingDataSelector': @enable

            @setValidators [
              @validateAddress
              @validateShippingOptions
            ]

            if vtexjs?.checkout?.orderForm?
              @orderFormUpdated null, vtexjs.checkout.orderForm

    return defineComponent(ShippingData, withi18n, withValidation)