define = vtex.define || window.define
require = vtex.curl || window.require

define ->
  class Address
    constructor: (data) ->
      @addressId = if data.addressId? then data.addressId else null
      @addressType = if data.addressType? then data.addressType else "residential"
      @city = if data.city? then data.city else null
      @complement = if data.complement? then data.complement else null
      @country = if data.country? then data.country else null
      @geoCoordinates = if data.geoCoordinates? then data.geoCoordinates else []
      @neighborhood = if data.neighborhood then data.neighborhood else null
      @number = if data.number? then data.number else null
      @postalCode = if data.postalCode? then data.postalCode else null
      @receiverName = if data.receiverName? then data.receiverName else null
      @reference = if data.reference? then data.reference else null
      @state = if data.state? then data.state else null
      @street = if data.street? then data.street else null