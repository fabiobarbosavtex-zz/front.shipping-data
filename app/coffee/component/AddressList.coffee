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

      templates: {}

      createAddressSelector: '.address-create'
      editAddressSelector: '.address-edit'
      addressItemSelector: '.address-list .address-item'
      submitButtonSelector: '.submit .btn-success'

    @render = (data) ->
      data = @attr.data if not data
      if not data.showAddressList
        @$node.html('')
      else
        @attr.templates.addressListTemplate.then =>
          dust.render 'addressList', data, (err, output) =>
            output = $(output).i18n()
            $(@$node).html(output)

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

    @editAddress = ->
      @attr.data.showAddressList = false
      @render(@attr.data)

      @attr.data.showDontKnowPostalCode = false
      @$node.trigger 'showAddressForm', @attr.data

    @updateAddresses = (ev, data) ->
      @attr.data.address = data.address
      @attr.data.availableAddresses = data.availableAddresses

      for aa in @attr.data.availableAddresses
        aa.firstPart = '' + aa.street
        aa.firstPart += ', ' + aa.number
        aa.firstPart += ', ' + aa.complement if aa.complement
        aa.firstPart += ', ' + aa.reference if aa.reference
        aa.secondPart = '' + aa.city
        aa.secondPart += ' - ' + aa.state
        aa.secondPart += ' - ' + aa.country
        aa.summary = '' + aa.street
        aa.summary += ' - ' + aa.postalCode if aa.postalCode

      if _.isEmpty(@attr.data.address)
        @attr.data.hasOtherAddresses = false
        @createAddress()
      else
        @attr.data.selectedAddressId = data.address.addressId
        @attr.data.hasOtherAddresses = true
        @attr.data.showAddressList = true
        @render()

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

    @after 'initialize', ->
      @on document, 'updateAddresses', @updateAddresses
      @on document, 'selectAddress', @selectAddress
      @on document, 'click',
        'forceShippingFieldsSelector': @forceShippingFields
        'createAddressSelector': @createAddress
        'addressItemSelector': @selectAddress
        'editAddressSelector': @editAddress

      @on 'keyup',
        postalCodeSelector: @validatePostalCode

      @attr.templates['addressListTemplate'] = vtex.
        require('template/addressList')