'use strict';

var tests = Object.keys(window.__karma__.files).filter(function (file) {
  return (/\.spec\.js$/.test(file));
});

var preLoad = Object.keys(window.__karma__.files).filter(function (file) {
  return (/setup|translation|template|rule/.test(file));
});

for (var i = preLoad.length - 1; i >= 0; i--) {
  preLoad[i] = preLoad[i].replace('/base/build/shipui/js/', '');
  preLoad[i] = preLoad[i].replace('.js', '');
};

tests = preLoad.concat(tests);

require.config({
  // Karma serves files from '/base'
  baseUrl: '/base/build/shipui/js',

  paths: {
    'component': 'component',
    'rule': 'rule',
    'template': 'template',
    'translation': 'translation',
    'setup': 'setup'
  },

  // ask Require.js to load these files (all our tests)
  deps: tests,

  // start test run, once Require.js is done
  callback: function(){
    setTimeout(function(){
      window.__karma__.start();
    }, 3000);
  }

});