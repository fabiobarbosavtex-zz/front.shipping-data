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
					{
						expand: true
						cwd: 'bower_components'
						src: 'flight/lib/**.js'
						dest: 'app/libs/'
					},
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

		connect:
			main:
				options:
					hostname: "*"
					port: 9001
					base: 'build/'

		remote: main: {}

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
				tasks: ['clean', 'dust', 'copy:main', 'coffee', 'copy:build']

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

		release:
			options:
				commitMessage: 'Bump <%= version %>'

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

	grunt.registerTask 'default', ['clean', 'dust', 'copy:main', 'copy:libs', 'coffee', 'copy:build', 'server', 'watch']
	grunt.registerTask 'min', ['useminPrepare', 'concat', 'uglify', 'usemin'] # minifies files
	grunt.registerTask 'devmin', ['clean', 'dust', 'copy:main', 'copy:libs', 'coffee', 'min', 'copy:build', 'server', 'watch'] # Dev - minifies files
	grunt.registerTask 'dist', ['clean', 'dust', 'copy:main', 'copy:libs', 'coffee', 'min', 'copy:build'] # Dist - minifies files
	grunt.registerTask 'test', []
	grunt.registerTask 'server', ['connect', 'remote']