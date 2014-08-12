module.exports = (grunt) ->
  pkg = grunt.file.readJSON('package.json')

  # Project configuration.
  grunt.initConfig
    relativePath: 'shipui'
    appName: pkg.name

  # Tasks
    clean:
      main: ['build', 'build-raw', 'tmp-deploy']

    copy:
      main:
        files: [
          expand: true
          cwd: 'app/'
          src: ['**', '!**/*.coffee', '!**/*.less', '!**/*.dust']
          dest: 'build-raw/<%= relativePath %>'
        ,
          src: ['app/index.html']
          dest: 'build-raw/<%= relativePath %>/index.debug.html'
        ]
      build:
        expand: true
        cwd: 'build-raw/'
        src: '**/*.*'
        dest: 'build/'      
      templates:
        expand: true
        cwd: 'app/shipping/'
        src: ['template/**/*.*']
        dest: 'app/shipping/'
        options:
          process: (content) ->
            prepend = '(function() {\n' \
              + 'var define = window.vtex.define || window.define;\n'
            content = '' + prepend + content
            content = content + '\n}).call(this);'
            return content

    coffee:
      main:
        files: [
            expand: true
            cwd: 'app/shipping'
            src: ['**/*.coffee']
            dest: 'build-raw/<%= relativePath %>/shipping/'
            ext: '.js'
        ]
      example:
        files: [
          expand: true
          cwd: 'app/coffee'
          src: ['**/*.coffee']
          dest: 'build-raw/<%= relativePath %>/js/'
          ext: '.js'
        ]
      lean:
        files: [
            expand: true
            cwd: 'app/shipping'
            src: ['**/*.coffee', '!rule/**']
            dest: 'build-raw/<%= relativePath %>/shipping/'
            ext: '.js'
        ]
      rules:
        files: [
            expand: true
            cwd: 'app/shipping'
            src: ['rule/**/*.coffee']
            dest: 'build-raw/<%= relativePath %>/shipping/'
            ext: '.js'
        ]

    less:
      main:
        files:
          'build-raw/<%= relativePath %>/shipping/css/main.css': 'app/shipping/css/main.less'

    uglify:
      options:
        mangle: false

    useminPrepare:
      html: 'build-raw/<%= relativePath %>/index.html'
      options:
        dest: 'build-raw/'
        root: 'build-raw/'

    usemin:
      html: 'build-raw/<%= relativePath %>/index.html'

    karma:
      options:
        configFile: 'karma.conf.js'
        browsers: ['Chrome']
      unit:
        background: true
      single:
        singleRun: true

    watch:
      options:
        livereload: true
      coffee:
        files: ['app/shipping/**/*.coffee', '!app/shipping/rule/**']
        tasks: ['coffee:lean', 'copy:build']
      coffeeRules:
        files: ['app/shipping/rule/**/*.coffee']
        tasks: ['coffee:rules', 'copy:build']
      coffeeExample:
        files: ['app/coffee/**/*.coffee']
        tasks: ['coffee:example', 'copy:build']
      main:
        files: ['app/js/main.js', 'app/shipping/js/front-shipping-data.js',
                'app/index.html']
        tasks: ['copy:main', 'copy:build']
      less:
        files: ['app/shipping/css/**/*.less']
        tasks: ['less', 'copy:build']
      dust:
        files: ['app/**/*.dust']
        tasks: ['dust', 'copy:templates', 'copy:main', 'copy:build']
      test:
        files: ['app/shipping/**/*.coffee', 'test/spec/**/*.coffee']
        tasks: []

    dust:
      files:
        expand: true
        cwd: 'app/shipping/dust-template'
        src: ['**/*.dust']
        dest: 'app/shipping/template/'
        ext: '.js'
      options:
        relative: true
        runtime: false
        wrapper: 'amd'
        wrapperOptions:
          packageName: null
          deps: false

    connect:
      server:
        options:
          livereload: true
          hostname: "*"
          port: 80
          middleware: (connect, options) ->
            proxy = require("grunt-connect-proxy/lib/utils").proxyRequest
            [proxy, connect.static('./build/')]
        proxies: [
          context: ['/', '!/<%= relativePath %>']
          host: 'portal.vtexcommerce.com.br'
          headers: {
            "X-VTEX-Router-Backend-EnvironmentType": "beta"
          }
        ]

    vtex_deploy:
      main:
        cwd: "build/<%= relativePath %>/"
        publish: true
        upload:
          version:
            "/": "**"

        transform:
          replace:
            "/shipui/": "//io.vtex.com.br/<%= appName %>/{{version}}/"
            VERSION_NUMBER: "{{version}}"

          files: ["index.html", "index.debug.html",
                  "/shipping/setup/front-shipping-data.js"]

  grunt.loadNpmTasks name for name of pkg.devDependencies \
    when name[0..5] is 'grunt-'

  grunt.registerTask 'base', ['clean', 'dust', 'copy:templates',
                              'copy:main', 'coffee:main', 'coffee:example',
                              'less', 'copy:build']

  grunt.registerTask 'default', ['base', 'server', 'watch']

  # minifies files
  grunt.registerTask 'min', ['useminPrepare', 'concat', 'uglify', 'usemin']

  # Dev - minifies files
  grunt.registerTask 'devmin', ['clean', 'dust', 'copy:templates',
                                'copy:main', 'coffee:main', 'min',
                                'copy:build', 'server', 'watch']
  # Dist - minifies files
  grunt.registerTask 'dist', ['clean', 'dust', 'copy:templates', 'copy:main',
                              'coffee:main', 'min', 'copy:build']

  grunt.registerTask 'test', ['base', 'server', 'karma:single']
  grunt.registerTask 'server', ['configureProxies:server', 'connect']