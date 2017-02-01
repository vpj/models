Mod.require 'Weya.Base',
 'Weya'
 'Models.Editor'
 (Base, Weya, Editor) ->

  class App extends Base
   @initialize ->
    @elems = {}
    @_changed = false
    @content = ''
    @editor = new Editor model: 'Resume'

   @listen 'error', (e) ->
    console.error e

   render: ->
    @editor.render document.body,
     height: window.innerHeight
     width: window.innerWidth
     @on.rendered

   @listen 'rendered', ->
    window.addEventListener 'resize', @on.resize
    @editor.structured()
    @editor.setJSON
     name: 'Batman'
     role: 'Vigilante'
     mobile: 'Bat Signal'
     email: 'darkknight@batcomputer.com'
     timeline: [
       {
         from: 1997
         to: 1999
         institute: 'Leage of Shadows'
         course: 'Stealth and Reconnaissance'
       }, {
         from: 2003
         to: 2007
         company: 'The Outsiders'
         role: 'Team Leader'
       }, {
         from: 2004
         to: 2016
         company: 'Batman, Inc.'
         role: 'Crime Fighter'
       }, {
         from: 2007
         to: 2016
         company: 'Justice League'
         role: 'Team Member'
       }
     ]
     skills:
      Detective: 10
      'Martial arts': 10
      Chemistry: 8
      Criminology: 10
      Forensics: 10

   @listen 'resize', ->
    @editor.resize
     height: window.innerHeight
     width: window.innerWidth


  APP = new App()
  APP.render()

document.addEventListener 'DOMContentLoaded', ->
 Mod.set 'Weya', Weya
 Mod.set 'Weya.Base', Weya.Base
 Mod.set 'CodeMirror', CodeMirror
 Mod.set 'YAML', YAML

 Mod.debug true

 Mod.initialize()
