Copyright 2014 - 2015
Author: Varuna Jayasiri http://blog.varunajayasiri.com

#PROPERTIES

    Mod.require 'Models.Util',
     (Util) ->


class Properties

      class Models
       constructor: ->
        @models = {}

       register: (name, model) ->
        @models[name] = model

       get: (name) ->
        if not @models[name]?
         throw new Error "Unknown model: #{name}"
        return @models[name]



      MODELS = new Models
      Mod.set 'Models.Models', MODELS
