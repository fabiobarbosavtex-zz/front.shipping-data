define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class CountryBRA
    constructor: () ->
      @country = 'BRA'
      @abbr = 'BR'
      @states = ['AC', 'AL', 'AM', 'AP', 'BA', 'CE', 'DF', 'ES',
               'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR',
               'PE', 'PI', 'RJ', 'RN', 'RO', 'RS', 'RR', 'SC',
               'SE', 'SP', 'TO']

      @postalCodeByInput = true
      @postalCodeByState = false
      @postalCodeByCity = false

      @queryByPostalCode = true
      @queryByGeocoding = false

      @deliveryOptionsByPostalCode = true
      @deliveryOptionsByGeocordinates = false

      @basedOnStateChange = false
      @geocodingAvailable = true

      @dontKnowPostalCodeURL = "http://www.buscacep.correios.com.br/servicos/dnec/index.do"

      @regexes =
        postalCode: new RegExp(/^([\d]{5})\-?([\d]{3})$/)

      @masks =
        postalCode: '99999-999'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'postalCode', 'street', 'citytal', 'state',
                         'country', 'number', 'neighborhood']

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