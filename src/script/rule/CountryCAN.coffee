define ->
  class CountryCAN
    constructor: () ->
      @country = 'CAN'
      @abbr = 'CA'
      @states = []
      @map = {
        "AB": "Alberta",
        "BC": "British Columbia",
        "MB": "Manitoba",
        "NB": "New Brunswick",
        "NL": "Newfoundland and Labrador",
        "NT": "Northern Territories",
        "NS": "Nova Scotia",
        "NV": "Nunavut",
        "ON": "Ontario",
        "PE": "Prince Edward Island",
        "QC": "Quebec",
        "SK": "Saskatchewan",
        "YK": "Yukon"
      }

      for acronym, state of @map
        prop =
          value: acronym
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
      @isStateUpperCase = true

      @dontKnowPostalCodeURL = "https://www.canadapost.ca/cpo/mc/personal/postalcode/fpc.jsf"

      @regexes =
        postalCode: new RegExp(/^[A-z0-9]{3}\ ?[A-z0-9]{3}$/)

      @masks =
        postalCode: '*** ***'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'postalCode', 'street', 'city', 'state',
                         'country']
