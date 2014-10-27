define = vtex.define || window.define
require = vtex.curl || window.require

define [], () ->
  ->
    @defaultAttrs
      route: null

    @handleChanges = (newHash, oldHash) ->
      newHash += ''
      oldHash += ''

      newHit = newHash.indexOf(@attr.route) is 0
      oldHit = oldHash.indexOf(@attr.route) is 0

      if newHit
        @enter?(newHash, oldHash)
      else if not newHit and oldHit
        @exit?(newHash, oldHash)

    @redirect = (to) ->
      hasher.replaceHash(to)

    @go = (to) ->
      hasher.setHash(to)

    @after 'initialize', ->
      if not @attr.route
        throw new Error "Module should set a route"

      # Add hash change listener
      hasher.changed.add(@handleChanges.bind(this))
      # Add initialized listener (to grab initial value in case it is already set)
      hasher.initialized.add(@handleChanges.bind(this))