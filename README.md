

# InterTalk


<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [InterTalk](#intertalk)
  - [API](#api)
  - [Is Done](#is-done)
  - [To Do](#to-do)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# InterTalk

## API

* `emit_on_event: ( element, event_name, note_name ) ->` (only in browser): given a DOM `element`, a DOM
  `event_name` and a `note` name, when a matching event is triggered on the element, emit a note with `$key:
  note_name` and `$value: event`
  * when `emit_on_event` is called with the arguments `( event_name, note_name )` then the event listener
    will be attached to `document`: `IT.emit_on_event div_1, 'click', 'bar'` will be triggered when clicking
    on the `div_1` element only, but `IT.emit_on_event 'click', 'bar'` will be triggered by any click
    anywhere within the browser document window.

## Is Done

* **[+]** allow to use `Map` (or other suitable replacement) instead of `WeakMap` where `Symbol`s are not
  allowed as keys (true for Firefox at least up to v124.0.1)
* **[+]** fix some names:
  * class *`Async_events`* (-> `Intertalk`?)
  * class *`AE_Event`* (-> `Note`)
  * instance *`ae_event`* (-> `note`?)
  * class *`AE_Event_results`* (-> `Results`)
  * datom key *`ae_event-results`* (`$results`)
* **[+]** export singular instance of `Intertalk`, provide other names as properties (?)

## To Do

* **[–]** event namespacing
