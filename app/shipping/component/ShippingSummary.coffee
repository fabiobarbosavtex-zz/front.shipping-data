define = vtex.define || window.define
require = vtex.curl || window.require

define ['flight/lib/component',
        'shipping/setup/extensions',
        'shipping/mixin/withi18n',
        'shipping/template/shippingSummary'],
(defineComponent, extensions, withi18n, template) ->
  ShippingSummary = ->
    @defaultAttrs
      data:
        address: {}
        isActive: false

    # Render this component according to the data object
    @render = ->
      dust.render template, @attr.data, (err, output) =>
        output = $(output).i18n()
        @$node.html(output)

    @addressUpdated = (ev, address) ->
      ev?.stopPropagation()
      @attr.data.address = address

    @deliverySelected = (ev, logisticsInfo) ->
      ev?.stopPropagation()
      @attr.data.logisticsInfo = logisticsInfo

    @enable = (ev) ->
      ev?.stopPropagation()
      @attr.data.isActive = true;
      @render()

    @disable = (ev) ->
      ev?.stopPropagation()
      @attr.data.isActive = false;
      @$node.html('')

    # Bind events
    @after 'initialize', ->
      @on 'enable.vtex', @enable
      @on 'disable.vtex', @disable
      @on 'addressUpdated.vtex', @addressUpdated
      @on 'deliverySelected.vtex', @deliverySelected

  return defineComponent(ShippingSummary, withi18n)