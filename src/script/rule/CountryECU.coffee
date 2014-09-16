define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class CountryECU
    constructor: () ->
      @country = 'ECU'
      @abbr = 'EC'
      @states = []
      @cities = {}
      @map =
        "Azuay":{"Camilo Ponce Enriquez":"0000","Chordeleg":"0000","Cuenca":"0000","El Pan":"0000","Giron":"0000","Guachapala":"0000","Gualaceo":"0000","Nabon":"0000","Oña":"0000","Paute":"0000","Pucara":"0000","San Fernando":"0000","Santa Isabel":"0000","Sevilla De Oro":"0000","Sigsig":"0000"}
        "Bolivar":{"Caluma":"0001","Chillanes":"0001","Chimbo":"0001","Echeandia":"0001","Guaranda":"0001","Las Naves":"0001","San Miguel":"0001"}
        "Canar":{"Azogues":"0002","Biblian":"0002","Cañar":"0002","Deleg":"0002","El Tambo":"0002","La Troncal":"0002","Suscal":"0002"}
        "Carchi":{"Bolivar":"0003","Espejo":"0003","Mira":"0003","Montufar":"0003","San Pedro De Huaca":"0003","Tulcan":"0003"}
        "Chimborazo":{"Alausi":"0004","Chambo":"0004","Chunchi":"0004","Colta":"0004","Cumanda":"0004","Guamote":"0004","Guano":"0004","Pallatanga":"0004","Penipe":"0004","Riobamba":"0004"}
        "Cotopaxi":{"La Mana":"0005","Latacunga":"0005","Pangua":"0005","Pujili":"0005","Salcedo":"0005","Saquisili":"0005","Sigchos":"0005"}
        "El Oro":{"Arenillas":"0006","Atahualpa":"0006","Balsas":"0006","Chilla":"0006","El Guabo":"0006","Huaquillas":"0006","Las Lajas":"0006","Machala":"0006","Marcabeli":"0006","Pasaje":"0006","Piñas":"0006","Portovelo":"0006","Santa Rosa":"0006","Zaruma":"0006"}
        "Esmeraldas":{"Atacames":"0007","Eloy Alfaro":"0007","Esmeraldas":"0007","La Concordia":"0007","Muisne":"0007","Quininde":"0007","Rio Verde":"0007","San Lorenzo":"0007"}
        "Galapagos":{"Isabela":"0008","San Cristobal":"0008","Santa Cruz":"0008"}
        "Guayas":{"A. Baquerizo Moreno - Jujan":"0009","Balao":"0009","Balzar":"0009","Colimes":"0009","Daule":"0009","Duran":"0009","El Empalme":"0009","El Triunfo":"0009","General Antonio Elizalde - Bucay":"0009","Guayaquil":"0009","Isidro Ayora":"0009","Lomas De Sargentillo":"0009","Marcelino Mariduena":"0009","Milagro":"0009","Naranjal":"0009","Naranjito":"0009","Nobol":"0009","Palestina":"0009","Pedro Carbo":"0009","Playas":"0009","Samborondon":"0009","San Jacinto De Yaguachi":"0009","Santa Lucia":"0009","Simon Bolivar":"0009","Urbina Jado - Salitre":"0009"}
        "Imbabura":{"Antonio Ante":"0010","Cotacachi":"0010","Ibarra":"0010","Otavalo":"0010","Pimampiro":"0010","San Miguel De Urcuqui":"0010"}
        "Loja":{"Calvas":"0011","Catamayo":"0011","Celica":"0011","Chaguarpamba":"0011","Espindola":"0011","Gonzanama":"0011","Loja":"0011","Macara":"0011","Olmedo":"0011","Paltas":"0011","Pindal":"0011","Puyango":"0011","Quilanga":"0011","Saraguro":"0011","Sozoranga":"0011","Zapotillo":"0011"}
        "Los Rios":{"Baba":"0012","Babahoyo":"0012","Buena Fe":"0012","Mocache":"0012","Montalvo":"0012","Palenque":"0012","Puebloviejo":"0012","Quevedo":"0012","Quinsaloma":"0012","Urdaneta":"0012","Valencia":"0012","Ventanas":"0012","Vinces":"0012"}
        "Manabi":{"24 De Mayo":"0013","Bolivar":"0013","Chone":"0013","El Carmen":"0013","Flavio Alfaro":"0013","Jama":"0013","Jaramijo":"0013","Jipijapa":"0013","Junin":"0013","Manta":"0013","Montecristi":"0013","Olmedo":"0013","Pajan":"0013","Pedernales":"0013","Pichincha":"0013","Portoviejo":"0013","Puerto Lopez":"0013","Rocafuerte":"0013","San Vicente":"0013","Santa Ana":"0013","Sucre":"0013","Tosagua":"0013"}
        "Morona Santiago":{"Gualaquiza":"0014","Huamboya":"0014","Limon - Indanza":"0014","Logroño":"0014","Morona":"0014","Pablo Sexto":"0014","Palora":"0014","San Juan Bosco":"0014","Santiago":"0014","Sucua":"0014","Taisha":"0014","Tiwintza":"0014"}
        "Napo":{"Archidona":"0015","Carlos Julio Arosemena Tola":"0015","El Chaco":"0015","Quijos":"0015","Tena":"0015"}
        "Orellana":{"Aguarico":"0016","La Joya De Los Sachas":"0016","Loreto":"0016","Orellana":"0016"}
        "Pastaza":{"Arajuno":"0017","Mera":"0017","Pastaza":"0017","Santa Clara":"0017"}
        "Pichincha":{"Cayambe":"0018","Mejia":"0018","Pedro Moncayo":"0018","Pedro Vicente Maldonado":"0018","Puerto Quito":"0018","Quito":"0018","Ruminahui":"0018","San Miguel De Los Bancos":"0018"}
        "Santa Elena":{"Santa Elena":"0019","La Libertad":"0019","Salinas":"0019"}
        "Santo Domingo De Los Tsachilas":{"Santo Domingo":"0020"}
        "Sucumbios":{"Cascales":"0021","Cuyabeno":"0021","Gonzalo Pizarro":"0021","Lago Agrio":"0021","Putumayo":"0021","Shushufindi":"0021","Sucumbios":"0021"}
        "Tungurahua":{"Ambato":"0022","Banos De Agua Santa":"0022","Cevallos":"0022","Mocha":"0022","Patate":"0022","Quero":"0022","San Pedro De Pelileo":"0022","Santiago De Pillaro":"0022","Tisaleo":"0022"}
        "Zamora Chinchipe":{"Centinela Del Condor":"0023","Chinchipe":"0023","El Pangui":"0023","Nagaritza":"0023","Palanda":"0023","Paquisha":"0023","Yacuambi":"0023","Yantzaza":"0023","Zamora":"0023"}    

      @postalCodeByInput = false
      @postalCodeByState = true
      @postalCodeByCity = false

      @queryByPostalCode = false
      @queryByGeocoding = false

      @deliveryOptionsByPostalCode = true
      @deliveryOptionsByGeocordinates = false

      @basedOnStateChange = true
      @basedOnCityChange = false

      @geocodingAvailable = false
      @isStateUpperCase = false

      @regexes =
        postalCode: new RegExp(/^([\d]{4})$/)

      @masks =
        postalCode: '9999'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'postalCode', 'street', 'city', 'state',
                         'country', 'number']

      for state of @map
        prop =
          value: state.toUpperCase()
          label: state
        @states.push(prop)
        @cities[state.toUpperCase()] = _.keys(@map[state])