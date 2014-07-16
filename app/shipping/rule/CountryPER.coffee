define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class CountryPER
    constructor: () ->
      @country = 'PER'
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

      @regexes =
        postalCode: new RegExp(/^([\d]{5})$/)

      @masks =
        postalCode: '99999'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'street', 'city', 'state',
                         'country', 'neighborhood']

      @googleDataMap = [
        postalCode =
          value: "postalCode"
          length: "long_name"
          types: ["postal_code"]
        number =
          value: "number"
          length: "long_name"
          types: ["street_number"]
        street =
          value: "street"
          length: "long_name"
          types: ["route"]
        neighborhood =
          value: "neighborhood"
          length: "long_name"
          types: ["locality", "neighborhood"]
        state =
          value: "state"
          length: "short_name"
          types: ["administrative_area_level_1"]
        city =
          value: "city"
          length: "long_name"
          types: ["administrative_area_level_2"]
      ]