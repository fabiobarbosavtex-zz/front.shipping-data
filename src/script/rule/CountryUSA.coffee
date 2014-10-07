define ->
  class CountryUSA
    constructor: () ->
      @country = 'USA'
      @abbr = 'US'
      @states = []
      @statesList = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
                     'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
                     'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas',
                     'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts',
                     'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana',
                     'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
                     'New Mexico', 'New York', 'North Carolina', 'North Dakota',
                     'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island',
                     'South Carolina', 'South Dakota', 'Tennessee', 'Texas',
                     'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia',
                     'Wisconsin', 'Wyoming']

      for state in @statesList
        prop =
          value: state.toUpperCase()
          label: state
        @states.push(prop)

      @postalCodeByInput = true
      @postalCodeByState = false
      @postalCodeByCity = false

      @queryByPostalCode = true
      @queryByGeocoding = false

      @deliveryOptionsByPostalCode = true
      @deliveryOptionsByGeocordinates = false

      @basedOnStateChange = false
      @basedOnCityChange = false

      @geocodingAvailable = false
      @isStateUpperCase = false

      @dontKnowPostalCodeURL = "https://tools.usps.com/go/ZipLookupAction!input.action"

      @regexes =
        postalCode: new RegExp(/^([\d]{5})$/)

      @masks =
        postalCode: '99999'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'postalCode', 'street', 'city', 'state',
                         'country']