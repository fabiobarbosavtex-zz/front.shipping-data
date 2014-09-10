define = vtex.define || window.define
require = vtex.curl || window.require

define [], () ->
  ->
    stateMachineEvents = [
      { name: 'start',       from: 'none',    to: 'empty'        }
      { name: 'orderform',   from: 'empty',   to: 'summary'      }
      { name: 'invalidAddress',from: ['empty', 'list', 'summary'], to: 'editWithSLA'  }
      { name: 'search',      from: 'empty',   to: 'search'       }
      { name: 'editNoSLA',   from: 'empty',   to: 'editNoSLA'    }
      { name: 'list',        from: 'summary', to: 'list'         }
      { name: 'apiError',    from: 'summary', to: 'editWithSLA'  }
      { name: 'orderform',   from: 'summary', to: 'summary'      }
      { name: 'doneSearch',  from: 'search',  to: 'editNoSLA'    }
      { name: 'doneSLA',     from: ['editNoSLA','editWithSLA'],   to: 'editWithSLA'  }
      { name: 'unavailable', from: ['empty', 'summary'], to: 'editNoSLA'  }
      { name: 'submit',      from: 'editWithSLA', to: 'summary'  }
      { name: 'submit',      from: 'list',    to: 'summary'      }
      { name: 'select',      from: 'list',    to: 'list'         }
      { name: 'editNoSLA',   from: 'list',    to: 'editNoSLA'    }
      { name: 'editWithSLA', from: 'list',    to: 'editWithSLA'  }
      { name: 'cancelEdit',  from: 'editWithSLA', to: 'list'     }
      { name: 'loadSLA',     from: 'editWithSLA', to: 'editNoSLA'}
      { name: 'loadSLA',     from: 'editNoSLA',   to: 'editNoSLA'}
      { name: 'new',         from: 'list',    to: 'search'       }
      { name: 'cancelNew',   from: 'search',  to: 'list'         } # only if available addresses > 0
      { name: 'editNoSLA',   from: 'editNoSLA',   to: 'editNoSLA'}
      { name: 'clearSearch', from: ['editNoSLA', 'editWithSLA'], to: 'search'  }
      { name: 'cancelFirst', from: ['search', 'editNoSLA', 'editWithSLA'],  to: 'empty' } # only if available addresses == 0
      { name: 'cancelOther', from: ['search', 'editNoSLA', 'editWithSLA'],  to: 'summary' } # only if available addresses == 0
    ]

    @createStateMachine = ->
      StateMachine.create
        events: stateMachineEvents,
        callbacks:
          onafterevent:      @onAfterEvent.bind(this)
          onenterempty:      @onEnterEmpty.bind(this)
          onleaveempty:      @onLeaveEmpty.bind(this)
          onentersummary:    @onEnterSummary.bind(this)
          onleavesummary:    @onLeaveSummary.bind(this)
          onentersearch:     @onEnterSearch.bind(this)
          onleavesearch:     @onLeaveSearch.bind(this)
          onenterlist:       @onEnterList.bind(this)
          onbeforeselect:    @onBeforeSelect.bind(this)
          onleavelist:       @onLeaveList.bind(this)
          onentereditNoSLA:  @onEnterEditNoSLA.bind(this)
          onleaveeditNoSLA:  @onLeaveEditNoSLA.bind(this)
          onentereditWithSLA:@onEnterEditWithSLA.bind(this)

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
      @select('addressFormSelector').trigger('disable.vtex')

    @onLeaveEmpty = (event, from, to) ->
      console.log "Leave empty"
      @select('addressNotFilledSelector').hide()

    @onEnterSummary = (event, from, to, locale, orderForm, rules) ->
      console.log "Enter summary"
      # Disable other components
      @select('shippingOptionsSelector').trigger('disable.vtex')
      @select('addressFormSelector').trigger('disable.vtex')
      # We can only enter summary if getting disabled
      @attr.data.active = false
      @select('shippingSummarySelector').trigger('enable.vtex', [locale, orderForm.shippingData, orderForm.items, orderForm.sellers, rules, orderForm.canEditData, orderForm.giftRegistryData])
      @select('goToPaymentButtonWrapperSelector').hide()
      @select('editShippingDataSelector').show()

    @onLeaveSummary = (event, from, to) ->
      console.log "Leave summary"
      @select('shippingSummarySelector').trigger('disable.vtex')
      # We can only leave summary if getting active
      @attr.data.active = true
      @select('goToPaymentButtonWrapperSelector').show()
      @select('editShippingDataSelector').hide()

    @onEnterSearch = (event, from, to, postalCodeQuery, useGeolocationSearch) ->
      @attr.data.active = true
      console.log "Enter search"
      @select('addressFormSelector').trigger('disable.vtex')
      @select('shippingOptionsSelector').trigger('disable.vtex')
      @select('addressSearchSelector').trigger('enable.vtex', [@attr.data.countryRules[@attr.data.country], postalCodeQuery, if useGeolocationSearch? then useGeolocationSearch else false])
      @select('goToPaymentButtonWrapperSelector').hide()

    @onLeaveSearch = (event, from, to) ->
      @attr.data.active = true
      console.log "Leave search"
      @select('addressSearchSelector').trigger('disable.vtex', null)

    @onEnterList = (event, from, to, deliveryCountries, orderForm) ->
      @attr.data.active = true
      console.log "Enter list"
      @select('addressFormSelector').trigger('disable.vtex')
      @select('addressListSelector').trigger('enable.vtex', [deliveryCountries, orderForm.shippingData, orderForm.giftRegistryData])
      @select('shippingOptionsSelector').trigger('enable.vtex', [orderForm.shippingData?.logisticsInfo, orderForm.items, orderForm.sellers])

    @onLeaveList = (event, from, to) ->
      console.log "Leave list"
      @select('addressListSelector').trigger('disable.vtex')
      @select('shippingOptionsSelector').trigger('disable.vtex')

    @onBeforeSelect = (event, from, to, orderForm) ->
      @attr.data.active = true
      console.log "After select"
      if to is 'list'
        @select('shippingOptionsSelector').trigger('enable.vtex', [orderForm.shippingData?.logisticsInfo, orderForm.items, orderForm.sellers])

    @onEnterEditNoSLA = (event, from, to, address) ->
      console.log "Enter edit with no SLA", address
      if event is 'loadSLA' then return
      @select('addressFormSelector').trigger('enable.vtex', [address])
      @select('shippingOptionsSelector').trigger('disable.vtex')

    @onLeaveEditNoSLA = (event, from, to) ->
      if to isnt 'editWithSLA' # No need to disable if we simply have new shipping options
        @select('addressFormSelector').trigger('disable.vtex')

    @onEnterEditWithSLA = (event, from, to, address, logisticsInfo, items, sellers) ->
      console.log "Enter edit with SLA", logisticsInfo
      if from isnt 'editNoSLA'
        @select('addressFormSelector').trigger('enable.vtex', [address])

      @select('shippingOptionsSelector').trigger('enable.vtex', [logisticsInfo, items, sellers])
      @select('goToPaymentButtonWrapperSelector').show()
