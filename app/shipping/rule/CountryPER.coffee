define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class CountryPER
    constructor: () ->
      @country = 'PER'
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
      @cities = {}

      @usePostalCode = false
      @queryPostalCode = false
      @citiesBasedOnStateChange = true
      @postalCodeByState = false
      @postalCodeByCity = true

      @regexes =
        postalCode: new RegExp(/^([\d]{5})$/)

      @masks =
        postalCode: '99999'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'postalCode', 'street', 'city', 'state',
                         'country']