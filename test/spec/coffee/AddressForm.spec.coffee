
describeComponent 'shipping/component/AddressForm', ->

    # Initialize the component and attach it to the DOM
    beforeEach ->
      setupComponent()

    it 'should be defined', ->
      expect(this.component).toBeDefined()

    describe 'with new address', ->

      it 'example', ->
        # Assert
        expect(true).toBe(true)