define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class Address
    constructor: (data = {}) ->
      @addressId = data.addressId ? (new Date().getTime() * -1).toString()
      @addressType = data.addressType ? "residential"
      @city = data.city
      @complement = data.complement
      @country = data.country
      @geoCoordinates = data.geoCoordinates ? []
      @neighborhood = data.neighborhood
      @number = data.number
      @postalCode = data.postalCode
      @receiverName = data.receiverName
      @reference = data.reference
      @state = data.state
      @street = data.street

    validateField: (rules, name) =>
      value = @[name]
      regex = rules.regexes[name] ? new RegExp(/^[A-Za-zÀ-ž0-9\/\\\-\.\,\s\(\)\'\#ªº]*$/)
      isRequired = name in rules.requiredFields
      return false if isRequired and (not value? or value is "")
      return regex.test(value)

    validate: (rules) =>
      if not rules?
        return "Address has no country"

      fieldsToValidate = ['postalCode', 'city', 'complement', 'neighborhood', 'number', 'receiverName', 'reference', 'street', 'state']
      for field in fieldsToValidate
        return "#{field} invalid (value: #{this[field]})" unless @validateField(rules, field)

      # Geocoordinates
      if 'geoCoordinates' in rules.requiredFields and @geoCoordinates.length isnt 2
        return 'geoCoordinates invalid'

      # Caso tenha uma lista de cidades e nao esteja na lista
      if rules.cities and !(@city in rules.cities)
        return "City not in allowed cities list"

      # Caso tenha uma lista de estados e nao esteja na lista
      if rules.states and !(@state in rules.states)
        return 'state not in allowed states'

      return true