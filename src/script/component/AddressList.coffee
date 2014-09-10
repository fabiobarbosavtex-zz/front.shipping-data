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
          deliveryCountries: ['BRA', 'ARG', 'CHL']
          countryRules: {}

        createAddressSelector: '.address-create'
        editAddressSelector: '.address-edit'
        addressItemSelector: '.address-list .address-item'
        submitButtonSelector: '.submit .btn-success'

      @render = ->
        dust.render template, @attr.data, (err, output) =>
          output = $(output).i18n()
          @$node.html(output)

      # Create a new address
      @createAddress = ->
        @trigger('editAddress.vtex')

      # Edit an existing address
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
              aa.isSelected = aa.addressId is @attr.data.address?.addressId
              aa.isGiftList = aa.addressType is "giftRegistry"

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
        for aa in @attr.data.availableAddresses
          if aa.addressId is selectedAddressId
            aa.isSelected = true
            @attr.data.address = aa
          else
            aa.isSelected = false

        @trigger 'addressSelected.vtex', @attr.data.address
        @render()

      # Store new country rules in the data object
      @addCountryRule = (data) ->
        _.extend(@attr.data.countryRules, data)

      @enable = (ev, deliveryCountries, shippingData, giftRegistryData) ->
        if ev then ev.stopPropagation()
        @attr.data.deliveryCountries = deliveryCountries
        @attr.data.address = shippingData.address
        @attr.data.availableAddresses = shippingData.availableAddresses
        @attr.data.giftRegistryData = giftRegistryData

        if @attr.data.availableAddresses.length > 0
          @createAddressesSummaries()
          @render()

      @disable = (ev) ->
        ev?.stopPropagation()
        @$node.html('')

      @startLoading = (ev) ->
        ev?.stopPropagation()
        console.log "start loading"

      @stopLoading = (ev) ->
        ev?.stopPropagation()
        console.log "stop loading"

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on 'startLoading.vtex', @startLoading
        @on 'stopLoading.vtex', @stopLoading
        @on 'click',
          'createAddressSelector': @createAddress
          'addressItemSelector': @selectAddressHandler
          'editAddressSelector': @editAddress

        @setLocalePath 'shipping/script/translation/'

    return defineComponent(AddressList, withi18n)