define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class CountryPER
    constructor: () ->
      @country = 'PER'
      @abbr = 'PE'

      @postalCodeByInput = false
      @postalCodeByState = false
      @postalCodeByCity = false

      @queryByPostalCode = false # Busca default é Postal Code
      @queryByGeocoding = true # Busca default é Geocoding

      @deliveryOptionsByPostalCode = false
      @deliveryOptionsByGeocordinates = true

      @basedOnStateChange = false
      @geocodingAvailable = true # oferece busca de endereço por API

      @regexes =
        postalCode: new RegExp(/^([\d]{5})$/)

      @masks =
        postalCode: '99999'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'street', 'city', 'state', 'neighborhood',
                         'country', 'geocordinates']

      @googleDataMap = [
          value: "postalCode"
          length: "long_name"
          types: ["postal_code"]
          required: false
        ,
          value: "number"
          length: "long_name"
          types: ["street_number"]
          required: false
        ,
          value: "street"
          length: "long_name"
          types: ["route"]
          required: true
        ,
          value: "neighborhood" # Provincia
          length: "long_name"
          types: ["administrative_area_level_2"]
          required: true
        ,
          value: "state" # Región
          length: "short_name"
          types: ["administrative_area_level_1"]
          required: true
        ,
          value: "city" # Distrito
          length: "long_name"
          types: ["locality"]
          required: true
      ]

      # Address components documentation
      # -> https://developers.google.com/maps/documentation/geocoding/?hl=nl#Types