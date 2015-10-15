coffee  = require 'gulp-coffee'
gulp    = require 'gulp'
mocha   = require 'gulp-mocha'
plumber = require 'gulp-plumber'

gulp.task 'test', ->
  gulp.src './test/{,**/}*.coffee', read: false
  .pipe plumber()
  .pipe mocha
    reporter: 'spec'
  .pipe plumber.stop()
  return

gulp.task 'default', ['test']

gulp.task 'watch', ['test'], ->
  gulp.watch ['{source,test}/{,**/}*.coffee'], ['test']

