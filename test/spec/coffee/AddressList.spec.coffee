
describe '', ->

  AddressList = null
  componentPath = 'component/AddressList'

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

  describeComponent componentPath, AddressList, ->

    # Initialize the component and attach it to the DOM
    beforeEach ->
      setupComponent()

    it 'should be defined', ->
      expect(this.component).toBeDefined()

    describe 'with no addresses', ->

      it 'should list no address', ->
        listItems = $('.address-item', this.component.$node)
        expect(listItems.length).toBe(0)

      it 'should know there is no other addresses', ->
        expect(this.component.attr.data.hasOtherAddresses).toBe(false)

    describe 'with some addresses', ->

      beforeEach ->
        # Arrange
        shippingData = {
          "address": {
            "addressId": "-1385141491001",
            "addressType": "residential",
            "city": "Rio De Janeiro",
            "complement": "",
            "country": "BRA",
            "neighborhood": "Botafogo",
            "number": "2",
            "postalCode": "22251-030",
            "receiverName": "Breno Calazans",
            "reference": null,
            "state": "RJ",
            "street": "Rua  Assuncao"
          },
          "attachmentId": "shippingData",
          "availableAddresses": [
            {
              "addressId": "-1385141491001",
              "addressType": "residential",
              "city": "Rio De Janeiro",
              "complement": "",
              "country": "BRA",
              "neighborhood": "Botafogo",
              "number": "2",
              "postalCode": "22251-030",
              "receiverName": "Breno Calazans",
              "reference": null,
              "state": "RJ",
              "street": "Rua  Assuncao"
            },
            {
              "addressId": "-1385141491002",
              "addressType": "residential",
              "city": "Rio De Janeiro",
              "complement": "",
              "country": "BRA",
              "neighborhood": "Botafogo",
              "number": "2",
              "postalCode": "22251-030",
              "receiverName": "Breno Calazans",
              "reference": null,
              "state": "RJ",
              "street": "Rua  Assuncao"
            }
          ]
        }

        # Act
        $(document).trigger('updateAddresses', shippingData)

      xit 'should know there is other addresses', ->
        # Assert
        expect(this.component.attr.data.hasOtherAddresses).toBe(true)

      xit 'should list addresses', ->
        # Assert
        listItems = $('.address-item', this.component.$node)
        expect(listItems.length).toBe(2)

      xit 'should have one address selected', ->
        # Assert
        data = this.component.attr.data
        expect(data.selectedAddressId).not.toBeNull()
        expect(data.address.addressId).toEqual(data.selectedAddressId)

      xit 'should select a new address when clicked', ->
        # Arrange
        data = this.component.attr.data
        address = $('.address-item')

        # Act
        $(address[1]).trigger('click')

        # Arrange
        expect(data.availableAddresses[1].addressId).toEqual(data.selectedAddressId)
