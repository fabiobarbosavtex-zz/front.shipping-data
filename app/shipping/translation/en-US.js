define = vtex.define || window.define;
require = vtex.curl || window.require;

define(function(){
	return {
		"shipping": {
			"addressList": {
				"header": 'Choose a delivery address',
				"selected": 'Selected',
				"select": 'Select',
				"editSelectedAddress": 'Edit current address',
				"anotherAddress": 'Delivery in another address'
			},
			"addressForm": {
				"header": 'New address',
				"dontKnowPostalCode": 'I don\'t know my postal code',
				"postalCodeBRA": 'CEP',
				"postalCodeUSA": 'ZIP',
				"postalCode": 'Postal Code',
				"street": 'Street',
				"addressLine1": 'Address Line 1',
				"addressLine2": 'Address Line 2',
				"number": 'Number',
				"complement": 'Additional info (eg: apt 201)',
				"reference": 'Close to',
				"district": 'District',
				"neighborhood": 'Neighborhod',
				"commercial": 'Commercial address',
				"city": 'City',
				"locality": 'Locality',
				"state": 'State',
				"region": 'Region',
				"community": 'Community',
				"direction": 'Direction',
				"department": 'Departament',
				"municipality": 'Municipality',
				"province": "Province",
				"type": 'Address type',
				"receiver": 'Receiver',
				"deliveryCountry": 'Delivery country',
				"cancelEditAddress": 'Back to address list'
			},
			"shippingOptions": {
				"shippingOptions": 'Choose the delivery options',
				"chooseShippingOption": 'Choose your shipping option',
				"followingProducts": 'Products from',
				"shippingOption": 'Shipping option',
				"shippingEstimate": 'Estimate',
				"ofSeller": 'of the seller ',
				"deliveryDate": 'Delivery date',
				"chooseScheduledDate": 'Choose your shipping date',
				"deliveryHour": 'Delivery hour',
				"workingDay": 'Up to __count__ working day',
				"workingDay_plural": 'Up to __count__ working days',
				"day": 'Up to __count__ day',
				"day_plural": 'Up to __count__ day'
			}
		},
		"validation": {
			"defaultMessage": 'This value seems to be invalid.',
			"type": {
				"email": 'This value should be a valid email.',
				"url": 'This value should be a valid url.',
				"urlstrict": 'This value should be a valid url.',
				"number": 'This value should be a valid number.',
				"digits": 'This value should be digits.',
				"dateIso": 'This value should be a valid date (YYYY-MM-DD).',
				"alphanum": 'This value should be alphanumeric.',
				"phone": 'This value should be a valid phone number.'
			},
			"notnull": 'This value should not be null.',
			"notblank": 'This value should not be blank.',
			"required": 'This value is required.',
			"regexp": 'This value seems to be invalid.',
			"min": 'This value should be greater than or equal to %s.',
			"max": 'This value should be lower than or equal to %s.',
			"range": 'This value should be between %s and %s.',
			"minlength": 'This value is too short. It should have %s characters or more.',
			"maxlength": 'This value is too long. It should have %s characters or less.',
			"rangelength": 'This value length is invalid. It should be between %s and %s characters long.',
			"mincheck": 'You must select at least %s choices.',
			"maxcheck": 'You must select %s choices or less.',
			"rangecheck": 'You must select between %s and %s choices.',
			"equalto": 'This value should be the same.',
			"postalcode": 'Enter a valid postal code, please.',
			"alphanumponc": 'Enter only numbers, hyphens, dots and slashes, please.',
			"minwords": 'This value should have %s words at least.',
			"maxwords": 'This value should have %s words maximum.',
			"rangewords": 'This value should have between %s and %s words.',
			"greaterthan": 'This value should be greater than %s.',
			"lessthan": 'This value should be less than %s.',
			"beforedate": 'This date should be before %s.',
			"afterdate": 'This date should be after %s.',
			"americandate": 'This value should be a valid date (MM/DD/YYYY).'
		},
		"countries": {
			"ARG": 'Argentina',
			"BRA": 'Brazil',
			"CHL": 'Chile',
			"COL": 'Colombia',
			"ECU": 'Equator',
			"PER": 'Peru',
			"PRY": 'Paraguay',
			"URY": 'Uruguay',
			"USA": 'USA'
		},
		"global": {
			"cancel": 'Cancel',
			"loading": 'Loading',
			"edit": 'Edit',
			"save": 'Save',
			"optional": 'Optional'
		}
	}
});