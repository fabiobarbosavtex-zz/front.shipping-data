define = vtex.define || window.define
require = vtex.curl || window.require

# Inspired by Parsley, this mixin offers two main methods:
# isValid, which does not affect the DOM or toggle events and
# validate, which toggles the valid data in the component's $node
# and trigger the validated event
define [], () ->
  ->
    validators = []

    matchValidationRules = ->
      validationResults = []
      for validationFunction in validators
        valid = validationFunction.call(this) # preserve scope
        unless typeof valid is 'boolean' and valid is true
          # Add failure
          validationResults.push(if valid instanceof Error then valid else new Error(valid))
      return validationResults

    triggerValidationEvent = (validationResults) ->
      @trigger 'componentValidated.vtex', [validationResults]

    # Public API
    @setValidators = (validationFunctionArray) ->
      validators = validationFunctionArray

    # Returns boolean
    @isValid = ->
      validationResults = matchValidationRules.call(this)
      # validationResults is an array of errors
      validationResults.length is 0 or validationResults is true

    # Returns array of errors
    @validate = (e) ->
      e?.stopPropagation()
      validationResults = matchValidationRules.call(this)
      triggerValidationEvent.call this, validationResults
      return validationResults

    @updateValidationClass = ->
      @clearValidationClass()
      if @isValid()
        @$node.addClass('valid')
      else
        @$node.addClass('has-error')

    @clearValidationClass = ->
      @$node.removeClass('valid')
      @$node.removeClass('has-error')

    @after 'initialize', ->
      @on 'validate.vtex', @validate
