define ->
  class CountryUNI
    constructor: () ->
      @country = 'UNI'
      @abbr = null

      @postalCodeByInput = false
      @postalCodeByState = false
      @postalCodeByCity = false

      @queryByPostalCode = false
      @queryByGeocoding = true

      @deliveryOptionsByPostalCode = false
      @deliveryOptionsByGeocordinates = true

      @basedOnStateChange = false
      @basedOnCityChange = false

      @geocodingAvailable = true
      @isStateUpperCase = false

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'postalCode', 'street', 'city', 'state',
                         'country', 'number', 'neighborhood']

      @googleDataMap = [
          value: "postalCode"
          length: "long_name"
          types: ["postal_code"],
          required: true
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
          types: ["neighborhood"],
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

      # Address components documentation
      # -> https://developers.google.com/maps/documentation/geocoding/?hl=nl#Types