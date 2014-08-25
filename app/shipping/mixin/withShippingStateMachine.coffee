define = vtex.define || window.define
require = vtex.curl || window.require

define [], () ->
  ->
    @createStateMachine = ->
      StateMachine.create
        events: [
          { name: 'start',       from: 'none',    to: 'empty'  }
          { name: 'orderform',   from: 'empty',   to: 'summary'  }
          { name: 'enable',      from: 'empty',   to: 'search'   }
          { name: 'enable',      from: 'summary', to: 'list'     }
          { name: 'failSearch',  from: 'search',  to: 'search'   }
          { name: 'doneSearch',  from: 'search',  to: 'edit'     }
          { name: 'doneSLA',     from: 'edit',    to: 'editSLA'  }
          { name: 'submit',      from: 'editSLA', to: 'summary'  }
          { name: 'submit',      from: 'list',    to: 'summary'  }
          { name: 'select',      from: 'list',    to: 'list'     }
          { name: 'edit',        from: 'list',    to: 'editSLA'  }
          { name: 'cancelEdit',  from: 'editSLA', to: 'list'     }
          { name: 'new',         from: 'list',    to: 'search'   }
          { name: 'cancelNew',   from: 'search',  to: 'list'     } # only if available addresses > 0
          { name: 'cancelFirst', from: ['search', 'edit', 'editSLA'],  to: 'empty' } # only if available addresses == 0
        ],
        callbacks:
          onafterevent:      @onAfterEvent.bind(this)
          onbeforeorderform: @onBeforeOrderForm.bind(this)
          onenterempty:      @onEnterEmpty.bind(this)
          onleaveempty:      @onLeaveEmpty.bind(this)
          onentersummary:    @onEnterSummary.bind(this)
          onleavesummary:    @onLeaveSummary.bind(this)
          onentersearch:     @onEnterSearch.bind(this)
          onleavesearch:     @onLeaveSearch.bind(this)
          onenterlist:       @onEnterList.bind(this)
          onenteredit:       @onEnterEdit.bind(this)
          onentereditSLA:    @onEnterEditSLA.bind(this)
          onleaveedit:       @onLeaveEdit.bind(this)
          onleaveeditSLA:    @onLeaveEditSLA.bind(this)

    #
    # Changed state events (FINITE STATE MACHINE)
    #
    @onAfterEvent = ->
      if @attr.data.active
        @select('shippingStepSelector').addClass('active', 'visited')
      else
        @select('shippingStepSelector').removeClass('active')

    @onBeforeOrderForm = (event, from, to, shippingData) ->
      @select('shippingSummarySelector')
        .trigger('addressUpdated.vtex', shippingData.address)
        .trigger('deliverySelected.vtex', shippingData.logisticsInfo)

    @onEnterEmpty = (event, from, to) ->
      console.log "Enter empty"
      @select('addressNotFilledSelector').show()

    @onLeaveEmpty = (event, from, to) ->
      console.log "Leave empty"
      @select('addressNotFilledSelector').hide()

    @onEnterSummary = (event, from, to) ->
      console.log "Enter summary"
      @select('shippingSummarySelector').trigger('enable.vtex')
      # Disable other components
      @select('shippingOptionsSelector').trigger('disable.vtex')
      # We can only enter summary if getting disabled
      @attr.data.active = false
      @select('goToPaymentButtonWrapperSelector').hide()

    @onLeaveSummary = (event, from, to) ->
      console.log "Leave summary"
      @select('shippingSummarySelector').trigger('disable.vtex')
      # We can only leave summary if getting active
      @attr.data.active = true

    @onEnterSearch = (event, from, to) ->
      @attr.data.active = true
      console.log "Enter search"
      @select('addressSearchSelector').trigger('enable.vtex', null)

    @onLeaveSearch = (event, from, to) ->
      @attr.data.active = true
      console.log "Leave search"
      @select('addressSearchSelector').trigger('disable.vtex', null)

    @onEnterList = (event, from, to, orderForm) ->
      @attr.data.active = true
      console.log "Enter list"
      @select('addressListSelector').trigger('enable.vtex', orderForm.shippingData)
      @select('shippingOptionsSelector').trigger('enable.vtex', [orderForm.shippingData?.logisticsInfo, orderForm.items, orderForm.sellers])

    @onEnterEdit = (event, from, to, address) ->
      console.log "Enter edit", address
      @select('addressFormSelector').trigger('enable.vtex', address)
      # When we start editing, we always start looking for shipping options
      @select('shippingOptionsSelector').trigger('startLoadingShippingOptions.vtex')

    @onLeaveEdit = (event, from, to) ->
      return if to is 'editSLA' # No need to disable if we simply have new shipping options
      @select('addressFormSelector').trigger('disable.vtex')

    @onEnterEditSLA = (event, from, to, logisticsInfo, items, sellers) ->
      console.log "Enter edit SLA", logisticsInfo
      @select('shippingOptionsSelector').trigger('enable.vtex', [logisticsInfo, items, sellers])
      @select('goToPaymentButtonWrapperSelector').show()

    @onLeaveEditSLA = (event, from, to) ->
      @select('addressFormSelector').trigger('disable.vtex')