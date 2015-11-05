define ->
  class CountryBRA
    constructor: () ->
      @country = 'BRA'
      @abbr = 'BR'
      @states = []
      @statesList = ['AC', 'AL', 'AM', 'AP', 'BA', 'CE', 'DF', 'ES',
               'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR',
               'PE', 'PI', 'RJ', 'RN', 'RO', 'RS', 'RR', 'SC',
               'SE', 'SP', 'TO']

      for state in @statesList
        prop =
          value: state.toUpperCase()
          label: state
        @states.push(prop)

      @postalCodeByInput = true
      @postalCodeByState = false
      @postalCodeByCity = false

      @queryByPostalCode = true
      @queryByGeocoding = false

      @deliveryOptionsByPostalCode = true
      @deliveryOptionsByGeocordinates = false

      @basedOnStateChange = false
      @basedOnCityChange = false

      @geocodingAvailable = false
      @isStateUpperCase = true

      @dontKnowPostalCodeURL = "http://www.buscacep.correios.com.br/servicos/dnec/index.do"

      @regexes =
        postalCode: new RegExp(/^([\d]{5})\-?([\d]{3})$/)

      @masks =
        postalCode: '99999-999'

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
