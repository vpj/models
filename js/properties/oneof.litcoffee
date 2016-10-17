Copyright 2014 - 2015
Author: Varuna Jayasiri http://blog.varunajayasiri.com

#OneOf

    Mod.require 'Models.Properties',
     'Models.Property.Base'
     'Models.Models'
     'Weya.Base'
     'Weya'
     (PROPERTIES, Base, MODELS, WeyaBase, Weya) ->


Class

      class OneOf extends Base
       @extend()

       propertyType: 'oneof'

       @default 'oneof', ['Null']
       @default 'default', ->
        return null if @schema.oneof.length is 0
        model = new (MODELS.get @schema.oneof[0])
        r = model.parse @schema.defaultValues.call this
        return r.value

       @default 'defaultValues', -> {}

       @default 'isDefault', (value) ->
        return true if @schema.oneof.length is 0
        model = new (MODELS.get @schema.oneof[0])
        model.parse value
        model.isDefault()

       @isValidSchema: (schema) ->
        return false if not super schema
        return false if not schema.oneof?
        return true

       parse: (data, stack) ->
        r = super data, stack
        return r unless r is true

        res = @error 'invalid'
        for type in @schema.oneof
         m = new (MODELS.get type)
         r = m.parse data, stack
         if res.score < r.score
          res = r

        return res

       toJSON: (value, stack) -> value.toJSON stack
       toJSONFull: (value, stack) -> value.toJSONFull stack

       edit: (elem, value, onChanged, stack) ->
        new Edit this, elem, value, onChanged, stack


Edit

      class Edit extends WeyaBase
       @extend()

       @initialize (property, elem, value, onChanged, stack) ->
        @property = property
        @elems =
         parent: elem
        @model = value
        @onChanged = onChanged
        @stack = stack
        @render()

       render: ->
        Weya elem: @elems.parent, context: this, ->
         @$.elems.controls = @div ".oneof-controls", ->
          @$.elems.type = @select on: {change: @$.on.typeChange}, ->
           for type in @$.property.schema.oneof
            @option value: type, type

         @$.elems.model = @div ".model", null

        if @property.schema.oneof.length <= 1
         @elems.controls.style.display = 'none'

        @renderModel()

       @listen 'typeChange', (e) ->
        type = @elems.type.value
        return if type is @model.type
        json = @model.toJSON stack
        @model = new (MODELS.get type)
        r = @model.parse json, stack
        @onChanged @model, true
        @renderModel()

       renderModel: ->
        @elems.model.innerHTML = ''
        @elems.type.value = @model.type
        @model.edit @elems.model,
         @modelChanged.bind this
         @stack

       modelChanged: (value) ->
        @onChanged value, false





      PROPERTIES.register 'oneof', OneOf
