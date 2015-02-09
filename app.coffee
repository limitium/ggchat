WebSocketClient = require("websocket").client
request = require('request')
request = request.defaults({jar: true})


class GGClient
  client: null
  connection: null
  uid: null
  token: null
  channel_id: null
  constructor: (@uid, @token, @channel_id)->
    @client = new WebSocketClient()
    @init_listeners()

  init_listeners: ->
    @client.on "connectFailed", (error) ->
      console.log "Connect Error: " + error.toString()

    @client.on "connect", (connection) =>
      @connection = connection
      console.log "WebSocket client connected"

      connection.on "error", (error) ->
        console.log "Connection Error: " + error.toString()

      connection.on "close", ->
        console.log arguments
        console.log "echo-protocol Connection Closed"

      connection.on "message", (message) =>
        if message.type is "utf8"
          msg = JSON.parse message.utf8Data
          switch msg.type
            when 'welcome' then @auth()
            when 'success_auth' then @enter()
            when 'success_join' then @send('Hi! (._.)')
            when 'message' then console.log msg.data
            else
              console.log msg

  send_data: (data)->
    if @connection
      @connection.sendUTF JSON.stringify data
    else
      console.log 'not connected'

  connect: ->
    @client.connect "ws://chat.goodgame.ru:8081/chat/websocket"

  auth: =>
    console.log 'auth'
    @send_data
      type: 'auth',
      data:
        user_id: @uid,
        token: @token

  enter: =>
    @send_data
      type: 'join',
      data:
        channel_id: @channel_id,
        hidden: false
        mobile: 0

  send: (text)=>
    @send_data
      type: 'send_message',
      data:
        channel_id: @channel_id,
        text: text
        hideIcon: false
        mobile: 0


class GGConnector
  channel_name: null
  channel_id: null
  uid: null
  token: null
  constructor: (@channel_name)->
  get_channel_id: (cb)=>
    request.get(
      url: "http://goodgame.ru/channel/#{@channel_name}/"
      followAllRedirects: true
    , (err, response, body)=>
      m = body.match(/src="http\:\/\/goodgame\.ru\/player\?(\d+)"><\/iframe>/)
      @channel_id = m[1]
      cb(@channel_id)
    )
  get_token: (username, password, cb)=>
    j = request.jar();
    request.get(
      url: 'http://goodgame.ru'
      jar: j
    , (err, response) =>
      j.setCookie(request.cookie("fixed=1; auto_login_name=#{username}"), 'goodgame.ru');
      request.post(
        url: 'http://goodgame.ru/ajax/login/',
        form:
          login: username,
          password: password,
          remember: 1
        headers:
          'X-Requested-With': 'XMLHttpRequest'
        jar: j
      , (err, response)=>
        userData =
          uid: null
          token: null
        userData[cookie.key] = cookie.value for cookie in j.getCookies('http://goodgame.ru') when cookie.key in ['uid',
                                                                                                                 'token']

        request.get(
          url: "http://goodgame.ru/channel/#{@channel_name}"
          jar: j
        , (err, response, body)=>
          m = body.match(/token: '(.*?)',/)
          unless m
            m = body.match(/Token = '(.*?)';/)
          userData.token = m[1]
          cb(userData)
        )
      )
    )
  get_client: (username, password, cb)=>
    @get_token username, password, (userData)=>
      cb new GGClient(userData.uid, userData.token, @channel_id)



conn = new GGConnector('HawK')
conn.get_channel_id ->
  conn.get_client('limitan', 'qweqwe123', (client)->
    client.connect()
  )



