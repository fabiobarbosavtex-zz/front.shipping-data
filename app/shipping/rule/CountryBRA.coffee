define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class CountryBRA
    constructor: () ->
      @country = 'BRA'
      @states = ['AC', 'AL', 'AM', 'AP', 'BA', 'CE', 'DF', 'ES',
               'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR',
               'PE', 'PI', 'RJ', 'RN', 'RO', 'RS', 'RR', 'SC',
               'SE', 'SP', 'TO']

      @usePostalCode = true
      @queryPostalCode = true
      @postalCodeByState = false
      @postalCodeByCity = false

      @regexes =
        postalCode: new RegExp(/^([\d]{5})\-?([\d]{3})$/)

      @masks =
        postalCode: '99999-999'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'postalCode', 'street', 'city', 'state',
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
          types: ["neighborhood"]
        state =
          value: "state"
          length: "short_name"
          types: ["administrative_area_level_1"]
        city =
          value: "city"
          length: "long_name"
          types: ["administrative_area_level_2", "locality"]
      ]