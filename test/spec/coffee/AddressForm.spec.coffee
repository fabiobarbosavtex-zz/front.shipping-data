
describe '', ->

  AddressForm = null
  componentPath = 'component/AddressForm'

  # We need to do this bootstrap to require the component
  beforeEach ->

    requireCallback = ((Component) ->
      flight.registry.reset()
      this.Component = Component
    ).bind(this)

    require([componentPath], requireCallback)

    waitsFor (->
      return this.Component isnt null
    ).bind(this)
  # end of bootstraping

  describeComponent componentPath, AddressForm, ->

    # Initialize the component and attach it to the DOM
    beforeEach ->
      setupComponent()

    it 'should be defined', ->
      expect(this.component).toBeDefined()

    describe 'with new address', ->

      beforeEach ->
        # Arrange
        data = {}
        data.address = {}
        data.postalCode = ''
        data.labelShippingFields = false
        data.disableCityAndState = false
        data.address.addressId = (new Date().getTime() * -1).toString()
        data.showDontKnowPostalCode = true

        # Act
        $(document).trigger 'showAddressForm', data

        waitsFor (->
          return $('.address-form', this.component.$node)[0]
        ).bind(this)

      it 'should show form', ->
        # Assert
        form = $('.address-form', this.component.$node)[0]
        expect(form).toBeDefined()

      it 'should not trigger newAddress event when submit form with invalid data', ->
        # Arrange
        eventNewAddress = spyOnEvent(document, 'newAddress')

        # Act
        $(this.component.attr.submitButtonSelector).trigger('click')

        # Assert
        expect(eventNewAddress).not.toHaveBeenTriggeredOn(document)
