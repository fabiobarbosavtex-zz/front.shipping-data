define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class CountryURY
    constructor: () ->
      @country = 'URY'
      @abbr = 'UY'
      @states = []
      @cities = {}
      @map =
        "Artigas": { "Artigas": "", "Baltasar Brum": "", "Bella Unión": "", "Bernabe Rivera": "", "Calpica Itacumbú": "", "Colonia Palma": "", "Cuaró": "", "Javier De Viana": "", "Paso Campamento": "", "Sequeira": "", "Tomas Gomensoro":""}
        "Canelones": { "Aeropuerto": "", "Aguas Corrientes": "", "Araminda": "", "Argentino": "", "Atlántida": "", "Barra De Carrasco": "", "Barros Blancos": "", "Bello Horizonte": "", "Biarritz": "", "Bolívar": "", "Campo Militar": "", "Canelón Grande Represa": "", "Canelones": "", "Castellanos": "", "Chamizo": "", "Colonia Nicolich": "", "Colonia Treinta Y Tres Orientales": "", "Costa Azul": "", "Cuchilla Alta": "", "El Bosque": "", "El Dorado": "", "El Fortín De Santa Rosa": "", "El Pinar": "", "Empalme Olmos": "", "Estación Migues": "", "Estación Pedrera": "", "Estación Tapia": "", "Fray Marcos": "", "Guazuvirá": "", "Guazuvirá Nuevo": "", "Jaureguiberry": "", "Joanicó": "", "Joaquín Suárez": "", "La Escobilla": "", "La Floresta": "", "La Paz": "", "La Tuna": "", "Lagomar": "", "Las Piedras": "", "Las Toscas": "", "Las Vegas": "", "Lomas De Solymar": "", "Los Cerrillos": "", "Los Titanes": "", "Marindia": "", "Médanos De Solymar": "", "Migues": "", "Montes": "", "Neptunia": "", "Pando": "", "Paraje San Juan": "", "Parque Carrasco": "", "Parque Del Plata": "", "Paso De Carrasco": "", "Paso De Pache": "", "Paso Del Bote": "", "Piedras De Afilar": "", "Pinamar": "", "Pine Park": "", "Progreso": "", "Salinas": "", "San Antonio": "", "San Bautista": "", "San Jacinto": "", "San José De Carrasco": "", "San Luis": "", "San Ramón": "", "Santa Ana": "", "Santa Lucía": "", "Santa Lucía Del Este": "", "Santa Rosa": "", "Sauce": "", "Shangrila": "", "Soca": "", "Solymar": "", "Tala": "", "Toledo": "", "Villa Argentina": "", "Villa Del Mar":""}
        "Cerro Largo": { "Aceguá": "", "Bañado De Medina": "", "Cerro De Las Cuentas": "", "Fraile Muerto": "", "Isidoro Noblía": "", "Melo": "", "Plácido Rosas": "", "Río Branco": "", "Tupambaé":""}
        "Colonia": { "Agraciada": "", "Artilleros": "", "Barker": "", "Campana": "", "Carmelo": "", "Colonia": "", "Colonia Valdense": "", "Conchillas": "", "Cufré": "", "Florencio Sánchez": "", "Juan Lacaze": "", "La Estanzuela": "", "La Paz": "", "Los Pinos": "", "Miguelete": "", "Minuano": "", "Nueva Helvecia": "", "Nueva Palmira": "", "Ombúes De Lavalle": "", "Playa Fomento": "", "Riachuelo": "", "Rosario": "", "Santa Ana": "", "Tarariras":""}
        "Durazno": { "Blanquillo": "", "Carlos Reyles": "", "Centenario": "", "Durazno": "", "Feliciano": "", "La Paloma": "", "Santa Bernardina": "", "Sarandí Del Yí":""}
        "Flores": { "Andresito": "", "Ismael Cortinas": "", "Trinidad":""}
        "Florida": { "25 De Agosto": "", "25 De Mayo": "", "Capilla Del Sauce": "", "Cardal": "", "Casupá": "", "Cerro Colorado": "", "Chamizo": "", "Florida": "", "Fray Marcos": "", "Goñi": "", "Independencia": "", "La Cruz": "", "Mendoza Chico": "", "Mendoza Grande": "", "Monte Coral": "", "Pintado": "", "Polanco Del Yí": "", "Puntas De Maciel": "", "Reboledo": "", "Sarandí Grande":""}
        "Lavalleja": { "Colón": "", "Estación Solís": "", "Illescas": "", "José Batlle Y Ordóñez": "", "José Pedro Varela": "", "Mariscala": "", "Minas": "", "Nico Pérez": "", "Pirarajá": "", "Polanco Norte": "", "Solís De Mataojo": "", "Valentines": "", "Zapicán":""}
        "Maldonado": { "Aiguá": "", "Garzón": "", "José Ignacio": "", "La Barra": "", "Las Flores": "", "Maldonado": "", "Manantiales": "", "Pan De Azúcar": "", "Pinares - Las Delicias": "", "Piriápolis": "", "Playa Verde": "", "Punta Ballena": "", "Punta Del Este": "", "San Carlos": "", "San Rafael - El Placer": "", "Sauce De Portezuelo": "", "Solís":""}
        "Montevideo": { "Montevideo":""}
        "Paysandú": { "Algorta": "", "Beisso": "", "Cerro Chato": "", "Chapicuy": "", "Eucaliptus": "", "Gallinal": "", "Guichón": "", "Lorenzo Geyres": "", "Merinos": "", "P. Pandule": "", "Paysandú": "", "Piedras Coloradas": "", "Piñera": "", "Porvenir": "", "Quebracho": "", "San Javier":""}
        "Rio Negro": { "Algorta": "", "Bellaco": "", "Fray Bentos": "", "Menafra": "", "Nuevo Berlín": "", "Paso De Los Mellizos": "", "San Javier": "", "Sarandí De Navarro": "", "Young":""}
        "Rivera": { "Lapuente": "", "Masoller": "", "Minas De Corrales": "", "Rivera": "", "Tranqueras": "", "Vichadero":""}
        "Rocha": { "18 De Julio": "", "19 De Abril": "", "Aguas Dulces": "", "Arachania": "", "Barra Del Chuy": "", "Castillos": "", "Cebollatí": "", "Chuy": "", "La Aguada - Costa Azul": "", "La Coronilla": "", "La Paloma": "", "La Pedrera": "", "Lascano": "", "Punta Del Diablo": "", "Rocha": "", "San Luis Al Medio": "", "Velázquez":""}
        "Salto": { "Belén": "", "Biassini": "", "Cerro De Vera": "", "Colonia Itapebí": "", "Constitución": "", "Palomas": "", "Puntas De Alentín": "", "Salto": "", "San Antonio": "", "Sarandí Del Arapey": "", "Saucedo": "", "Termas Del Arapey":""}
        "San Jose": { "Capurro": "", "Delta Del Tigre": "", "Ecilda Paullier": "", "Ituzaingó": "", "Juan Soler": "", "Kiyú - Ordeig": "", "Libertad": "", "Mal Abrigo": "", "Playa Pascual": "", "Puntas De Valdés": "", "Rafael Perazza": "", "Rincón De La Bolsa": "", "San José De Mayo": "", "Villa María": "", "Villa Rodriguez":""}
        "Soriano": { "Cañada Nieto": "", "Cardona": "", "Cuchilla Del Perdido": "", "Dolores": "", "Egaña": "", "José Enrique Rodó": "", "Mercedes": "", "Palmar": "", "Palmitas": "", "Palo Solo": "", "Risso": "", "Santa Catalina": "", "Villa Darwin": "", "Villa De Soriano":""}
        "Tacuarembó": { "Achar": "", "Ansina": "", "Cardoso": "", "Chamberlain": "", "Cuchilla De Peralta": "", "Curtina": "", "La Pedrera": "", "Las Toscas": "", "Laureles": "", "Paso Bonilla": "", "Paso De Los Toros": "", "Paso Del Cerro": "", "Piedra Sola": "", "San Gregorio De Polanco": "", "Tacuarembó": "", "Tambores": "", "Valle Edén":""}
        "Treinta Y Tres": { "Cerro Chato": "", "Isla Patrulla": "", "María Albina": "", "Santa Clara De Olimar": "", "Treinta Y Tres": "", "Valentines": "", "Vergara":""}
      

      @postalCodeByInput = true
      @postalCodeByState = false
      @postalCodeByCity = false

      @queryByPostalCode = false
      @queryByGeocoding = false

      @deliveryOptionsByPostalCode = true
      @deliveryOptionsByGeocordinates = false

      @basedOnStateChange = true
      @geocodingAvailable = false

      @dontKnowPostalCodeURL = "http://geo.correo.com.uy/IsisBusquedaDireccionPlugin/cp.jsp"

      @regexes =
        postalCode: new RegExp(/^([\d]{5})$/)

      @masks =
        postalCode: '99999'

      @requiredFields = ['addressType', 'addressId', 'receiverName',
                         'postalCode', 'street', 'city', 'state',
                         'country', 'number']
      for state of @map
        @states.push(state)
        @cities[state] = _.map(@map[state], (k, v) -> return v )