phantom = require 'phantom'

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
      page.evaluate ->
        $('[rel=reg-popup]').trigger('mousedown')
        setTimeout(->
          $('#form-reg [name=email]').val('aaaa@aaa.ru')
          $('#form-reg [name=password]').val('wwwwwwwwwwwww')
        ,500)
      ,->


      setTimeout(->
        console.log 1
        page.render('ggsc.png');
        console.log 2
        ph.exit()
      ,2000)
#      page.evaluate (-> document.title), (result) ->
#        console.log 'Page title is ' + result
#        ph.exit()