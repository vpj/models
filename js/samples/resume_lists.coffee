Mod.require 'Models.Models',
 'Models.Model.Base'
 (MODELS, Base) ->

  class Resume extends Base
   @extend()

   type: 'Resume'

   @property 'name', {}
   @property 'mobile', {}
   @property 'website', {}
   # @property 'address

   @property 'experience',
    list:
     oneof: ['Experience']
     defaultValues: -> {name: 'Your name', age: 24}

   @property 'education',
    list:
     oneof: ['Education']
     defaultValues: -> {name: 'Your name', age: 24}

   template: (self) ->
    values = self._values
    @p "Name: #{values.name}"
    @p "Mobile: #{values.mobile}"
    @p "Website: #{values.website}"
    if values.experience.length > 0
     @div ->
      @h4 "Experience"
      for f in values.experience
       @div ->
        f.weya this

    if values.education.length > 0
     @div ->
      @h4 "Education"
      for f in values.education
       @div ->
        f.weya this


   @check()

  MODELS.register 'Resume', Resume


  class Experience extends Base
   @extend()

   type: 'Experience'

   @property 'from', {}
   @property 'to', {}
   @property 'company', {}
   @property 'role', {}

   template: (self) ->
    values = self._values

    @p "From #{values.from} To #{values.to}"
    @p ->
     @em "#{values.role}"
    @p ->
     @strong "#{values.company}"

   @check()

  MODELS.register 'Experience', Experience


  class Education extends Base
   @extend()

   type: 'Education'

   @property 'from', {}
   @property 'to', {}
   @property 'institute', {}
   @property 'course', {}

   template: (self) ->
    values = self._values

    @p "From #{values.from} To #{values.to}"
    @p ->
     @em "#{values.course}"
    @p ->
     @strong "#{values.institute}"

   @check()

  MODELS.register 'Education', Education

