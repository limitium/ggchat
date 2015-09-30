phantom = require 'phantom'
fireEvent = (node, eventName) ->
  `var event`
  # Make sure we use the ownerDocument from the provided node to avoid cross-window problems
  doc = undefined
  if node.ownerDocument
    doc = node.ownerDocument
  else if node.nodeType == 9
    # the node may be the document itself, nodeType 9 = DOCUMENT_NODE
    doc = node
  else
    throw new Error('Invalid node passed to fireEvent: ' + node.id)
  if node.dispatchEvent
    # Gecko-style approach (now the standard) takes more work
    eventClass = ''
    # Different events have different event classes.
    # If this switch statement can't map an eventName to an eventClass,
    # the event firing is going to fail.
    switch eventName
    # Dispatching of 'click' appears to not work correctly in Safari. Use 'mousedown' or 'mouseup' instead.
      when 'click', 'mousedown', 'mouseup'
        eventClass = 'MouseEvents'
      when 'focus', 'change', 'blur', 'select'
        eventClass = 'HTMLEvents'
      else
        throw 'fireEvent: Couldn\'t find an event class for event \'' + eventName + '\'.'
        break
    event = doc.createEvent(eventClass)
    bubbles = if eventName == 'change' then false else true
    event.initEvent eventName, bubbles, true
    # All events created as bubbling and cancelable.
    event.synthetic = true
    # allow detection of synthetic events
    # The second parameter says go ahead with the default action
    node.dispatchEvent event, true
  else if node.fireEvent
    # IE-old school style
    event = doc.createEventObject()
    event.synthetic = true
    # allow detection of synthetic events
    node.fireEvent 'on' + eventName, event
  return

steps = [
  f: ->
    $('[rel=reg-popup]').trigger('mousedown')
  t: 10000
,
  f: ->
    $('#form-reg [name=email]').val('qweasdzxc1231@mailinator.com')
    $('#form-reg [name=password]').val('wwwwwwwwwwwww')
  t: 100
,
  em: ['click',200,400]
  t: 10000
#,
#  em: ['mousedown',247,322]
#  t: 3000
#  f: ->
#    iframe = $('.g-recaptcha iframe').get(0)
#    doc = iframe.contentWindow.document || iframe.contentDocument
#    fireEvent(doc.querySelectorAll('label'),'mouseover')
#    fireEvent(doc.querySelectorAll('label'),'mousedown')
#    fireEvent(doc.querySelectorAll('label'),'click')
#    $('#form-reg [name=email]').val(doc.querySelectorAll('label'))
#    doc.getElementsByTagName('body')[0].remove()
#    for n in doc.querySelectorAll('div')
#      n.remove()
#    doc.getElementById('recaptcha-anchor-label').remove()
#    doc.title
#  t: 10000
]

next_step = (page, done)->
  if steps.length
    step = steps.shift()
    console.log "steps left: #{steps.length + 1}"
    if step.em?
      console.log 1
      page.sendEvent.apply page, step.em
#      page.sendEvent 'click', 48,18
    else
      console.log 2
      page.evaluate step.f
    setTimeout ->
      next_step(page, done)
    , step.t
  else
    done()


phantom.create "--web-security=no", "--ignore-ssl-errors=yes", {}, (ph) ->
  ph.createPage (page) ->
    page.onConsoleMessage = (msg) ->
      console.log(msg)
    page.onLoadStarted = ->
      console.log("load started")
    page.onLoadFinished = ->
      console.log("load done")

    page.open "http://goodgame.ru", (status) ->
      console.log "opened? ", status
      next_step(page, ->
        page.render('ggsc.png');
        console.log 'done'
        ph.exit()
      )