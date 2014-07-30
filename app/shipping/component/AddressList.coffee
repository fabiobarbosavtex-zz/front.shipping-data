define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component', 'shipping/setup/extensions'],
  (defineComponent, extensions) ->
    AddressList = ->
      @defaultAttrs
        API: null
        data:
          address: {}
          availableAddresses: []
          selectedAddressId: ''
          hasOtherAddresses: false
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
      @render = (data) ->
        data = @attr.data if not data
        if not data.showAddressList
          @$node.html('')
        else
          require [@attr.templates.list.template], =>
            dust.render @attr.templates.list.name, data, (err, output) =>
              output = $(output).i18n()
              $(@$node).html(output)

      # Create a new address
      # Trigger an event to AddressForm component
      @createAddress = ->
        @attr.data.showAddressList = false
        @render(@attr.data)

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
        @attr.data.showAddressList = false
        @render(@attr.data)

        @attr.data.showDontKnowPostalCode = false
        @$node.trigger 'showAddressForm', @attr.data.address

      # Update address list
      @updateAddresses = (ev, data) ->
        # First, check which countries the store deliveries
        if data?.deliveryCountries?.length > 0
          @attr.data.deliveryCountries = data.deliveryCountries

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
            @trigger document, 'newCountryRule', prop

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

      # Handle selection of an address in the list
      @selectAddress = (ev, data) ->
        selectedAddressId = undefined

        if ev.type is 'click'
          selectedAddressId = $('input', data.el).attr('value')
        else
          selectedAddressId = data

        wantedAddress = _.find @attr.data.availableAddresses, (a) ->
          a.addressId is selectedAddressId
        @attr.data.address = wantedAddress

        @attr.data.selectedAddressId = selectedAddressId
        @$node.trigger 'addressSelected', @attr.data.address

        @attr.data.showAddressList = true
        @render(@attr.data)

        ev.preventDefault()

      # Store new country rules in the data object
      @addCountryRule = (ev, data) ->
        _.extend(@attr.data.countryRules, data)

      @showAddressList = (ev, data) ->
        return if @attr.data.showAddressList
        @attr.data.showAddressList = true
        @render(@attr.data)

      @hideAddressList = (evt, data) ->
        @attr.data.showAddressList = false
        @render(@attr.data)


      # Bind events
      @after 'initialize', ->
        @on document, 'newCountryRule', @addCountryRule
        @on document, 'updateAddresses', @updateAddresses
        @on document, 'addressFormCanceled', @showAddressList
        @on document, 'showAddressList.vtex', @showAddressList
        @on document, 'hideAddressList.vtex', @hideAddressList
        @on document, 'selectAddress', @selectAddress
        @on document, 'click',
          'createAddressSelector': @createAddress
          'addressItemSelector': @selectAddress
          'editAddressSelector': @editAddress
        @on document, 'dblclick',
          'addressItemSelector': @editAddress
        return
    return defineComponent(AddressList)