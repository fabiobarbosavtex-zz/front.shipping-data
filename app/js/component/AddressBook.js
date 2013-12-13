var AddressBook = flight.component(function() {
	this.defaultAttrs({
		dataForm: {
			address: {},
			availableAddresses: [],
			selectedAddressId: '',
			country: 'BRA',
			states: ['AC','AL','AM','AP','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RO','RS','RR','SC','SE','SP','TO'],
			alphaNumericPunctuationRegex: '^[A-Za-zÀ-ú0-9\/\\\-\.\,\s\(\)\']*$',
			hasOtherAddresses: true,
			isEditingAddress: false,
			showAddressList: false,
			showPostalCode: true,
			showAddressForm: false
		},
		
		baseSelector: '.placeholder-component-address-book',
		addressFormSelector: '.address-form-new',
		submitAddressSelector: '.btn-success',
		postalCodeSelector: '#ship-postal-code',
		forceShippingFieldsSelector: '#force-shipping-fields',
		stateSelector: '#ship-state',
		createAddressSelector: '.address-create',
		editAddressSelector: '.address-edit',
		cancelAddressFormSelector: '.cancel-address-form a',
		addressItemSelector: '.address-list .address-item',
		submitButtonSelector: '.submit .btn-success'
	});

	this.render = function(ev, data) {
		var attr = this.attr;
		dust.render('base', data,
			function (err, output) {
				$(attr.baseSelector).html(output);
				if ($(attr.addressFormSelector)[0]) {
					$(attr.addressFormSelector).parsley({
						errorClass: 'error',
						successClass: 'success',
						errors: {
							errorsWrapper: '<div class="help error-list"></div>',
							errorElem: '<span class="help error"></span>'
						}
					});
					$(attr.postalCodeSelector, attr.addressFormSelector).inputmask({'mask': '99999-999'});
				}
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

	this.getPostalCode = function (ev, data) {
		var self = this;
		this.attr.dataForm.showAddressForm = true;
		var country = this.attr.dataForm.country;
		var postalCode = data.replace(/-/g, '');
		$.ajax({
			url: 'http://postalcode.vtexfrete.com.br/api/postal/pub/address/'+country+'/'+postalCode,
			crossDomain: true
		}).done(function(data){
			if (data.properties) {
				var address = data.properties[0].value.address;
				var dataForm = self.attr.dataForm;
				if (address.neighborhood !== '' && address.street !== '' && address.stateAcronym !== '' && address.city !== '') {
					dataForm.labelShippingFields = true;
				} else {
					dataForm.labelShippingFields = false;
				}
				if (address.stateAcronym !== '' && address.city) {
					dataForm.disableCityAndState = true;
				} else {
					dataForm.disableCityAndState = false;
				}
				dataForm.showDontKnowPostalCode = false;
				dataForm.address.city = address.city;
				dataForm.address.state = address.stateAcronym;
				dataForm.address.street = address.street;
				dataForm.address.neighborhood = address.neighborhood;
				dataForm.address.country = dataForm.country;
				dataForm.throttledLoading = false;
				dataForm.showAddressForm = true;
				$(self.$node).trigger('addressFormRender', dataForm);
			}
		}).fail(function(){
			console.log('CEP não encontrado!');
			var dataForm = self.attr.dataForm;
			dataForm.throttledLoading = false;
			dataForm.showAddressForm = true;
			dataForm.labelShippingFields = false;
			$(self.$node).trigger('addressFormRender', dataForm);
		});
	};

	this.forceShippingFields = function() {
		this.attr.dataForm.labelShippingFields = false;
		$(this.$node).trigger('addressFormRender', this.attr.dataForm);
	};

	this.submitAddress = function(ev, data) {
		var valid = $(this.attr.addressFormSelector).parsley('validate');
		if (valid) {
			var disabled = $(this.attr.addressFormSelector).find(':input:disabled').removeAttr('disabled');
			var serializedForm = $(this.attr.addressFormSelector).find('select,textarea,input').serializeArray();
			disabled.attr('disabled','disabled');
			var addressObj = {};
			$.each(serializedForm, function() { addressObj[this.name] = this.value; });
			if (addressObj.addressTypeCommercial) {
				addressObj.addressType = 'commercial';
			} else {
				addressObj.addressType = 'residental';
			}
			$(this.$node).trigger('newAddress', addressObj);
		}
		ev.preventDefault();
	};

	this.createAddress = function() {
		this.attr.dataForm.address = {};
		this.attr.dataForm.postalCode = '';
		this.attr.dataForm.labelShippingFields = false;
		this.attr.dataForm.disableCityAndState = false;
		this.attr.dataForm.address.addressId = (new Date().getTime() * -1).toString();
		this.attr.dataForm.showDontKnowPostalCode = true;
		$(this.$node).trigger('showAddressForm');
	};

	this.editAddress = function() {
		this.attr.dataForm.showDontKnowPostalCode = false;
		$(this.$node).trigger('showAddressForm');
	};

	this.cancelAddressForm = function() {
		this.attr.dataForm.isEditingAddress = false;
		this.attr.dataForm.showAddressList = true;
		$(this.$node).trigger('selectAddress', this.attr.dataForm.selectedAddressId);
	};

	this.showAddressList = function() {
		this.attr.dataForm.isEditingAddress = false;
		this.attr.dataForm.showAddressList = true;
		for (var i = this.attr.dataForm.availableAddresses.length - 1; i >= 0; i--) {
			var a = this.attr.dataForm.availableAddresses[i];

			a.firstPart = '' + a.street;
			a.firstPart += ', ' + a.number;
			if (a.complement) {
				a.firstPart += ', ' + a.complement;
			}
			if (a.reference) {
				a.firstPart += ', ' + a.reference;
			}
			
			a.secondPart = '' + a.city;
			a.secondPart += ' - ' + a.state;
			a.secondPart += ' - ' + a.country;

			a.summary = '' + a.street;
			if (a.postalCode) {
				a.summary += ' - ' + a.postalCode;
			}
			
			this.attr.dataForm.availableAddresses[i] = a;
		}
		$(this.$node).trigger('addressFormRender', this.attr.dataForm);
	};

	this.showAddressForm = function(){
		this.attr.dataForm.isEditingAddress = true;
		this.attr.dataForm.showAddressList = false;
		this.attr.dataForm.showAddressForm = true;
		$(this.$node).trigger('addressFormRender', this.attr.dataForm);
	};

	this.updateAddresses = function(ev, data) {
		this.attr.dataForm.address = data.address;
		if (data.avaliableAddresses) {
			this.attr.dataForm.availableAddresses = data.avaliableAddresses;
		} else {
			this.attr.dataForm.availableAddresses = data.availableAddresses;
		}
		if (_.isEmpty(this.attr.dataForm.address)) {
			this.attr.dataForm.hasOtherAddresses = false;
			$(this.$node).trigger('showAddressForm');
		} else {
			this.attr.dataForm.selectedAddressId = data.address.addressId;
			$(this.$node).trigger('showAddressList');
		}
	};

	this.selectAddress = function(ev, data) {
		var selectedAddressId;
		if (ev.type === 'click') {
			selectedAddressId = $('input', data.el).attr('value');
		} else {
			selectedAddressId = data;
		}
		var wantedAddress = _.find(this.attr.dataForm.availableAddresses, function(a) {
			return a.addressId === selectedAddressId;
		});
		this.attr.dataForm.address = wantedAddress;
		this.attr.dataForm.selectedAddressId = selectedAddressId;
		$(this.$node).trigger('addressSelected', this.attr.dataForm.address);
		$(this.$node).trigger('showAddressList');
		ev.preventDefault();
	};

	this.after('initialize', function () {
		this.on('addressFormRender', this.render);
		this.on('updateAddresses', this.updateAddresses);
		this.on('showAddressList', this.showAddressList);
		this.on('showAddressForm', this.showAddressForm);
		this.on('submitPostalCode', this.getPostalCode);
		this.on('selectAddress', this.selectAddress);

		this.on('click', {
			'forceShippingFieldsSelector': this.forceShippingFields,
			'createAddressSelector': this.createAddress,
			'cancelAddressFormSelector': this.cancelAddressForm,
			'addressItemSelector': this.selectAddress,
			'editAddressSelector': this.editAddress,
			'submitButtonSelector': this.submitAddress
		});

		this.on('keyup', {
			'postalCodeSelector': this.validatePostalCode
		});
	});
});
