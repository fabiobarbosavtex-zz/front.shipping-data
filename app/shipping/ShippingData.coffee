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
        'link!shipping/css/main'],
  (defineComponent, extensions, AddressForm, AddressList, ShippingOptions, ShippingSummary, template, withi18n) ->
    ShippingData = ->
      @defaultAttrs
        API: null

        data:
          orderForm: false
          isValid: false

        state:
          active: false
          visited: false
          loading: false

        goToPaymentBtnSelector: ".btn-go-to-payment"
        editShippingDataSelector: "#edit-shipping-data"

      @enable = ->
        @attr.state.active = true
        @$node.addClass("active", "visited")
        $('.btn-go-to-payment', @$node).show()
        $('#edit-shipping-data').hide()
        $(window).trigger("showShippingSummary.vtex", false)
        $(window).trigger("showAddressList.vtex")
        $(".accordion-shipping-title").addClass("accordion-toggle-active")
        $(".address-not-filled-verification").hide()

      @disable = ->
        @attr.state.active = false
        @$node.removeClass("active")
        $('.btn-go-to-payment', @$node).hide()
        $('#edit-shipping-data').show()
        $(window).trigger("showShippingSummary.vtex", true)
        $(window).trigger("hideAddressList.vtex")
        $(".accordion-shipping-title").removeClass("accordion-toggle-active")
        if !@attr.orderForm.shippingData?.address?
          $(".address-not-filled-verification").show()

      @commit = ->

      @revert = ->

      @update = =>

      @submit = =>
        console.log "submit"

      @render = ->
        require 'shipping/translation/' + @attr.locale, (translation) =>
          @extendTranslations(translation)
          # Only render parts not controlled by children components
          dust.render template, @attr.data, (err, output) =>
            translatedOutput = $(output).i18n()
            $(".accordion-heading", @$node).html($(".accordion-heading", translatedOutput))
            $(".address-not-filled-verification", @$node).html($(".address-not-filled-verification", translatedOutput))
            $(".shipping-summary-placeholder", @$node).html($(".shipping-summary-placeholder", translatedOutput))
            $(".btn-submit-wrapper", @$node).html($(".btn-submit-wrapper", translatedOutput))

      @getDeliveryCountries = (logisticsInfo) =>
        return _.uniq(_.reduceRight(logisticsInfo, (memo, l) ->
          return memo.concat(l.shipsTo)
        , []))

      @orderFormUpdated = (ev, orderForm) ->
        @attr.orderForm = orderForm

        # Update addresses
        if (@attr.orderForm.shippingData?.address?)
          addressData = @attr.orderForm.shippingData
          addressData.deliveryCountries = @getDeliveryCountries(addressData.logisticsInfo)
          @$node.trigger 'updateAddresses', addressData
        else
          $(".address-not-filled-verification").show();

        # Update shipping options
        if @attr.orderForm.shippingData and @attr.orderForm.sellers
          @$node.trigger 'updateShippingOptions'

      # When a new addresses is selected
      # Should call API to get delivery options
      @onAddressSelected = (ev, addressObj) ->
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

      # Bind events
      @after 'initialize', ->
        require 'shipping/translation/' + @attr.locale, (translation) =>
          @extendTranslations(translation)
          dust.render template, @attr.data, (err, output) =>
            translatedOutput = $(output).i18n()
            @$node.html(translatedOutput)

            # Start the components
            AddressList.attachTo('.address-list-placeholder', { API: @attr.API })
            AddressForm.attachTo('.address-form-placeholder', { API: @attr.API })
            ShippingOptions.attachTo('.address-shipping-options', { API: @attr.API })
            ShippingSummary.attachTo('.shipping-summary-placeholder', { API: @attr.API })

            # Start event listeners
            @on @$node, 'newAddress', @onAddressSaved
            @on @$node, 'addressSelected', @onAddressSelected
            @on @$node, 'postalCode', @onPostalCodeLoaded
            @on window, 'orderFormUpdated.vtex', @orderFormUpdated
            @on window, 'enableShippingData.vtex', @enable
            @on window, 'disableShippingData.vtex', @disable
            @on 'click',
              'goToPaymentBtnSelector': @goToPayment
              'editShippingDataSelector': @enable

            if vtexjs.checkout.orderForm?
              @orderFormUpdated null, vtexjs.checkout.orderForm

    return defineComponent(ShippingData, withi18n)