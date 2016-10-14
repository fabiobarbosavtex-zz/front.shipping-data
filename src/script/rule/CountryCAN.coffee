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
        "NT": "Northwest Territories",
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

      @deliveryOptionsByPostalCode = true
      @deliveryOptionsByGeocordinates = false

      @basedOnStateChange = false
      @basedOnCityChange = false

      @isStateUpperCase = true

      @dontKnowPostalCodeURL = "https://www.canadapost.ca/cpo/mc/personal/postalcode/fpc.jsf"

      @regexes =
        postalCode: new RegExp(/^[A-z][0-9][A-z]\ ?[0-9][A-z][0-9]$/)

      @masks =
        postalCode: 'A9A 9A9'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'postalCode', 'street', 'city', 'state',
                         'country']
