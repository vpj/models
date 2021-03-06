Copyright 2014 - 2015
Author: Varuna Jayasiri http://blog.varunajayasiri.com

#Model Base

    Mod.require 'Weya',
     'Models.Properties'
     'Models.Util'
     (Weya, PROPERTIES, UTIL) ->


Class

      class Model
       _initialize: []
       _properties: {}
       _requiredFunctions: {}
       on: {}

       @extend: ->
        @::_initialize = @::_initialize.slice()
        @::_properties = UTIL.extend {}, @::_properties
        @::_requiredFunctions = UTIL.extend {}, @::_requiredFunctions
        @::on = UTIL.extend {}, @::on

       @include: (obj) ->
        if not obj?
         throw new Error 'Cannot include a null object'
        for k, v of obj
         switch k
          when 'initialize'
           @::_initialize.push v
          when 'property'
           for name, obj of v
            @_addProperty name, obj
          when 'requireFunction'
           for name, desc of v
            @::_requiredFunctions[name] = desc
          when 'on'
           for event, listener of v
            if not @::on[event]?
             @::on[event] = listener
          else
           @prototype[k] = v

        return null

 Initialize variables.

       @initialize: (func) ->
        @::_initialize.push func

Add listener

       @listen: (name, func) ->
        @::on[name] = func

Register a property

       @property: (name, obj) ->
        if (typeof name) is 'string'
         @_addProperty name, obj
        else
         objs = name
         for name, obj of objs
          @_addProperty name, obj

       @_addProperty: (name, obj) ->
        if (typeof name) isnt 'string'
         throw new Error "Property name not a string: #{name}"
        if (typeof obj) isnt 'object'
         throw new Error "Property not an object: #{name}"

        @::_properties[name] = PROPERTIES.create obj, name

       @requireFunction: (name, desc) ->
        if (typeof name) is 'string'
         @::_requiredFunctions[name] = desc
        else
         obj = name
         for name, desc of obj
          @::_requiredFunctions[name] = desc


Check properties

       @check: ->
        if not @::type?
         throw new Error "Object type not defined"
        type = @::type

        mentioned =
         type: true
        for func, desc of @::_requiredFunctions
         mentioned[func] = true
         if not @::[func]?
          throw new Error "#{type}: Function not defined: #{func} - #{desc}"
         if (typeof @::[func]) isnt 'function'
          throw new Error "#{type}: Not a function: #{func} - #{desc}"

        extra = []
        for k of this.prototype
         continue if k in ['on', 'values']
         if not mentioned[k]?
          if k[0] isnt '_'
           extra.push k

        if extra.length > 0
         console.error type, extra

        @::_checked = true

Get values

       @::__defineGetter__ 'values', -> @_values


       constructor: ->
        @initialize.apply this, arguments

##Override

##Initialize

       initialize: (options) ->
        if @_checked isnt on
         throw new Error "Object #{@type} wasnt checked"

        @_bindEvents()

        for init in @_initialize
         init.call this


       @requireFunction
        'initialize': 'Initialize'
        'parse': 'Parse'
        'render': 'Render element'
        'weya': 'Render weya template'
        'html': 'Render html'
        'template': 'Render template'
        'toJSON': 'To JSON'
        'toJSONFull': 'To JSON Full'
        'isDefault': 'Is default value'
        'edit': 'Render editor'
        'unedit': 'Destroy editor'
        'validate': 'Validate if the values in editor are correct'
        'valueChanged': 'A property value change event'

##Public functions

       parse: (data, stack = []) ->
        stack = stack.slice 0
        stack.push this
        excess = 0
        @_errors = []
        fields = 0
        @_score = 0
        @_values = {}

        for name of data when not @_properties[name]?
         @_errors.push ": #{name} excess"
         excess++


        for name, prop of @_properties
         fields++
         r = prop.parse data[name], stack
         @_values[name] = r.value
         if not prop.isDefault r.value, stack
          @_score += r.score
         for e in r.errors
          @_errors.push "#{name}(#{@type})/#{e}"

        if fields is 0
         @_score = (if excess > 0 then 0 else 1)
        else
         @_score = (@_score - excess) / fields
        @_score = 0 if @_score < 0
        if @_score > 1
         throw new Error "Score greater than 1: #{score}"

        return {
         score: @_score,
         value: this
         errors: @_errors
        }

       weya: (weya, stack = []) ->
        @template.call weya, this, stack

       render: (elem, stack = []) ->
        self = this
        Weya elem: elem, ->
         self.weya this, stack

       html: (stack = []) ->
        self = this
        Weya.markup {}, ->
         self.weya this, stack

       toJSON: (stack = [])->
        stack = stack.slice 0
        stack.push this
        data = {}
        for name, prop of @_properties
         v = prop.toJSON @_values[name], stack
         if not prop.isDefault v, stack
          data[name] = v


        return data

       toJSONFull: (stack = []) ->
        stack = stack.slice 0
        stack.push this
        data = {}
        for name, prop of @_properties
         data[name] = prop.toJSONFull @_values[name], stack

        return data


       isDefault: (stack = []) ->
        stack = stack.slice 0
        stack.push this
        for name, prop of @_properties
         v = prop.toJSON @_values[name]
         if not prop.isDefault v, stack
          return false

        return true

       edit: (elem, changed, stack = []) ->
        stack = stack.slice 0
        stack.push this
        @onChanged = changed
        @_editElems = {}
        @_editProperties = {}
        Weya elem: elem, context: this, ->
         for name, prop of @$._properties
          @div ".property.property-type-#{prop.propertyType}", ->
           @span ".property-name", name
           @$._editElems[name] = @div ".property-value", ""

        for name, prop of @_properties
         @_editProperties[name] = prop.edit @_editElems[name], @_values[name],
          @valueChanged.bind self: this, name: name
          stack

       unedit: ->
        return if not @_editProperties?
        for name, edit of @_editProperties
         edit.unedit()
        @_editElems = null
        @_editProperties = null

       validate: ->
        return null if not @_editProperties?

        for name, edit of @_editProperties
         return false if not edit.validate()

        return true

       valueChanged: (value, changed) ->
        @self._values[@name] = value
        @self.onChanged @self, false


##Private functions

Bind

       _bindEvents: ->
        events = @on
        @on = {}
        for k, v of events
         @on[k] = v.bind this




      Mod.set 'Models.Model.Base', Model
