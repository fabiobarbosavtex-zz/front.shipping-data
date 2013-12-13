'use strict';

var addressBook = new AddressBook('.placeholder-component-address-book');

var data;
var giftList = window.giftList ? window.giftList : '';
var componentSelector = '.placeholder-component-address-book';
$.ajax('/no-cache/giftlistv2/address/get/'+giftList).done(function(_data){
	data = _data.shippingData;
	$(componentSelector).trigger('updateAddresses', data);
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
	}).fail(function(){
		// Tratar em caso de erro
	});
});

$(componentSelector).on('addressSelected', function(ev, addressObj){
	console.log('Address selected:', addressObj.addressId);
});

/*
	initializeDefault();

	var componentSelector = '.placeholder-component-address-book';

	// Do an AJAX to load the addreses
	var data = {
		"shippingData": {
			"address": {
				"addressId": "-1385141491001",
				"addressType": "residential",
				"city": "Rio De Janeiro",
				"complement": "",
				"country": "BRA",
				"neighborhood": "Botafogo",
				"number": "2",
				"postalCode": "22251-030",
				"receiverName": "Breno Calazans",
				"reference": null,
				"state": "RJ",
				"street": "Rua  Assuncao"
			},
			"attachmentId": "shippingData",
			"availableAddresses": [
				{
					"addressId": "-1385141491001",
					"addressType": "residential",
					"city": "Rio De Janeiro",
					"complement": "",
					"country": "BRA",
					"neighborhood": "Botafogo",
					"number": "2",
					"postalCode": "22251-030",
					"receiverName": "Breno Calazans",
					"reference": null,
					"state": "RJ",
					"street": "Rua  Assuncao"
				}
			]
		}
	};
	// Update with the new data
	$(componentSelector).trigger('updateAddresses', data);

	// When a new addresses is saved
	$(componentSelector).on('newAddress', function(ev, addressObj){
		// Do an AJAX to save in your API
		// When you're done, update with the new data
		data.availableAddresses.push(addressObj);
		data.address = addressObj;
		$(componentSelector).trigger('updateAddresses', data);
	});

	// When a new address is selected on the list, do something
	$(componentSelector).on('addressSelected', function(ev, addressObj){
		console.log('Address selected:', addressObj.addressId);
	});
*/

