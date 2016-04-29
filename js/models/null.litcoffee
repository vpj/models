    Mod.require 'Models.Models',
     'Models.Model.Base'
     (MODELS, Base) ->

      class Null extends Base
       @extend()

       type: 'Null'

       template: (self) ->

       @check()

      MODELS.register 'Null', Null
