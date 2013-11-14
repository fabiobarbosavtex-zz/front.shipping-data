define(function (require) {

	'use strict';

	/**
	 * Module dependencies
	 */

	var defineComponent = require('flight/lib/component');
	var storage = require('flight-storage/lib/adapters/memory');
	var dust = window.dust;
	var _ = window._;

	/**
	 * Module exports
	 */

	return defineComponent(addressBook, storage);

	/**
	 * Module function
	 */

	function addressBook() {
		this.defaultAttrs({
			dataForm: {
				showPostalCode: true,
				showAddressForm: false,
				address: {},
				country: 'BRA',
				states: ['AC','AL','AM','AP','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RO','RS','RR','SC','SE','SP','TO'],
				alphaNumericPunctuationRegex: '^[A-Za-zÀ-ú0-9\/\\\-\.\,\s\(\)\']*$'
			},
			
			newAddressSelector: '.new-address',
			newAddressFormSelector: '.new-address form',
			submitNewAddressSelector: '.btn-success',
			postalCodeSelector: '#ship-postal-code',
			forceShippingFieldsSelector: '#force-shipping-fields',
			stateSelector: '#ship-state'
		});

		this.render = function(ev, data) {
			var attr = this.attr;
			dust.render('newAddress', data,
				function (err, output) {
					$(attr.newAddressSelector).html(output);
					$(attr.newAddressFormSelector).parsley();
					$(attr.postalCodeSelector, attr.newAddressSelector).inputmask({'mask': '99999-999'});
				}
			);
		};

		this.validatePostalCode = function(ev, data) {
			var postalCode = data.el.value;
			var dataForm = this.attr.dataForm;
			if (/^([\d]{5})\-?([\d]{3})$/.test(postalCode)) {
				dataForm.throttledLoading = true;
				dataForm.postalCode = postalCode;
				$(this.$node).trigger('addressFormRender', dataForm);
				$(this.$node).trigger('submitPostalCode', postalCode);
			}
		};

		this.deselectAllStates = function() {
			this.attr.dataForm.statesObj = _.map(this.attr.dataForm.states, function(s){
				return {'selected': false, 'value': s};
			});
		};

		this.selectState = function(ev, data) {
			$(this.$node).trigger('deselectAllStates');
			var selectedState = data;
			if (ev.type === 'change') {
				selectedState = data.el.value;
			}
			var states = this.attr.dataForm.statesObj;
			for (var state in states) {
				if (states[state].value === selectedState) {
					states[state].selected = true;
					break;
				}
			}
			this.attr.dataForm.state = selectedState;
		};

		this.getPostalCode = function (ev, data) {
			var self = this;
			this.attr.dataForm.showAddressForm = true;
			$.ajax({
				url: 'postalcode.vtexfrete.com.br/api/postal/pub/address/BRA/'+data,
				dataType: 'json'
			}).done(function(data){
				if (data.properties) {
					var address = data.properties[0].value.address;
					var dataForm = self.attr.dataForm;
					dataForm.address.city = address.city;
					$(self.$node).trigger('selectState', address.stateAcronym);
					dataForm.address.state = address.stateAcronym;
					dataForm.address.street = address.street;
					dataForm.address.neighborhood = address.neighborhood;
					dataForm.address.country = dataForm.country;
					dataForm.throttledLoading = false;
					dataForm.showAddressForm = true;
					dataForm.labelShippingFields = true;
					$(self.$node).trigger('addressFormRender', dataForm);
				}
			}).fail(function(){
				console.log('CEP não encontrado!');
			});
		};

		this.forceShippingFields = function() {
			this.attr.dataForm.labelShippingFields = false;
			$(this.$node).trigger('addressFormRender', this.attr.dataForm);
		};

		this.serializeObject = function(el) {
			var o = {};
			var a = el.serializeArray();
			$.each(a, function() {
				if (o[this.name] !== undefined) {
					if (!o[this.name].push) {
						o[this.name] = [o[this.name]];
					}
					o[this.name].push(this.value || '');
				} else {
					o[this.name] = this.value || '';
				}
			});
			return o;
		};

		this.submitNewAddres = function(ev, data) {
			var addressObj = this.serializeObject($(data.el));
			$(this.$node).trigger('newAddress', addressObj);
		};

		this.after('initialize', function () {
			this.on('deselectAllStates', this.deselectAllStates);
			this.on('selectState', this.selectState);
			this.on('addressFormRender', this.render);
			this.on('click', {
				'forceShippingFieldsSelector': this.forceShippingFields
			});
			this.on('submit', {
				'newAddressFormSelector': this.submitNewAddres
			});
			this.on('keyup', {
				'postalCodeSelector': this.validatePostalCode
			});
			this.on('change', {
				'stateSelector': this.selectState
			});
			this.on('submitPostalCode', this.getPostalCode);

			this.trigger('deselectAllStates');
			this.trigger('addressFormRender', this.attr.dataForm);
		});
	}

});
