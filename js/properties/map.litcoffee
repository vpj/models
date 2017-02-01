Copyright 2014 - 2015
Author: Varuna Jayasiri http://blog.varunajayasiri.com

#List

    Mod.require 'Models.Properties',
     'Models.Property.Base'
     'Weya.Base'
     'Weya'
     (PROPERTIES, Base, WeyaBase, Weya) ->

Class

      class MapProperty extends Base
       @extend()

       propertyType: 'map'

       @default 'map', {}
       @default 'validKey', (key) ->
        return false if (typeof key) isnt 'string'
        return false if key.trim().length is 0
        return true

       @default 'default', -> {}
       @default 'isDefault', (value) ->
        return true if not value?
        return true if (typeof value) is 'object'
        return false

       constructor: (schema) ->
        super schema

        map = @schema.map
        @item = PROPERTIES.create map

       @isValidSchema: (schema) ->
        return false if not super schema
        return false if not schema.map?
        return PROPERTIES.isValidSchema schema.map

       toJSON: (value) ->
        return null if not value?
        data = {}
        elemsCount = 0
        for k, v of value
         data[k] = @item.toJSON v
         elemsCount++
        return null if not elemsCount
        return data

       toJSONFull: (value) ->
        return null if not value
        data = {}
        for k, v of value
         data[k] = @item.toJSON v
        return data


       parse: (data) ->
        r = super data
        return r unless r is true
        if (typeof data) isnt 'object'
         return @error 'object expected'
        if Array.isArray data
         return @error 'object expected'

        res =
         score: 0
         errors: []
         value: {}
        elemsCount = 0
        for k, v of data
         r = @item.parse v
         res.score += r.score
         if not @schema.validKey k
          return @error "invalid key: #{k}"
         for e in r.errors
          res.errors.push e
         res.value[k] = r.value
         elemsCount++

        res.score /= elemsCount

        return res

       edit: (elem, value, changed) ->
        new Edit this, elem, value, changed



Edit

      class Edit extends WeyaBase
       @extend()

       @initialize (property, elem, value, changed) ->
        @property = property
        @elems =
         parent: elem
        @map = value
        @list = []
        for k, v of @map
         @list.push
          key: k
          value: v
        @onChanged = changed
        @render()

       render: ->
        Weya elem: @elems.parent, context: this, ->
         @div ".list-controls", ->
          @$.elems.add = @i ".fa.fa-plus", null
         @$.elems.list = @div ".list", null

        @elems.add.addEventListener 'click', @on.addClick

        @mapList()
        @renderList()

       @listen 'addClick', (e) ->
        @list.push
         key: ''
         value: (@property.item.parse null).value
        @mapList()
        @renderList()
        @onChanged @map, false

       @listen 'listClick',(e) ->
        n = e.target
        idx = null
        action = null
        while n?
         idx = n.listIdx if n.listIdx?
         action = n.listAction if n.listAction?
         n = n.parentNode

        return if not idx?
        return if not action?

        switch action
         when 'delete'
          for i in [idx...@list.length - 1]
           @list[i] = @list[i + 1]
          @list.pop()

        @mapList()
        @renderList()
        @onChanged @map, false

       mapList: ->
        keys = (k for k of @map)
        for k in keys
         delete @map[k]
        for obj in @list
         continue if @map[obj.key]?
         @map[obj.key] = obj.value

       renderList: ->
        @elems.list.innerHTML = ''
        @elems.items = []
        @elems.keys = []
        Weya elem: @elems.list, context: this, ->
         for v, i in @$.list
          @div ".list-item", ->
           @div ".list-item-controls-hover", ->
            @i ".fa.fa-cog", null
            @div ".list-item-controls",
             on: {click: @$.on.listClick}
             ->
              icon = @i ".fa.fa-lg.fa-trash", null
              icon.listIdx = i
              icon.listAction = 'delete'
           @div ".list-item-content", ->
            @div ".property.property-type-value", ->
             @span ".property-name", 'Key'
             @div ".property-value", ->
              @$.elems.keys.push @input '.value',
               type: 'text'
               placeholder: 'Key'
               style:
                width: "20px"
            @div ".property.property-type-#{@$.property.item.propertyType}", ->
             @$.elems.items.push @div ".property-value", null

        for v, i in @list
         @property.item.edit @elems.items[i], v.value, @itemChanged.bind self: this, idx: i
         @elems.keys[i].value = v.key
         @elems.keys[i].addEventListener 'input', @keyChanged.bind self: this, idx: i

       keyChanged: ->
        elem = @self.elems.keys[@idx]
        key = elem.value.trim()
        if not @self.property.schema.validKey.call @property, key
         elem.classList.add 'invalid'
        else
         elem.classList.remove 'invalid'
         @self.list[@idx].key = key
         @self.mapList()
         @self.onChanged @self.map, false

       itemChanged: (value, changed) ->
        if changed
         @self.list[@idx].value = value
         @self.map[@self.list[@idx].key] = value
        @self.onChanged @self.map, false



      PROPERTIES.register 'map', MapProperty
