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

       parse: (data) ->
        r = super data
        return r unless r is true

        res =
         score: 0
         errors: ['invalid']
         value: @schema.default.call this
        for type in @schema.oneof
         m = new (MODELS.get type)
         r = m.parse data
         if res.score < r.score
          res = r

        return res

       toJSON: (value) -> value.toJSON()
       toJSONFull: (value) -> value.toJSONFull()

       edit: (elem, value, changed) ->
        new Edit this, elem, value, changed


Edit

      class Edit extends WeyaBase
       @extend()

       @initialize (property, elem, value, changed) ->
        @property = property
        @elems =
         parent: elem
        @model = value
        @onChanged = changed
        @render()

       render: ->
        Weya elem: @elems.parent, context: this, ->
         @div ".oneof-controls", ->
          @$.elems.type = @select on: {change: @$.on.typeChange}, ->
           for type in @$.property.schema.oneof
            @option value: type, type

         @$.elems.model = @div ".model", null

        #@elems.add.addEventListener 'click', @addClicked.bind this

        @renderModel()

       @listen 'typeChange', (e) ->
        type = @elems.type.value
        return if type is @model.type
        json = @model.toJSON()
        @model = new (MODELS.get type)
        r = @model.parse json
        @onChanged @model, true
        @renderModel()

       renderModel: ->
        @elems.model.innerHTML = ''
        @elems.type.value = @model.type
        @model.edit @elems.model, @modelChanged.bind this

       modelChanged: (value) ->
        @onChanged value, false





      PROPERTIES.register 'oneof', OneOf
