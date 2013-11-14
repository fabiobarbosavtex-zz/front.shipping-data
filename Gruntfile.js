'use strict';

module.exports = function(grunt) {
	var pkg = grunt.file.readJSON('package.json');

	grunt.initConfig({
		connect: {
			main: {
				options: {
					port: 9001,
					base: 'app/',
					middleware: function (connect, options) {
						return [
							connect.compress(),
							connect.static(options.base),
							connect.directory(options.base)
						];
					}
				}
			}
		},
		watch: {
			options: {
				livereload: true
			},
			main: {
				files: ['app/**/*.html',
								'app/js/component/*.js',
								'app/js/page/*.js',
								'app/js/main.js',
								'app/**/*.css',
								'app/**/*.dust'],
				tasks: ['dust']
			}
		},
		remote: {
			main: {}
		},
		dust: {
			files: {
				expand: true,
				cwd: 'app/templates',
				src: ['**/*.dust'],
				dest: 'app/js/templates/',
				ext: '.js'
			},
			options: {
				relative: true,
				runtime: false,
				wrapper: false
			}
		}
	});

	for (var name in pkg.devDependencies) {
		if (name.slice(0, 6) === 'grunt-') {
			grunt.loadNpmTasks(name);
		}
	}

	grunt.registerTask('default', ['dust', 'connect', 'remote', 'watch:main']);
};