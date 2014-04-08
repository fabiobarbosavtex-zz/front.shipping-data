'use strict';

vtex.curl(vtex.curl.configuration, ['shipping/component/AddressForm', 'shipping/component/AddressList'],
  function(AddressForm, AddressList) {
    var addressBookComponent = '.address-book';
    var addressListComponent = '.address-list-placeholder';
    var addressFormComponent = '.address-form-placeholder';
    var addressList = new AddressList(addressListComponent);
    var addressForm = new AddressForm(addressFormComponent);

    if (false) {
      var data;
      var giftList = window.giftList ? window.giftList : '';
      $.ajax('/no-cache/giftlistv2/address/get/'+giftList).done(function(_data){
        $('.address-component-layover').stop(true, true).slideUp('fast');
        $(addressBookComponent).trigger('updateAddresses', data.shippingData);
      }).fail(function(){
        console.error('Não autenticado!');
      });

      $(addressBookComponent).on('newAddress', function(ev, addressObj){
        $('.submit.btn-success').attr("disabled", "disabled");
        $('.address-component-layover').stop(true, true).slideDown('fast');
        $.ajax({
          url: '/no-cache/giftlistv2/address/save',
          type: 'POST',
          contentType: 'application/json; charset=utf-8',
          dataType: 'json',
          data: JSON.stringify(addressObj)
        }).done(function(data){
          $('.address-component-layover').stop(true, true).slideUp('fast');
          $('.submit.btn-success').removeAttr("disabled", "");
          $(addressBookComponent).trigger('updateAddresses', data.shippingData);
        }).fail(function(){
          $('.address-component-layover').stop(true, true).slideUp('fast');
          $('.submit.btn-success').removeAttr("disabled", "");
          console.error('Erro!');
        });
      });
    } else if (false) {
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
            },
            {
              "addressId": "-1385141491002",
              "addressType": "residential",
              "city": "Tame",
              "complement": "#69b-53",
              "country": "COL",
              "neighborhood": "Andarillo",
              "number": "",
              "postalCode": "22251-030",
              "receiverName": "Breno Calazans",
              "reference": null,
              "state": "Arauca",
              "street": "Av. El Dorado"
            }
          ],
          deliveryCountries: ["BRA", "COL"]
        }
      };

      // Update with the new data
      $(addressBookComponent).trigger('updateAddresses', data.shippingData);

      // When a new addresses is saved
      $(addressBookComponent).on('newAddress', function(ev, addressObj){
        console.log(addressObj);
        // Do an AJAX to save in your API
        // When you're done, update with the new data
        var updated = false;
        for (var i = data.shippingData.availableAddresses.length - 1; i >= 0; i--) {
          var address = data.shippingData.availableAddresses[i];
          if (address.addressId === addressObj.addressId) {
            address = _.extend(address, addressObj);
            updated = true;
            break;
          }
        }
        if (!updated) {
          data.shippingData.availableAddresses.push(addressObj);
        }
        data.shippingData.address = addressObj;
        setTimeout(function() {
          $(addressBookComponent).trigger('updateAddresses', data.shippingData);
        }, 400);
      });

      // When a new address is selected on the list, do something
      $(addressBookComponent).on('addressSelected', function(ev, addressObj){
        console.log('Address selected:', addressObj.addressId);
      });

      $(addressBookComponent).on('postalCode', function(ev, postalCode) {
        console.log('New postal code:', postalCode);
      })
    } else if (true) {

      var checkout = { API: new vtex.checkout.API() };

      checkout.API.getOrderForm().done(function(data){
        var shippingData = data.shippingData;

        if (shippingData) {
          shippingData.deliveryCountries = _.reduceRight(
            shippingData.logisticsInfo,
            function(memo, l) {
              return memo.concat(l.shipsTo);
            }, []
          );
        }

        $(addressBookComponent).trigger('updateAddresses', shippingData);
      }).fail(function(){
        // Tratamento de erro
      });

      $(addressBookComponent).on('newAddress addressSelected', function(ev, addressObj){
        var shippingData = { address: addressObj };
        var serializedAttachment = JSON.stringify(shippingData);
        checkout.API.sendAttachment('shippingData', serializedAttachment).done(function(data){
          $(addressBookComponent).trigger('updateAddresses', data.shippingData);
        }).fail(function(){
          // Tratamento de erro
        });;
      });
    }
  }
);
