'use strict';

vtex.require(['component/AddressForm', 'component/AddressList'],
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
        $(componentSelector).trigger('updateAddresses', data.shippingData);
      }).fail(function(){
        console.error('Não autenticado!');
      });

      $(addressListComponent).on('newAddress', function(ev, addressObj){
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
          $(componentSelector).trigger('updateAddresses', data.shippingData);
        }).fail(function(){
          $('.address-component-layover').stop(true, true).slideUp('fast');
          $('.submit.btn-success').removeAttr("disabled", "");
          console.error('Erro!');
        });
      });
    } else {
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
      $(addressBookComponent).trigger('updateAddresses', data.shippingData);

      // When a new addresses is saved
      $(addressBookComponent).on('newAddress', function(ev, addressObj){
        // Do an AJAX to save in your API
        // When you're done, update with the new data
        data.availableAddresses.push(addressObj);
        data.address = addressObj;
        $(addressBookComponent).trigger('updateAddresses', data);
      });

      // When a new address is selected on the list, do something
      $(addressBookComponent).on('addressSelected', function(ev, addressObj){
        console.log('Address selected:', addressObj.addressId);
      });
    }
  }
);
