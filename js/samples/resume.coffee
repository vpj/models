Mod.require 'Models.Models',
 'Models.Model.Base'
 (MODELS, Base) ->
  ROLES =
   Vigilante: true
   Programmer: true
   Designer: true
   Manager: true
   Other: true

  class Resume extends Base
   @extend()

   type: 'Resume'

   @property 'name', {}
   @property 'role',
    valid: (str) -> ROLES[str]
    search: (str) ->
     str = str.toLowerCase()
     (id for id of ROLES when (id.toLowerCase().indexOf str) isnt -1)

   @property 'website', {}

   @property 'mobile', {}
   @property 'email', {}
   @property 'address',
    oneof: ['Null', 'Address']

   @property 'statement',
    list: {}

   @property 'timeline',
    list:
     oneof: ['Experience', 'Education', 'Recognition']
     defaultValues: -> {from: '2010', to: '2020'}

   @property 'skills',
    list:
     oneof: ['Skill']

   _education: ->
    res = (e for e in @_values.timeline when e.type is 'Education')
    res.sort (x, y) -> y._values.from - x._values.from

   _experience: ->
    res = (e for e in @_values.timeline when e.type is 'Experience')
    res.sort (x, y) -> y._values.from - x._values.from

   _recognitions: ->
    res = (e for e in @_values.timeline when e.type is 'Recognition')
    res.sort (x, y) -> y._values.year - x._values.year

   template: (self) ->
    values = self._values
    education = self._education()
    experience = self._experience()
    recognitions = self._recognitions()

    @div ".resume", ->
     @div ".row", ->
      @div ".six.columns", ->
       @div ".name", "#{values.name}"
       @div ".role", "#{values.role}"
       if values.website isnt ''
        @div ".website", ->
         @a href: "#{values.website}", "#{values.website}"

      if values.address.type isnt 'Null'
       @div ".three.columns.address", ->
        values.address.weya this

      @div ".three.columns.contact", ->
       if values.mobile isnt ''
        @div "#{values.mobile}"
       if values.email isnt ''
        @div ".email", "#{values.email}"

     @div ".row.content", ->
      @div ".six.columns", ->
       if values.statement.length > 0
        @div ".statement", ->
         @h2 "Personal Statement"
         for p in values.statement
          @p p

       if education.length > 0
        @div ".education", ->
         @h2 "Education"
         for e in education
          e.weya this

       if values.skills.length > 0
        @div ".skills", ->
         @h2 "Skills"
         for e in values.skills
          e.weya this


      @div ".six.columns", ->
       if experience.length > 0
        @div ".experience", ->
         @h2 "Experience"
         for e in experience
          e.weya this

       if recognitions.length > 0
        @div ".recognition", ->
         @h2 "Recognitions"
         for e in recognitions
          e.weya this

   @check()

  MODELS.register 'Resume', Resume

  class Address extends Base
   @extend()

   type: 'Address'

   @property 'street1', {}
   @property 'street2', {}
   @property 'city', {}
   @property 'country', {}

   template: (self) ->
    values = self._values

    if values.street1 isnt ''
     @div "#{values.street1}"
    if values.street2 isnt ''
     @div "#{values.street2}"
    if values.city isnt ''
     @div "#{values.city}"
    if values.country isnt ''
     @div "#{values.country}"

   @check()

  MODELS.register 'Address', Address



  class Experience extends Base
   @extend()

   type: 'Experience'

   @property 'from',
    columns: 5
    valid: (str) -> "#{parseInt str}" is "#{str}"
    value: (str) -> parseInt str
    default: -> 0
   @property 'to',
    columns: 5
    valid: (str) -> "#{parseInt str}" is "#{str}"
    value: (str) -> parseInt str
    default: -> 0
   @property 'company', {}
   @property 'role', {}

   template: (self) ->
    values = self._values

    @div ".experience", ->
     @div ".period", "From #{values.from} To #{values.to}"
     @div ".role", "#{values.role}"
     @div ".company", "#{values.company}"

   @check()

  MODELS.register 'Experience', Experience


  class Education extends Base
   @extend()

   type: 'Education'

   @property 'from',
    columns: 5
    valid: (str) -> "#{parseInt str}" is "#{str}"
    value: (str) -> parseInt str
    default: -> 0
   @property 'to',
    columns: 5
    valid: (str) -> "#{parseInt str}" is "#{str}"
    value: (str) -> parseInt str
    default: -> 0

   @property 'institute', {}
   @property 'course', {}

   template: (self) ->
    values = self._values

    @div ".education", ->
     @div ".period", "From #{values.from} To #{values.to}"
     @div ".course", "#{values.course}"
     @div ".institute", "#{values.institute}"

   @check()

  MODELS.register 'Education', Education

  class Recognition extends Base
   @extend()

   type: 'Recognition'

   @property 'year',
    columns: 5
    valid: (str) -> "#{parseInt str}" is "#{str}"
    value: (str) -> parseInt str
    default: -> 0

   @property 'recognition', {}
   @property 'detail', {}

   template: (self) ->
    values = self._values

    @div ".recognition", ->
     @div ".icon", ->
      @i ".fa.fa-4x.fa-trophy", null
     @div ->
      @div ".period", "#{values.year}"
      @div ".recognition-info", "#{values.recognition}"
      if values.detail isnt ''
       @div ".detail", "#{values.detail}"

   @check()


  MODELS.register 'Recognition', Recognition

  class Skill extends Base
   @extend()

   type: 'Skill'

   @property 'level',
    columns: 5
    valid: (str) ->
     n = parseInt str
     return false if "#{n}" isnt "#{str}"
     if 0 <= n <= 10
      return true
     else
      return false
    value: (str) -> parseInt str
    default: -> 10
   @property 'skill', {}

   template: (self) ->
    values = self._values

    @div ".skill.row", ->
     @div ".columns.six.skill-name", "#{values.skill}"
     @div ".columns.six.skill-level", ->
      for i in [0...values.level]
       @i ".fa.fa-circle.filled", null
      for i in [0...10 - values.level]
       @i ".fa.fa-circle.unfilled", null

   @check()


  MODELS.register 'Skill', Skill

