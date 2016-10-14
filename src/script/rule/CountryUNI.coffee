define ->
  class CountryUNI
    constructor: () ->
      @country = 'UNI'
      @abbr = null

      @postalCodeByInput = false
      @postalCodeByState = false
      @postalCodeByCity = false

      @queryByPostalCode = false

      @deliveryOptionsByPostalCode = true
      @deliveryOptionsByGeocordinates = false

      @basedOnStateChange = false
      @basedOnCityChange = false

      @isStateUpperCase = false

      @regexes = {}

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'postalCode', 'street', 'city', 'state',
                         'country']

      @googleDataMap = [
          value: "postalCode"
          length: "long_name"
          types: ["postal_code"],
          required: true
        ,
          value: "complement"
          length: "long_name",
          types: ["street_number", "colloquial_area", "floor", "room", "premise", "subpremise"],
          required: false
        ,
          value: "street"
          length: "long_name"
          types: ["route", "street_address"],
          required: false
        ,
          value: "neighborhood"
          length: "long_name"
          types: ["neighborhood",
                  "administrative_area_level_3",
                  "administrative_area_level_4",
                  "administrative_area_level_5",
                  "sublocality",
                  "sublocality_level_1",
                  "sublocality_level_2",
                  "sublocality_level_3",
                  "sublocality_level_4",
                  "sublocality_level_5"],
          required: false
        ,
          value: "state"
          length: "short_name"
          types: ["administrative_area_level_1"],
          required: false
        ,
          value: "city"
          length: "long_name"
          types: ["locality", "administrative_area_level_2"],
          required: false
      ]

      # Address components documentation
      # -> https://developers.google.com/maps/documentation/geocoding/?hl=nl#Types
