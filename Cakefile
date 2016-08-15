require 'coffee-script/register'
global.BUILD = 'build'

util = require './build-script/util'
ui = require './build-script/ui'
fs = require 'fs'
{spawn, exec} = require 'child_process'

option '-q', '--quiet',    'Only diplay errors'
option '-w', '--watch',    'Watch files for change and automatically recompile'
option '-c', '--compress', 'Compress files via YUIC'
option '-i', '--inplace',  'Compress files in-place'
option '-m', '--map',  'Source map'

task 'clean', "Cleans up build directory", (opts) ->
 commands = []
 if fs.existsSync "#{BUILD}"
  commands.push "rm -r #{BUILD}/"

 commands = commands.concat [
  "mkdir #{BUILD}"
 ]

 exec commands.join('&&'), (err, stderr, stdout) ->
  if err?
   util.log stderr.trim(), 'red'
   util.log stdout.trim(), 'red'
   err = 1

  util.finish err

task 'build', "Build", (opts) ->
 global.options = opts
 ui.assets (e1) ->
  ui.js (e2) ->
   util.finish e1 + e2

