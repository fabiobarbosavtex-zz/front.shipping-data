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
					'app/libs/parsleyjs/i18n/messages.pt_br.js': 'bower_components/parsleyjs/i18n/messages.pt_br.js'
					'app/libs/parsleyjs/dist/parsley.min.js': 'bower_components/parsleyjs/dist/parsley.min.js'
					'app/libs/es5-shim/es5-shim.js': 'bower_components/es5-shim/es5-shim.js'
					'app/libs/es5-shim/es5-sham.js': 'bower_components/es5-shim/es5-sham.js'
				]
		coffee:
			main:
				files: [
						expand: true
						cwd: 'app/coffee'
						src: ['**/*.coffee']
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
				browsers: ['PhantomJS']
			unit:
				background: true
			single:
				singleRun: true

		watch:
			options:
				livereload: true
			coffee:
				files: ['app/coffee/**/*.coffee']
				tasks: ['coffee']
			main:
				files: ['app/js/main.js', 'app/**/*.css', 'app/index.html']
				tasks: ['copy']
			dust:
				files: ['app/**/*.dust']
				tasks: ['dust']
			test:
				files: ['app/coffee/**/*.coffee', 'test/spec/**/*.coffee']
				tasks: ['karma:unit:run']

		dust:
			files:
				expand: true
				cwd: 'app/templates'
				src: ['**/*.dust']
				dest: 'app/js/templates/'
				ext: '.js'			
			options:
				relative: true
				runtime: false
				wrapper: false

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

					files: ["index.html", "index.debug.html"]

	grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'default', ['clean', 'dust', 'copy:libs', 'copy:main', 'coffee', 'copy:build', 'karma:unit', 'server', 'watch']
	grunt.registerTask 'min', ['useminPrepare', 'concat', 'uglify', 'usemin'] # minifies files
	grunt.registerTask 'devmin', ['clean', 'dust', 'copy:libs', 'copy:main',  'coffee', 'min', 'copy:build', 'server', 'watch'] # Dev - minifies files
	grunt.registerTask 'dist', ['clean', 'dust', 'copy:libs', 'copy:main', 'coffee', 'min', 'copy:build'] # Dist - minifies files
	grunt.registerTask 'test', ['karma:single']
	grunt.registerTask 'server', ['configureProxies:server', 'connect']