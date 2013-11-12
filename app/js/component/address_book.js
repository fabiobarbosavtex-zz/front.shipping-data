define(function (require) {

	'use strict';

	/**
	 * Module dependencies
	 */

	var defineComponent = require('flight/lib/component');
	var storage = require('flight-storage/lib/adapters/memory');
	var dust = window.dust;

	/**
	 * Module exports
	 */

	return defineComponent(addressBook, storage);

	/**
	 * Module function
	 */

	function addressBook() {
		this.defaultAttrs({
			
		});

		this.saveData = function(ev, data) {
			// Salva
			this.set(data.key, data.value);
			console.log('Salvando');
		};

		this.after('initialize', function () {
			dust.render('addressForm', {}, function (err, output) {
				$('.address-form').html(output);
			});
			this.on('addressBookEventQualquer', this.saveData);
		});

	}

});
