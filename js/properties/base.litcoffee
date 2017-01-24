Copyright 2014 - 2015
Author: Varuna Jayasiri http://blog.varunajayasiri.com

#Properties Base

    Mod.require 'Models.Util',
     (UTIL) ->


Class

      class Base
       propertyType: 'base'
       _defaults: {}

       @extend: ->
        @::_defaults = UTIL.extend {}, @::_defaults

       @default: (name, value) ->
        @::_defaults[name] = value

       @isValidSchema: (schema) ->
        for k of schema
         if not @::_defaults[k]?
          return false

        return true

       @default 'required', false
       @default 'default', -> null
       @default 'isDefault', (value) ->
        return true if not value?
        return false


       constructor: (schema, name) ->
        @_name = name
        @schema = {}

        for k, v of @_defaults
         if schema[k]?
          @schema[k] = schema[k]
         else
          @schema[k] = v

Abstract methods

       toJSON: (value, stack) ->
        throw new Error "#{@propertyType}: toJSON not implementaed"

       toJSONFULL: (value, stack) ->
        throw new Error "#{@propertyType}: toJSONFULL not implementaed"

       edit: (elem, value, onChanged, stack) ->
        throw new Error "#{@propertyType}: edit not implementaed"

Error helper

       error: (error) ->
        return {
         score: 0
         value: @schema.default.call this
         errors: [error]
        }

       parse: (data, stack) ->
        if not data?
         if @schema.required
          return (@error 'required')
         else
          return {score: 1, value: (@schema.default.call this), errors: []}

        return true

       isDefault: (value, stack) ->
        @schema.isDefault.call this, value, stack




      class EditBase extends WeyaBase
       @extend()

       @initialize (property, elem, value, changed, stack) ->
        @property = property
        @elems =
         parent: elem
        @value = value
        @onChanged = onChanged
        @stack = stack
        @render()

       render: -> throw new Error "Property render unimplemented"
       validate: -> throw new Error "Property validate unimplemented"



      Mod.set 'Models.Property.Base', Base
      Mod.set 'Models.Property.EditBase', EditBase
