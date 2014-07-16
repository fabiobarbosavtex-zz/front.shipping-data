define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class CountryPER
    constructor: () ->
      @country = 'PER'
      @states = []
      @cities = {}
      
      @map =
        "AMAZONAS":
          "BAGUA": {}
          "BONGARA": {}
          "CHACHAPOYAS": {}
        "ANCASH":
          "AIJA": {}
          "ANTONIO RAYMONDI": {}
          "ASUNCION": {}
          "BOLOGNESI": {}
        "Lima":
          "Lima": {}

      for state of @map
        @states.push(state)
        @cities[state] = _.map(@map[state], (k, v) -> return v )

      @usePostalCode = false
      @queryPostalCode = false
      @citiesBasedOnStateChange = true
      @postalCodeByState = false
      @postalCodeByCity = false

      @regexes =
        postalCode: new RegExp(/^([\d]{5})$/)

      @masks =
        postalCode: '99999'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'street', 'city', 'state',
                         'country', 'number', 'neighborhood']

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