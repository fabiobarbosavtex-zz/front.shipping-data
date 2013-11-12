define(function (require) {

  'use strict';

  /**
   * Module dependencies
   */

  var addressBook = require('component/address_book');

  /**
   * Module exports
   */

  return initialize;

  /**
   * Module function
   */

  function initialize() {
    addressBook.attachTo('.adress-book');
  }

});
