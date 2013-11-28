'use strict';

curl.config({
	baseUrl: '',
	paths: {
		'flight': 'bower_components/flight',
		'component': 'js/component',
		'page': 'js/page',
		'flight-storage': 'bower_components/flight-storage'
	},
	apiName: 'require'
});

curl(
	[
		'bower_components/flight/lib/compose',
		'bower_components/flight/lib/registry',
		'bower_components/flight/lib/advice',
		'bower_components/flight/lib/logger',
		'bower_components/flight/lib/debug'
	],

	function(compose, registry, advice, withLogging, debug) {
		debug.enable(false);
		debug.events.logNone();

		compose.mixin(registry, [advice.withAdvice, withLogging]);



		require(['page/default'], function(initializeDefault) {
			initializeDefault();

			var data;
			var giftList = window.giftList ? window.giftList : '';
			var componentSelector = '.placeholder-component-address-book';
			$.ajax('/no-cache/giftlistv2/address/get/'+giftList).done(function(_data){
				data = _data.shippingData;
				$(componentSelector).trigger('updateAddresses', data);
				$(componentSelector).trigger('showAddressList');
			}).fail(function(){
				console.error('Não autenticado!');
			});

			$(componentSelector).on('newAddress', function(ev, addressObj){
				$.ajax({
					url: '/no-cache/giftlistv2/address/save',
					type: 'POST',
					contentType: 'application/json; charset=utf-8',
					dataType: 'json',
					data: JSON.stringify(addressObj)
				}).done(function(data){
					data.availableAddresses.push(addressObj);
					data.address = addressObj;
					$(componentSelector).trigger('updateAddresses', data);
					$(componentSelector).trigger('selectAddress', addressObj.addressId);
					$(componentSelector).trigger('showAddressList');
				});
			});

			$(componentSelector).on('addressSelected', function(ev, addressObj){
				console.log('Address selected:', addressObj.addressId);
			});
		});


	}
);
