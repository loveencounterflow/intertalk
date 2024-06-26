


'use strict'


#===========================================================================================================
rpr                       = ( require 'webguy' ).trm.rpr
#-----------------------------------------------------------------------------------------------------------
resolved_promise          = Promise.resolve()
# s                         = ( name ) -> Symbol.for  name
# ps                        = ( name ) -> Symbol      name
#-----------------------------------------------------------------------------------------------------------
{ isa
  isa_optional
  validate
  validate_optional }     = require './types'
#-----------------------------------------------------------------------------------------------------------
get_WeakMap = ->
  return Map unless globalThis.WeakMap?
  try ( new WeakMap() ).set Symbol 'whatever', 123 catch error then return Map
  return globalThis.WeakMap


#===========================================================================================================
class SYMBOLIC

  #---------------------------------------------------------------------------------------------------------
  constructor: -> throw new Error "class cannot be instantiated"

  #---------------------------------------------------------------------------------------------------------
  @_text_from_key:              ( $key ) -> if isa.symbol $key then $key.description else $key
  @_listener_name_from_key:     ( $key ) -> 'on_' + @_text_from_key $key
  @_unique_key_symbol_from_key: ( $key ) -> Symbol @_text_from_key $key


#===========================================================================================================
class Datom
  ### all API methods should start with `$` like `$key` and `$value` ###

  #---------------------------------------------------------------------------------------------------------
  constructor: ( $key, $value = null ) ->
    throw new Error "expected 1 or 2 arguments, got #{arguments.length}" unless isa.unary_or_binary arguments
    #.......................................................................................................
    if arguments.length is 1
      if isa.object $key
        $value = $key
        $key   = $value.$key ? null
    #.......................................................................................................
    @$key = $key
    if isa.object $value
      values = { $value..., }
      delete values.$key ### special case: ensure we don't overwrite 'explicit' `$key` ###
      Object.assign @, values
    else
      @$value = $value if $value?
    #.......................................................................................................
    $freeze = ( validate_optional.$freeze @$freeze ) ? true
    delete @$freeze
    Object.freeze @ if $freeze
    #.......................................................................................................
    validate.IT_note_$key @$key
    return undefined


#===========================================================================================================
class Note extends Datom

#===========================================================================================================
class Results extends Datom

  #---------------------------------------------------------------------------------------------------------
  constructor: ( note, results ) ->
    throw new Error "expected 2 arguments, got #{arguments.length}" unless isa.binary arguments
    super '$results', { note, results, }
    return undefined


#===========================================================================================================
class Intertalk

  #---------------------------------------------------------------------------------------------------------
  constructor: ->
    @symbols        = { any: ( Symbol 'any' ), unhandled: ( Symbol 'unhandled' ), }
    @key_symbols    = new Map()
    @listeners      = new ( get_WeakMap() )()
    return undefined

  #---------------------------------------------------------------------------------------------------------
  on: ( $key, listener ) ->
    ### TAINT prevent from registering a listener more than once per note $key ###
    throw new Error "expected 2 arguments, got #{arguments.length}" unless isa.binary arguments
    validate.IT_note_$key $key
    validate.IT_listener  listener
    ctl = @_get_ctl $key, listener
    ( @_listeners_from_key $key ).push [ listener, ctl, ]
    return null

  #---------------------------------------------------------------------------------------------------------
  unsubscribe: ( $key, listener ) ->
    switch arity = arguments.length
      when 1 then [ $key, listener, ] = [ null, $key, ]
      when 2 then null
      else throw new Error "expected 1 or 2 arguments, got #{arity}"
    validate_optional.IT_note_$key $key
    validate.IT_listener listener
    R = 0
    for [ registered_key, key_symbol, ] from @key_symbols
      continue if $key? and ( $key isnt registered_key )
      registered_listeners_and_ctls = ( @listeners.get key_symbol ) ? []
      for idx in [ registered_listeners_and_ctls.length - 1 .. 0 ] by -1
        [ registered_listener, ctl, ] = registered_listeners_and_ctls[ idx ]
        continue unless registered_listener is listener
        R++
        registered_listeners_and_ctls.splice idx, 1
    return R

  #---------------------------------------------------------------------------------------------------------
  on_any:       ( listener ) -> @on @symbols.any,       listener
  on_unhandled: ( listener ) -> @on @symbols.unhandled, listener

  #---------------------------------------------------------------------------------------------------------
  _get_ctl : ( $key, listener ) -> R =
    unsubscribe_this: => @unsubscribe     $key, listener
    unsubscribe_all:  => @unsubscribe           listener

  #---------------------------------------------------------------------------------------------------------
  _listeners_from_key: ( $key ) ->
    ### TAINT is this necessary and does it what it intends to do? ###
    ### use Symbol, WeakMap to allow for garbage collection when `Intertalk` instance gets out of scope: ###
    unless ( key_symbol = @key_symbols.get $key )?
      @key_symbols.set $key, ( key_symbol = SYMBOLIC._unique_key_symbol_from_key $key )
    unless ( R = @listeners.get key_symbol )?
      @listeners.set key_symbol, ( R = [] )
    return R

  #---------------------------------------------------------------------------------------------------------
  emit: ( P... ) ->
    note                = new Note P...
    { $key }            = note
    key_listeners       = @_listeners_from_key  note.$key
    any_listeners       = @_listeners_from_key  @symbols.any
    fallback_listeners  = if key_listeners.length is 0 then @_listeners_from_key @symbols.unhandled else []
    results             = []
    await resolved_promise ### as per https://github.com/sindresorhus/emittery/blob/main/index.js#L363 ###
    results.push ( await Promise.all ( ( -> lstnr note, ctl )() for [ lstnr, ctl, ] from any_listeners      ) )...
    results.push ( await Promise.all ( ( -> lstnr note, ctl )() for [ lstnr, ctl, ] from fallback_listeners ) )...
    results.push ( await Promise.all ( ( -> lstnr note, ctl )() for [ lstnr, ctl, ] from key_listeners      ) )...
    return new Results note, results

  #---------------------------------------------------------------------------------------------------------
  emit_on_event: ( element, event_name, note_name ) ->
    switch arity = arguments.length
      # when 1
      when 2 then [ element, event_name, note_name, ] = [ document, element , event_name, ]
      when 3 then null
      else validate.binary_or_trinary arguments
    handler = ( event ) => @emit note_name, event
    return element.addEventListener event_name, handler, false


#===========================================================================================================
_extras         = { Datom, isa, validate, isa_optional, validate_optional, }
module.exports  = { Intertalk, Note, Results, _extras, version: ( require '../package.json' ).version, }
