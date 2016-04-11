define ['flight/lib/component',
        'shipping/script/setup/extensions',
        'shipping/script/mixin/withi18n',
        'shipping/script/mixin/withImplementedCountries',
        'shipping/templates/addressList'],
  (defineComponent, extensions, withi18n, withImplementedCountries, template) ->
    AddressList = ->
      @defaultAttrs
        data:
          address: {}
          availableAddresses: []
          deliveryCountries: ['BRA', 'ARG', 'CHL']
          countryRules: {}
          loading: false
          disableEdit: false

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
        return if @attr.data.loading
        @trigger('newAddress.vtex')

      # Edit an existing address
      @editAddress = ->
        return if @attr.data.loading or @attr.data.disableEdit
        @attr.data.showDontKnowPostalCode = false
        @trigger('editAddress.vtex', @attr.data.address)

      @createAddressesSummaries = ->
        countriesUsedRequire = _.map @attr.data.availableAddresses, (a) ->
          if @isCountryImplemented(a.country)
            return 'shipping/script/rule/Country'+a.country
          else
            return 'shipping/script/rule/CountryUNI'

        vtex.curl countriesUsedRequire, =>
          for country, i in arguments
            prop = {}
            prop[@attr.data.deliveryCountries[i]] = new arguments[i]()
            @trigger window, 'newCountryRule', prop
            @addCountryRule prop

            for aa in @attr.data.availableAddresses
              aa.isSelected = aa.addressId is @attr.data.address?.addressId
              aa.isGiftList = aa.addressType is "giftRegistry"
              if aa.isSelected and aa.isGiftList
                @attr.data.disableEdit = true

              aa.firstPart = '' + aa.street
              aa.firstPart += ', ' + aa.number if aa.number and aa.number isnt 'N/A'
              aa.firstPart += ', ' + aa.complement if aa.complement
              aa.firstPart += ', ' + aa.neighborhood if aa.neighborhood
              aa.firstPart += ', ' + aa.reference if aa.reference

              # State is upper case based on the country rules
              if @attr.data.countryRules[aa.country]?.isStateUpperCase
                state = aa.state
              else
                state = _.capitalizeSentence(aa.state)

              if aa.city
                aa.secondPart = aa.city + ' - ' + state
              else
                aa.secondPart = state

              # Show postal code only if user typed it
              if @attr.data.countryRules[aa.country]?.postalCodeByInput
                aa.secondPart += ' - ' + aa.postalCode

              aa.secondPart += ' - ' + i18n.t('countries.'+aa.country)

      # Handle selection of an address in the list
      @selectAddressHandler = (ev, data) ->
        ev.preventDefault()
        @selectAddress($('input', data.el).attr('value'))

      @selectAddressByIdHandler = (ev, id) ->
        ev.stopPropagation()
        @selectAddress(id)

      @selectAddress = (selectedAddressId) ->
        for aa in @attr.data.availableAddresses
          if aa.addressId is selectedAddressId
            @attr.data.address = aa
            aa.isSelected = true
            # Disable edit input if selected address is from gift list
            if aa.isGiftList
              @attr.data.disableEdit = true
              $('a', @select('editAddressSelector')).addClass('disabled')
            else
              @attr.data.disableEdit = false
              $('a', @select('editAddressSelector')).removeClass('disabled')
          else
            aa.isSelected = false

        @trigger 'addressSelected.vtex', @attr.data.address
        @render()

      # Store new country rules in the data object
      @addCountryRule = (data) ->
        _.extend(@attr.data.countryRules, data)

      @enable = (ev, deliveryCountries, shippingData, giftRegistryData) ->
        if ev then ev.stopPropagation()
        @attr.data.loading = false
        @attr.data.deliveryCountries = deliveryCountries
        @attr.data.address = shippingData.address
        @attr.data.availableAddresses = shippingData.availableAddresses
        @attr.data.giftRegistryData = giftRegistryData

        if @attr.data.availableAddresses.length > 0
          @createAddressesSummaries().then =>
            @render()

      @disable = (ev) ->
        ev?.stopPropagation()
        @$node.html('')

      @startLoading = (ev) ->
        ev?.stopPropagation()
        $('a', @select('createAddressSelector')).addClass('disabled')
        $('a', @select('editAddressSelector')).addClass('disabled')
        @attr.data.loading = true

      @stopLoading = (ev) ->
        ev?.stopPropagation()
        $('a', @select('createAddressSelector')).removeClass('disabled')
        $('a', @select('editAddressSelector')).removeClass('disabled')
        @attr.data.loading = false

      # Bind events
      @after 'initialize', ->
        @on 'enable.vtex', @enable
        @on 'disable.vtex', @disable
        @on 'startLoading.vtex', @startLoading
        @on 'stopLoading.vtex', @stopLoading
        @on 'selectAddress.vtex', @selectAddressByIdHandler
        @on 'click',
          'createAddressSelector': @createAddress
          'addressItemSelector': @selectAddressHandler
          'editAddressSelector': @editAddress

        @setLocalePath 'shipping/script/translation/'

    return defineComponent(AddressList, withi18n, withImplementedCountries)
