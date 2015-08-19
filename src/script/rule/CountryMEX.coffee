define ->
  class CountryMEX
    constructor: () ->
      @country = 'MEX'
      @abbr = 'MX'
      @states = []
      @statesList = ["Aguascalientes", "Baja California", "Baja California Sur", "Campeche", "Chiapas", "Chihuahua", "Coahuila De Zaragoza", "Colima", "Distrito Federal", "Durango", "Guanajuato", "Guerrero", "Hidalgo", "Jalisco", "México", "Michoacán De Ocampo", "Morelos", "Nayarit", "Nuevo León", "Oaxaca", "Puebla", "Querétaro De Arteaga", "Quintana Roo", "San Luis Potosí", "Sinaloa", "Sonora", "Tabasco", "Tamaulipas", "Tlaxcala", "Veracruz De Ignacio De La Llave", "Yucatán", "Zacatecas"]

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
      @isStateUpperCase = false

      @dontKnowPostalCodeURL = "http://www.sepomex.gob.mx/servicioslinea/paginas/ccpostales.aspx"

      @regexes =
        postalCode: new RegExp(/^\d{5}$/)

      @masks =
        postalCode: '99999'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'postalCode', 'street', 'citytal', 'state',
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
