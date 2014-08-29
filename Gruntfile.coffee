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

  config.dust =
    files:
      expand: true
      cwd: 'src/templates/'
      src: ['**/*.dust']
      dest: 'build/<%= relativePath %>/templates/'
      ext: '.js'
    options:
      relative: true
      runtime: false
      wrapper: 'amd'
      wrapperOptions:
        packageName: null
        deps: false

  config.copy.templates =
    expand: true
    cwd: 'build/<%= relativePath %>/'
    src: ['templates/**/*.*']
    dest: 'build/<%= relativePath %>/'
    options:
      process: (content) ->
        "(function(){var define=window.vtex.define||window.define;#{content}})()"

  config.watch.dust =
    files: ['src/templates/**/*.dust']
    tasks: ['dust', 'copy:templates']

  # Add app files to coffe compilation and watch
  config.watch.coffee.files.push 'src/app/**/*.coffee'
  config.watch.main.files.push 'src/app/**/*.html'
  config.coffee.main.files[0].cwd = 'src/'
  config.coffee.main.files[0].dest = 'build/<%= relativePath %>/'

  tasks =
  # Building block tasks
    build: ['clean', 'copy:main', 'copy:pkg', 'coffee', 'less', 'dust', 'copy:templates']
  # Deploy tasks
    dist: ['build', 'copy:deploy'] # Dist - minifies files
    test: []
    vtex_deploy: ['shell:cp']
  # Development tasks
    dev: ['nolr', 'build', 'watch']
    default: ['build', 'connect', 'watch']
    devmin: ['build', 'min', 'connect:http:keepalive'] # Minifies files and serve

  # Project configuration.
  grunt.initConfig config
  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-' and name isnt 'grunt-vtex'
  grunt.registerTask 'nolr', ->
    # Turn off LiveReload in development mode
    grunt.config 'watch.options.livereload', false
    return true
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks