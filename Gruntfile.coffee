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
          src: ['**', '!coffee/**', '!**/*.less', '!**/*.dust']
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
      libs:
        files: [
          'app/libs/jquery.inputmask/dist/jquery.inputmask.bundle.min.js': 'bower_components/jquery.inputmask/dist/jquery.inputmask.bundle.min.js'
          'app/libs/parsleyjs/dist/parsley.min.js': 'bower_components/parsleyjs/dist/parsley.min.js'
          'app/libs/es5-shim/es5-shim.min.js': 'bower_components/es5-shim/es5-shim.min.js'
          'app/libs/es5-shim/es5-sham.min.js': 'bower_components/es5-shim/es5-sham.min.js'
          'app/libs/i18next/release/i18next-1.6.3.min.js': 'bower_components/i18next/release/i18next-1.6.3.min.js'
        ]
      templates:
        expand: true
        cwd: 'app/'
        src: ['js/template/**/*.*']
        dest: 'app/'
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
            cwd: 'app/coffee'
            src: ['**/*.coffee']
            dest: 'build-raw/<%= relativePath %>/js/'
            ext: '.js'
        ]
      lean:
        files: [
            expand: true
            cwd: 'app/coffee'
            src: ['**/*.coffee', '!rule/**']
            dest: 'build-raw/<%= relativePath %>/js/'
            ext: '.js'
        ]
      rules:
        files: [
            expand: true
            cwd: 'app/coffee'
            src: ['rule/**/*.coffee']
            dest: 'build-raw/<%= relativePath %>/js/'
            ext: '.js'
        ]

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
        files: ['app/coffee/**/*.coffee', '!app/coffee/rule/**']
        tasks: ['coffee:lean', 'copy:build']
      coffeeRules:
        files: ['app/coffee/rule/**/*.coffee']
        tasks: ['coffee:rules', 'copy:build']
      main:
        files: ['app/js/main.js', 'app/js/front-shipping-data.js',
                'app/**/*.css', 'app/index.html']
        tasks: ['copy:main', 'copy:build']
      dust:
        files: ['app/**/*.dust']
        tasks: ['dust', 'copy:templates', 'copy:main', 'copy:build']
      test:
        files: ['app/coffee/**/*.coffee', 'test/spec/**/*.coffee']
        tasks: ['karma:unit:run']

    dust:
      files:
        expand: true
        cwd: 'app/template/'
        src: ['**/*.dust']
        dest: 'app/js/template/'
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
                  "/js/front-shipping-data.js"]

  grunt.loadNpmTasks name for name of pkg.devDependencies \
    when name[0..5] is 'grunt-'

  grunt.registerTask 'default', ['clean', 'dust', 'copy:templates',
                                 'copy:libs', 'copy:main', 'coffee:main',
                                 'copy:build', 'karma:unit:start', 'server',
                                 'watch']

  # minifies files
  grunt.registerTask 'min', ['useminPrepare', 'concat', 'uglify', 'usemin']

  # Dev - minifies files
  grunt.registerTask 'devmin', ['clean', 'dust', 'copy:templates', 'copy:libs',
                                'copy:main', 'coffee:main',
                                'min', 'copy:build', 'server', 'watch']
  # Dist - minifies files
  grunt.registerTask 'dist', ['clean', 'dust', 'copy:templates', 'copy:libs',
                              'copy:main', 'coffee:main', 'min', 'copy:build']

  grunt.registerTask 'test', ['karma:single']
  grunt.registerTask 'server', ['configureProxies:server', 'connect']