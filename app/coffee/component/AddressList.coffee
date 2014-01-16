define = window.define or window.vtex.define

define ->
  AddressList = flight.component ->
    @defaultAttrs
      data:
        address: {}
        availableAddresses: []
        selectedAddressId: ''
        hasOtherAddresses: false
        showAddressList: true
        deliveryCountries: ['ARG', 'BRA', 'CHL', 'COL', 'ECU', 'URY','USA']
        countryRules: {}

      templates:
        list:
          name: 'addressList'

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
        @attr.templates.list.template.then =>
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
      @$node.trigger 'showAddressForm', @attr.data

    # Update address list
    @updateAddresses = (ev, data) ->
      @$node.trigger 'cancelAddressForm', true
      @attr.data.address = data.address
      @attr.data.availableAddresses = data.availableAddresses

      countriesUsed = []
      for aa in @attr.data.availableAddresses
        countriesUsed.push(aa.country)

      if _.isEmpty(@attr.data.address)
        @attr.data.hasOtherAddresses = false
        @createAddress()
      else
        @attr.data.selectedAddressId = data.address.addressId
        @attr.data.hasOtherAddresses = true
        @attr.data.showAddressList = true

      countriesUsedRequire = _.map countriesUsed, (c) ->
        return 'countries/Country'+c

      vtex.require(countriesUsedRequire).then =>
        for country, i in arguments
          prop = {}
          prop[countriesUsed[i]] = new arguments[i]()
          @trigger document, 'newCountryRule', prop

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
          aa.secondPart += ' - ' + i18n.t("countries."+aa.country)
        @render()

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

    # Bind events
    @after 'initialize', ->
      @on document, 'newCountryRule', @addCountryRule
      @on document, 'updateAddresses', @updateAddresses
      @on document, 'selectAddress', @selectAddress
      @on document, 'click',
        'forceShippingFieldsSelector': @forceShippingFields
        'createAddressSelector': @createAddress
        'addressItemSelector': @selectAddress
        'editAddressSelector': @editAddress

      @on 'keyup',
        postalCodeSelector: @validatePostalCode

      @attr.templates.list['template'] = vtex.
        require('template/'+@attr.templates.list.name)