define = vtex.define || window.define
require = vtex.require || window.require

define ['flight/lib/component', 'shipping/setup/extensions', 'shipping/component/AddressForm', 'shipping/component/AddressList',
        'shipping/component/ShippingOptions', 'shipping/component/ShippingSummary', 'link!shipping/css/main'],
  (defineComponent, extensions, AddressForm, AddressList, ShippingOptions, ShippingSummary) ->
    ShippingData = ->
      @defaultAttrs
        addressBookComponent: '.address-book'
        API: null
        data:
          orderForm: false
          isValid: false
        state:
          active: false
          visited: false
          loading: false
        goToPaymentBtn: ".btn-go-to-payment"
        editShippingData: "#edit-shipping-data"

      @enable = ->
        @attr.state.active = true
        $(".address-book").addClass("active");
        $('.shipping-data .btn-go-to-payment').show();
        $('#edit-shipping-data').hide();
        $(window).trigger("showShippingSummary.vtex", false);
        $(document).trigger("showAddressList.vtex");
        $(".accordion-shipping-title").addClass("accordion-toggle-active");
        $(".address-not-filled-verification").hide();

      @disable = ->
        @attr.state.active = false
        $(".address-book").removeClass("active");
        $('.shipping-data .btn-go-to-payment').hide();
        $('#edit-shipping-data').show();
        $(window).trigger("showShippingSummary.vtex", true);
        $(document).trigger("hideAddressList.vtex");
        $(".accordion-shipping-title").removeClass("accordion-toggle-active");
        if (!@attr.orderForm.shippingData?.address?)
          $(".address-not-filled-verification").show();

      @commit = ->

      @revert = ->

      @update = =>

      @submit = =>
        console.log "submit"

      @startModule = ->
        # Start the components
        AddressList.attachTo('.address-list-placeholder', { API: @attr.API })
        AddressForm.attachTo('.address-form-placeholder', { API: @attr.API })
        ShippingOptions.attachTo('.address-shipping-options', { API: @attr.API })
        ShippingSummary.attachTo('.shipping-summary-placeholder', { API: @attr.API })

        # Start event listeners
        @startEventListeners()

        # Make first API call
        @attr.API.getOrderForm();

      @orchestrate = ->
        # Update addresses
        if (@attr.orderForm.shippingData?.address?)
          addressData = @attr.orderForm.shippingData
          addressData.deliveryCountries = @getDeliveryCountries(addressData.logisticsInfo)
          $(@attr.addressBookComponent).trigger 'updateAddresses', addressData
          @enable()
        else
          $(".address-not-filled-verification").show();

        # Update shipping options
        if @attr.orderForm.shippingData and @attr.orderForm.sellers
          $(@attr.addressBookComponent).trigger 'updateShippingOptions'
          @enable()

      @getDeliveryCountries = (logisticsInfo) =>
        return _.uniq(_.reduceRight(logisticsInfo, (memo, l) ->
          return memo.concat(l.shipsTo)
        , []))

      @orderFormUpdated = (evt, orderForm) ->
        @attr.orderForm = orderForm
        @orchestrate()

      # When a new addresses is selected
      # Should call API to get delivery options
      @onAddressSelected = (evt, addressObj) ->
        console.log (addressObj)

      @onPostalCodeLoaded = (ev, addressObj) ->
        console.log (addressObj)

      @validate = ->
        return @attr.data.isValid = false;

      @goToPayment = () ->
        console.log "goToPayment"
        if (@validate())
          console.log "valid"
        else
          console.log "invalid"

      # When a new addresses is saved
      @onAddressSaved = (evt, addressObj) ->
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
#        $(@attr.addressBookComponent).trigger('updateAddresses', @attr.orderForm.shippingData)

      @startEventListeners = ->
        @on @attr.addressBookComponent, 'newAddress', @onAddressSaved
        @on @attr.addressBookComponent, 'addressSelected', @onAddressSelected
        @on @attr.addressBookComponent, 'postalCode', @onPostalCodeLoaded
        @on window, 'orderFormUpdated.vtex', @orderFormUpdated
        @on window, 'enableShippingData.vtex', @enable
        @on window, 'disableShippingData.vtex', @disable
        @on document, 'click',
          'goToPaymentBtn': @goToPayment
          'editShippingData': @enable

      # Bind events
      @after 'initialize', ->
        @startModule()

    return defineComponent(ShippingData)