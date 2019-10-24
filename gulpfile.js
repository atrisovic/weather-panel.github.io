const gulp = require('gulp');
const del = require('del');
const exec = require('child_process').exec;
const gulpLoadPlugins = require('gulp-load-plugins');


const $ = gulpLoadPlugins();


gulp.task('clean', function () {
  return del(['docs/**', 'docs/.*', '!docs'], {
    force: true
  });
});
gulp.task('copy', function () {
  return gulp.src([
      '_book/**/*'
    ])
    .pipe(gulp.dest('docs'));
});


gulp.task('build', function (callback) {
  // In gulp 4, you can return a child process to signal task completion
  exec('gitbook build', function (err, stdout, stderr) {
    console.log(stdout);
    console.log(stderr);
    callback();
  });
});

gulp.task('default', gulp.series('clean', 'build', 'copy', function (done) {
  done();
}));