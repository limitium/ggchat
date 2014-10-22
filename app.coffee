WebSocketClient = require("websocket").client
client = new WebSocketClient()

client.on "connectFailed", (error) ->
  console.log "Connect Error: " + error.toString()

userData =
  uid: 0
  token: ''

client.on "connect", (connection) ->
  console.log "WebSocket client connected"
  connection.on "error", (error) ->
    console.log "Connection Error: " + error.toString()

  connection.on "close", ->
    console.log arguments
    console.log "echo-protocol Connection Closed"

  auth = ->
    console.log 'auth'
    toSend =
      type: 'auth',
      data:
        user_id: userData.uid,
        token: userData.token
    connection.sendUTF JSON.stringify toSend

  enter = ->
    console.log 'enter'
    toSend =
      type: 'join',
      data:
        channel_id: 7290,
        hidden: false
        mobile: 0
    connection.sendUTF JSON.stringify toSend
  send =->
    console.log 'send'
    toSend =
      type: 'send_message',
      data:
        channel_id: 7290,
        text: 'aaaaaaa'
        hideIcon: false
        mobile: 0
    console.log toSend
    connection.sendUTF JSON.stringify toSend
  connection.on "message", (message) ->
    if message.type is "utf8"
      msg = JSON.parse message.utf8Data
      switch msg.type
        when 'welcome' then auth()
        when 'success_auth' then enter()
        when 'success_join' then send()
        when 'message' then console.log msg.data
        else
          console.log msg





request = require('request')
request = request.defaults({jar: true})

j = request.jar();
request.get(
    url:'http://goodgame.ru'
    jar: j
  , (err, response) ->

  j.setCookie(request.cookie('fixed=1; auto_login_name=limitium'), 'goodgame.ru');
  request.post(
    url: 'http://goodgame.ru/ajax/login/',
    form:
      login: 'limitan',
      password: 'qweqwe123',
      remember: 1
    headers:
      'X-Requested-With': 'XMLHttpRequest'
    jar: j
  , (err, response)->

    userData[cookie.key] = cookie.value for cookie in j.getCookies('http://goodgame.ru') when cookie.key in ['uid', 'token']
    console.log userData
    request.get(
      url:'http://goodgame.ru/chat/guitman'
      jar:j
    ,(err,response,body)->

      m = body.match(/token: '(.*?)',/)
      userData.token = m[1]
      m = body.match(/userId: '(.*?)',/)
      userData.uid = m[1]
      client.connect "ws://chat.goodgame.ru:8081/chat/websocket"
    )
  )
)
