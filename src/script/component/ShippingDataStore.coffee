# Encapsulates all shipping data for components
class ShippingDataStore
  constructor: ->
    $(window).on 'orderFormUpdated.vtex', @orderFormUpdated
    if window.vtexjs.checkout.orderForm?
      @orderFormUpdated(null, window.vtexjs.checkout.orderForm)

  orderFormUpdated: (ev, orderForm) =>
    @orderForm = JSON.parse JSON.stringify orderForm # RUDE cloning

  sendAttachment: (attachment) =>
    att = {}
    att.clearAddressIfPostalCodeNotFound = attachment.clearAddressIfPostalCodeNotFound
    att.address = JSON.parse JSON.stringify attachment.address
    addressIsEqual = _.isEqual att.address, @orderForm.shippingData?.address

    if attachment.logisticsInfo
      att.logisticsInfo = _(attachment.logisticsInfo).map (li) ->
          shipObj = _(li).pick "itemIndex", "selectedSla", "deliveryWindow", "tax"
          shipObj.isScheduled = _.find li.slas, (sla) ->
            if sla.id is shipObj.selectedSla
              return sla.availableDeliveryWindows?.length > 0
          return shipObj

      logisticsInfoAreEqual = _.all att.logisticsInfo, (li, i) =>
        existingLI = @orderForm.shippingData?.logisticsInfo[i]
        existingSelectedSLA = _.find existingLI.slas, (s) -> s.id is existingLI.selectedSla

        if (existingSelectedSLA.availableDeliveryWindows?.length > 0 and li.isScheduled?)
          deliveryWindowIsEqual = _.isEqual(existingSelectedSLA.deliveryWindow, li.deliveryWindow)
        else
          deliveryWindowIsEqual = true

        return li.itemIndex is existingLI.itemIndex and
          li.selectedSla is existingLI.selectedSla and
          li.tax is existingLI.tax and
          deliveryWindowIsEqual

    # Don't send to API if our orderForm is exactly equal.
    return $.when(@orderForm) if addressIsEqual and logisticsInfoAreEqual

    vtexjs.checkout.sendAttachment('shippingData', att)

store = new ShippingDataStore()

define -> store
