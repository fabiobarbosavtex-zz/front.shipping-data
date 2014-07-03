define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component', 'shipping/setup/extensions'],
  (defineComponent, extensions) ->
    AddressForm = ->
      @defaultAttrs
        data:
          address: {}
          postalCode: ''
          deliveryCountries: ['BRA']
          
          disableCityAndState: false
          labelShippingFields: false
          
          showPostalCode: false
          showAddressForm: false
          showDontKnowPostalCode: true
          showSelectCountry: false

          countryRules: {}

        templates:
          form:
            baseName: 'countries/addressForm'
          selectCountry:
            name: 'selectCountry'
            template: 'shipping/template/selectCountry'

        addressFormSelector: '.address-form-new'
        postalCodeSelector: '#ship-postal-code'
        forceShippingFieldsSelector: '#force-shipping-fields'
        stateSelector: '#ship-state'
        citySelector: '#ship-city'
        deliveryCountrySelector: '#ship-country'
        cancelAddressFormSelector: '.cancel-address-form a'
        submitButtonSelector: '.submit .btn-success.address-save'

      # Render this component according to the data object
      @render = (ev, data) ->
        data = @attr.data if not data
        if data.showSelectCountry
          require [@attr.templates.selectCountry.template], =>
            dust.render @attr.templates.selectCountry.name, data, (err, output) =>
              output = $(output).i18n()
              @$node.html(output)
        else if data.showAddressForm
          rules = @getCurrentRule()
          data.states = rules.states
          data.regexes = rules.regexes
          dust.render @attr.templates.form.name, data, (err, output) =>
            output = $(output).i18n()
            @$node.html(output)

            if data.loading
              $('input, select, .btn', @$node).attr('disabled', 'disabled')

            if rules.citiesBasedOnStateChange
              @changeCities()
              if data.address.city
                $(@attr.citySelector, @$node).val(data.address.city)

            if rules.usePostalCode
              $(@attr.postalCodeSelector, @$node).inputmask
                mask: rules.masks.postalCode
              if data.labelShippingFields
                $(@attr.postalCodeSelector).addClass('success')

            $(@attr.addressFormSelector, @$node).parsley
              errorClass: 'error'
              successClass: 'success'
              errors:
                errorsWrapper: '<div class="help error-list"></div>'
                errorElem: '<span class="help error"></span>'
              validators:
                postalcode: =>
                  validate: (val) =>
                    rules = @attr.data.countryRules[@attr.data.country]
                    return rules.regexes.postalCode.test(val)
                  priority: 32

            # Focus on the first empty rqeuired field
            inputs = 'input[type=email].required,' + \
                     'input[type=tel].required,' + \
                     'input[type=text].required'
            $(@$node).find(inputs)
              .filter ->
                if($(this).val() == "")
                  return true
            .first().focus()
        else
          @$node.html('')

      # Helper function to get the current country's rules
      @getCurrentRule = ->
        @attr.data.countryRules[@attr.data.country]

      # Validate the postal code input
      # If successful, this will call the postal code API
      @validatePostalCode = (ev, data) ->
        postalCode = data.el.value
        rules = @getCurrentRule()
        if rules.regexes.postalCode.test(postalCode)
          @attr.data.throttledLoading = true
          @attr.data.postalCode = postalCode
          @attr.data.address.postalCode = postalCode
          @attr.data.loading = true if rules.queryPostalCode
          @$node.trigger 'addressFormRender', @attr.data
          if rules.queryPostalCode
            @getPostalCode postalCode

      # Handle the initial view of this component
      @showAddressForm = (ev, data) ->
        $.extend(@attr.data, data) if data

        @attr.data.isEditingAddress = true

        if data.address.addressType
          @selectCountry(data.address.country)
        else if @attr.data.deliveryCountries.length is 1
          country = @attr.data.deliveryCountries[0]
          @selectCountry(country)
        else
          @attr.data.showSelectCountry = true
          @trigger('addressFormRender', @attr.data)

      # Call the postal code API
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
            data.loading = false
            @trigger('addressFormRender', data)
            @$node.trigger('postalCode', @getCurrentAddress())
        ).fail =>
          data = @attr.data
          data.throttledLoading = false
          data.showAddressForm = true
          data.labelShippingFields = false
          data.disableCityAndState = false
          data.loading = false
          @trigger('addressFormRender', data)
          @$node.trigger('postalCode', @getCurrentAddress())

      # Able the user to edit the suggested fields
      # filled by the postal code service
      @forceShippingFields = ->
        @attr.data.labelShippingFields = false
        @trigger('addressFormRender', @attr.data)

      # Get the current address typed in the form
      @getCurrentAddress = ->
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
          addressObj.addressType = 'residential'

        return addressObj

      # Submit address to the server
      @submitAddress = (ev, data) ->
        valid = $(@attr.addressFormSelector).parsley('validate')

        if valid
          addressObj = @getCurrentAddress()
          @attr.data.address = addressObj

          @$node.trigger 'loading', true
          @attr.showAddressForm = false
          @$node.trigger 'newAddress', addressObj

        ev.preventDefault()

      # Select a delivery country
      # This will load the country's form and rules
      @selectCountry = (country) ->
        @attr.data.country = country
        @attr.data.showAddressForm = true
        @attr.data.showSelectCountry = false

        @attr.templates.form.name =
          @attr.templates.form.baseName + country
        @attr.templates.form['template'] =
              'shipping/template/' + @attr.templates.form.name

        deps = [@attr.templates.form.template,
                @attr.templates.selectCountry.template]
        if not @attr.data.countryRules[country]
          deps.push('shipping/rule/Country'+country)
          require deps, (ft, sct, C) =>
            @attr.data.countryRules[country] = new C()
            @trigger('addressFormRender', @attr.data)
        else
          require deps, =>
            @trigger('addressFormRender', @attr.data)

      @createMap = ->
        console.log "create map"
        mapOptions =
          zoom: 8
          center: new google.maps.LatLng(-34.397, 150.644)
        geocoder = new google.maps.Geocoder()
        window.setTimeout( ->
          map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions)
        ,100)

      # Handle the selection event
      @selectedCountry = (ev, data) ->
        @attr.data.address = {}
        @attr.data.postalCode = ''
        country = $(@attr.deliveryCountrySelector, @$node).val()
        @selectCountry country if country
        @createMap()

      # Close the form
      @cancelAddressForm = ->
        @attr.data.showAddressForm = false
        @attr.data.showSelectCountry = false
        @attr.data.loading = false
        @trigger('addressFormRender', @attr.data)
        @trigger('addressFormCanceled')

      # Change the city select options when a state is selected
      # citiesBasedOnStateChange should be true in the country's rule
      @changeCities = (ev, data) ->
        rules = @getCurrentRule()
        return if not rules.citiesBasedOnStateChange

        state = $(@attr.stateSelector, @$node).val()
        $(@attr.citySelector, @$node).find('option').remove().end()

        for city of rules.map[state]
          elem = '<option value="'+city+'">'+city+'</option>'
          $(@attr.citySelector, @$node).append(elem)

      # Change postal code according to the state selected
      # postalCodeByState should be true in the country's rule
      @changePostalCodeByState = (ev, data) ->
        rules = @getCurrentRule()
        return if not rules.postalCodeByState
        
        state = $(@attr.stateSelector, @$node).val()
        for city, postalCode of rules.map[state]
          break

        $(@attr.postalCodeSelector, @$node).val(postalCode)
        @$node.trigger('postalCode', postalCode)
      
      # Change postal code according to the city selected
      # postalCodeByCity should be true in the country's rule
      @changePostalCodeByCity = (ev, data) ->
        rules = @getCurrentRule()
        return if not rules.postalCodeByCity

        state = $(@attr.stateSelector, @$node).val()
        city = $(@attr.citySelector, @$node).val()
        postalCode = rules.map[state][city]

        $(@attr.postalCodeSelector, @$node).val(postalCode)
        @$node.trigger('postalCode', @getCurrentAddress())

      # Set to a loading state
      # This will disable all fields
      @loading = (ev, data) ->
        @attr.data.loading = true
        @trigger('addressFormRender', @attr.data)
        console.log "loaded"

      # Store new country rules in the data object
      @addCountryRule = (ev, data) ->
        _.extend(@attr.data.countryRules, data)

      # Call two functions for the same event
      @onChangeState = (ev, data) ->
        @changeCities(ev, data)
        @changePostalCodeByState(ev, data)

      # Bind events
      @after 'initialize', ->
        console.log "módulo de form inicializado"
        @on 'loading', @loading
        @on document, 'newCountryRule', @addCountryRule
        @on document, 'addressFormRender', @render
        @on document, 'showAddressForm', @showAddressForm
        @on document, 'updateAddresses', @cancelAddressForm
        @on document, 'cancelAddressForm', @cancelAddressForm
        @on document, 'click',
          'forceShippingFieldsSelector': @forceShippingFields
          'cancelAddressFormSelector': @cancelAddressForm
          'submitButtonSelector': @submitAddress
        @on 'change',
          'deliveryCountrySelector': @selectedCountry
          'stateSelector': @onChangeState
          'citySelector': @changePostalCodeByCity

        @on 'keyup',
          'postalCodeSelector': @validatePostalCode
        return
    return defineComponent(AddressForm)