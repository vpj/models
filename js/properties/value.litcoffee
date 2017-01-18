Copyright 2014 - 2015
Author: Varuna Jayasiri http://blog.varunajayasiri.com

#Value

    Mod.require 'Models.Properties',
     'Models.Property.Base'
     'Weya.Base'
     'Weya'
     (PROPERTIES, Base, WeyaBase, Weya) ->


Class

      class Value extends Base
       @extend()

       propertyType: 'value'

       @default 'value', (str, stack) ->
        if (typeof str) isnt 'string'
         throw new Error "Exected string: #{typeof str}, #{str}"
        return str

       @default 'string', (value, stack) -> "#{value}"

       @default 'rows', 1
       @default 'columns', 20

       @default 'valid', (str, stack, isData = false) ->
        if (typeof str) isnt 'string'
         return false
        else
         return true

       @default 'search', (str, stack) -> null

       @default 'default', -> ''

       @default 'isDefault', (value, stack) ->
        value is @schema.default()

       parse: (data, stack) ->
        r = super data, stack
        return r unless r is true
        if not @schema.valid data, stack, true
         return @error 'invalid'

        return {
         score: 1
         errors: []
         value: @schema.value data, stack
        }

       toJSON: (value, stack) -> value
       toJSONFull: (value, stack) -> value

       edit: (elem, value, onChanged, stack) ->
        new Edit this, elem, value, onChanged, stack


Edit

      class Edit extends WeyaBase
       @extend()

       @initialize (property, elem, value, onChanged, stack) ->
        @property = property
        @elems =
         parent: elem
        @value = value
        @onChanged = onChanged
        @stack = stack
        @render()

       render: ->
        schema = @property.schema
        width = 2 + Math.round schema.columns * 7.25
        Weya elem: @elems.parent, context: this, ->
         if schema.rows is 1
          @$.elems.input = @input '.value',
           type: 'text'
           placeholder: @$.property._name
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

        @elems.input.value = schema.string @value, @stack
        @elems.input.addEventListener "input", @on.change
        @elems.input.addEventListener "focus", @on.focus
        @elems.input.addEventListener "blur", @on.blur
        @elems.search.addEventListener 'click', @on.searchClick
        @change()

       search: ->
        value = @elems.input.value
        results = @property.schema.search.call @property, value, @stack
        return if not results?
        return if not Array.isArray results

        if results.length is 0
         @elems.search.style.display = 'none'
         return

        @elems.search.style.display = 'block'
        @elems.search.innerHTML = ''
        Weya elem: @elems.search, ->
         for r, i in results
          break if i > 10
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
        , 400

       @listen 'change', (e) ->
        @search()
        @change()

       change: ->
        value = @elems.input.value
        if not @property.schema.valid.call @property, value, @stack
         @elems.input.classList.add 'invalid'
        else
         @elems.input.classList.remove 'invalid'
         value = @property.schema.value.call this, value, @stack
         @onChanged value, true




      PROPERTIES.register 'value', Value
