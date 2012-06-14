Snips = new Meteor.Collection('snips')


if Meteor.is_client
  window.Snips = Snips

  Template.snip.snipets = ->
    Snips.find({},{sort:{title:1}})

  Template.snip.events =
    "click #add": (evt)->
      snip = Snips.insert(title:'New')
      Session.set('current-snip',snip)
    "click a.item": (evt)->
      el = evt.target
      id = $(el).attr('href').replace(/^#/,'')
      snip = Snips.findOne(_id:id)
      Session.set('current-snip',snip)

  Template.editor.title =->
    snip = Session.get('current-snip')
    snip && snip.title

  Template.editor.script =->
    snip = Session.get('current-snip')
    snip && snip.script

  evalCode =->
    script = $('#code').val()
    console.log(script)
    try
      console.log eval(script)
    catch e
      console.error e.message

  saveSnip =->
    title = $('#title').val()
    script = $('#code').val()
    snip = Session.get('current-snip')
    if title && snip
      Snips.update({_id:snip._id},{$set: {title: title, script: script}})

  Template.editor.events =
    "keypress #code":(evt)->
      evalCode() if evt.which == 10 and evt.ctrlKey
      saveSnip()
    "keypress #title": saveSnip
    "click #eval": evalCode
    "click #save":-> saveSnip

  Meteor.startup ->
    #Session.set('current-snip') = Snips.findOne()


if Meteor.is_server
  Meteor.startup ->
