define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component', 'shipping/setup/extensions', 'shipping/mixin/withi18n'],
  (defineComponent, extensions, withi18n) ->
    AddressList = ->
      @defaultAttrs
        API: null
        data:
          address: {}
          availableAddresses: []
          selectedAddressId: ''
          hasOtherAddresses: false
          canEditData: false
          loggedIn: false
          deliveryCountries: ['BRA', 'ARG', 'CHL']
          countryRules: {}

        templates:
          list:
            name: 'addressList'
            template: 'shipping/template/addressList'

        createAddressSelector: '.address-create'
        editAddressSelector: '.address-edit'
        addressItemSelector: '.address-list .address-item'
        submitButtonSelector: '.submit .btn-success'

      # Render this component according to the data object
      @render = (data) ->
        data = @attr.data if not data

        require ['shipping/translation/' + @attr.locale, @attr.templates.list.template], (translation) =>
          @extendTranslations(translation)
          dust.render @attr.templates.list.name, data, (err, output) =>
            output = $(output).i18n()
            $(@$node).html(output)

      # Create a new address
      # Trigger an event to AddressForm component
      @createAddress = ->
        if @attr.data.canEditData or @attr.data.loggedIn
          @disable()

          @attr.data.address = {}
          @attr.data.postalCode = ''
          @attr.data.labelShippingFields = false
          @attr.data.disableCityAndState = false
          @attr.data.address.addressId = (new Date().getTime() * -1).toString()
          @attr.data.showDontKnowPostalCode = true
          @trigger('showAddressForm.vtex', @attr.data)
        else
          # CALL VTEX ID
          if window.vtexid? then window.vtexid.start(window.location.href)

      # Edit an existing address
      # Trigger an event to AddressForm component
      @editAddress = ->
        if @attr.data.canEditData or @attr.data.loggedIn
          @disable()
          @attr.data.showDontKnowPostalCode = false
          @trigger('showAddressForm.vtex', @attr.data.address)
        else
          # CALL VTEX ID
          if window.vtexid? then window.vtexid.start(window.location.href)

      @getDeliveryCountries = (logisticsInfo) =>
        return _.uniq(_.reduceRight(logisticsInfo, (memo, l) ->
          return memo.concat(l.shipsTo)
        , []))

      # Update address list
      @updateAddresses = (ev, data) ->
        # Remove all the addresses located in countries the store is not
        # delivering
        @attr.data.availableAddresses = _.filter data?.availableAddresses, (a) =>
          return a.country in @attr.data.deliveryCountries

        if @attr.data.availableAddresses.length is 0
          # The user has no addresses yet
          @attr.data.hasOtherAddresses = false
        else
          @attr.data.address = data.address
          @attr.data.selectedAddressId = data.address.addressId
          @attr.data.hasOtherAddresses = true

        @createAddressesSummaries()

      @createAddressesSummaries = ->
        countriesUsedRequire = _.map @attr.data.deliveryCountries, (c) ->
          return 'shipping/rule/Country'+c

        require countriesUsedRequire, =>
          for country, i in arguments
            prop = {}
            prop[@attr.data.deliveryCountries[i]] = new arguments[i]()
            @trigger window, 'newCountryRule', prop
            @addCountryRule prop

            for aa in @attr.data.availableAddresses
              aa.firstPart = '' + aa.street
              aa.firstPart += ', ' + aa.complement if aa.complement
              aa.firstPart += ', ' + aa.number if aa.number
              aa.firstPart += ', ' + aa.neighborhood if aa.neighborhood
              aa.firstPart += ', ' + aa.reference if aa.reference
              aa.secondPart = '' + aa.city
              aa.secondPart += ' - ' + aa.state
              if @attr.data.countryRules[aa.country].usePostalCode
                aa.secondPart += ' - ' + aa.postalCode
              aa.secondPart += ' - ' + i18n.t('countries.'+aa.country)

      # Handle selection of an address in the list
      @selectAddressHandler = (ev, data) ->
        ev.preventDefault()
        @selectAddress($('input', data.el).attr('value'))

      @selectAddress = (selectedAddressId) ->
        wantedAddress = _.find @attr.data.availableAddresses, (a) ->
          a.addressId is selectedAddressId
        @attr.data.address = wantedAddress

        @attr.data.selectedAddressId = selectedAddressId
        @trigger 'addressSelected.vtex', @attr.data.address

        @render()

      # Store new country rules in the data object
      @addCountryRule = (data) ->
        _.extend(@attr.data.countryRules, data)

      @enable = (ev) ->
        if ev then ev.stopPropagation()
        if @attr.data.availableAddresses.length > 0
          @createAddressesSummaries()
          @render()

      @disable = (ev) ->
        if ev then ev.stopPropagation()
        @$node.html('')

      @orderFormUpdated = (ev, data) ->
        if data.shippingData?
          @attr.data.address = data.shippingData.address
          @attr.data.deliveryCountries = @getDeliveryCountries(data.shippingData.logisticsInfo)
          @attr.data.availableAddresses = data.shippingData.availableAddresses
          @attr.data.selectedAddressId = data.shippingData.address?.addressId
          @attr.data.canEditData = data.canEditData
          @attr.data.loggedIn = data.loggedIn
          #@updateAddresses(null, @attr.data)

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on window, 'localeSelected.vtex', @localeUpdate
        @on window, 'orderFormUpdated.vtex', @orderFormUpdated
        @on window, 'addressFormCanceled.vtex', @enable
        @on 'updateAddresses.vtex', @updateAddresses
        @on 'selectAddress.vtex', @selectAddress
        @on 'click',
          'createAddressSelector': @createAddress
          'addressItemSelector': @selectAddressHandler
          'editAddressSelector': @editAddress

        if vtexjs?.checkout?.orderForm?
          @orderFormUpdated null, vtexjs.checkout.orderForm

    return defineComponent(AddressList, withi18n)