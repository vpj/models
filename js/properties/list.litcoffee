Copyright 2014 - 2015
Author: Varuna Jayasiri http://blog.varunajayasiri.com

#List

    Mod.require 'Models.Properties',
     'Models.Property.Base'
     'Weya.Base'
     'Weya'
     (PROPERTIES, Base, WeyaBase, Weya) ->

Class

      class List extends Base
       @extend()

       @default 'list', {}

       @default 'default', -> []
       @default 'isDefault', (value) ->
        return true if not value?
        return true if value.length is 0
        return false

       constructor: (schema) ->
        super schema

        list = @schema.list
        @item = PROPERTIES.create list

       @isValidSchema: (schema) ->
        return false if not super schema
        return false if not schema.list?
        return PROPERTIES.isValidSchema schema.list

       toJSON: (value) ->
        return null if not value
        return null if value.length is 0
        data = []
        for v in value
         data.push @item.toJSON v
        return data

       toJSONFull: (value) ->
        return null if not value
        data = []
        for v in value
         data.push @item.toJSONFull v
        return data


       parse: (data) ->
        r = super data
        return r unless r is true
        if not Array.isArray data
         return @error 'array expected'

        res =
         score: 0
         errors: []
         value: []
        for d in data
         r = @item.parse d
         res.score += r.score
         for e in r.errors
          res.errors.push e
         res.value.push r.value

        res.score /= res.value.length

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
        @list = value
        @onChanged = changed
        @render()

       render: ->
        Weya elem: @elems.parent, context: this, ->
         @div ".list-controls", ->
          @$.elems.add = @i ".fa.fa-plus", null
         @$.elems.list = @div ".list", null

        @elems.add.addEventListener 'click', @on.addClick

        @renderList()

       @listen 'addClick', (e) ->
        @list.push (@property.item.parse null).value
        @renderList()
        @onChanged @list

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
         when 'down'
          return if idx >= @list.length - 1
          temp = @list[idx]
          @list[idx] = @list[idx + 1]
          @list[idx + 1] = temp
         when 'up'
          return if idx <= 0
          temp = @list[idx]
          @list[idx] = @list[idx - 1]
          @list[idx - 1] = temp
         when 'delete'
          for i in [idx...@list.length - 1]
           @list[i] = @list[i + 1]
          @list.pop()

        @renderList()
        @onChanged @list, false


       renderList: ->
        @elems.list.innerHTML = ''
        @elems.items = []
        Weya elem: @elems.list, context: this, ->
         for v, i in @$.list
          @div ".list-item", ->
           @div ".list-item-controls-hover", ->
            @i ".fa.fa-cog", null
            @div ".list-item-controls",
             on: {click: @$.on.listClick}
             ->
              icon = @i ".fa.fa-lg.fa-arrow-up", null
              icon.listIdx = i
              icon.listAction = 'up'
              icon = @i ".fa.fa-lg.fa-arrow-down", null
              icon.listIdx = i
              icon.listAction = 'down'
              icon = @i ".fa.fa-lg.fa-trash", null
              icon.listIdx = i
              icon.listAction = 'delete'
           @$.elems.items.push @div ".list-item-content", null

        for v, i in @list
         @property.item.edit @elems.items[i], v, @itemChanged.bind self: this, idx: i

       itemChanged: (value, changed) ->
        if changed
         @self.list[@idx] = value
        @self.onChanged @self.list, false



      PROPERTIES.register 'list', List
