define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/script/setup/extensions',
        'shipping/script/mixin/withi18n',
        'shipping/templates/addressList'],
  (defineComponent, extensions, withi18n, template) ->
    AddressList = ->
      @defaultAttrs
        data:
          address: {}
          availableAddresses: []
          selectedAddressId: ''
          hasOtherAddresses: false
          canEditData: false
          loggedIn: false
          deliveryCountries: ['BRA', 'ARG', 'CHL']
          countryRules: {}

        createAddressSelector: '.address-create'
        editAddressSelector: '.address-edit'
        addressItemSelector: '.address-list .address-item'
        submitButtonSelector: '.submit .btn-success'

      # Render this component according to the data object
      @render = (data) ->
        data = @attr.data if not data

        require ['shipping/script/translation/' + @attr.locale], (translation) =>
          @extendTranslations(translation)
          dust.render template, data, (err, output) =>
            output = $(output).i18n()
            $(@$node).html(output)

      # Create a new address
      # Trigger an event to AddressForm component
      @createAddress = ->
        @trigger('editAddress.vtex')

      # Edit an existing address
      # Trigger an event to AddressForm component
      @editAddress = ->
        @attr.data.showDontKnowPostalCode = false
        @trigger('editAddress.vtex', @attr.data.address)

      @createAddressesSummaries = ->
        countriesUsedRequire = _.map @attr.data.deliveryCountries, (c) ->
          return 'shipping/script/rule/Country'+c

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
              if @attr.data.countryRules[aa.country]?.usePostalCode
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

      @enable = (ev, deliveryCountries, shippingData) ->
        if ev then ev.stopPropagation()
        @attr.data.deliveryCountries = deliveryCountries
        @attr.data.address = shippingData.address
        @attr.data.availableAddresses = shippingData.availableAddresses
        @attr.data.selectedAddressId = shippingData.address?.addressId

        if @attr.data.availableAddresses.length > 0
          @createAddressesSummaries()
          @render()

      @disable = (ev) ->
        if ev then ev.stopPropagation()
        @$node.html('')

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on 'click',
          'createAddressSelector': @createAddress
          'addressItemSelector': @selectAddressHandler
          'editAddressSelector': @editAddress

    return defineComponent(AddressList, withi18n)