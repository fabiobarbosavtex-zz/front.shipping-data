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
        "Artigas": { "Artigas": "", "Baltasar Brum": "", "Bella Unión": "", "Bernabe Rivera": "", "Calpica Itacumbú": "", "Colonia Palma": "", "Cuaró": "", "Javier de Viana": "", "Paso Campamento": "", "Sequeira": "", "Tomas Gomensoro":""}
        "Canelones": { "Aeropuerto": "", "Aguas Corrientes": "", "Araminda": "", "Argentino": "", "Atlántida": "", "Barra de carrasco": "", "Barros Blancos": "", "Bello Horizonte": "", "Biarritz": "", "Bolívar": "", "Campo Militar": "", "Canelón Grande Represa": "", "Canelones": "", "Castellanos": "", "Chamizo": "", "Colonia Nicolich": "", "Colonia Treinta y Tres Orientales": "", "Costa Azul": "", "Cuchilla Alta": "", "El Bosque": "", "El Dorado": "", "El Fortín de Santa Rosa": "", "El Pinar": "", "Empalme Olmos": "", "Estación Migues": "", "Estación Pedrera": "", "Estación Tapia": "", "Fray Marcos": "", "Guazuvirá": "", "Guazuvirá Nuevo": "", "Jaureguiberry": "", "Joanicó": "", "Joaquín Suárez": "", "La Escobilla": "", "La Floresta": "", "La Paz": "", "La Tuna": "", "Lagomar": "", "Las Piedras": "", "Las Toscas": "", "Las Vegas": "", "Lomas de Solymar": "", "Los Cerrillos": "", "Los Titanes": "", "Marindia": "", "Médanos de Solymar": "", "Migues": "", "Montes": "", "Neptunia": "", "Pando": "", "Paraje San Juan": "", "Parque Carrasco": "", "Parque del Plata": "", "Paso de Carrasco": "", "Paso de Pache": "", "Paso del Bote": "", "Piedras de Afilar": "", "Pinamar": "", "Pine Park": "", "Progreso": "", "Salinas": "", "San Antonio": "", "San Bautista": "", "San Jacinto": "", "San José de Carrasco": "", "San Luis": "", "San Ramón": "", "Santa Ana": "", "Santa Lucía": "", "Santa Lucía del Este": "", "Santa Rosa": "", "Sauce": "", "Shangrila": "", "Soca": "", "Solymar": "", "Tala": "", "Toledo": "", "Villa Argentina": "", "Villa del Mar":""}
        "Cerro Largo": { "Aceguá": "", "Bañado de Medina": "", "Cerro de las Cuentas": "", "Fraile Muerto": "", "Isidoro Noblía": "", "Melo": "", "Plácido Rosas": "", "Río Branco": "", "Tupambaé":""}
        "Colonia": { "Agraciada": "", "Artilleros": "", "Barker": "", "Campana": "", "Carmelo": "", "Colonia": "", "Colonia Valdense": "", "Conchillas": "", "Cufré": "", "Florencio Sánchez": "", "Juan Lacaze": "", "La Estanzuela": "", "La Paz": "", "Los Pinos": "", "Miguelete": "", "Minuano": "", "Nueva Helvecia": "", "Nueva Palmira": "", "Ombúes de Lavalle": "", "Playa Fomento": "", "Riachuelo": "", "Rosario": "", "Santa Ana": "", "Tarariras":""}
        "Durazno": { "Blanquillo": "", "Carlos Reyles": "", "Centenario": "", "Durazno": "", "Feliciano": "", "La Paloma": "", "Santa Bernardina": "", "Sarandí del Yí":""}
        "Flores": { "Andresito": "", "Ismael Cortinas": "", "Trinidad":""}
        "Florida": { "25 de Agosto": "", "25 de Mayo": "", "Capilla del Sauce": "", "Cardal": "", "Casupá": "", "Cerro Colorado": "", "Chamizo": "", "Florida": "", "Fray Marcos": "", "Goñi": "", "Independencia": "", "La Cruz": "", "Mendoza Chico": "", "Mendoza Grande": "", "Monte Coral": "", "Pintado": "", "Polanco del Yí": "", "Puntas de Maciel": "", "Reboledo": "", "Sarandí Grande":""}
        "Lavalleja": { "Colón": "", "Estación Solís": "", "Illescas": "", "José Batlle y Ordóñez": "", "José Pedro Varela": "", "Mariscala": "", "Minas": "", "Nico Pérez": "", "Pirarajá": "", "Polanco Norte": "", "Solís de Mataojo": "", "Valentines": "", "Zapicán":""}
        "Maldonado": { "Aiguá": "", "Garzón": "", "José Ignacio": "", "La Barra": "", "Las Flores": "", "Maldonado": "", "Manantiales": "", "Pan de Azúcar": "", "Pinares - Las Delicias": "", "Piriápolis": "", "Playa Verde": "", "Punta Ballena": "", "Punta del Este": "", "San Carlos": "", "San Rafael - El Placer": "", "Sauce de Portezuelo": "", "Solís":""}
        "Montevideo": { "Montevideo":""}
        "Paysandú": { "Algorta": "", "Beisso": "", "Cerro Chato": "", "Chapicuy": "", "Eucaliptus": "", "Gallinal": "", "Guichón": "", "Lorenzo Geyres": "", "Merinos": "", "P. Pandule": "", "Paysandú": "", "Piedras Coloradas": "", "Piñera": "", "Porvenir": "", "Quebracho": "", "San Javier":""}
        "Rio Negro": { "Algorta": "", "Bellaco": "", "Fray Bentos": "", "Menafra": "", "Nuevo Berlín": "", "Paso de los Mellizos": "", "San Javier": "", "Sarandí de Navarro": "", "Young":""}
        "Rivera": { "Lapuente": "", "Masoller": "", "Minas de Corrales": "", "Rivera": "", "Tranqueras": "", "Vichadero":""}
        "Rocha": { "18 de Julio": "", "19 de Abril": "", "Aguas Dulces": "", "Arachania": "", "Barra del Chuy": "", "Castillos": "", "Cebollatí": "", "Chuy": "", "La Aguada - Costa Azul": "", "La Coronilla": "", "La Paloma": "", "La Pedrera": "", "Lascano": "", "Punta del Diablo": "", "Rocha": "", "San Luis al Medio": "", "Velázquez":""}
        "Salto": { "Belén": "", "Biassini": "", "Cerro de Vera": "", "Colonia Itapebí": "", "Constitución": "", "Palomas": "", "Puntas de alentín": "", "Salto": "", "San Antonio": "", "Sarandí del Arapey": "", "Saucedo": "", "Termas del Arapey":""}
        "San Jose": { "Capurro": "", "Delta del Tigre": "", "Ecilda Paullier": "", "Ituzaingó": "", "Juan Soler": "", "Kiyú - Ordeig": "", "Libertad": "", "Mal Abrigo": "", "Playa Pascual": "", "Puntas de Valdés": "", "Rafael Perazza": "", "Rincón de la Bolsa": "", "San José de Mayo": "", "Villa María": "", "Villa Rodriguez":""}
        "Soriano": { "Cañada Nieto": "", "Cardona": "", "Cuchilla del Perdido": "", "Dolores": "", "Egaña": "", "José Enrique Rodó": "", "Mercedes": "", "Palmar": "", "Palmitas": "", "Palo Solo": "", "Risso": "", "Santa Catalina": "", "Villa Darwin": "", "Villa de Soriano":""}
        "Tacuarembó": { "Achar": "", "Ansina": "", "Cardoso": "", "Chamberlain": "", "Cuchilla de Peralta": "", "Curtina": "", "La Pedrera": "", "Las Toscas": "", "Laureles": "", "Paso Bonilla": "", "Paso de los Toros": "", "Paso del Cerro": "", "Piedra Sola": "", "San Gregorio de Polanco": "", "Tacuarembó": "", "Tambores": "", "Valle Edén":""}
        "Treinta y Tres": { "Cerro Chato": "", "Isla Patrulla": "", "María Albina": "", "Santa Clara de Olimar": "", "Treinta y Tres": "", "Valentines": "", "Vergara":""}
      

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