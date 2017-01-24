Mod.require 'Weya.Base',
 'CodeMirror'
 'YAML'
 'Models.Models'
 (Base, CodeMirror, YAML, MODELS) ->

  class Editor  extends Base
   @extend()

   template: ->
    @$.elems.editorContainer = @div ".model-editor", ->
     @div ".model-editor-container", ->
       @div ".toolbar", ->
        tools = @$.elems.toolbar = {}
        tools.yaml = @i ".fa.fa-lg.fa-pencil", on: {click: @$.on.yaml}
        tools.structured = @i ".fa.fa-lg.fa-table", on: {click: @$.on.structured}
        tools.indent = @i ".fa.fa-indent", on: {click: @$.on.indent}
        tools.outdent = @i ".fa.fa-outdent", on: {click: @$.on.outdent}

       @$.elems.yaml = @div ->
        @$.elems.textarea = @textarea ".editor",
         autocomplete: "off"
         spellcheck: "false"

       @$.elems.structured = @div '.structured-editor', ''

     @$.elems.preview = @div ".model-preview-container", ->
      @$.elems.errors = @div ".error", null

      @$.elems.previewMain = @div ".model-preview", ''

   @initialize (options) ->
    @elems = {}
    @options = options
    @_editMode = 'yaml'

   yaml: ->
    @_editMode = 'yaml'
    @elems.yaml.style.display = 'block'
    @elems.toolbar.yaml.style.display = 'none'
    @elems.toolbar.structured.style.display = 'inline-block'
    @elems.toolbar.indent.style.display = 'inline-block'
    @elems.toolbar.outdent.style.display = 'inline-block'
    @elems.structured.style.display = 'none'
    json = @model.toJSON()
    text = YAML.stringify json, 10
    @editor.setValue text
    @model.unedit()

   structured: ->
    @_editMode = 'structured'
    @elems.yaml.style.display = 'none'
    @elems.toolbar.yaml.style.display = 'inline-block'
    @elems.toolbar.structured.style.display = 'none'
    @elems.toolbar.indent.style.display = 'none'
    @elems.toolbar.outdent.style.display = 'none'
    @elems.structured.style.display = 'block'
    @elems.structured.innerHTML = ''
    @model.edit @elems.structured, @on.structuredChange

   getModel: -> @model
   setJSON: (json) ->
    @_loadJSON json
    if @_editMode is 'yaml'
     text = YAML.stringify json, 10
     @editor.setValue text
    else
     @elems.structured.innerHTML = ''
     @model.edit @elems.structured, @on.structuredChange

   @listen 'yaml', -> @yaml()
   @listen 'structured', -> @structured()
   @listen 'yamlChange', ->
    @elems.previewMain.innerHTML = ''
    try
     json = YAML.parse @editor.getValue()
    catch e
     @elems.errors.textContent = e.message
     return

    @_loadJSON json


   @listen 'structuredChange', (value, changed) ->
    @elems.previewMain.innerHTML = ''
    @model = value if changed?
    #console.log @model.html()
    @model.render @elems.previewMain

   @listen 'indent', ->
    sels = @editor.listSelections()
    for sel in sels
     for i in [sel.anchor.line..sel.head.line]
      @editor.indentLine i, 'add'

   @listen 'outdent', ->
    sels = @editor.listSelections()
    for sel in sels
     for i in [sel.anchor.line..sel.head.line]
      @editor.indentLine i, 'subtract'

   _loadJSON: (json) ->
    @model = new (MODELS.get @options.model)

    try
     res = @model.parse json
    catch e
     @elems.errors.textContent = e.message
     return

    #console.log res.score
    #console.log res.value
    #for e in res.errors
    # console.error e
    #console.log @model.html()

    @elems.errors.textContent = ''
    @model.render @elems.previewMain

   @listen 'setupEditor', ->
    @editor = CodeMirror.fromTextArea @elems.textarea,
     mode: "yaml"
     lineNumbers: true
     lineWrapping: true
     tabSize: 1
     indentUnit: 1
     foldGutter: true
     gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"]

    @editor.on 'change', @on.yamlChange
    @resize @size
    @editor.setValue '{}'
    @onRendered()

   resize: (size) ->
    @size = size
    height = @size.height
    @editor.setSize null, "#{height - 100}px"
    @elems.structured.style.height = "#{height - 100}px"
    @elems.preview.style.maxHeight = "#{height - 50}px"

   render: (elem , size, rendered) ->
    @elems.container = elem
    @size = size
    @onRendered = rendered
    Weya elem: @elems.container, context: this, @template
    @elems.structured.style.display = 'none'
    @elems.toolbar.yaml.style.display = 'none'

    window.requestAnimationFrame @on.setupEditor

  Mod.set 'Models.Editor', Editor
