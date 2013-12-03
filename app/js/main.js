'use strict';

curl.config({
	baseUrl: '',
	paths: {
		'flight': 'libs/flight',
		'component': 'js/component',
		'page': 'js/page'
	},
	apiName: 'require'
});

curl(
	[
		'libs/flight/lib/compose',
		'libs/flight/lib/registry',
		'libs/flight/lib/advice',
	],

	function(compose, registry, advice) {

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
