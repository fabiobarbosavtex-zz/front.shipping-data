define = vtex.define || define
require = vtex.require || require

define ->
  class Orchestrator
    constructor: (@API) ->

      @addressBookComponent = '.address-book'
      @checkout = null
      @orderForm = null
      @hash = ""
      @startModule()

    enable: () =>
      console.log "enable"

    disable: () =>
      console.log "disable"

    commit: =>

    revert: =>

    update: =>

    submit: =>
      console.log "submit"

    startModule: =>
      console.log("startModule")
      @checkout = new @API(@addressBookComponent);
      @orderForm = @checkout.orderForm
      @orchestrate();
      @startEventListeners()

    orchestrate: =>
      # Update addresses
      if (@orderForm.shippingData)
        addressData = @orderForm.shippingData
        addressData.deliveryCountries = @getDeliveryCountries(addressData.logisticsInfo)
        $(@addressBookComponent).trigger 'updateAddresses', addressData

      # Update shipping options
      if @orderForm.shippingData and @orderForm.sellers
        window.shippingOptionsData = @getShippingOptionsData()
        $(@addressBookComponent).trigger 'updateShippingOptions', shippingOptionsData

    getDeliveryCountries: (logisticsInfo) =>
      return _.uniq(_.reduceRight(logisticsInfo, (memo, l) ->
        return memo.concat(l.shipsTo)
      , []))

    getShippingOptionsData: =>
      logisticsInfo = []
      for li in @orderForm.shippingData.logisticsInfo
        item = @orderForm.items[li.itemIndex]

        seller = _.find @orderForm.sellers, (s) ->
          return parseInt(s.id) is parseInt(item.seller)

        if seller
          current = _.extend({}, li, {seller:seller}, {item: item})
          logisticsInfo.push(current)

      logisticsBySeller = _.groupBy logisticsInfo, (so) -> return so.seller.id
      logisticsInfoArray = _.map logisticsBySeller, (logistic) ->
        composedLogistic =
          items: []
          seller: {}
          selectedSla: ''
          slas: []

        for logi in logistic
          composedLogistic.items.push(logi.item)
          composedLogistic.seller = logi.seller
          for sla in logi.slas
            sla.isScheduled = sla.availableDeliveryWindows and sla.availableDeliveryWindows.length > 0
            sla.businessDays = (sla.shippingEstimate+'').indexOf('bd') isnt -1
            sla.shippingEstimateDays = parseInt((sla.shippingEstimate+'').replace(/bd|d/,''), 10)
            sla.isSelected = (sla.id is logi.selectedSla)
            sla.valueLabel = if sla.price > 0 then _.intAsCurrency sla.price else i18n.t('global.free')
            sla.taxValueLabel = if sla.tax > 0 then _.intAsCurrency sla.tax else i18n.t('global.free')
          composedLogistic.slas = logi.slas
          selectedSla = _.find logi.slas, (sla) -> sla.name is logi.selectedSla
          composedLogistic.selectedSla = selectedSla

        return composedLogistic

      return logisticsInfoArray


    startEventListeners: =>
      $(@addressBookComponent).on 'newAddress', @onAddressSaved
      $(@addressBookComponent).on 'addressSelected', @onAddressSelected
      $(@addressBookComponent).on 'postalCode', @onPostalCode

    # When a new addresses is selected
    # Should call API to get delivery options
    onAddressSelected: (evt, addressObj) =>
      console.log (addressObj)

    onPostalCodeLoaded: (ev, addressObj) =>
      console.log (addressObj)

    # When a new addresses is saved
    onAddressSaved: (evt, addressObj) =>
      # Do an AJAX to save in your API
      # When you're done, update with the new data
      updated = false
      for address in @orderForm.shippingData.availableAddresses
        if address.addressId is addressObj.addressId
          address = _.extend(address, addressObj)
          updated = true
          break;

      if not updated
        @orderForm.shippingData.availableAddresses.push(addressObj)

      @orderForm.shippingData.address = addressObj
      $(@addressBookComponent).trigger('updateAddresses', @orderForm.shippingData)