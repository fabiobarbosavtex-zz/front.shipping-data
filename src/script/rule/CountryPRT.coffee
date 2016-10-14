define ->
  class CountryPRT
    constructor: () ->
      @country = 'PRT'
      @abbr = 'PT'

      @postalCodeByInput = true
      @postalCodeByState = false
      @postalCodeByCity = false

      @queryByPostalCode = false

      @deliveryOptionsByPostalCode = true
      @deliveryOptionsByGeocordinates = false

      @basedOnStateChange = false
      @basedOnCityChange = false

      @isStateUpperCase = false

      @dontKnowPostalCodeURL = "https://www.ctt.pt/feapl_2/app/open/postalCodeSearch/postalCodeSearch.jspx"

      @regexes =
        postalCode: new RegExp(/^(?:[\d]{4})(?:\-|)(?:[\d]{3}|)$/)

      @masks =
        postalCode: '9999-999'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'postalCode', 'street', 'city', 'state',
                         'country']
