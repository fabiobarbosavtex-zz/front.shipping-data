define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class Address
    constructor: (data = {}) ->
      @addressId = data.addressId
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