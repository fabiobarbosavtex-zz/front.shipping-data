define = vtex.define || window.define
require = vtex.curl || window.require

define [], () ->
  ->
    @createStateMachine = ->
      StateMachine.create
        events: [
          { name: 'start',       from: 'none',    to: 'empty'  }
          { name: 'orderform',   from: 'empty',   to: 'summary'  }
          { name: 'invalidAddress',from: 'empty', to: 'editSLA'  }
          { name: 'enable',      from: 'empty',   to: 'search'   }
          { name: 'enable',      from: 'summary', to: 'list'     }
          { name: 'failSearch',  from: 'search',  to: 'search'   }
          { name: 'doneSearch',  from: 'search',  to: 'edit'     }
          { name: 'doneSLA',     from: ['edit','editSLA'],   to: 'editSLA'  }
          { name: 'submit',      from: 'editSLA', to: 'summary'  }
          { name: 'submit',      from: 'list',    to: 'summary'  }
          { name: 'select',      from: 'list',    to: 'list'     }
          { name: 'edit',        from: 'list',    to: 'edit'  }
          { name: 'cancelEdit',  from: 'editSLA', to: 'list'     }
          { name: 'new',         from: 'list',    to: 'search'   }
          { name: 'cancelNew',   from: 'search',  to: 'list'     } # only if available addresses > 0
          { name: 'clearSearch', from: ['edit', 'editSLA'], to: 'search'  }
          { name: 'cancelFirst', from: ['search', 'edit', 'editSLA'],  to: 'empty' } # only if available addresses == 0
        ],
        callbacks:
          onafterevent:      @onAfterEvent.bind(this)
          onenterempty:      @onEnterEmpty.bind(this)
          onleaveempty:      @onLeaveEmpty.bind(this)
          onentersummary:    @onEnterSummary.bind(this)
          onleavesummary:    @onLeaveSummary.bind(this)
          onentersearch:     @onEnterSearch.bind(this)
          onleavesearch:     @onLeaveSearch.bind(this)
          onenterlist:       @onEnterList.bind(this)
          onleavelist:       @onLeaveList.bind(this)
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

    @onEnterEmpty = (event, from, to) ->
      console.log "Enter empty"
      @select('addressNotFilledSelector').show()

    @onLeaveEmpty = (event, from, to) ->
      console.log "Leave empty"
      @select('addressNotFilledSelector').hide()

    @onEnterSummary = (event, from, to, orderForm, rules) ->
      console.log "Enter summary"
      @select('shippingSummarySelector').trigger('enable.vtex', [orderForm.shippingData, orderForm.items, orderForm.sellers, rules, orderForm.canEditData])
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
      @select('goToPaymentButtonWrapperSelector').show()

    @onEnterSearch = (event, from, to, addressSearch) ->
      @attr.data.active = true
      console.log "Enter search"
      @select('addressSearchSelector').trigger('enable.vtex', [addressSearch, @attr.data.countryRules[@attr.data.country]])
      @select('shippingOptionsSelector').trigger('disable.vtex')
      @select('goToPaymentButtonWrapperSelector').hide()

    @onLeaveSearch = (event, from, to) ->
      @attr.data.active = true
      console.log "Leave search"
      @select('addressSearchSelector').trigger('disable.vtex', null)

    @onEnterList = (event, from, to, orderForm) ->
      @attr.data.active = true
      console.log "Enter list"
      @select('addressListSelector').trigger('enable.vtex', orderForm.shippingData)
      @select('shippingOptionsSelector').trigger('enable.vtex', [orderForm.shippingData?.logisticsInfo, orderForm.items, orderForm.sellers])

    @onLeaveList = (event, from, to) ->
      @select('addressListSelector').trigger('disable.vtex')
      @select('shippingOptionsSelector').trigger('disable.vtex')

    @onEnterEdit = (event, from, to, address) ->
      console.log "Enter edit", address
      @select('addressFormSelector').trigger('enable.vtex', address)

    @onLeaveEdit = (event, from, to) ->
      return if to is 'editSLA' # No need to disable if we simply have new shipping options
      @select('addressFormSelector').trigger('disable.vtex')

    @onEnterEditSLA = (event, from, to, address, logisticsInfo, items, sellers) ->
      console.log "Enter edit SLA", logisticsInfo
      if from isnt 'edit'
        @select('addressFormSelector').trigger('enable.vtex', address)

      @select('shippingOptionsSelector').trigger('enable.vtex', [logisticsInfo, items, sellers])
      @select('goToPaymentButtonWrapperSelector').show()

    @onLeaveEditSLA = (event, from, to) ->
      @select('addressFormSelector').trigger('disable.vtex')