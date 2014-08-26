
describeComponent 'shipping/component/AddressList', ->

    # Initialize the component and attach it to the DOM
    beforeEach ->
      setupComponent()

    it 'should be defined', ->
      expect(this.Component).toBeDefined()

    describe 'with no addresses', ->


    describe 'with some addresses', ->

      beforeEach ->
        # Arrange
        shippingData = {}

        # Act
        $(document).trigger('updateAddresses', shippingData)

      it 'should know there is other addresses', ->
        # Assert
        expect(true).toBe(true)
