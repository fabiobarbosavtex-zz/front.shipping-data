define ->
  return (address, googleDataMap, postalCodeRegex, storeAcceptsGeoCoords) ->
    invalidFields = []

    for rule in googleDataMap
      requiredPropertyIsNull = rule.required and not address[rule.value]
      requiredPostalCodeIsNotValid = not storeAcceptsGeoCoords and rule.value is 'postalCode' and not postalCodeRegex.test(address[rule.value])

      if requiredPropertyIsNull or requiredPostalCodeIsNotValid
        invalidFields.push(rule.value)
    
    return invalidFields