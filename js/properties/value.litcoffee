Copyright 2014 - 2015
Author: Varuna Jayasiri http://blog.varunajayasiri.com

#List

    Mod.require 'Models.Properties',
     'Models.Property.Base'
     'Weya.Base'
     'Weya'
     (PROPERTIES, Base, WeyaBase, Weya) ->


Class

      class Value extends Base
       @extend()

       @default 'value', (str) ->
        if (typeof str) isnt 'string'
         throw new Error "Exected string: #{typeof str}, #{str}"
        return str

       @default 'string', (value) -> "#{str}"

       @default 'rows', 1
       @default 'columns', 20

       @default 'valid', (str) ->
        if (typeof str) isnt 'string'
         return false
        else
         return true

       @default 'search', (str) ->
        if (typeof str) isnt 'string'
         throw new Error "Exected string: #{typeof str}, #{str}"
        return str

       @default 'default', -> ''

       @default 'isDefault', (value) -> (value is @schema.default())

       parse: (data) ->
        r = super data
        return r unless r is true
        if not @schema.valid data
         return @error 'invalid'

        res =
         score: 1
         errors: []
         value: @schema.value data

        return res

       toJSON: (value) -> value
       toJSONFull: (value) -> value

       edit: (elem, value, changed) ->
        new Edit this, elem, value, changed


Edit

      class Edit extends WeyaBase
       @extend()

       @initialize (property, elem, value, changed) ->
        @property = property
        @elems =
         parent: elem
        @value = value
        @onChanged = changed
        @render()

       render: ->
        schema = @property.schema
        Weya elem: @elems.parent, context: this, ->
         if schema.rows is 1
          @$.elems.input = @input '.value',
           type: 'text'
           style:
            width: "#{2 + Math.round schema.columns * 7.25}px"
         else
          @$.elems.input = @textarea '.value',
           rows: schema.rows
           columns: schema.columns
           style:
            width: "#{2 + Math.round schema.columns * 7.25}px"
            height: "#{Math.round schema.rows * 18}px"
        @elems.input.value = @value
        @elems.input.addEventListener "input", @on.change

       @listen 'change', (e) ->
        #TODO validate
        value = @elems.input.value
        if not @property.schema.valid.call @property, value
         @elems.input.classList.add 'invalid'
        else
         @elems.input.classList.remove 'invalid'
         value = @property.schema.value.call this, value
         @onChanged value, true




      PROPERTIES.register 'value', Value
