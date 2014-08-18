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
          showAddressList: true
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
      @render = ->
        data = @attr.data
        if not data.showAddressList
          @$node.html('')
        else
          require ['shipping/translation/' + @attr.locale, @attr.templates.list.template], (translation) =>
            @extendTranslations(translation)
            dust.render @attr.templates.list.name, data, (err, output) =>
              output = $(output).i18n()
              $(@$node).html(output)

      # Create a new address
      # Trigger an event to AddressForm component
      @createAddress = ->
        @attr.data.showAddressList = false
        @render()

        @attr.data.address = {}
        @attr.data.postalCode = ''
        @attr.data.labelShippingFields = false
        @attr.data.disableCityAndState = false
        @attr.data.address.addressId = (new Date().getTime() * -1).toString()
        @attr.data.showDontKnowPostalCode = true
        @$node.trigger 'showAddressForm', @attr.data

      # Edit an existing address
      # Trigger an event to AddressForm component
      @editAddress = ->
        if @attr.data.canEditData || @attr.data.loggedIn
          @attr.data.showAddressList = false
          @render()
          @attr.data.showDontKnowPostalCode = false
          @$node.trigger 'showAddressForm', @attr.data.address
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
          @attr.data.showAddressList = true

        countriesUsedRequire = _.map @attr.data.deliveryCountries, (c) ->
          return 'shipping/rule/Country'+c

        require countriesUsedRequire, =>
          for country, i in arguments
            prop = {}
            prop[@attr.data.deliveryCountries[i]] = new arguments[i]()
            @trigger window, 'newCountryRule', prop

          if @attr.data.hasOtherAddresses
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
            @render()
          else
            @createAddress()

      @createAddressesSummarys = ->
        countriesUsedRequire = _.map @attr.data.deliveryCountries, (c) ->
          return 'shipping/rule/Country'+c

        require countriesUsedRequire, =>
          for country, i in arguments
            prop = {}
            prop[@attr.data.deliveryCountries[i]] = new arguments[i]()
            @trigger window, 'newCountryRule', prop

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
        @$node.trigger 'addressSelected', @attr.data.address

        @attr.data.showAddressList = true
        @render()

      # Store new country rules in the data object
      @addCountryRule = (ev, data) ->
        _.extend(@attr.data.countryRules, data)

      @showAddressList = (ev, data) ->
        if @attr.data.availableAddresses.length > 0
          @attr.data.showAddressList = true
          @createAddressesSummarys()
          @render()

      @hideAddressList = (ev, data) ->
        @attr.data.showAddressList = false
        @render()

      @orderFormUpdated = (ev, data) ->
        if data.shippingData?
          @attr.data.address = data.shippingData.address
          @attr.data.deliveryCountries = @getDeliveryCountries(data.shippingData.logisticsInfo)
          @attr.data.availableAddresses = data.shippingData.availableAddresses
          @attr.data.canEditData = data.canEditData
          @attr.data.loggedIn = data.loggedIn

      # Bind events
      @after 'initialize', ->
        @on window, 'localeSelected.vtex', @localeUpdate
        @on window, 'newCountryRule', @addCountryRule
        @on window, 'updateAddresses', @updateAddresses
        @on window, 'addressFormCanceled', @showAddressList
        @on window, 'showAddressList.vtex', @showAddressList
        @on window, 'hideAddressList.vtex', @hideAddressList
        @on window, 'selectAddress', @selectAddress
        @on window, 'orderFormUpdated.vtex', @orderFormUpdated
        @on window, 'click',
          'createAddressSelector': @createAddress
          'addressItemSelector': @selectAddressHandler
          'editAddressSelector': @editAddress

        if vtexjs?.checkout?.orderForm?
          @orderFormUpdated null, vtexjs.checkout.orderForm

    return defineComponent(AddressList, withi18n)