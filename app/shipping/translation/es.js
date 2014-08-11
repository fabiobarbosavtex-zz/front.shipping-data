define = vtex.define || window.define;
require = vtex.curl || window.require;

define(function() {
	return {
		"shipping": {
			"addressList": {
				"header": 'Elija la dirección de entrega',
				"selected": 'Selecionado',
				"select": 'Selecionar',
				"editSelectedAddress": 'Editar dirección',
				"anotherAddress": 'Enviar a otra dirección'
			},
			"addressForm": {
				"header": 'Registrar nueva dirección',
				"dontKnowPostalCode": 'Não sei meu CEP',
				"postalCodeBRA": 'CEP',
				"postalCodeUSA": 'ZIP',
				"postalCode": 'Código Postal (CP)',
				"street": 'Calle',
				"addressLine1": 'Dirección Línea 1',
				"addressLine2": 'Dirección Línea 2',
				"number": 'Número',
				"complement": 'Piso o Departamento (ej: 2A)',
				"reference": 'Punto o calle acerca',
				"district": 'Distrito',
				"neighborhood": 'Barrio',
				"commercial": 'Dirección de Trabajo',
				"city": 'Ciudad',
				"locality": 'Localidad',
				"state": 'Provincia',
				"region": 'Región',
				"community": 'Comuna',
				"direction": 'Dirección',
				"department": 'Departamento',
				"municipality": 'Municipio',
				"province": "Provincia",
				"type": 'Tipo de dirección',
				"receiver": 'Nombre de la persona que va a recibir',
				"deliveryCountry": 'Elija el país de entrega',
				"backToAddressList": 'Volver a las direcciones ya registradas'
			},
			"shippingOptions": {
				"shippingOptions": 'Elija las opciones de envío',
				"chooseShippingOption": 'Elija el tipo de envío',
				"followingProducts": 'Productos del',
				"shippingOption": 'Tipo de envío',
				"shippingEstimate": 'Estimado',
				"ofSeller": 'del vendedor ',
				"deliveryDate": 'Fecha de entrega',
				"chooseScheduledDate": 'Seleccione la fecha de entrega',
				"deliveryHour": 'Hora de entrega',
				"workingDay": 'Hasta __count__ día hábil',
				"workingDay_plural": 'Hasta __count__ días hábiles',
				"day": 'Hasta __count__ día',
				"day_plural": 'Hasta __count__ días'
			}
		},
		"validation": {
			"defaultMessage": 'Este valor parece ser inválido.',
			"type": {
				"email": 'Este valor debe ser un correo válido.',
				"url": 'Este valor debe ser una URL válida.',
				"urlstrict": 'Este valor debe ser una URL válida.',
				"number": 'Este valor debe ser un número válido.',
				"digits": 'Este valor debe ser un dígito válido.',
				"dateIso": 'Este valor debe ser una fecha válida (YYYY-MM-DD).',
				"alphanum": 'Este valor debe ser alfanumérico.',
				"phone": 'Este valor debe ser un número telefónico válido.'
			},
			"notnull": 'Este valor no debe ser nulo.',
			"notblank": 'Este valor no debe estar en blanco.',
			"required": 'Este valor es requerido.',
			"regexp": 'Este valor es incorrecto.',
			"min": 'Este valor no debe ser menor que %s.',
			"max": 'Este valor no debe ser mayor que %s.',
			"range": 'Este valor debe estar entre %s y %s.',
			"minlength": 'Este valor es muy corto. La longitud mínima es de %s caracteres.',
			"maxlength": 'Este valor es muy largo. La longitud máxima es de %s caracteres.',
			"rangelength": 'La longitud de este valor debe estar entre %s y %s caracteres.',
			"mincheck": 'Debe seleccionar al menos %s opciones.',
			"maxcheck": 'Debe seleccionar %s opciones o menos.',
			"rangecheck": 'Debe seleccionar entre %s y %s opciones.',
			"equalto": 'Este valor debe ser idéntico.',
			"postalcode": 'Introduzca un código postal válido, por favor.',
			"alphanumponc": 'Introduzca sólo números, guiones, puntos y barras, por favor.',
			"minwords": 'Este valor debe tener al menos %s palabras.',
			"maxwords": 'Este valor no debe exceder las %s palabras.',
			"rangewords": 'Este valor debe tener entre %s y %s palabras.',
			"greaterthan": 'Este valor no debe ser mayor que %s.',
			"lessthan": 'Este valor no debe ser menor que %s.',
			"beforedate": 'Esta fecha debe ser anterior a %s.',
			"afterdate": 'Esta fecha debe ser posterior a %s.',
			"americandate": 'Este valor debe ser una fecha válida (MM/DD/YYYY).'
		},
		"countries": {
			"ARG": 'Argentina',
			"BRA": 'Brasil',
			"CHL": 'Chile',
			"COL": 'Colombia',
			"ECU": 'Ecuador',
			"PER": 'Peru',
			"PRY": 'Paraguay',
			"URY": 'Uruguay',
			"USA": 'Estados Unidos'
		},
		"global": {
			"cancel": 'Cancelar',
			"loading": 'Cargando',
			"edit": 'Cambiar',
			"save": 'Guardar',
			"optional": 'Opcional'
		}
	}
});