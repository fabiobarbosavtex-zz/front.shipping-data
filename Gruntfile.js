'use strict';

module.exports = function(grunt) {
	var pkg = grunt.file.readJSON('package.json');

	grunt.initConfig({
		connect: {
			main: {
				options: {
					port: 9001,
					base: 'app/'
				}
			}
		},
		watch: {
			options: {
				livereload: true
			},
			main: {
				files: ['app/**/*.html', 'app/**/*.js', 'app/**/*.css']
			}
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

	grunt.registerTask('default', ['dust', 'connect', 'watch:main']);
};