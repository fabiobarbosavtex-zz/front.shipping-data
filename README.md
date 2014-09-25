# VTEX Shipping Data

Browser component that offers a complete experience to collect shipping information from the user.

Also available are separate, smallers components for single tasks, such as editing an address or listing multiple addresses.  

- [Developing](#developing)
	- [Requirements](#requirements)
	- [Quick Start](#quick-start) 
- [Usage](#usage)
- [Architecture](#architecture)
	- [Shipping Data](#shipping-data)
	- [Address Form Component](#address-form-component)
	- [Address List Component](#address-list-component)
	- [Address Search Component](#address-search-component)
	- [Country Select Component](#country-select-component)
	- [Shipping Options Component](#shipping-options-component)
	- [Shipping Summary Component](#shipping-summary-component)
	- [Validation Mixin](#validation-mixin)
	- [i18n Mixin](#i18n-mixin)
 

# Developing

## Requirements

Install grunt-cli

	npm install -g grunt-cli

Install this project's dependencies

	npm install

**Windows Users:** Issue these commands in your Git Shell, or a cmd with git in your PATH. (Afterwards, please [install a decent OS](http://ubuntu.com/download))

**Using port 80 without `sudo`:** Follow [this gist](https://gist.github.com/gadr/6389682) to allow node to bind to port 80. Otherwise, you will need to `sudo grunt`.

## Quick start

	grunt

This will start the application at [http://basedevmkp.vtexlocal.com.br/front.shipping-data/app/](http://walmartv5.vtexlocal.com.br/front.shipping-data/app/).

To develop alongside [Checkout-UI](https://github.com/vtex/vcs.checkout-ui), use the `dev` task.

	grunt dev
		
------

# Usage

The component is always published on VTEX IO CDN:

First, grab the setup file:

http://io.vtex.com.br/front.shipping-data/2.0.53/script/setup/front-shipping-data.js

Then, simply `require` the component:

	vtex.curl ['shipping/script/ShippingData'], (ShippingData) ->
		ShippingData.attachTo('#shipping-data',  { API: vtexjs.checkout })

------

# Architecture 

This repository is divided into one main application component, `ShippingData`, and other, smaller, focused components. 

## ShippingData

`ShippingData` adheres to the [Component Event API](https://github.com/vtex/vcs.checkout-ui/blob/master/README.md#component-event-api). It coordinates the children components in order to enable the desired behaviour in the checkout shipping step.

## Address Form Component

	vtex.curl ['shipping/script/component/AddressForm'], (AddressForm) ->
		AddressForm.attachTo('#address-form')

### Events listened to

#### `enable.vtex`
#### `disable.vtex`
#### `startLoading.vtex`

### Events triggered

#### `addressKeysInvalidated.vtex`
#### `addressKeysUpdated.vtex`
#### `addressUpdated.vtex`
#### `cancelAddressEdit.vtex`

## Address List Component

## Address Search Component

## Country Select Component

## Shipping Options Component

## Shipping Summary Component

## Validation Mixin

## i18n Mixin
