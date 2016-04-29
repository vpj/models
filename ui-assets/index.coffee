Weya = require '../lib//weya/weya'

template = ->
 @html ->
  @head ->
   @meta charset: "utf-8"
   @title "Object"
   @meta name: "viewport", content: "width=device-width, initial-scale=1.0"
   @meta name: "apple-mobile-web-app-capable", content:"yes"
   @link
    href: 'http://fonts.googleapis.com/css?family=Raleway:400,100,200,300,500,600,700,800,900'
    rel: 'stylesheet'
    type: 'text/css'
   @link
    href: 'https://fonts.googleapis.com/css?family=Roboto:400,100,100italic,300,300italic,400italic,500,500italic,700,700italic,900,900italic'
    rel: 'stylesheet'
    type: 'text/css'

   @link href: "lib/Font-Awesome/css/font-awesome.css", rel: "stylesheet"
   @link href: "lib/skeleton/css/skeleton.css", rel: "stylesheet"
   @link href: "lib/CodeMirror/lib/codemirror.css", rel: "stylesheet"
   @link href: "lib/CodeMirror/addon/fold/foldgutter.css", rel: "stylesheet"
   @link href: "css/style.css", rel: "stylesheet"
   @link href: "css/editor.css", rel: "stylesheet"

  @body ->
   @script src:"lib/CodeMirror/lib/codemirror.js"
   @script src:"lib/CodeMirror/mode/yaml/yaml.js"
   @script src:"lib/CodeMirror/addon/fold/foldcode.js"
   @script src:"lib/CodeMirror/addon/fold/foldgutter.js"
   @script src:"lib/CodeMirror/addon/fold/indent-fold.js"
   @script src:"lib/yaml.min.js"

   @script src:"lib/weya/weya.js"
   @script src:"lib/weya/base.js"
   @script src:"lib/mod/mod.js"

   for file in @$.scripts
    @script src: "#{file}"

exports.html = (options) ->
 options ?= {}
 options.scripts ?= []

 html = Weya.markup context: options, template
 html = "<!DOCTYPE html>#{html}"

 return html


