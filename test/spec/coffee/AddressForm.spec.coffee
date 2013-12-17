
describeComponent 'component/AddressForm', AddressForm, ->

  # Initialize the component and attach it to the DOM
  beforeEach ->
    setupComponent()

  it 'should be defined', ->
    expect(this.component).toBeDefined()

  it 'should do something', ->
    expect(true).toBe(true);
