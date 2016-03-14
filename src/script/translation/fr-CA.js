(function(){
var define = vtex.define || window.define;

define(function () {
  return {
    "shipping": {
      "title": "Adresse de livraison",
      "goToPayment": "aller au paiement",
      "addressList": {
        "header": "Choisir une adresse de livraison",
        "selected": "Choisi",
        "select": "Sélectionner",
        "editSelectedAddress": "Modifier l'adresse actuelle",
        "anotherAddress": "Livraison dans une autre adresse",
        "deliverAtAddressOf": "Livrer à l'adresse de:"
      },
      "addressForm": {
        "header": "Nouvelle adresse",
        "postalCodeBRA": "CEP",
        "postalCodeCAN": "Code postal",
        "postalCodeUSA": "ZIP",
        "postalCodeARG": "Código Postal (CP)",
        "postalCodeURY": "Código Postal (CP)",
        "postalCodePER": "Código Postal (CP)",
        "postalCodeMEX": "Código Postal",
        "postalCode": "Code postal",
        "street": "Rue",
        "addressLine1": "Ligne d'adresse 1",
        "addressLine2": "Ligne d'adresse 2",
        "number": "Numéro",
        "exteriorNumber": "Exterior Number",
        "interiorNumber": "Interior Number",
        "complement": "Additional info (eg: apt 201)",
        "reference": "Close to",
        "district": "District",
        "neighborhood": "Neighborhood",
        "commercial": "Commercial address",
        "city": "Ville",
        "locality": "Locality",
        "state": "State",
        "region": "Region",
        "community": "Community",
        "colony": "Colony",
        "direction": "Direction",
        "department": "Departament",
        "municipality": "Municipality",
        "province": "Province",
        "delegation": "Delegation",
        "type": "Address type",
        "receiver": "Receiver",
        "deliveryCountry": "Delivery country",
        "cancelEditAddress": "Cancel and go back to the address list",
        "searchForAnotherAddress": "Search for another address"
      },
      "addressSearch": {
        "address": "Adresse",
        "dontKnowPostalCode": "I don't know my postal code",
        "knowPostalCode": "Use my postal code",
        "addressExampleARG": "Eg: Cerrito, 1350, Buenos Aires",
        "addressExampleBRA": "Eg: Av Dr Cardoso de Melo, 1750, São Paulo",
        "addressExampleCHL": "Eg: Apoquindo, 3039, Santiago",
        "addressExampleCOL": "Eg: Calle 93 # 14-20, Bogotá",
        "addressExampleECU": "Eg: Av Amazonas River, N 37-61, Quito",
        "addressExamplePER": "Eg: Av. José Pardo, 850, Miraflores, Lima",
        "addressExamplePRY": "Eg: Avenida Eusebio Ayala, 100, Assunção",
        "addressExampleURY": "Eg: Bulevar Artigas, 1394, Montevidéu",
        "addressExampleUSA": "Eg: 225 East 41st Street, New York",
        "addressNotDetailed": "The address doesn't have enough info.",
        "whatAboutMoreInfo": "What don't you give us some more info? (eg: number)",
        "incompleteAddressData": "We didn't find your",
        "searchPostalCode": "Use the postal code service to search for it.",
        "shipsTo": "Ship to"
      },
      "countrySelect": {
        "chooseDeliveryCountry": "Choose the delivery country"
      },
      "postalCodeInput": {
        "dontUse": "The address doesn't have a postal code",
        "use": "Add postal code"
      },
      "shippingOptions": {
        "shippingOptions": "Choisissez les options de livraison",
        "chooseShippingOption": "Veuillez sélectionner un mode de livraison",
        "followingProducts": "Products from",
        "shippingOption": "Option de livraison",
        "shippingEstimate": "Estimate",
        "ofSeller": "of the seller ",
        "deliveryDate": "Date de livraison",
        "chooseScheduledDate": "Choisissez votre date d'expédition",
        "deliveryHour": "Delivery hour",
        "workingDay": "Up to __count__ working day",
        "workingDay_plural": "Up to __count__ working days",
        "day": "Up to __count__ day",
        "day_plural": "Up to __count__ day",
        "fromToHour": "From __from__ to __to__",
        "priceFrom": "from"
      },
      "shippingSummary": {
        "shipping": "Livraison:",
        "chooseOtherShippingOption": "Choisissez une autre option d'expédition",
        "atAddressOf": "At address of:"
      }
    },
    "validation": {
      "defaultMessage": "This value seems to be invalid.",
      "type": {
        "email": "This value should be a valid email.",
        "url": "This value should be a valid url.",
        "urlstrict": "This value should be a valid url.",
        "number": "This value should be a valid number.",
        "digits": "This value should be digits.",
        "dateIso": "This value should be a valid date (YYYY-MM-DD).",
        "alphanum": "This value should be alphanumeric.",
        "phone": "This value should be a valid phone number."
      },
      "notnull": "This value should not be null.",
      "notblank": "This value should not be blank.",
      "required": "This value is required.",
      "regexp": "This value seems to be invalid.",
      "min": "This value should be greater than or equal to %s.",
      "max": "This value should be lower than or equal to %s.",
      "range": "This value should be between %s and %s.",
      "minlength": "This value is too short. It should have %s characters or more.",
      "maxlength": "This value is too long. It should have %s characters or less.",
      "rangelength": "This value length is invalid. It should be between %s and %s characters long.",
      "mincheck": "You must select at least %s choices.",
      "maxcheck": "You must select %s choices or less.",
      "rangecheck": "You must select between %s and %s choices.",
      "equalto": "This value should be the same.",
      "postalcode": "Enter a valid postal code, please.",
      "alphanumponc": "Enter only numbers, hyphens, dots and slashes, please.",
      "minwords": "This value should have %s words at least.",
      "maxwords": "This value should have %s words maximum.",
      "rangewords": "This value should have between %s and %s words.",
      "greaterthan": "This value should be greater than %s.",
      "lessthan": "This value should be less than %s.",
      "beforedate": "This date should be before %s.",
      "afterdate": "This date should be after %s.",
      "americandate": "This value should be a valid date (MM/DD/YYYY)."
    },
    "countries": {
      "ARG": "Argentina",
      "BOL": "Bolivia",
      "BRA": "Brazil",
      "CAN": "Canada",
      "CHL": "Chile",
      "COL": "Colombia",
      "ECU": "Equator",
      "GTM": "Guatemala",
      "MEX": "Mexico",
      "PER": "Peru",
      "PRY": "Paraguay",
      "URY": "Uruguay",
      "USA": "USA"
    },
    "global": {
      "free": "Free",
      "cancel": "Cancel",
      "loading": "Loading",
      "edit": "Edit",
      "save": "Save",
      "waiting": "Waiting for more information",
      "notRequired": "Optional"
    }
  }
});
})();
