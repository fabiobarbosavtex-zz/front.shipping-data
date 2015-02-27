define ->
  class CountryPER
    constructor: () ->
      @country = 'PER'
      @abbr = 'PE'
      @states = []
      @cities = {}

      `this.map = {
          "Lima": {
              "Lima": {
                  "Lima": "150101",
                  "Ancon": "150102",
                  "Ate": "150103",
                  "Barranco": "150125",
                  "Breña": "150104",
                  "Carabayllo": "150105",
                  "Chaclacayo": "150107",
                  "Chorrillos": "150108",
                  "Cieneguilla": "150139",
                  "Comas": "150106",
                  "El Agustino": "150135",
                  "Independencia": "150134",
                  "Jesus Maria": "150133",
                  "La Molina": "150110",
                  "La Victoria": "150109",
                  "Lince": "150111",
                  "Los Olivos": "150142",
                  "Lurigancho": "150112",
                  "Lurin": "150113",
                  "Magdalena Del Mar": "150114",
                  "Miraflores": "150115",
                  "Pachacamac": "150116",
                  "Pucusana": "150118",
                  "Pueblo Libre": "150117",
                  "Puente Piedra": "150119",
                  "Punta Hermosa": "150120",
                  "Punta Negra": "150121",
                  "Rimac": "150122",
                  "San Bartolo": "150123",
                  "San Borja": "150140",
                  "San Isidro": "150124",
                  "San Juan De Lurigancho": "150137",
                  "San Juan De Miraflores": "150136",
                  "San Luis": "150138",
                  "San Martin De Porres": "150126",
                  "San Miguel": "150127",
                  "Santa Anita": "150143",
                  "Santa Maria Del Mar": "150128",
                  "Santa Rosa": "150129",
                  "Santiago De Surco": "150130",
                  "Surquillo": "150131",
                  "Villa El Salvador": "150141",
                  "Villa Maria Del Triunfo": "150132"
              },
              "Barranca": {
                  "Barranca": "150901",
                  "Paramonga": "150902",
                  "Pativilca": "150903",
                  "Supe": "150904",
                  "Supe Puerto": "150905"
              },
              "Cajatambo": {
                  "Cajatambo": "150201",
                  "Copa": "150205",
                  "Gorgor": "150206",
                  "Huancapon": "150207",
                  "Manas": "150208"
              },
              "Callao": {
                  "Bellavista": "070102",
                  "Callao": "070101",
                  "Carmen De La Legua Reynoso": "070103",
                  "La Perla": "070104",
                  "La Punta": "070105",
                  "Ventanilla": "070106"
              },
              "Canta": {
                  "Arahuay": "150302",
                  "Canta": "150301",
                  "Huamantanga": "150303",
                  "Huaros": "150304",
                  "Lachaqui": "150305",
                  "San Buenaventura": "150306",
                  "Santa Rosa De Quives": "150307"
              },
              "Cañete": {
                  "Asia": "150416",
                  "Calango": "150402",
                  "Cerro Azul": "150403",
                  "Chilca": "150405",
                  "Coayllo": "150404",
                  "Imperial": "150406",
                  "Lunahuana": "150407",
                  "Mala": "150408",
                  "Nuevo Imperial": "150409",
                  "Pacaran": "150410",
                  "Quilmana": "150411",
                  "San Antonio": "150412",
                  "San Luis": "150413",
                  "San Vicente De Cañete": "150401",
                  "Santa Cruz De Flores": "150414",
                  "Zuñiga": "150415"
              },
              "Huaral": {
                  "Atavillos Alto": "150802",
                  "Atavillos Bajo": "150803",
                  "Aucallama": "150804",
                  "Chancay": "150805",
                  "Huaral": "150801",
                  "Ihuari": "150806",
                  "Lampian": "150807",
                  "Pacaraos": "150808",
                  "San Miguel De Acos": "150809",
                  "Santa Cruz De Andamarca": "150811",
                  "Sumbilca": "150812",
                  "Veintisiete De Noviembre": "150810"
              },
              "Huarochiri": {
                  "Antioquia": "150602",
                  "Callahuanca": "150603",
                  "Carampoma": "150604",
                  "Casta": "150605",
                  "Chicla": "150607",
                  "Huachupampa": "150630",
                  "Huanza": "150608",
                  "Huarochiri": "150609",
                  "Lahuaytambo": "150610",
                  "Langa": "150611",
                  "Laraos": "150631",
                  "Mariatana": "150612",
                  "Matucana": "150601",
                  "Ricardo Palma": "150613",
                  "San Andres De Tupicocha": "150614",
                  "San Antonio": "150615",
                  "San Bartolome": "150616",
                  "San Damian": "150617",
                  "San Jose De Los Chorrillos": "150606",
                  "San Juan De Iris": "150632",
                  "San Juan De Tantaranche": "150619",
                  "San Lorenzo De Quinti": "150620",
                  "San Mateo": "150621",
                  "San Mateo De Otao": "150622",
                  "San Pedro De Huancayre": "150623",
                  "Sangallaya": "150618",
                  "Santa Cruz De Cocachacra": "150624",
                  "Santa Eulalia": "150625",
                  "Santiago De Anchucaya": "150626",
                  "Santiago De Tuna": "150627",
                  "Santo Domingo De Los Olleros": "150628",
                  "Surco": "150629"
              },
              "Huaura": {
                  "Ambar": "150502",
                  "Caleta De Carquin": "150504",
                  "Checras": "150505",
                  "Huacho": "150501",
                  "Hualmay": "150506",
                  "Huaura": "150507",
                  "Leoncio Prado": "150508",
                  "Paccho": "150509",
                  "Santa Leonor": "150511",
                  "Santa Maria": "150512",
                  "Sayan": "150513",
                  "Vegueta": "150516"
              },
              "Oyon": {
                  "Andajes": "151004",
                  "Caujul": "151003",
                  "Cochamarca": "151006",
                  "Navan": "151002",
                  "Oyon": "151001",
                  "Pachangara": "151005"
              },
              "Yauyos": {
                  "Alis": "150702",
                  "Allauca": "150703",
                  "Ayaviri": "150704",
                  "Azangaro": "150705",
                  "Cacra": "150706",
                  "Carania": "150707",
                  "Catahuasi": "150733",
                  "Chocos": "150710",
                  "Cochas": "150708",
                  "Colonia": "150709",
                  "Hongos": "150730",
                  "Huampara": "150711",
                  "Huancaya": "150712",
                  "Huangascar": "150713",
                  "Huantan": "150714",
                  "Huañec": "150715",
                  "Laraos": "150716",
                  "Lincha": "150717",
                  "Madean": "150731",
                  "Miraflores": "150718",
                  "Omas": "150719",
                  "Putinza": "150732",
                  "Quinches": "150720",
                  "Quinocay": "150721",
                  "San Joaquin": "150722",
                  "San Pedro De Pilas": "150723",
                  "Tanta": "150724",
                  "Tauripampa": "150725",
                  "Tomas": "150727",
                  "Tupe": "150726",
                  "Vitis": "150729",
                  "Viñc": "150728",
                  "Yauyos": "150701"
              }
          },
          "Amazonas": {
              "Bagua": {
                  "Aramango": "010202",
                  "Bagua": "010205",
                  "Copallin": "010203",
                  "El Parco": "010204",
                  "Imaza": "010206",
                  "La Peca": "010201"
              },
              "Bongara": {
                  "Chisquilla": "010304",
                  "Churuja": "010305",
                  "Corosha": "010302",
                  "Cuispes": "010303",
                  "Florida": "010306",
                  "Jazan": "010312",
                  "Jumbilla": "010301",
                  "Recta": "010307",
                  "San Carlos": "010308",
                  "Shipasbamba": "010309",
                  "Valera": "010310",
                  "Yambrasbamba": "010311"
              },
              "Chachapoyas": {
                  "Asuncion": "010102",
                  "Balsas": "010103",
                  "Chachapoyas": "010101",
                  "Cheto": "010104",
                  "Chiliquin": "010105",
                  "Chuquibamba": "010106",
                  "Granada": "010107",
                  "Huancas": "010108",
                  "La Jalca": "010109",
                  "Leimebamba": "010110",
                  "Levanto": "010111",
                  "Magdalena": "010112",
                  "Mariscal Castilla": "010113",
                  "Molinopampa": "010114",
                  "Montevideo": "010115",
                  "Olleros": "010116",
                  "Quinjalca": "010117",
                  "San Francisco De Daguas": "010118",
                  "San Isidro De Maino": "010119",
                  "Soloco": "010120",
                  "Sonche": "010121"
              },
              "Condorcanqui": {
                  "El Cenepa": "010603",
                  "Nieva": "010601",
                  "Rio Santiago": "010602"
              },
              "Luya": {
                  "Camporredondo": "010402",
                  "Cocabamba": "010403",
                  "Colcamar": "010404",
                  "Conila": "010405",
                  "Inguilpata": "010406",
                  "Lamud": "010401",
                  "Longuita": "010407",
                  "Lonya Chico": "010408",
                  "Luya": "010409",
                  "Luya Viejo": "010410",
                  "Maria": "010411",
                  "Ocalli": "010412",
                  "Ocumal": "010413",
                  "Pisuquia": "010414",
                  "Providencia": "010423",
                  "San Cristobal": "010415",
                  "San Francisco De Yeso": "010416",
                  "San Jeronimo": "010417",
                  "San Juan De Lopecancha": "010418",
                  "Santa Catalina": "010419",
                  "Santo Tomas": "010420",
                  "Tingo": "010421",
                  "Trita": "010422"
              },
              "Rodriguez De Mendoza": {
                  "Chirimoto": "010503",
                  "Cochamal": "010502",
                  "Huambo": "010504",
                  "Limabamba": "010505",
                  "Longar": "010506",
                  "Mariscal Benavides": "010508",
                  "Milpucc": "010507",
                  "Omia": "010509",
                  "San Nicolas": "010501",
                  "Santa Rosa": "010510",
                  "Totora": "010511",
                  "Vista Alegre": "010512"
              },
              "Utcubamba": {
                  "Bagua Grande": "010701",
                  "Cajaruro": "010702",
                  "Cumba": "010703",
                  "El Milagro": "010704",
                  "Jamalca": "010705",
                  "Lonya Grande": "010706",
                  "Yamon": "010707"
              }
          },
          "Ancash": {
              "Aija": {
                  "Aija": "020201",
                  "Coris": "020203",
                  "Huacllan": "020205",
                  "La Merced": "020206",
                  "Succha": "020208"
              },
              "Antonio Raimondi": {
                  "Aczo": "021602",
                  "Chaccho": "021603",
                  "Chingas": "021604",
                  "Llamellin": "021601",
                  "Mirgas": "021605",
                  "San Juan De Rontoy": "021606"
              },
              "Asuncion": {
                  "Acochaca": "021802",
                  "Chacas": "021801"
              },
              "Bolognesi": {
                  "Abelardo Pardo Lezameta": "020302",
                  "Antonio Raimondi": "020321",
                  "Aquia": "020304",
                  "Cajacay": "020305",
                  "Canis": "020322",
                  "Chiquian": "020301",
                  "Colquioc": "020323",
                  "Huallanca": "020325",
                  "Huasta": "020311",
                  "Huayllacayan": "020310",
                  "La Primavera": "020324",
                  "Mangas": "020313",
                  "Pacllon": "020315",
                  "San Miguel De Corpanqui": "020317",
                  "Ticllos": "020320"
              },
              "Carhuaz": {
                  "Acopampa": "020402",
                  "Amashca": "020403",
                  "Anta": "020404",
                  "Ataquero": "020405",
                  "Carhuaz": "020401",
                  "Marcara": "020406",
                  "Pariahuanca": "020407",
                  "San Miguel De Aco": "020408",
                  "Shilla": "020409",
                  "Tinco": "020410",
                  "Yungar": "020411"
              },
              "Carlos Fermin Fitzcarrald": {
                  "San Luis": "021701",
                  "San Nicolas": "021703",
                  "Yauya": "021702"
              },
              "Casma": {
                  "Buena Vista Alta": "020502",
                  "Casma": "020501",
                  "Comandante Noel": "020503",
                  "Yautan": "020505"
              },
              "Corongo": {
                  "Aco": "020602",
                  "Bambas": "020603",
                  "Corongo": "020601",
                  "Cusca": "020604",
                  "La Pampa": "020605",
                  "Yanac": "020606",
                  "Yupan": "020607"
              },
              "Huaraz": {
                  "Cochabamba": "020103",
                  "Colcabamba": "020104",
                  "Huanchay": "020105",
                  "Huaraz": "020101",
                  "Independencia": "020102",
                  "Jangas": "020106",
                  "La Libertad": "020107",
                  "Olleros": "020108",
                  "Pampas Grande": "020109",
                  "Pariacoto": "020110",
                  "Pira": "020111",
                  "Tarica": "020112"
              },
              "Huari": {
                  "Anra": "020816",
                  "Cajay": "020802",
                  "Chavin De Huantar": "020803",
                  "Huacachi": "020804",
                  "Huacchis": "020806",
                  "Huachis": "020805",
                  "Huantar": "020807",
                  "Huari": "020801",
                  "Masin": "020808",
                  "Paucas": "020809",
                  "Ponto": "020810",
                  "Rahuapampa": "020811",
                  "Rapayan": "020812",
                  "San Marcos": "020813",
                  "San Pedro De Chana": "020814",
                  "Uco": "020815"
              },
              "Huarmey": {
                  "Cochapeti": "021902",
                  "Culebras": "021905",
                  "Huarmey": "021901",
                  "Huayan": "021903",
                  "Malvas": "021904"
              },
              "Huaylas": {
                  "Caraz": "020701",
                  "Huallanca": "020702",
                  "Huata": "020703",
                  "Huaylas": "020704",
                  "Mato": "020705",
                  "Pamparomas": "020706",
                  "Pueblo Libre": "020707",
                  "Santa Cruz": "020708",
                  "Santo Toribio": "020710",
                  "Yuracmarca": "020709"
              },
              "Mariscal Luzuriaga": {
                  "Casca": "020902",
                  "Eleazar Guzman Barron": "020908",
                  "Fidel Olivas Escudero": "020904",
                  "Llama": "020905",
                  "Llumpa": "020906",
                  "Lucma": "020903",
                  "Musga": "020907",
                  "Piscobamba": "020901"
              },
              "Ocros": {
                  "Acas": "022001",
                  "Cajamarquilla": "022002",
                  "Carhuapampa": "022003",
                  "Cochas": "022004",
                  "Congas": "022005",
                  "Llipa": "022006",
                  "Ocros": "022007",
                  "San Cristobal De Rajan": "022008",
                  "San Pedro": "022009",
                  "Santiago De Chilcas": "022010"
              },
              "Pallasca": {
                  "Bolognesi": "021002",
                  "Cabana": "021001",
                  "Conchucos": "021003",
                  "Huacaschuque": "021004",
                  "Huandoval": "021005",
                  "Lacabamba": "021006",
                  "Llapo": "021007",
                  "Pallasca": "021008",
                  "Pampas": "021009",
                  "Santa Rosa": "021010",
                  "Tauca": "021011"
              },
              "Pomabamba": {
                  "Huayllan": "021102",
                  "Parobamba": "021103",
                  "Pomabamba": "021101",
                  "Quinuabamba": "021104"
              },
              "Recuay": {
                  "Catac": "021210",
                  "Cotaparaco": "021202",
                  "Huayllapampa": "021203",
                  "Llacllin": "021209",
                  "Marca": "021204",
                  "Pampas Chico": "021205",
                  "Pararin": "021206",
                  "Recuay": "021201",
                  "Tapacocha": "021207",
                  "Ticapampa": "021208"
              },
              "Santa": {
                  "Caceres Del Peru": "021302",
                  "Chimbote": "021301",
                  "Coishco": "021308",
                  "Macate": "021303",
                  "Moro": "021304",
                  "Nepeñ": "021305",
                  "Nuevo Chimbote": "021309",
                  "Samanco": "021306",
                  "Santa": "021307"
              },
              "Sihuas": {
                  "Acobamba": "021407",
                  "Alfonso Ugarte": "021402",
                  "Cashapampa": "021408",
                  "Chingalpo": "021403",
                  "Huayllabamba": "021404",
                  "Quiches": "021405",
                  "Ragash": "021409",
                  "San Juan": "021410",
                  "Sicsibamba": "021406",
                  "Sihuas": "021401"
              },
              "Yungay": {
                  "Cascapara": "021502",
                  "Mancos": "021503",
                  "Matacoto": "021504",
                  "Quillo": "021505",
                  "Ranrahirca": "021506",
                  "Shupluy": "021507",
                  "Yanama": "021508",
                  "Yungay": "021501"
              }
          },
          "Apurimac": {
              "Abancay": {
                  "Abancay": "030101",
                  "Chacoche": "030104",
                  "Circa": "030102",
                  "Curahuasi": "030103",
                  "Huanipaca": "030105",
                  "Lambrama": "030106",
                  "Pichirhua": "030107",
                  "San Pedro De Cachora": "030108",
                  "Tamburco": "030109"
              },
              "Andahuaylas": {
                  "Andahuaylas": "030301",
                  "Andarapa": "030302",
                  "Chiara": "030303",
                  "Huancarama": "030304",
                  "Huancaray": "030305",
                  "Huayana": "030317",
                  "Kaquiabamba": "030319",
                  "Kishuara": "030306",
                  "Pacobamba": "030307",
                  "Pacucha": "030313",
                  "Pampachiri": "030308",
                  "Pomacocha": "030314",
                  "San Antonio De Cachi": "030309",
                  "San Jeronimo": "030310",
                  "San Miguel De Chaccrampa": "030318",
                  "Santa Maria De Chicmo": "030315",
                  "Talavera": "030311",
                  "Tumay Huaraca": "030316",
                  "Turpo": "030312"
              },
              "Antabamba": {
                  "Antabamba": "030401",
                  "El Oro": "030402",
                  "Huaquirca": "030403",
                  "Juan Espinoza Medrano": "030404",
                  "Oropesa": "030405",
                  "Pachaconas": "030406",
                  "Sabaino": "030407"
              },
              "Aymaraes": {
                  "Capaya": "030202",
                  "Caraybamba": "030203",
                  "Chalhuanca": "030201",
                  "Chapimarca": "030206",
                  "Colcabamba": "030204",
                  "Cotaruse": "030205",
                  "Huayllo": "030207",
                  "Justo Apu Sahuaraura": "030217",
                  "Lucre": "030208",
                  "Pocohuanca": "030209",
                  "San Juan De Chacñ": "030216",
                  "Sañyca": "030210",
                  "Soraya": "030211",
                  "Tapairihua": "030212",
                  "Tintay": "030213",
                  "Toraya": "030214",
                  "Yanaca": "030215"
              },
              "Chincheros": {
                  "Anco Huallo": "030705",
                  "Chincheros": "030701",
                  "Cocharcas": "030704",
                  "Huaccana": "030706",
                  "Ocobamba": "030703",
                  "Ongoy": "030702",
                  "Ranracancha": "030708",
                  "Uranmarca": "030707"
              },
              "Cotabambas": {
                  "Challhuahuacho": "030506",
                  "Cotabambas": "030503",
                  "Coyllurqui": "030502",
                  "Haquira": "030504",
                  "Mara": "030505",
                  "Tambobamba": "030501"
              },
              "Grau": {
                  "Chuquibambilla": "030601",
                  "Curasco": "030614",
                  "Curpahuasi": "030602",
                  "Huaillati": "030603",
                  "Mamara": "030604",
                  "Mariscal Gamarra": "030605",
                  "Micaela Bastidas": "030606",
                  "Pataypampa": "030608",
                  "Progreso": "030607",
                  "San Antonio": "030609",
                  "Santa Rosa": "030613",
                  "Turpay": "030610",
                  "Vilcabamba": "030611",
                  "Virundo": "030612"
              }
          },
          "Arequipa": {
              "Arequipa": {
                  "Alto Selva Alegre": "040128",
                  "Arequipa": "040101",
                  "Cayma": "040102",
                  "Cerro Colorado": "040103",
                  "Characato": "040104",
                  "Chiguata": "040105",
                  "Jacobo Hunter": "040127",
                  "Jose Luis Bustamante Y Rivero": "040129",
                  "La Joya": "040106",
                  "Mariano Melgar": "040126",
                  "Miraflores": "040107",
                  "Mollebaya": "040108",
                  "Paucarpata": "040109",
                  "Pocsi": "040110",
                  "Polobaya": "040111",
                  "Quequeñ": "040112",
                  "Sabandia": "040113",
                  "Sachaca": "040114",
                  "San Juan De Siguas": "040115",
                  "San Juan De Tarucani": "040116",
                  "Santa Isabel De Siguas": "040117",
                  "Santa Rita De Sihuas": "040118",
                  "Socabaya": "040119",
                  "Tiabaya": "040120",
                  "Uchumayo": "040121",
                  "Vitor": "040122",
                  "Yanahuara": "040123",
                  "Yarabamba": "040124",
                  "Yura": "040125"
              },
              "Camana": {
                  "Camana": "040301",
                  "Jose Maria Quimper": "040302",
                  "Mariano Nicolas Valcarcel": "040303",
                  "Mariscal Caceres": "040304",
                  "Nicolas De Pierola": "040305",
                  "Ocoñ": "040306",
                  "Quilca": "040307",
                  "Samuel Pastor": "040308"
              },
              "Caraveli": {
                  "Acari": "040402",
                  "Atico": "040403",
                  "Atiquipa": "040404",
                  "Bella Union": "040405",
                  "Cahuacho": "040406",
                  "Caraveli": "040401",
                  "Chala": "040407",
                  "Chaparra": "040408",
                  "Huanuhuanu": "040409",
                  "Jaqui": "040410",
                  "Lomas": "040411",
                  "Quicacha": "040412",
                  "Yauca": "040413"
              },
              "Castilla": {
                  "Andagua": "040502",
                  "Aplao": "040501",
                  "Ayo": "040503",
                  "Chachas": "040504",
                  "Chilcaymarca": "040505",
                  "Choco": "040506",
                  "Huancarqui": "040507",
                  "Machaguay": "040508",
                  "Orcopampa": "040509",
                  "Pampacolca": "040510",
                  "Tipan": "040511",
                  "Uraca": "040512",
                  "Uñon": "040513",
                  "Viraco": "040514"
              },
              "Caylloma": {
                  "Achoma": "040202",
                  "Cabanaconde": "040203",
                  "Callalli": "040205",
                  "Caylloma": "040204",
                  "Chivay": "040201",
                  "Coporaque": "040206",
                  "Huambo": "040207",
                  "Huanca": "040208",
                  "Ichupampa": "040209",
                  "Lari": "040210",
                  "Lluta": "040211",
                  "Maca": "040212",
                  "Madrigal": "040213",
                  "Majes": "040220",
                  "San Antonio De Chuca": "040214",
                  "Sibayo": "040215",
                  "Tapay": "040216",
                  "Tisco": "040217",
                  "Tuti": "040218",
                  "Yanque": "040219"
              },
              "Condesuyos": {
                  "Andaray": "040602",
                  "Cayarani": "040603",
                  "Chichas": "040604",
                  "Chuquibamba": "040601",
                  "Iray": "040605",
                  "Rio Grande": "040608",
                  "Salamanca": "040606",
                  "Yanaquihua": "040607"
              },
              "Islay": {
                  "Cocachacra": "040702",
                  "Dean Valdivia": "040703",
                  "Islay": "040704",
                  "Mejia": "040705",
                  "Mollendo": "040701",
                  "Punta De Bombon": "040706"
              },
              "La Union": {
                  "Alca": "040802",
                  "Charcana": "040803",
                  "Cotahuasi": "040801",
                  "Huaynacotas": "040804",
                  "Pampamarca": "040805",
                  "Puyca": "040806",
                  "Quechualla": "040807",
                  "Sayla": "040808",
                  "Tauria": "040809",
                  "Tomepampa": "040810",
                  "Toro": "040811"
              }
          },
          "Ayacucho": {
              "Cangallo": {
                  "Cangallo": "050201",
                  "Chuschi": "050204",
                  "Los Morochucos": "050206",
                  "Maria Parado De Bellido": "050211",
                  "Paras": "050207",
                  "Totos": "050208"
              },
              "Huamanga": {
                  "Acocro": "050111",
                  "Acos Vinchos": "050102",
                  "Ayacucho": "050101",
                  "Carmen Alto": "050103",
                  "Chiara": "050104",
                  "Jesus Nazareno": "050115",
                  "Ocros": "050113",
                  "Pacaycasa": "050114",
                  "Quinua": "050105",
                  "San Jose De Ticllas": "050106",
                  "San Juan Bautista": "050107",
                  "Santiago De Pischa": "050108",
                  "Socos": "050112",
                  "Tambillo": "050110",
                  "Vinchos": "050109"
              },
              "Huanca Sancos": {
                  "Carapo": "050804",
                  "Sacsamarca": "050802",
                  "Sancos": "050801",
                  "Santiago De Lucanamarca": "050803"
              },
              "Huanta": {
                  "Ayahuanco": "050302",
                  "Huamanguilla": "050303",
                  "Huanta": "050301",
                  "Iguain": "050304",
                  "Llochegua": "050309",
                  "Luricocha": "050305",
                  "Santillana": "050307",
                  "Sivia": "050308"
              },
              "La Mar": {
                  "Anco": "050402",
                  "Ayna": "050403",
                  "Chilcas": "050404",
                  "Chungui": "050405",
                  "Luis Carranza": "050407",
                  "Samugari": "050409",
                  "San Miguel": "050401",
                  "Santa Rosa": "050408",
                  "Tambo": "050406"
              },
              "Lucanas": {
                  "Aucara": "050502",
                  "Cabana": "050503",
                  "Carmen Salcedo": "050504",
                  "Chaviñ": "050506",
                  "Chipao": "050508",
                  "Huac-huas": "050510",
                  "Laramate": "050511",
                  "Leoncio Prado": "050512",
                  "Llauta": "050514",
                  "Lucanas": "050513",
                  "Ocañ": "050516",
                  "Otoca": "050517",
                  "Puquio": "050501",
                  "Saisa": "050529",
                  "San Cristobal": "050532",
                  "San Juan": "050521",
                  "San Pedro": "050522",
                  "San Pedro De Palco": "050531",
                  "Sancos": "050520",
                  "Santa Ana De Huaycahuacho": "050524",
                  "Santa Lucia": "050525"
              },
              "Parinacochas": {
                  "Chumpi": "050605",
                  "Coracora": "050601",
                  "Coronel Castañeda": "050604",
                  "Pacapausa": "050608",
                  "Pullo": "050611",
                  "Puyusca": "050612",
                  "San Francisco De Ravacayco": "050615",
                  "Upahuacho": "050616"
              },
              "Paucar Del Sara Sara": {
                  "Colta": "051002",
                  "Corculla": "051003",
                  "Lampa": "051004",
                  "Marcabamba": "051005",
                  "Oyolo": "051006",
                  "Pararca": "051007",
                  "Pausa": "051001",
                  "San Javier De Alpabamba": "051008",
                  "San Jose De Ushua": "051009",
                  "Sara Sara": "051010"
              },
              "Sucre": {
                  "Belen": "051102",
                  "Chalcos": "051103",
                  "Chilcayoc": "051110",
                  "Huacañ": "051109",
                  "Morcolla": "051111",
                  "Paico": "051105",
                  "Querobamba": "051101",
                  "San Pedro De Larcay": "051107",
                  "San Salvador De Quije": "051104",
                  "Santiago De Paucaray": "051106",
                  "Soras": "051108"
              },
              "Victor Fajardo": {
                  "Alcamenca": "050702",
                  "Apongo": "050703",
                  "Asquipata": "050715",
                  "Canaria": "050704",
                  "Cayara": "050706",
                  "Colca": "050707",
                  "Hualla": "050708",
                  "Huamanquiquia": "050709",
                  "Huancapi": "050701",
                  "Huancaraylla": "050710",
                  "Sarhua": "050713",
                  "Vilcanchos": "050714"
              },
              "Vilcas Huaman": {
                  "Accomarca": "050903",
                  "Carhuanca": "050904",
                  "Concepcion": "050905",
                  "Huambalpa": "050906",
                  "Independencia": "050908",
                  "Saurama": "050907",
                  "Vilcas Huaman": "050901",
                  "Vischongo": "050902"
              }
          },
          "Cajamarca": {
              "Cajabamba": {
                  "Cachachi": "060202",
                  "Cajabamba": "060201",
                  "Condebamba": "060203",
                  "Sitacocha": "060205"
              },
              "Cajamarca": {
                  "Asuncion": "060102",
                  "Cajamarca": "060101",
                  "Chetilla": "060104",
                  "Cospan": "060103",
                  "Encañda": "060105",
                  "Jesus": "060106",
                  "Llacanora": "060108",
                  "Los Baños Del Inca": "060107",
                  "Magdalena": "060109",
                  "Matara": "060110",
                  "Namora": "060111",
                  "San Juan": "060112"
              },
              "Celendin": {
                  "Celendin": "060301",
                  "Chumuch": "060303",
                  "Cortegana": "060302",
                  "Huasmin": "060304",
                  "Jorge Chavez": "060305",
                  "Jose Galvez": "060306",
                  "La Libertad De Pallan": "060312",
                  "Miguel Iglesias": "060307",
                  "Oxamarca": "060308",
                  "Sorochuco": "060309",
                  "Sucre": "060310",
                  "Utco": "060311"
              },
              "Chota": {
                  "Anguia": "060602",
                  "Chadin": "060605",
                  "Chalamarca": "060619",
                  "Chiguirip": "060606",
                  "Chimban": "060607",
                  "Choropampa": "060618",
                  "Chota": "060601",
                  "Cochabamba": "060603",
                  "Conchan": "060604",
                  "Huambos": "060608",
                  "Lajas": "060609",
                  "Llama": "060610",
                  "Miracosta": "060611",
                  "Paccha": "060612",
                  "Pion": "060613",
                  "Querocoto": "060614",
                  "San Juan De Licupis": "060617",
                  "Tacabamba": "060615",
                  "Tocmoche": "060616"
              },
              "Contumaza": {
                  "Chilete": "060403",
                  "Contumaza": "060401",
                  "Cupisnique": "060406",
                  "Guzmango": "060404",
                  "San Benito": "060405",
                  "Santa Cruz De Toled": "060409",
                  "Tantarica": "060407",
                  "Yonan": "060408"
              },
              "Cutervo": {
                  "Callayuc": "060502",
                  "Choros": "060504",
                  "Cujillo": "060503",
                  "Cutervo": "060501",
                  "La Ramada": "060505",
                  "Pimpingos": "060506",
                  "Querocotillo": "060507",
                  "San Andres De Cutervo": "060508",
                  "San Juan De Cutervo": "060509",
                  "San Luis De Lucma": "060510",
                  "Santa Cruz": "060511",
                  "Santo Domingo De La Capilla": "060512",
                  "Santo Tomas": "060513",
                  "Socota": "060514",
                  "Toribio Casanova": "060515"
              },
              "Hualgayoc": {
                  "Bambamarca": "060701",
                  "Chugur": "060702",
                  "Hualgayoc": "060703"
              },
              "Jaen": {
                  "Bellavista": "060802",
                  "Chontali": "060804",
                  "Colasay": "060803",
                  "Huabal": "060812",
                  "Jaen": "060801",
                  "Las Pirias": "060811",
                  "Pomahuaca": "060805",
                  "Pucara": "060806",
                  "Sallique": "060807",
                  "San Felipe": "060808",
                  "San Jose Del Alto": "060809",
                  "Santa Rosa": "060810"
              },
              "San Ignacio": {
                  "Chirinos": "061102",
                  "Huarango": "061103",
                  "La Coipa": "061105",
                  "Namballe": "061104",
                  "San Ignacio": "061101",
                  "San Jose De Lourdes": "061106",
                  "Tabaconas": "061107"
              },
              "San Marcos": {
                  "Chancay": "061207",
                  "Eduardo Villanueva": "061205",
                  "Gregorio Pita": "061203",
                  "Ichocan": "061202",
                  "Jose Manuel Quiroz": "061204",
                  "Jose Sabogal": "061206",
                  "Pedro Galvez": "061201"
              },
              "San Miguel": {
                  "Bolivar": "061013",
                  "Calquis": "061002",
                  "Catilluc": "061012",
                  "El Prado": "061009",
                  "La Florida": "061003",
                  "Llapa": "061004",
                  "Nanchoc": "061005",
                  "Niepos": "061006",
                  "San Gregorio": "061007",
                  "San Miguel": "061001",
                  "San Silvestre De Cochan": "061008",
                  "Tongod": "061011",
                  "Union Agua Blanca": "061010"
              },
              "San Pablo": {
                  "San Bernardino": "061302",
                  "San Luis": "061303",
                  "San Pablo": "061301",
                  "Tumbaden": "061304"
              },
              "Santa Cruz": {
                  "Andabamba": "060910",
                  "Catache": "060902",
                  "Chancaybaños": "060903",
                  "La Esperanza": "060904",
                  "Ninabamba": "060905",
                  "Pulan": "060906",
                  "Santa Cruz": "060901",
                  "Saucepampa": "060911",
                  "Sexi": "060907",
                  "Uticyacu": "060908",
                  "Yauyucan": "060909"
              }
          },
          "Cusco": {
              "Acomayo": {
                  "Acomayo": "080201",
                  "Acopia": "080202",
                  "Acos": "080203",
                  "Mosoc Llacta": "080207",
                  "Pomacanchi": "080204",
                  "Rondocan": "080205",
                  "Sangarara": "080206"
              },
              "Anta": {
                  "Ancahuasi": "080309",
                  "Anta": "080301",
                  "Cachimayo": "080308",
                  "Chinchaypujio": "080302",
                  "Huarocondo": "080303",
                  "Limatambo": "080304",
                  "Mollepata": "080305",
                  "Pucyura": "080306",
                  "Zurite": "080307"
              },
              "Calca": {
                  "Calca": "080401",
                  "Coya": "080402",
                  "Lamay": "080403",
                  "Lares": "080404",
                  "Pisac": "080405",
                  "San Salvador": "080406",
                  "Taray": "080407",
                  "Yanatile": "080408"
              },
              "Canas": {
                  "Checca": "080502",
                  "Kunturkanki": "080503",
                  "Langui": "080504",
                  "Layo": "080505",
                  "Pampamarca": "080506",
                  "Quehue": "080507",
                  "Tupac Amaru": "080508",
                  "Yanaoca": "080501"
              },
              "Canchis": {
                  "Checacupe": "080603",
                  "Combapata": "080602",
                  "Marangani": "080604",
                  "Pitumarca": "080605",
                  "San Pablo": "080606",
                  "San Pedro": "080607",
                  "Sicuani": "080601",
                  "Tinta": "080608"
              },
              "Chumbivilcas": {
                  "Capacmarca": "080702",
                  "Chamaca": "080704",
                  "Colquemarca": "080703",
                  "Livitaca": "080705",
                  "Llusco": "080706",
                  "Quiñota": "080707",
                  "Santo Tomas": "080701",
                  "Velille": "080708"
              },
              "Cusco": {
                  "Ccorca": "080102",
                  "Cusco": "080101",
                  "Poroy": "080103",
                  "San Jeronimo": "080104",
                  "San Sebastian": "080105",
                  "Santiago": "080106",
                  "Saylla": "080107",
                  "Wanchaq": "080108"
              },
              "Espinar": {
                  "Alto Pichigua": "080808",
                  "Condoroma": "080802",
                  "Coporaque": "080803",
                  "Espinar": "080801",
                  "Ocoruro": "080804",
                  "Pallpata": "080805",
                  "Pichigua": "080806",
                  "Suyckutambo": "080807"
              },
              "La Convencion": {
                  "Echarate": "080902",
                  "Huayopata": "080903",
                  "Kimbiri": "080909",
                  "Maranura": "080904",
                  "Ocobamba": "080905",
                  "Pichari": "080910",
                  "Quellouno": "080908",
                  "Santa Ana": "080901",
                  "Santa Teresa": "080906",
                  "Vilcabamba": "080907"
              },
              "Paruro": {
                  "Accha": "081002",
                  "Ccapi": "081003",
                  "Colcha": "081004",
                  "Huanoquite": "081005",
                  "Omacha": "081006",
                  "Paccaritambo": "081008",
                  "Paruro": "081001",
                  "Pillpinto": "081009",
                  "Yaurisque": "081007"
              },
              "Paucartambo": {
                  "Caicay": "081102",
                  "Challabamba": "081104",
                  "Colquepata": "081103",
                  "Huancarani": "081106",
                  "Kosñipata": "081105",
                  "Paucartambo": "081101"
              },
              "Quispicanchi": {
                  "Andahuaylillas": "081202",
                  "Camanti": "081203",
                  "Ccarhuayo": "081204",
                  "Ccatca": "081205",
                  "Cusipata": "081206",
                  "Huaro": "081207",
                  "Lucre": "081208",
                  "Marcapata": "081209",
                  "Ocongate": "081210",
                  "Oropesa": "081211",
                  "Quiquijana": "081212",
                  "Urcos": "081201"
              },
              "Urubamba": {
                  "Chinchero": "081302",
                  "Huayllabamba": "081303",
                  "Machupicchu": "081304",
                  "Maras": "081305",
                  "Ollantaytambo": "081306",
                  "Urubamba": "081301",
                  "Yucay": "081307"
              }
          },
          "Huancavelica": {
              "Acobamba": {
                  "Acobamba": "090201",
                  "Andabamba": "090203",
                  "Anta": "090202",
                  "Caja": "090204",
                  "Marcas": "090205",
                  "Paucara": "090206",
                  "Pomacocha": "090207",
                  "Rosario": "090208"
              },
              "Angaraes": {
                  "Anchonga": "090302",
                  "Callanmarca": "090303",
                  "Ccochaccasa": "090312",
                  "Chincho": "090305",
                  "Congalla": "090304",
                  "Huallay-grande": "090306",
                  "Huanca-huanca": "090307",
                  "Julcamarca": "090308",
                  "Lircay": "090301",
                  "San Antonio De Antaparco": "090309",
                  "Santo Tomas De Pata": "090310",
                  "Secclla": "090311"
              },
              "Castrovirreyna": {
                  "Arma": "090402",
                  "Aurahua": "090403",
                  "Capillas": "090405",
                  "Castrovirreyna": "090401",
                  "Chupamarca": "090408",
                  "Cocas": "090406",
                  "Huachos": "090409",
                  "Huamatambo": "090410",
                  "Mollepampa": "090414",
                  "San Juan": "090422",
                  "Santa Ana": "090429",
                  "Tantara": "090427",
                  "Ticrapo": "090428"
              },
              "Churcampa": {
                  "Anco": "090702",
                  "Chinchihuasi": "090703",
                  "Churcampa": "090701",
                  "Cosme": "090711",
                  "El Carmen": "090704",
                  "La Merced": "090705",
                  "Locroja": "090706",
                  "Pachamarca": "090710",
                  "Paucarbamba": "090707",
                  "San Miguel De Mayocc": "090708",
                  "San Pedro De Coris": "090709"
              },
              "Huancavelica": {
                  "Acobambilla": "090102",
                  "Acoria": "090103",
                  "Ascension": "090119",
                  "Conayca": "090104",
                  "Cuenca": "090105",
                  "Huachocolpa": "090106",
                  "Huancavelica": "090101",
                  "Huando": "090120",
                  "Huayllahuara": "090108",
                  "Izcuchaca": "090109",
                  "Laria": "090110",
                  "Manta": "090111",
                  "Mariscal Caceres": "090112",
                  "Moya": "090113",
                  "Nuevo Occoro": "090114",
                  "Palca": "090115",
                  "Pilchaca": "090116",
                  "Vilca": "090117",
                  "Yauli": "090118"
              },
              "Huaytara": {
                  "Ayavi": "090601",
                  "Cordova": "090602",
                  "Huayacundo Arma": "090603",
                  "Huaytara": "090604",
                  "Laramarca": "090605",
                  "Ocoyo": "090606",
                  "Pilpichaca": "090607",
                  "Querco": "090608",
                  "Quito Arma": "090609",
                  "San Antonio De Cusicancha": "090610",
                  "San Francisco De Sangayaico": "090611",
                  "San Isidro": "090612",
                  "Santiago De Chocorvos": "090613",
                  "Santiago De Quirahuara": "090614",
                  "Santo Domingo De Capillas": "090615",
                  "Tambo": "090616"
              },
              "Tayacaja": {
                  "Acostambo": "090502",
                  "Acraquia": "090503",
                  "Ahuaycha": "090504",
                  "Colcabamba": "090506",
                  "Daniel Hernandez": "090509",
                  "Huachocolpa": "090511",
                  "Huaribamba": "090512",
                  "Pampas": "090501",
                  "Pazos": "090517",
                  "Quishuar": "090518",
                  "Salcabamba": "090519",
                  "Salcahuasi": "090526",
                  "San Marcos De Rocchac": "090520",
                  "Surcubamba": "090523",
                  "Tintay Puncu": "090525",
                  "Ñahuimpuquio": "090515"
              }
          },
          "Huanuco": {
              "Ambo": {
                  "Ambo": "100201",
                  "Cayna": "100202",
                  "Colpas": "100203",
                  "Conchamarca": "100204",
                  "Huacar": "100205",
                  "San Francisco": "100206",
                  "San Rafael": "100207",
                  "Tomay-kichwa": "100208"
              },
              "Dos De Mayo": {
                  "Chuquis": "100307",
                  "La Union": "100301",
                  "Marias": "100312",
                  "Pachas": "100314",
                  "Quivilla": "100316",
                  "Ripan": "100317",
                  "Shunqui": "100321",
                  "Sillapata": "100322",
                  "Yanas": "100323"
              },
              "Huacaybamba": {
                  "Canchabamba": "100903",
                  "Cochabamba": "100904",
                  "Huacaybamba": "100901",
                  "Pinra": "100902"
              },
              "Huamalies": {
                  "Arancay": "100402",
                  "Chavin De Pariarca": "100403",
                  "Jacas Grande": "100404",
                  "Jircan": "100405",
                  "Llata": "100401",
                  "Miraflores": "100406",
                  "Monzon": "100407",
                  "Punchao": "100408",
                  "Puños": "100409",
                  "Singa": "100410",
                  "Tantamayo": "100411"
              },
              "Huanuco": {
                  "Amarilis": "100110",
                  "Chinchao": "100102",
                  "Churubamba": "100103",
                  "Huanuco": "100101",
                  "Margos": "100104",
                  "Pillco Marca": "100111",
                  "Quisqui": "100105",
                  "San Francisco De Cayran": "100106",
                  "San Pedro De Chaulan": "100107",
                  "Santa Maria Del Valle": "100108",
                  "Yacus": "100112",
                  "Yarumayo": "100109"
              },
              "Lauricocha": {
                  "Baños": "101002",
                  "Jesus": "101001",
                  "Jivia": "101007",
                  "Queropalca": "101004",
                  "Rondos": "101006",
                  "San Francisco De Asis": "101003",
                  "San Miguel De Cauri": "101005"
              },
              "Leoncio Prado": {
                  "Daniel Alomia Robles": "100602",
                  "Hermilio Valdizan": "100603",
                  "Jose Crespo Y Castillo": "100606",
                  "Luyando": "100604",
                  "Mariano Damaso Beraun": "100605",
                  "Rupa-rupa": "100601"
              },
              "Marañon": {
                  "Cholon": "100502",
                  "Huacrachuco": "100501",
                  "San Buenaventura": "100505"
              },
              "Pachitea": {
                  "Chaglla": "100702",
                  "Molino": "100704",
                  "Panao": "100701",
                  "Umari": "100706"
              },
              "Puerto Inca": {
                  "Codo Del Pozuzo": "100803",
                  "Honoria": "100801",
                  "Puerto Inca": "100802",
                  "Tournavista": "100804",
                  "Yuyapichis": "100805"
              },
              "Yarowilca": {
                  "Aparicio Pomares": "101102",
                  "Cahuac": "101103",
                  "Chacabamba": "101104",
                  "Chavinillo": "101101",
                  "Choras": "101108",
                  "Jacas Chico": "101105",
                  "Obas": "101106",
                  "Pampamarca": "101107"
              }
          },
          "Ica": {
              "Chincha": {
                  "Alto Laran": "110209",
                  "Chavin": "110202",
                  "Chincha Alta": "110201",
                  "Chincha Baja": "110203",
                  "El Carmen": "110204",
                  "Grocio Prado": "110205",
                  "Pueblo Nuevo": "110210",
                  "San Juan De Yanac": "110211",
                  "San Pedro De Huacarpana": "110206",
                  "Sunampe": "110207",
                  "Tambo De Mora": "110208"
              },
              "Ica": {
                  "Ica": "110101",
                  "La Tinguiñ": "110102",
                  "Los Aquijes": "110103",
                  "Ocucaje": "110114",
                  "Pachacutec": "110113",
                  "Parcona": "110104",
                  "Pueblo Nuevo": "110105",
                  "Salas": "110106",
                  "San Jose De Los Molinos": "110107",
                  "San Juan Bautista": "110108",
                  "Santiago": "110109",
                  "Subtanjalla": "110110",
                  "Tate": "110112",
                  "Yauca Del Rosario": "110111"
              },
              "Nazca": {
                  "Changuillo": "110302",
                  "El Ingenio": "110303",
                  "Marcona": "110304",
                  "Nazca": "110301",
                  "Vista Alegre": "110305"
              },
              "Palpa": {
                  "Llipata": "110502",
                  "Palpa": "110501",
                  "Rio Grande": "110503",
                  "Santa Cruz": "110504",
                  "Tibillo": "110505"
              },
              "Pisco": {
                  "Huancano": "110402",
                  "Humay": "110403",
                  "Independencia": "110404",
                  "Paracas": "110405",
                  "Pisco": "110401",
                  "San Andres": "110406",
                  "San Clemente": "110407",
                  "Tupac Amaru Inca": "110408"
              }
          },
          "Junin": {
              "Chanchamayo": {
                  "Chanchamayo": "120801",
                  "Perene": "120806",
                  "Pichanaqui": "120805",
                  "San Luis De Shuaro": "120804",
                  "San Ramon": "120802",
                  "Vitoc": "120803"
              },
              "Chupaca": {
                  "Ahuac": "120902",
                  "Chongos Bajo": "120903",
                  "Chupaca": "120901",
                  "Huachac": "120904",
                  "Huamancaca Chico": "120905",
                  "San Juan De Jarpa": "120907",
                  "San Juan De Yscos": "120906",
                  "Tres De Diciembre": "120908",
                  "Yanacancha": "120909"
              },
              "Concepcion": {
                  "Aco": "120202",
                  "Andamarca": "120203",
                  "Chambara": "120206",
                  "Cochas": "120205",
                  "Comas": "120204",
                  "Concepcion": "120201",
                  "Heroinas Toledo": "120207",
                  "Manzanares": "120208",
                  "Mariscal Castilla": "120209",
                  "Matahuasi": "120210",
                  "Mito": "120211",
                  "Nueve De Julio": "120212",
                  "Orcotuna": "120213",
                  "San Jose De Quero": "120215",
                  "Santa Rosa De Ocopa": "120214"
              },
              "Huancayo": {
                  "Carhuacallanga": "120103",
                  "Chacapampa": "120106",
                  "Chicche": "120107",
                  "Chilca": "120108",
                  "Chongos Alto": "120109",
                  "Chupuro": "120112",
                  "Colca": "120104",
                  "Cullhuas": "120105",
                  "El Tambo": "120113",
                  "Huacrapuquio": "120114",
                  "Hualhuas": "120116",
                  "Huancan": "120118",
                  "Huancayo": "120101",
                  "Huasicancha": "120119",
                  "Huayucachi": "120120",
                  "Ingenio": "120121",
                  "Pariahuanca": "120122",
                  "Pilcomayo": "120123",
                  "Pucara": "120124",
                  "Quichuay": "120125",
                  "Quilcas": "120126",
                  "San Agustin": "120127",
                  "San Jeronimo De Tunan": "120128",
                  "Santo Domingo De Acobamba": "120131",
                  "Sapallanga": "120133",
                  "Saño": "120132",
                  "Sicaya": "120134",
                  "Viques": "120136"
              },
              "Jauja": {
                  "Acolla": "120302",
                  "Apata": "120303",
                  "Ataura": "120304",
                  "Canchayllo": "120305",
                  "Curicaca": "120331",
                  "El Mantaro": "120306",
                  "Huamali": "120307",
                  "Huaripampa": "120308",
                  "Huertas": "120309",
                  "Janjaillo": "120310",
                  "Jauja": "120301",
                  "Julcan": "120311",
                  "Leonor Ordoñez": "120312",
                  "Llocllapampa": "120313",
                  "Marco": "120314",
                  "Masma": "120315",
                  "Masma Chicche": "120332",
                  "Molinos": "120316",
                  "Monobamba": "120317",
                  "Muqui": "120318",
                  "Muquiyauyo": "120319",
                  "Paca": "120320",
                  "Paccha": "120321",
                  "Pancan": "120322",
                  "Parco": "120323",
                  "Pomacancha": "120324",
                  "Ricran": "120325",
                  "San Lorenzo": "120326",
                  "San Pedro De Chunan": "120327",
                  "Sausa": "120333",
                  "Sincos": "120328",
                  "Tunan Marca": "120329",
                  "Yauli": "120330",
                  "Yauyos": "120334"
              },
              "Junin": {
                  "Carhuamayo": "120402",
                  "Junin": "120401",
                  "Ondores": "120403",
                  "Ulcumayo": "120404"
              },
              "Satipo": {
                  "Coviriali": "120702",
                  "Llaylla": "120703",
                  "Mazamari": "120704",
                  "Pampa Hermosa": "120705",
                  "Pangoa": "120706",
                  "Rio Negro": "120707",
                  "Rio Tambo": "120708",
                  "Satipo": "120701"
              },
              "Tarma": {
                  "Acobamba": "120502",
                  "Huaricolca": "120503",
                  "Huasahuasi": "120504",
                  "La Union": "120505",
                  "Palca": "120506",
                  "Palcamayo": "120507",
                  "San Pedro De Cajas": "120508",
                  "Tapo": "120509",
                  "Tarma": "120501"
              },
              "Yauli": {
                  "Chacapalpa": "120602",
                  "Huay Huay": "120603",
                  "La Oroya": "120601",
                  "Marcapomacocha": "120604",
                  "Morococha": "120605",
                  "Paccha": "120606",
                  "Santa Barbara De Carhuacayan": "120607",
                  "Santa Rosa De Sacco": "120610",
                  "Suitucancha": "120608",
                  "Yauli": "120609"
              }
          },
          "La Libertad": {
              "Ascope": {
                  "Ascope": "130801",
                  "Casa Grande": "130808",
                  "Chicama": "130802",
                  "Chocope": "130803",
                  "Magdalena De Cao": "130805",
                  "Paijan": "130806",
                  "Razuri": "130807",
                  "Santiago De Cao": "130804"
              },
              "Bolivar": {
                  "Bambamarca": "130202",
                  "Bolivar": "130201",
                  "Condormarca": "130203",
                  "Longotea": "130204",
                  "Uchumarca": "130206",
                  "Ucuncha": "130205"
              },
              "Chepen": {
                  "Chepen": "130901",
                  "Pacanga": "130902",
                  "Pueblo Nuevo": "130903"
              },
              "Gran Chimu": {
                  "Cascas": "131101",
                  "Lucma": "131102",
                  "Marmot": "131103",
                  "Sayapullo": "131104"
              },
              "Julcan": {
                  "Calamarca": "131003",
                  "Carabamba": "131002",
                  "Huaso": "131004",
                  "Julcan": "131001"
              },
              "Otuzco": {
                  "Agallpampa": "130402",
                  "Charat": "130403",
                  "Huaranchal": "130404",
                  "La Cuesta": "130405",
                  "Mache": "130413",
                  "Otuzco": "130401",
                  "Paranday": "130408",
                  "Salpo": "130409",
                  "Sinsicap": "130410",
                  "Usquil": "130411"
              },
              "Pacasmayo": {
                  "Guadalupe": "130503",
                  "Jequetepeque": "130504",
                  "Pacasmayo": "130506",
                  "San Jose": "130508",
                  "San Pedro De Lloc": "130501"
              },
              "Pataz": {
                  "Buldibuyo": "130602",
                  "Chillia": "130603",
                  "Huancaspata": "130605",
                  "Huaylillas": "130604",
                  "Huayo": "130606",
                  "Ongon": "130607",
                  "Parcoy": "130608",
                  "Pataz": "130609",
                  "Pias": "130610",
                  "Santiago De Challas": "130613",
                  "Taurija": "130611",
                  "Tayabamba": "130601",
                  "Urpay": "130612"
              },
              "Sanchez Carrion": {
                  "Chugay": "130304",
                  "Cochorco": "130302",
                  "Curgos": "130303",
                  "Huamachuco": "130301",
                  "Marcabal": "130305",
                  "Sanagoran": "130306",
                  "Sarin": "130307",
                  "Sartimbamba": "130308"
              },
              "Santiago De Chuco": {
                  "Angasmarca": "130708",
                  "Cachicadan": "130702",
                  "Mollebamba": "130703",
                  "Mollepata": "130704",
                  "Quiruvilca": "130705",
                  "Santa Cruz De Chuca": "130706",
                  "Santiago De Chuco": "130701",
                  "Sitabamba": "130707"
              },
              "Trujillo": {
                  "El Porvenir": "130110",
                  "Florencia De Mora": "130112",
                  "Huanchaco": "130102",
                  "La Esperanza": "130111",
                  "Laredo": "130103",
                  "Moche": "130104",
                  "Poroto": "130109",
                  "Salaverry": "130105",
                  "Simbal": "130106",
                  "Trujillo": "130101",
                  "Victor Larco Herrera": "130107"
              },
              "Viru": {
                  "Chao": "131202",
                  "Guadalupito": "131203",
                  "Viru": "131201"
              }
          },
          "Lambayeque": {
              "Chiclayo": {
                  "Cayalti": "140116",
                  "Chiclayo": "140101",
                  "Chongoyape": "140102",
                  "Eten": "140103",
                  "Eten Puerto": "140104",
                  "Jose Leonardo Ortiz": "140112",
                  "La Victoria": "140115",
                  "Lagunas": "140105",
                  "Monsefu": "140106",
                  "Nueva Arica": "140107",
                  "Oyotun": "140108",
                  "Patapo": "140117",
                  "Picsi": "140109",
                  "Pimentel": "140110",
                  "Pomalca": "140118",
                  "Pucala": "140119",
                  "Reque": "140111",
                  "Santa Rosa": "140113",
                  "Sañ": "140114",
                  "Tuman": "140120"
              },
              "Ferreñfe": {
                  "Cañris": "140203",
                  "Ferreñfe": "140201",
                  "Incahuasi": "140202",
                  "Manuel Antonio Mesones Muro": "140206",
                  "Pitipo": "140204",
                  "Pueblo Nuevo": "140205"
              },
              "Lambayeque": {
                  "Chochope": "140302",
                  "Illimo": "140303",
                  "Jayanca": "140304",
                  "Lambayeque": "140301",
                  "Mochumi": "140305",
                  "Morrope": "140306",
                  "Motupe": "140307",
                  "Olmos": "140308",
                  "Pacora": "140309",
                  "Salas": "140310",
                  "San Jose": "140311",
                  "Tucume": "140312"
              }
          },
          "Loreto": {
              "Alto Amazonas": {
                  "Balsapuerto": "160202",
                  "Jeberos": "160205",
                  "Lagunas": "160206",
                  "Santa Cruz": "160210",
                  "Teniente Cesar Lopez Rojas": "160211",
                  "Yurimaguas": "160201"
              },
              "Datem Del Marañon": {
                  "Andoas": "160702",
                  "Barranca": "160701",
                  "Cahuapanas": "160703",
                  "Manseriche": "160704",
                  "Morona": "160705",
                  "Pastaza": "160706"
              },
              "Loreto": {
                  "Nauta": "160301",
                  "Parinari": "160302",
                  "Tigre": "160303",
                  "Trompeteros": "160305",
                  "Urarinas": "160304"
              },
              "Mariscal Ramon Castilla": {
                  "Pebas": "160602",
                  "Ramon Castilla": "160601",
                  "San Pablo": "160604",
                  "Yavari": "160603"
              },
              "Maynas": {
                  "Alto Nanay": "160102",
                  "Belen": "160112",
                  "Fernando Lores": "160103",
                  "Indiana": "160110",
                  "Iquitos": "160101",
                  "Las Amazonas": "160104",
                  "Mazan": "160105",
                  "Napo": "160106",
                  "Punchana": "160111",
                  "Putumayo": "160107",
                  "San Juan Bautista": "160113",
                  "Teniente Manuel Clavero": "160114",
                  "Torres Causana": "160108"
              },
              "Requena": {
                  "Alto Tapiche": "160402",
                  "Capelo": "160403",
                  "Emilio San Martin": "160404",
                  "Jenaro Herrera": "160410",
                  "Maquia": "160405",
                  "Puinahua": "160406",
                  "Requena": "160401",
                  "Saquena": "160407",
                  "Soplin": "160408",
                  "Tapiche": "160409",
                  "Yaquerana": "160411"
              },
              "Ucayali": {
                  "Contamana": "160501",
                  "Inahuaya": "160506",
                  "Padre Marquez": "160503",
                  "Pampa Hermosa": "160504",
                  "Sarayacu": "160505",
                  "Vargas Guerra": "160502"
              }
          },
          "Madre De Dios": {
              "Manu": {
                  "Fitzcarrald": "170202",
                  "Huepetuhe": "170204",
                  "Madre De Dios": "170203",
                  "Manu": "170201"
              },
              "Tahuamanu": {
                  "Iberia": "170302",
                  "Iñpari": "170301",
                  "Tahuamanu": "170303"
              },
              "Tambopata": {
                  "Inambari": "170102",
                  "Laberinto": "170104",
                  "Las Piedras": "170103",
                  "Tambopata": "170101"
              }
          },
          "Moquegua": {
              "General Sanchez Cerro": {
                  "Chojata": "180203",
                  "Coalaque": "180202",
                  "Ichuñ": "180204",
                  "La Capilla": "180205",
                  "Lloque": "180206",
                  "Matalaque": "180207",
                  "Omate": "180201",
                  "Puquina": "180208",
                  "Quinistaquillas": "180209",
                  "Ubinas": "180210",
                  "Yunga": "180211"
              },
              "Ilo": {
                  "El Algarrobal": "180302",
                  "Ilo": "180301",
                  "Pacocha": "180303"
              },
              "Mariscal Nieto": {
                  "Carumas": "180102",
                  "Cuchumbaya": "180103",
                  "Moquegua": "180101",
                  "Samegua": "180106",
                  "San Cristobal": "180104",
                  "Torata": "180105"
              }
          },
          "Pasco": {
              "Daniel Alcides Carrion": {
                  "Chacayan": "190202",
                  "Goyllarisquizga": "190203",
                  "Paucar": "190204",
                  "San Pedro De Pillao": "190205",
                  "Santa Ana De Tusi": "190206",
                  "Tapuc": "190207",
                  "Vilcabamba": "190208",
                  "Yanahuanca": "190201"
              },
              "Oxapampa": {
                  "Chontabamba": "190302",
                  "Constitucion": "190308",
                  "Huancabamba": "190303",
                  "Oxapampa": "190301",
                  "Palcazu": "190307",
                  "Pozuzo": "190306",
                  "Puerto Bermudez": "190304",
                  "Villa Rica": "190305"
              },
              "Pasco": {
                  "Chaupimarca": "190101",
                  "Huachon": "190103",
                  "Huariaca": "190104",
                  "Huayllay": "190105",
                  "Ninacaca": "190106",
                  "Pallanchacra": "190107",
                  "Paucartambo": "190108",
                  "San Fco De Asis De Yarusyacan": "190109",
                  "Simon Bolivar": "190110",
                  "Ticlacayan": "190111",
                  "Tinyahuarco": "190112",
                  "Vicco": "190113",
                  "Yanacancha": "190114"
              }
          },
          "Piura": {
              "Ayabaca": {
                  "Ayabaca": "200201",
                  "Frias": "200202",
                  "Jilili": "200209",
                  "Lagunas": "200203",
                  "Montero": "200204",
                  "Pacaipampa": "200205",
                  "Paimas": "200210",
                  "Sapillica": "200206",
                  "Sicchez": "200207",
                  "Suyo": "200208"
              },
              "Huancabamba": {
                  "Canchaque": "200302",
                  "El Carmen De La Frontera": "200306",
                  "Huancabamba": "200301",
                  "Huarmaca": "200303",
                  "Lalaquiz": "200308",
                  "San Miguel De El Faique": "200307",
                  "Sondor": "200304",
                  "Sondorillo": "200305"
              },
              "Morropon": {
                  "Buenos Aires": "200402",
                  "Chalaco": "200403",
                  "Chulucanas": "200401",
                  "La Matanza": "200408",
                  "Morropon": "200404",
                  "Salitral": "200405",
                  "San Juan De Bigote": "200410",
                  "Santa Catalina De Mossa": "200406",
                  "Santo Domingo": "200407",
                  "Yamango": "200409"
              },
              "Paita": {
                  "Amotape": "200502",
                  "Arenal": "200503",
                  "Colan": "200505",
                  "La Huaca": "200504",
                  "Paita": "200501",
                  "Tamarindo": "200506",
                  "Vichayal": "200507"
              },
              "Piura": {
                  "Castilla": "200103",
                  "Catacaos": "200104",
                  "Cura Mori": "200113",
                  "El Tallan": "200114",
                  "La Arena": "200105",
                  "La Union": "200106",
                  "Las Lomas": "200107",
                  "Piura": "200101",
                  "Tambo Grande": "200109"
              },
              "Sechura": {
                  "Bellavista De La Union": "200804",
                  "Bernal": "200803",
                  "Cristo Nos Valga": "200805",
                  "Rinconada-llicuar": "200806",
                  "Sechura": "200801",
                  "Vice": "200802"
              },
              "Sullana": {
                  "Bellavista": "200602",
                  "Ignacio Escudero": "200608",
                  "Lancones": "200603",
                  "Marcavelica": "200604",
                  "Miguel Checa": "200605",
                  "Querecotillo": "200606",
                  "Salitral": "200607",
                  "Sullana": "200601"
              },
              "Talara": {
                  "El Alto": "200702",
                  "La Brea": "200703",
                  "Lobitos": "200704",
                  "Los Organos": "200706",
                  "Mancora": "200705",
                  "Pariñs": "200701"
              }
          },
          "Puno": {
              "Azangaro": {
                  "Achaya": "210202",
                  "Arapa": "210203",
                  "Asillo": "210204",
                  "Azangaro": "210201",
                  "Caminaca": "210205",
                  "Chupa": "210206",
                  "Jose Domingo Choquehuanca": "210207",
                  "Muñni": "210208",
                  "Potoni": "210210",
                  "Saman": "210212",
                  "San Anton": "210213",
                  "San Jose": "210214",
                  "San Juan De Salinas": "210215",
                  "Santiago De Pupuja": "210216",
                  "Tirapata": "210217"
              },
              "Carabaya": {
                  "Ajoyani": "210302",
                  "Ayapata": "210303",
                  "Coasa": "210304",
                  "Corani": "210305",
                  "Crucero": "210306",
                  "Ituata": "210307",
                  "Macusani": "210301",
                  "Ollachea": "210308",
                  "San Gaban": "210309",
                  "Usicayos": "210310"
              },
              "Chucuito": {
                  "Desaguadero": "210402",
                  "Huacullani": "210403",
                  "Juli": "210401",
                  "Kelluyo": "210412",
                  "Pisacoma": "210406",
                  "Pomata": "210407",
                  "Zepita": "210410"
              },
              "El Collao": {
                  "Capaso": "211204",
                  "Conduriri": "211205",
                  "Ilave": "211201",
                  "Pilcuyo": "211202",
                  "Santa Rosa": "211203"
              },
              "Huancane": {
                  "Cojata": "210502",
                  "Huancane": "210501",
                  "Huatasani": "210511",
                  "Inchupalla": "210504",
                  "Pusi": "210506",
                  "Rosaspata": "210507",
                  "Taraco": "210508",
                  "Vilque Chico": "210509"
              },
              "Lampa": {
                  "Cabanilla": "210602",
                  "Calapuja": "210603",
                  "Lampa": "210601",
                  "Nicasio": "210604",
                  "Ocuviri": "210605",
                  "Palca": "210606",
                  "Paratia": "210607",
                  "Pucara": "210608",
                  "Santa Lucia": "210609",
                  "Vilavila": "210610"
              },
              "Melgar": {
                  "Antauta": "210702",
                  "Ayaviri": "210701",
                  "Cupi": "210703",
                  "Llalli": "210704",
                  "Macari": "210705",
                  "Nuñoa": "210706",
                  "Orurillo": "210707",
                  "Santa Rosa": "210708",
                  "Umachiri": "210709"
              },
              "Moho": {
                  "Conima": "211302",
                  "Huayrapata": "211304",
                  "Moho": "211301",
                  "Tilali": "211303"
              },
              "Puno": {
                  "Acora": "210102",
                  "Amantani": "210115",
                  "Atuncolla": "210103",
                  "Capachica": "210104",
                  "Chucuito": "210106",
                  "Coata": "210105",
                  "Huata": "210107",
                  "Mañzo": "210108",
                  "Paucarcolla": "210109",
                  "Pichacani": "210110",
                  "Plateria": "210114",
                  "Puno": "210101",
                  "San Antonio": "210111",
                  "Tiquillaca": "210112",
                  "Vilque": "210113"
              },
              "San Antonio De Putina": {
                  "Ananea": "211104",
                  "Pedro Vilca Apaza": "211102",
                  "Putina": "211101",
                  "Quilcapuncu": "211103",
                  "Sina": "211105"
              },
              "San Roman": {
                  "Cabana": "210902",
                  "Cabanillas": "210903",
                  "Caracoto": "210904",
                  "Juliaca": "210901"
              },
              "Sandia": {
                  "Alto Inambari": "210811",
                  "Cuyocuyo": "210803",
                  "Limbani": "210804",
                  "Patambuco": "210806",
                  "Phara": "210805",
                  "Quiaca": "210807",
                  "San Juan Del Oro": "210808",
                  "San Pedro De Putina Punco": "210812",
                  "Sandia": "210801",
                  "Yanahuaya": "210810"
              },
              "Yunguyo": {
                  "Anapia": "211003",
                  "Copani": "211004",
                  "Cuturapi": "211005",
                  "Ollaraya": "211006",
                  "Tinicachi": "211007",
                  "Unicachi": "211002",
                  "Yunguyo": "211001"
              }
          },
          "San Martin": {
              "Bellavista": {
                  "Alto Biavo": "220704",
                  "Bajo Biavo": "220706",
                  "Bellavista": "220701",
                  "Huallaga": "220705",
                  "San Pablo": "220703",
                  "San Rafael": "220702"
              },
              "El Dorado": {
                  "Agua Blanca": "221002",
                  "San Jose De Sisa": "221001",
                  "San Martin": "221004",
                  "Santa Rosa": "221005",
                  "Shatoja": "221003"
              },
              "Huallaga": {
                  "Alto Saposoa": "220205",
                  "El Eslabon": "220206",
                  "Piscoyacu": "220202",
                  "Sacanche": "220203",
                  "Saposoa": "220201",
                  "Tingo De Saposoa": "220204"
              },
              "Lamas": {
                  "Alonso De Alvarado": "220315",
                  "Barranquita": "220303",
                  "Caynarachi": "220304",
                  "Cuñumbuqui": "220305",
                  "Lamas": "220301",
                  "Pinto Recodo": "220306",
                  "Rumisapa": "220307",
                  "San Roque De Cumbaza": "220316",
                  "Shanao": "220311",
                  "Tabalosos": "220313",
                  "Zapatero": "220314"
              },
              "Mariscal Caceres": {
                  "Campanilla": "220402",
                  "Huicungo": "220403",
                  "Juanjui": "220401",
                  "Pachiza": "220404",
                  "Pajarillo": "220405"
              },
              "Moyobamba": {
                  "Calzada": "220102",
                  "Habana": "220103",
                  "Jepelacio": "220104",
                  "Moyobamba": "220101",
                  "Soritor": "220105",
                  "Yantalo": "220106"
              },
              "Picota": {
                  "Buenos Aires": "220902",
                  "Caspizapa": "220903",
                  "Picota": "220901",
                  "Pilluana": "220904",
                  "Pucacaca": "220905",
                  "San Cristobal": "220906",
                  "San Hilarion": "220907",
                  "Shamboyacu": "220910",
                  "Tingo De Ponasa": "220908",
                  "Tres Unidos": "220909"
              },
              "Rioja": {
                  "Awajun": "220509",
                  "Elias Soplin Vargas": "220506",
                  "Nueva Cajamarca": "220505",
                  "Pardo Miguel": "220508",
                  "Posic": "220502",
                  "Rioja": "220501",
                  "San Fernando": "220507",
                  "Yorongos": "220503",
                  "Yuracyacu": "220504"
              },
              "San Martin": {
                  "Alberto Leveau": "220602",
                  "Cacatachi": "220604",
                  "Chazuta": "220606",
                  "Chipurana": "220607",
                  "El Porvenir": "220608",
                  "Huimbayoc": "220609",
                  "Juan Guerra": "220610",
                  "La Banda De Shilcayo": "220621",
                  "Morales": "220611",
                  "Papaplaya": "220612",
                  "San Antonio": "220616",
                  "Sauce": "220619",
                  "Shapaja": "220620",
                  "Tarapoto": "220601"
              },
              "Tocache": {
                  "Nuevo Progreso": "220802",
                  "Polvora": "220803",
                  "Shunte": "220804",
                  "Tocache": "220801",
                  "Uchiza": "220805"
              }
          },
          "Tacna": {
              "Candarave": {
                  "Cairani": "230402",
                  "Camilaca": "230406",
                  "Candarave": "230401",
                  "Curibaya": "230403",
                  "Huanuara": "230404",
                  "Quilahuani": "230405"
              },
              "Jorge Basadre": {
                  "Ilabaya": "230303",
                  "Ite": "230302",
                  "Locumba": "230301"
              },
              "Tacna": {
                  "Alto De La Alianza": "230111",
                  "Calana": "230102",
                  "Ciudad Nueva": "230112",
                  "Coronel Gregorio Albarracin L.": "230113",
                  "Inclan": "230104",
                  "Pachia": "230107",
                  "Palca": "230108",
                  "Pocollay": "230109",
                  "Sama": "230110",
                  "Tacna": "230101"
              },
              "Tarata": {
                  "Estique": "230206",
                  "Estique Pampa": "230207",
                  "Heroes Albarracin": "230205",
                  "Sitajara": "230210",
                  "Susapaya": "230211",
                  "Tarata": "230201",
                  "Tarucachi": "230212",
                  "Ticaco": "230213"
              }
          },
          "Tumbes": {
              "Contralmirante Villar": {
                  "Canoas De Punta Sal": "240203",
                  "Casitas": "240202",
                  "Zorritos": "240201"
              },
              "Tumbes": {
                  "Corrales": "240102",
                  "La Cruz": "240103",
                  "Pampas De Hospital": "240104",
                  "San Jacinto": "240105",
                  "San Juan De La Virgen": "240106",
                  "Tumbes": "240101"
              },
              "Zarumilla": {
                  "Aguas Verdes": "240304",
                  "Matapalo": "240302",
                  "Papayal": "240303",
                  "Zarumilla": "240301"
              }
          },
          "Ucayali": {
              "Atalaya": {
                  "Raimondi": "250301",
                  "Sepahua": "250304",
                  "Tahuania": "250302",
                  "Yurua": "250303"
              },
              "Coronel Portillo": {
                  "Calleria": "250101",
                  "Campoverde": "250104",
                  "Iparia": "250105",
                  "Manantay": "250107",
                  "Masisea": "250103",
                  "Nueva Requena": "250106",
                  "Yarinacocha": "250102"
              },
              "Padre Abad": {
                  "Curimana": "250203",
                  "Irazola": "250202",
                  "Padre Abad": "250201"
              },
              "Purus": {
                  "Purus": "250401"
              }
          }
      }`

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