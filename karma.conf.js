// Karma configuration
// Generated on Fri Jan 17 2014 19:23:32 GMT-0200 (BRST)

module.exports = function(config) {
  config.set({

    // base path, that will be used to resolve files and exclude
    basePath: '',


    // frameworks to use
    frameworks: ['jasmine', 'requirejs'],


    // list of files / patterns to load in the browser
    files: [
      // loaded without require
      'bower_components/jquery/jquery.js',
      'bower_components/flight-standalone/flight.min.js',
      'bower_components/underscore/underscore.js',
      'bower_components/dustjs-linkedin/dist/dust-core-2.2.2.js',
      'bower_components/dustjs-linkedin-helpers/dist/dust-helpers-1.1.1.js',
      'bower_components/jquery.inputmask/dist/jquery.inputmask.bundle.min.js',
      'bower_components/jasmine-jquery/lib/jasmine-jquery.js',
      'bower_components/jasmine-flight-standalone/lib/jasmine-flight.js',
      'app/libs/**/*.js',
      'bower_components/front-i18n/dist/vtex-i18n.min.js',      

      // hack to load RequireJS after the shim libs
      'node_modules/karma-requirejs/lib/require.js',
      'node_modules/karma-requirejs/lib/adapter.js',

      // loaded with require
      {pattern: 'build/shipui/js/component/**/*', included: false},
      {pattern: 'build/shipui/js/rule/**/*', included: false},
      {pattern: 'build/shipui/js/translation/**/*', included: false},
      {pattern: 'build/shipui/js/template/**/*.js', included: false},
      {pattern: 'build/shipui/js/setup/extensions.js', included: false},
      {pattern: 'test/spec/**/*.spec.coffee', included: false},

      'test/test-main.js'
    ],


    // list of files to exclude
    exclude: [
      'app/libs/es5-shim/**/*.js'
    ],


    // test results reporter to use
    // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['progress'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera (has to be installed with `npm install karma-opera-launcher`)
    // - Safari (only Mac; has to be installed with `npm install karma-safari-launcher`)
    // - PhantomJS
    // - IE (only Windows; has to be installed with `npm install karma-ie-launcher`)
    browsers: ['Chrome'],


    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,


    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false,

    preprocessors: {
      'test/spec/**/*.coffee': 'coffee'
    }
  });
};
