define = window.define or window.vtex.define

define ->
  AddressForm = flight.component ->
    @defaultAttrs
      data:
        address: {}
        country: 'BRA'
        states: ['AC', 'AL', 'AM', 'AP', 'BA', 'CE', 'DF', 'ES',
                 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR',
                 'PE', 'PI', 'RJ', 'RN', 'RO', 'RS', 'RR', 'SC',
                 'SE', 'SP', 'TO']
        alphaNumericPunctuationRegex: '^[A-Za-zÀ-ú0-9/\\-.,s()\']*$'
        showPostalCode: false
        showAddressForm: false
        postalCode: ''
        disableCityAndState: false
        labelShippingFields: false
        showDontKnowPostalCode: true

      templates: {}

      addressFormSelector: '.address-form-new'
      postalCodeSelector: '#ship-postal-code'
      forceShippingFieldsSelector: '#force-shipping-fields'
      stateSelector: '#ship-state'
      cancelAddressFormSelector: '.cancel-address-form a'
      submitButtonSelector: '.submit .btn-success'

    @render = (ev, data) ->
      data = @attr.data if not data
      if not data.showAddressForm
        @$node.html('')
      else
        @attr.templates.addressFormTemplate.then =>
          dust.render 'addressForm', data, (err, output) =>
            output = $(output).i18n()
            @$node.html(output)
            $(@attr.postalCodeSelector, @$node).inputmask mask: '99999-999'
            $(@attr.addressFormSelector).parsley
              errorClass: 'error'
              successClass: 'success'
              errors:
                errorsWrapper: '<div class="help error-list"></div>'
                errorElem: '<span class="help error"></span>'

    @validatePostalCode = (ev, data) ->
      postalCode = data.el.value
      data = @attr.data
      if /^([\d]{5})\-?([\d]{3})$/.test(postalCode)
        data.throttledLoading = true
        data.postalCode = postalCode
        @$node.trigger 'addressFormRender', data
        @getPostalCode postalCode

    @showAddressForm = (ev, data) ->
      $.extend(@attr.data, data) if data
      @attr.data.isEditingAddress = true
      @attr.data.showAddressForm = true
      @render(@attr.data)

    @getPostalCode = (data) ->
      country = @attr.data.country
      postalCode = data.replace(/-/g, '')
      $.ajax(
        url: 'http://postalcode.vtexfrete.com.br/api/postal/pub/address/' \
          + country + '/' + postalCode
        crossDomain: true
      ).done((data) =>
        if data.properties
          address = data.properties[0].value.address
          data = @attr.data
          if address.neighborhood isnt '' and address.street isnt '' \
          and address.stateAcronym isnt '' and address.city isnt ''
            data.labelShippingFields = true
          else
            data.labelShippingFields = false
          if address.stateAcronym isnt '' and address.city
            data.disableCityAndState = true
          else
            data.disableCityAndState = false
          data.showDontKnowPostalCode = false
          data.address.city = address.city
          data.address.state = address.stateAcronym
          data.address.street = address.street
          data.address.neighborhood = address.neighborhood
          data.address.country = data.country
          data.throttledLoading = false
          data.showAddressForm = true
          @render(data)
      ).fail =>
        console.log 'CEP não encontrado!'
        data = @attr.data
        data.throttledLoading = false
        data.showAddressForm = true
        data.labelShippingFields = false
        @render(data)

    @forceShippingFields = ->
      @attr.data.labelShippingFields = false
      @render(@attr.data)

    @submitAddress = (ev, data) ->
      valid = $(@attr.addressFormSelector).parsley('validate')

      if valid
        disabled = $(@attr.addressFormSelector)
          .find(':input:disabled').removeAttr('disabled')

        serializedForm = $(@attr.addressFormSelector)
          .find('select,textarea,input').serializeArray()

        disabled.attr 'disabled', 'disabled'
        addressObj = {}
        $.each serializedForm, ->
          addressObj[@name] = @value

        if addressObj.addressTypeCommercial
          addressObj.addressType = 'commercial'
        else
          addressObj.addressType = 'residental'

        @$node.trigger 'newAddress', addressObj

      ev.preventDefault()

    @cancelAddressForm = ->
      @attr.data.showAddressForm = false
      @render(@attr.data)
      @$node.trigger 'selectAddress', @attr.data.selectedAddressId

    @after 'initialize', ->
      @on document, 'addressFormRender', @render
      @on document, 'showAddressForm', @showAddressForm
      @on document, 'click',
        'forceShippingFieldsSelector': @forceShippingFields
        'cancelAddressFormSelector': @cancelAddressForm
        'submitButtonSelector': @submitAddress

      @on 'keyup',
        postalCodeSelector: @validatePostalCode

      @attr.templates['addressFormTemplate'] = vtex
        .require('template/addressForm')