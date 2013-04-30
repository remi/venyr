class Venyr.Broadcaster
  constructor: ->
    @initTemplate()
    @initSocket(reconnect: false)

  initTemplate: ->
    $('.rdio-user').text(R.currentUser.get('vanityName'))
    $('.broadcast-url').forEach (e) -> e.setAttribute('href', $(e).text())
    @hud = new Venyr.Hud(e: $('.hud'))
    $('.loading').hide()
    $('.authenticated-content').show()

  initEvents: ->
    R.player.on 'change:playState', @onPlayStateChange
    R.player.on 'change:playingTrack', @onPlayingTrackChange
    @initPing()
    $(window).on 'beforeunload', -> 'This message is just there so you won’t accidentally close/reload the Venyr tab while you’re broadcasting. But leave if you must!'

  initState: ->
    @onPlayingTrackChange(R.player.playingTrack())
    if R.player.playingTrack() then @onPlayStateChange(R.player.playState()) else @hud.clear()

  socketPath: ->
    "/live/broadcast/#{R.currentUser.get('vanityName')}?token=#{R.accessToken()}"

  initSocket: (opts) ->
    @ws = new WebSocket('ws://' + window.location.host + @socketPath())
    @ws.onopen = =>
      @initEvents() unless opts.reconnect
      @initState()
    @ws.onclose = =>
      return false if window.Venyr.App.fatalError == true
      console.log('The WebSocket has closed, attempting to reconnect in 10 seconds…')
      @reconnectSocket(10000)
    @ws.onmessage = (message) => @handleMessage(message)

  reconnectSocket: (delay) ->
    setTimeout(=>
      console.log('Trying to reconnect…')
      @initSocket(reconnect: true)
    , delay)

  initPing: () ->
    setInterval(=>
      @ws.send(JSON.stringify({ event: 'ping', data: {} }))
    , Venyr.App.opts.pingInterval)

  handleMessage: (message) ->
    message = JSON.parse(message.data)

    switch message.event
      when "fatalError" then @ws.close(); window.Venyr.App.handleFatalError(message.data)
      when "listenersCountChange" then @handleListenersCountChange(message.data.count)
      when "pong" then true
      else console.log("Invalid event: #{message}")

  handleListenersCountChange: (count) ->
    $('.listeners-count').text("#{count} #{if count == 1 then 'user' else 'users' }")

  onPlayingTrackChange: (track) =>
    if track
      @hud.updateTrack(track.attributes)
      @ws.send JSON.stringify({ event: 'playingTrackChange', data: { track: track.attributes } })
    else
      @hud.clear()
      @ws.send JSON.stringify({ event: 'playingTrackChange', data: { track: null } })

  onPlayStateChange: (state) =>
    @hud.updateState(state)
    @ws.send JSON.stringify({ event: 'playStateChange', data: { state: state } })
