define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class CountryPER
    constructor: () ->
      @country = 'PER'
      @abbr = 'PE'
      @states = []
      @cities = {}
      @map = {
        "Lima": {
          "Lima": {"Lima":"150101","Ancon":"150102","Ate":"150103","Barranco":"150104","Breña":"150105","Carabayllo":"150106","Chaclacayo":"150107","Chorrillos":"150108","Cieneguilla":"150109","Comas":"150110","El Agustino":"150111","Independencia":"150112","Jesus Maria":"150113","La Molina":"150114","La Victoria":"150115","Lince":"150116","Los Olivos":"150117","Lurigancho":"150118","Lurin":"150119","Magdalena Del Mar":"150120","Pueblo Libre":"150121","Miraflores":"150122","Pachacamac":"150123","Pucusana":"150124","Puente Piedra":"150125","Punta Hermosa":"150126","Punta Negra":"150127","Rimac":"150128","San Bartolo":"150129","San Borja":"150130","San Isidro":"150131","San Juan De Lurigancho":"150132","San Juan De Miraflores":"150133","San Luis":"150134","San Martin De Porres":"150135","San Miguel":"150136","Santa Anita":"150137","Santa Maria Del Mar":"150138","Santa Rosa":"150139","Santiago De Surco":"150140","Surquillo":"150141","Villa El Salvador":"150142","Villa Maria Del Triunfo":"150143"},
          "Barranca": {"Barranca":"150201","Paramonga":"150202","Pativilca":"150203","Supe":"150204","Supe Puerto":"150205"},
          "Cajatambo": {"Cajatambo":"150301","Copa":"150302","Gorgor":"150303","Huancapon":"150304","Manas":"150305"},
          "Canta": {"Canta":"150401","Arahuay":"150402","Huamantanga":"150403","Huaros":"150404","Lachaqui":"150405","San Buenaventura":"150406","Santa Rosa De Quives":"150407"},
          "Cañete": {"San Vicente De Cañete":"150501","Asia":"150502","Calango":"150503","Cerro Azul":"150504","Chilca":"150505","Coayllo":"150506","Imperial":"150507","Lunahuana":"150508","Mala":"150509","Nuevo Imperial":"150510","Pacaran":"150511","Quilmana":"150512","San Antonio":"150513","San Luis":"150514","Santa Cruz De Flores":"150515","Zuñiga":"150516"},
          "Huaral": {"Huaral":"150601","Atavillos Alto":"150602","Atavillos Bajo":"150603","Aucallama":"150604","Chancay":"150605","Ihuari":"150606","Lampian":"150607","Pacaraos":"150608","San Miguel De Acos":"150609","Santa Cruz De Andamarca":"150610","Sumbilca":"150611","Veintisiete De Noviembre":"150612"},
          "Huarochiri": {"Matucana":"150701","Antioquia":"150702","Callahuanca":"150703","Carampoma":"150704","Chicla":"150705","Cuenca":"150706","Huachupampa":"150707","Huanza":"150708","Huarochiri":"150709","Lahuaytambo":"150710","Langa":"150711","Laraos":"150712","Mariatana":"150713","Ricardo Palma":"150714","San Andres De Tupicocha":"150715","San Antonio":"150716","San Bartolome":"150717","San Damian":"150718","San Juan De Iris":"150719","San Juan De Tantaranche":"150720","San Lorenzo De Quinti":"150721","San Mateo":"150722","San Mateo De Otao":"150723","San Pedro De Casta":"150724","San Pedro De Huancayre":"150725","Sangallaya":"150726","Santa Cruz De Cocachacra":"150727","Santa Eulalia":"150728","Santiago De Anchucaya":"150729","Santiago De Tuna":"150730","Santo Domingo De Los Olleros":"150731","Surco":"150732"},
          "Huaura": {"Huacho":"150801","Ambar":"150802","Caleta De Carquin":"150803","Checras":"150804","Hualmay":"150805","Huaura":"150806","Leoncio Prado":"150807","Paccho":"150808","Santa Leonor":"150809","Santa Maria":"150810","Sayan":"150811","Vegueta":"150812"},
          "Oyon": {"Oyon":"150901","Andajes":"150902","Caujul":"150903","Cochamarca":"150904","Navan":"150905","Pachangara":"150906"},
          "Yauyos": {"Yauyos":"151001","Alis":"151002","Allauca":"151003","Ayaviri":"151004","Azangaro":"151005","Cacra":"151006","Carania":"151007","Catahuasi":"151008","Chocos":"151009","Cochas":"151010","Colonia":"151011","Hongos":"151012","Huampara":"151013","Huancaya":"151014","Huangascar":"151015","Huantan":"151016","Huañec":"151017","Laraos":"151018","Lincha":"151019","Madean":"151020","Miraflores":"151021","Omas":"151022","Putinza":"151023","Quinches":"151024","Quinocay":"151025","San Joaquin":"151026","San Pedro De Pilas":"151027","Tanta":"151028","Tauripampa":"151029","Tomas":"151030","Tupe":"151031","Viñac":"151032","Vitis":"151033"},
          "Callao": {"Callao":"070101","Bellavista":"070102","Carmen De La Legua Reynoso":"070103","La Perla":"070104","La Punta":"070105","Ventanilla":"070106"}
        }
      }

      @postalCodeByInput = false
      @postalCodeByState = false
      @postalCodeByCity = false
      @postalCodeByNeighborhood = true

      @queryByPostalCode = false
      @queryByGeocoding = false

      @deliveryOptionsByPostalCode = true
      @deliveryOptionsByGeocordinates = false

      @basedOnStateChange = true
      @basedOnCityChange = true

      @geocodingAvailable = false
      @isStateUpperCase = false

      @regexes =
        postalCode: new RegExp(/^(\d{5,6})$/)

      @masks =
        postalCode: '999999'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'street', 'city', 'state', 'neighborhood',
                         'number', 'country', 'postalCode']

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
          value: "state" # Región
          length: "short_name"
          types: ["administrative_area_level_1"]
          required: true
        ,
          value: "city" # Provincia
          length: "long_name"
          types: ["locality", "administrative_area_level_2"]
          required: true
        ,
          value: "neighborhood" # Distrito
          length: "long_name"
          types: ["administrative_area_level_3"]
          required: false
      ]

      for state in _.keys(@map)
        prop =
          value: state.toUpperCase()
          label: state
        @states.push(prop)
        @cities[state.toUpperCase()] = _.keys(@map[state])