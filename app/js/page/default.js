define(function (require) {

  'use strict';

  /**
   * Module dependencies
   */

  var addressBook = require('component/AddressBook');

  /**
   * Module exports
   */

  return initialize;

  /**
   * Module function
   */

  function initialize() {
    addressBook.attachTo('.placeholder-component-address-book');
  }

});
