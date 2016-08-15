Copyright 2014 - 2015
Author: Varuna Jayasiri http://blog.varunajayasiri.com

#List

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

       constructor: (schema, name) ->
        @_name = name
        @schema = {}

        for k, v of @_defaults
         if schema[k]?
          @schema[k] = schema[k]
         else
          @schema[k] = v

       error: (error) ->
        return {
         score: 0
         value: @schema.default.call this
         errors: [error]
        }

       parse: (data) ->
        if not data?
         if @schema.required
          return (@error 'required')
         else
          return {score: 1, value: (@schema.default.call this), errors: []}

        return true

       @default 'required', false
       @default 'default', -> null
       @default 'isDefault', (value) ->
        return true if not value?
        return false

       isDefault: (value) ->
        @schema.isDefault.call this, value



      Mod.set 'Models.Property.Base', Base
