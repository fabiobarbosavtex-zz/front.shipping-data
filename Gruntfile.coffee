module.exports = (grunt) ->
	pkg = grunt.file.readJSON('package.json')

	# Project configuration.
	grunt.initConfig
		relativePath: 'shipping-ui'
		appName: pkg.name

	# Tasks
		clean:
			main: ['build', 'tmp-deploy']

		copy:
			main:
				files: [
					expand: true
					cwd: 'app/'
					src: ['**', '!coffee/**', '!**/*.less', '!**/*.dust']
					dest: 'build/<%= relativePath %>'
        ,
          src: ['package.json']
          dest: 'build/<%= relativePath %>/package.json'
				]
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
					dest: 'build/<%= relativePath %>/js/'
					ext: '.js'
				]

		uglify:
			options:
				mangle: false

		useminPrepare:
			html: 'build/<%= relativePath %>/index.html'
			options:
				dest: 'build/'
				root: 'build/'

		usemin:
			html: 'build/<%= relativePath %>/index.html'

		connect:
			server:
				options:
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

		watch:
			dev:
				options:
					livereload: true
				files: ['app/**/*.html',
								'app/coffee/**/*.coffee',
								'spec/**/*.coffee',
								'app/js/component/*.js',
								'app/js/page/*.js',
								'app/js/main.js',
								'app/**/*.css',
								'app/**/*.dust']
				tasks: ['clean', 'dust', 'copy:main', 'coffee']

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

		vtex_deploy:
			main:
				cwd: "build/<%= relativePath %>/"
				publish: true
				upload:
					"/{{version}}/": "**"

				transform:
					replace:
						"/shipping-ui/": "//io.vtex.com.br/<%= appName %>/{{version}}/"
						VERSION_NUMBER: "{{version}}"

					files: ["index.html"]

	grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'default', ['clean', 'dust', 'copy:main', 'copy:libs', 'coffee', 'server', 'watch']
	grunt.registerTask 'min', ['useminPrepare', 'concat', 'uglify', 'usemin'] # minifies files
	grunt.registerTask 'devmin', ['clean', 'dust', 'copy:main', 'copy:libs', 'coffee', 'min', 'server', 'watch'] # Dev - minifies files
	grunt.registerTask 'dist', ['clean', 'dust', 'copy:main', 'copy:libs', 'coffee', 'min'] # Dist - minifies files
	grunt.registerTask 'test', []
	grunt.registerTask 'server', ['configureProxies:server', 'connect']