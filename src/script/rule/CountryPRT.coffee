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

      @googleDataMap = [
          value: "postalCode"
          length: "long_name"
          types: ["postal_code"],
          required: false
        ,
          value: "number"
          length: "long_name"
          types: ["street_number"],
          required: false
        ,
          value: "street"
          length: "long_name"
          types: ["route"],
          required: false
        ,
          value: "neighborhood"
          length: "long_name"
          types: ["neighborhood", "sublocality_level_1", "sublocality_level_2", "sublocality_level_3", "sublocality_level_4", "sublocality_level_5"],
          required: false
        ,
          value: "state"
          length: "short_name"
          types: ["administrative_area_level_1"],
          required: false
        ,
          value: "city"
          length: "long_name"
          types: ["administrative_area_level_2", "locality"],
          required: false
      ]