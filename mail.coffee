request = require('request')

box = 'sadasdwqdqwdasd'
fromTarget = "no-reply@goodgame.ru"

request.get(
  url: "http://mailinator.com/settttt?box=#{box}&time=" + (Date.now())
, (err, response, body)=>
  boxMeta = JSON.parse(body)
  request.get(
    url: "http://mailinator.com/grab?inbox=#{box}&address=#{boxMeta.address}&time=" + (Date.now())
  , (err, response, body)=>
    mails = JSON.parse(body)
    for mail in mails.maildir
      if mail.fromfull is fromTarget
        request.get(
          url: "http://mailinator.com/rendermail.jsp?msgid=#{mail.id}&time=" + (Date.now())
        , (err, response, body)=>
          m = body.match(/"http:\/\/goodgame\.ru\/activate\/(.*?)\/"/)
          console.log m[1]
        )
  )
)
