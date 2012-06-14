Snips = new Meteor.Collection('snips')

Meteor.methods
  remote: ()->
    return new Date + ' from server'


if Meteor.is_client
  window.Snips = Snips

  getCurrentSnip =->
    snip_id = Session.get('current-snip-id')
    snip = Snips.findOne({_id:snip_id})

  Template.snip.snipets = ->
    Snips.find({},{sort:{title:1}})

  Template.snip.events =
    "click #add": (evt)->
      snip = Snips.insert(title:'New')
      Session.set('current-snip-id',snip._id)
    "click a.item": (evt)->
      el = evt.target
      snip_id = $(el).attr('href').replace(/^#/,'')
      Session.set('current-snip-id',snip_id)
      $('#nav .active').removeClass('active')
      $(el).closest('li').addClass('active')

  Template.editor.title =->
    snip = getCurrentSnip()
    snip && snip.title

  Template.editor.script =->
    snip = getCurrentSnip()
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
    snip = getCurrentSnip()
    if title && snip
      Snips.update({_id:snip._id},{$set: {title: title, script: script}})

  Template.editor.events =
    "keypress #code":(evt)->
      evalCode() if evt.which == 10 and evt.ctrlKey
      Meteor.setTimeout(saveSnip,0)
    "keypress #title": -> Meteor.setTimeout(saveSnip,0)
    "change #title": -> saveSnip
    "change #code": -> saveSnip
    "click #eval": evalCode

  Meteor.startup ->
    #Session.set('current-snip') = Snips.findOne()


if Meteor.is_server
  Meteor.startup ->
