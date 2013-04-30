class Venyr.Listener
  constructor: ->
    @initTemplate()
    @initSocket()
    @initEvents()

  initEvents: ->
    $(window).on 'beforeunload', -> 'This message is just there so you won’t accidentally close/reload the Venyr tab while you’re listening. But leave if you must!'

  initTemplate: ->
    @hud = new Venyr.Hud(e: $('.hud'))
    $('.loading').hide()
    $('.authenticated-content').show()

  socketPath: ->
    "/live/listen/#{$('#content').data('user')}"

  initSocket: ->
    @ws = new WebSocket('ws://' + window.location.host + @socketPath())
    @ws.onclose = -> console.log('The WebSocket has closed')
    @ws.onmessage = (message) => @handleMessage(message)
    setInterval(=>
      @ws.send(JSON.stringify({ event: 'ping', data: {} }))
    , Venyr.App.opts.pingInterval)

  handleMessage: (message) ->
    message = JSON.parse(message.data)

    switch message.event
      when "fatalError" then @ws.close(); R.player.pause(); window.Venyr.App.handleFatalError(message.data)
      when "playStateChange" then @handlePlayStateChange(message.data.state)
      when "playingTrackChange" then @handlePlayingTrackChange(message.data.track)
      when "pong" then true
      else console.log("Invalid event: #{message}")

  handlePlayStateChange: (state) ->
    @hud.updateState(state)
    if state == 0 then R.player.pause() else R.player.play()

  handlePlayingTrackChange: (track) ->
    if track
      @hud.updateTrack(track)
      R.player.play(source: track.key)
    else
      @hud.clear()
