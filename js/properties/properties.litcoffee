Copyright 2014 - 2015
Author: Varuna Jayasiri http://blog.varunajayasiri.com

#PROPERTIES

    Mod.require 'Models.Util',
     (Util) ->


class Properties

      class Properties
       constructor: ->
        @properties = {}

       register: (name, property) ->
        @properties[name] = property

       isValidSchema: (schema) ->
        for type, property of @properties
         if property.isValidSchema schema
          return true

        return false

       create: (schema) ->
        for type, property of @properties
         if property.isValidSchema schema
          return new property schema

        throw new Error "Unknown schema"



      PROPERTIES = new Properties
      Mod.set 'Models.Properties', PROPERTIES
