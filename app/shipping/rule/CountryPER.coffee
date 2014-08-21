define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class CountryPER
    constructor: () ->
      @country = 'PER'
      @abbr = 'PE'
      @cities = {}
      @states = [
        "Amazonas"
        "Ancash"
        "Apurímac"
        "Arequipa"
        "Ayacucho"
        "Cajamarca"
        "Callao"
        "Cusco"
        "Huancavelica"
        "Huánuco"
        "Ica"
        "Junín"
        "La Libertad"
        "Lambayeque"
        "Lima"
        "Loreto"
        "Madre de Dios"
        "Moquegua"
        "Pasco"
        "Piura"
        "Puno"
        "San Martín"
        "Tacna"
        "Tumbes"
        "Ucayali"
      ]

      @usePostalCode = false
      @queryPostalCode = false
      @citiesBasedOnStateChange = false
      @postalCodeByState = false
      @postalCodeByCity = false
      @useGeolocation = true

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
        ,
          value: "number"
          length: "long_name"
          types: ["street_number"]
        ,
          value: "street"
          length: "long_name"
          types: ["route"]
        ,
          value: "neighborhood"
          length: "long_name"
          types: ["locality", "neighborhood"]
        ,
          value: "state"
          length: "short_name"
          types: ["administrative_area_level_1"]
        ,
          value: "city"
          length: "long_name"
          types: ["administrative_area_level_2"]
      ]

      # Address components documentation
      # -> https://developers.google.com/maps/documentation/geocoding/?hl=nl#Types