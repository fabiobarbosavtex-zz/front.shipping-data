define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class Address
    constructor: (data = {}, deliveryCountries = []) ->
      @addressId = data.addressId ? (new Date().getTime() * -1).toString()
      @addressType = data.addressType ? "residential"
      @city = data.city
      @complement = data.complement
      @country = data.country or deliveryCountries[0]
      @geoCoordinates = data.geoCoordinates ? []
      @neighborhood = data.neighborhood
      @number = data.number
      @postalCode = data.postalCode
      @receiverName = data.receiverName
      @reference = data.reference
      @state = data.state
      @street = data.street

      @deliveryCountries = deliveryCountries

    validateField: (rules, name) =>
      value = @[name]
      regex = new RegExp(/^[A-Za-zÀ-ž0-9\/\\\-\.\,\s\(\)\'\#ªº]*$/)
      return name in rules.requiredFields and (not value or regex.test(value))

    validate: (rules) =>
      # City
      if 'city' in rules.requiredFields
        # Caso nao esteja preenchido
        if not @city
          return "City is required"

        # Caso tenha uma lista de cidades e nao esteja na lista
        if rules.cities and !(@city in rules.cities)
          return "City not in allowed cities list"

      # Complement
      if @validateField(rules, 'complement')
        return 'complement invalid'

      # Geocoordinates
      if 'geoCoordinates' in rules.requiredFields and @geoCoordinates.length isnt 2
        return 'geoCoordinates invalid'

      # Neighborhood
      if @validateField(rules, 'neighborhood')
        return 'neighborhood invalid'

      # Number
      if @validateField(rules, 'number')
        return 'number invalid'

      # Postal Code
      if 'postalCode' in rules.requiredFields
        if not @postalCode
          return 'postalCode is required'

        if not rules.regexes?.postalCode?.test(@postalCode)
          return 'postalCode invalid'

      # Receiver name
      if @validateField(rules, 'receiverName')
        return 'receiverName invalid'

      # Reference
      if @validateField(rules, 'reference')
        return 'reference invalid'

      # State
      if 'state' in rules.requiredFields
        if not @state
          return 'state required'

        # Caso tenha uma lista de estados e nao esteja na lista
        if rules.states and !(@state in rules.states)
          return 'state not in allowed states'

      # Street
      if @validateField(rules, 'street')
        return 'street invalid'

      return true