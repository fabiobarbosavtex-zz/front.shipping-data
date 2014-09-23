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
      return true if not isRequired and not value
      return regex.test(value)

    validate: (rules) =>
      if @addressType is "giftRegistry"
        return true

      if not rules?
        return "Country rules are required for validation"

      # Backwards compability
      if rules.country is 'ARG' and @state in ["Ciudad de Buenos Aires", "Provincia de Buenos Aires"]
        @state = "Ciudad Autónoma de Buenos Aires"
        @city = "Ciudad Autónoma Buenos Aires"
      if rules.country is 'PRY' and @state is "Distrito Capital"
        @state = "Central"

      # Profile System normaliza estados para serem sempre em upper case
      if rules.states
        @state = @state.toUpperCase()

      fieldsToValidate = ['postalCode', 'city', 'complement', 'neighborhood', 'number', 'receiverName', 'reference', 'street', 'state']
      for field in fieldsToValidate
        return "#{field} invalid (value: #{this[field]})" unless @validateField(rules, field)

      # Geocoordinates
      if 'geoCoordinates' in rules.requiredFields and @geoCoordinates.length isnt 2
        return 'geoCoordinates invalid'

      # Caso tenha uma lista de estados e nao esteja na lista
      if rules.states and !_.find(rules.states, (s) => s.value is @state)
        return 'state not in allowed states'

      # Caso tenha uma lista de cidades e nao esteja na lista
      if rules.cities
        for state, cities of rules.cities
          for city in cities
            if rules.swapNeighborhoodWithCity and city is @neighborhood
              return true
            else if city is @city
              return true
        return "City not in allowed cities list"

      return true
