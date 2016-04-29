#Copyright 2014 - 2015
#Author: Varuna Jayasiri http://blog.varunajayasiri.com

Mod.require ->
 Util =
  extend: ->
   return null if arguments.length is 0
   obj = arguments[0]
   if (typeof obj) isnt 'object'
    throw new Error "Cannot extend #{typeof obj}"

   for i in [1...arguments.length]
    o = arguments[i]
    if (typeof o) isnt 'object'
     throw new Error "Cannot extend #{typeof o}"
    for k, v of o
     obj[k] = v

   return obj



 Mod.set 'Models.Util', Util
