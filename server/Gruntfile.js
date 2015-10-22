module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      build: {
        src: 'src/<%= pkg.name %>.js',
        dest: 'build/<%= pkg.name %>.min.js'
      }
    },
    wiredep: {

      task: {

        // Point to the files that should be updated when
        // you run `grunt wiredep`
        src: [
          'views/**/*.tpl',   // .html support...
          'views/**/*.jade',   // .jade support...
          'static/css/main.scss',  // .scss & .sass support...
          'config.yml'         // and .yml & .yaml support out of the box!
        ],
        ignorePath: '..',
        options: {
          // See wiredep's configuration documentation for the options
          // you may pass:

          // https://github.com/taptapship/wiredep#configuration
          cwd: 'static/'
        },
         "overrides":{
                  "bootstrap" : {
                   "main": [
                    "less/bootstrap.less",
                    "dist/css/bootstrap.css",
                    "dist/js/bootstrap.js"
                ]}
          }, // overides
  
    }, // task

  } // wiredep 
  }); // grunt config

  // Load the plugin that provides the "uglify" task.
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-wiredep');

  // Default task(s).
  grunt.registerTask('default', ['uglify']);


};