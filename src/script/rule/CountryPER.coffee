define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class CountryPER
    constructor: () ->
      @country = 'PER'
      @abbr = 'PE'
      @cities = {}
      @states = []

      @usePostalCode = false # exibe campo de Postal Code
      @queryByPostalCode = false # Busca default é Postal Code
      @geocodingAvailable = true # oferece busca de endereço por API
      @queryByGeocoding = true # Busca default é Geocoding
      @deliveryOptionsByPostalCode = false
      @deliveryOptionsByGeocordinates = true

      @citiesBasedOnStateChange = false
      @postalCodeByState = false
      @postalCodeByCity = false

      @regexes =
        postalCode: new RegExp(/^([\d]{5})$/)

      @masks =
        postalCode: '99999'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'street', 'city', 'state',
                         'country', 'neighborhood', 'geocordinates']

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
          value: "neighborhood"
          length: "long_name"
          types: ["neighborhood", "locality"]
          required: true
        ,
          value: "state"
          length: "short_name"
          types: ["administrative_area_level_1"]
          required: true
        ,
          value: "city"
          length: "long_name"
          types: ["administrative_area_level_2"]
          required: true
      ]

      # Address components documentation
      # -> https://developers.google.com/maps/documentation/geocoding/?hl=nl#Types