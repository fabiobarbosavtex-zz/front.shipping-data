define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component', 'shipping/setup/extensions'],
  (defineComponent, extensions) ->
    ShippingOptions = ->
      @defaultAttrs
        data:
          address: {}
          deliveryCountries: ['BRA']
          
          disableCityAndState: false
          labelShippingFields: false

        templates:          
          shippingOptions:
            name: 'shippingOptions'
            template: 'shipping/template/shippingOptions'

        addressFormSelector: '.address-form-new'
        postalCodeSelector: '#ship-postal-code'

      # Render this component according to the data object
      @render = (ev, data) ->
        data = @attr.data if not data        
        require [@attr.templates.shippingOptions.template], =>
          dust.render @attr.templates.shippingOptions.name, data, (err, output) =>
            output = $(output).i18n()
            @$node.html(output)

      # Bind events
      @after 'initialize', ->  
        @on document, 'shippingOptionsRender', @render

        return
    return defineComponent(ShippingOptions)