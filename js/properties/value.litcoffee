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

       @default 'search', (str) -> null

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
        width = 2 + Math.round schema.columns * 7.25
        Weya elem: @elems.parent, context: this, ->
         if schema.rows is 1
          @$.elems.input = @input '.value',
           type: 'text'
           style:
            width: "#{width}px"
         else
          @$.elems.input = @textarea '.value',
           rows: schema.rows
           columns: schema.columns
           style:
            width: "#{width}px"
            height: "#{Math.round schema.rows * 18}px"

         @$.elems.search = @div '.search',
          style:
           display: 'none'
           width: "#{width}px"

        @elems.input.value = @value
        @elems.input.addEventListener "input", @on.change
        @elems.input.addEventListener "focus", @on.focus
        @elems.input.addEventListener "blur", @on.blur
        @elems.search.addEventListener 'click', @on.searchClick
        @change()

       search: ->
        value = @elems.input.value
        results = @property.schema.search.call @property, value
        return if not results?
        return if not Array.isArray results

        if results.length is 0
         @elems.search.style.display = 'none'
         return

        @elems.search.style.display = 'block'
        @elems.search.innerHTML = ''
        Weya elem: @elems.search, ->
         for r in results
          e = @div r
          e._result = r

       @listen 'searchClick', (e) ->
        n = e.target
        result = null
        while n? and n isnt @elems.search
         if n._result
          result = n._result
          break
         n = n.parentNode

        return if not result?
        @elems.input.value = result
        @elems.search.style.display = 'none'
        @change()

       @listen 'focus', (e) -> @search()
       @listen 'blur', (e) ->
        setTimeout =>
         @elems.search.style.display = 'none'
        , 100

       @listen 'change', (e) ->
        @search()
        @change()

       change: ->
        value = @elems.input.value
        if not @property.schema.valid.call @property, value
         @elems.input.classList.add 'invalid'
        else
         @elems.input.classList.remove 'invalid'
         value = @property.schema.value.call this, value
         @onChanged value, true




      PROPERTIES.register 'value', Value
