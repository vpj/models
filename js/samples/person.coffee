Mod.require 'Models.Models',
 'Models.Model.Base'
 (MODELS, Base) ->

  class Person extends Base
   @extend()

   type: 'Person'

   @property 'name', {}

   @property 'age',
    valid: (str) ->
     return "#{parseInt str}" is "#{str}"
    value: (str) -> parseInt str
    default: -> 0

   @property 'family',
    list: {}

   @property 'friends',
    list:
     oneof: ['Person']
     defaultValues: -> {name: 'Your name', age: 24}

   template: (self) ->
    values = self._values
    @p "Name: #{values.name}"
    @p "Age: #{values.age}"
    if values.family.length > 0
     @div ->
      @h4 "Family"
      @ul ->
       for f in values.family
        @li "#{f}"

    if values.friends.length > 0
     @div ->
      @h4 "Friends"
      for f in values.friends
       @div ->
        f.weya this

   @check()

  MODELS.register 'Person', Person
