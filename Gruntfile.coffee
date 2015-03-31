GruntVTEX = require 'grunt-vtex'

module.exports = (grunt) ->
  pkg = grunt.file.readJSON 'package.json'
  r = {}
  # Parts of the index we wish to replace on deploy
  r[pkg.paths[0] + '/'] = "//io.vtex.com.br/#{pkg.name}/#{pkg.version}/"

  config = GruntVTEX.generateConfig grunt, pkg,
    replaceMap: r
    replaceGlob: "build/**/front-shipping-data.js"
    open: 'http://basedevmkp.vtexlocal.com.br/front.shipping-data/app/'

  config.coffee["app"] =
    files: [
      expand: true
      cwd: 'src/app'
      src: ['**/*.coffee']
      dest: "build-raw/<%= relativePath %>/app/"
      rename: (path, filename) ->
        path + filename.replace("coffee", "js")
    ]

  config.dust =
    files:
      expand: true
      cwd: 'src/templates/'
      src: ['**/*.dust']
      dest: 'build-raw/<%= relativePath %>/templates/'
      ext: '.js'
    options:
      relative: true
      runtime: false
      wrapper: 'amd'
      wrapperOptions:
        packageName: null
        deps: false

  config.requirejs =
    options:
      namespace: 'vtex'
      appDir: "build-raw/<%= relativePath %>/"
      name: 'shipping/script/ShippingData'
      optimize: 'uglify2'
      generateSourceMaps: true
      preserveLicenseComments: false
      mainConfigFile: 'build-raw/<%= relativePath %>/app/main.js'
      exclude: [
        "flight/lib/component",
        "state-machine/state-machine",
        "link!shipping/style/style"
      ]
      dir: "build/<%= relativePath %>/"
    dev:
      uglify2:
        mangle: false
    dist:
      uglify2:
        mangle: true

  config.watch.dust =
    files: ['src/templates/**/*.dust']
    tasks: ['dust']

  # Add app files to coffe compilation and watch
  config.clean.main.push 'build-raw'
  config.watch.coffee.files.push 'src/app/**/*.coffee'
  config.watch.coffee.tasks.push 'requirejs:dev'
  config.watch.main.files.push 'src/app/**/*.html'
  config.less.main.files[0].dest = 'build-raw/<%= relativePath %>/style/'
  config.coffee.main.files[0].cwd = 'src/script/'
  config.coffee.main.files[0].dest = 'build-raw/<%= relativePath %>/script/'
  config.copy.main.files[0].dest = 'build-raw/<%= relativePath %>/'
  config.copy.pkg.files[0].dest = 'build-raw/<%= relativePath %>/package.json'

  tasks =
  # Building block tasks
    build: ['clean', 'copy:main', 'copy:pkg', 'coffee:main', 'coffee:app', 'less', 'dust']
  # Deploy tasks
    dist: ['build', 'requirejs:dist', 'copy:deploy'] # Dist - minifies files
    test: []
    vtex_deploy: ['shell:cp', 'shell:cp_br']
  # Development tasks
    dev: ['nolr', 'build', 'requirejs:dev', 'watch']
    default: ['build', 'requirejs:dev', 'connect', 'watch']
    devmin: ['build'] # Minifies files and serve

  # Project configuration.
  grunt.initConfig config
  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-' and name isnt 'grunt-vtex'
  grunt.registerTask 'nolr', ->
    # Turn off LiveReload in development mode
    grunt.config 'watch.options.livereload', false
    return true
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks