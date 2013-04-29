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
    window.location.pathname + '/live'

  initSocket: ->
    @ws = new WebSocket('ws://' + window.location.host + @socketPath())
    @ws.onclose = -> console.log('The WebSocket has closed')
    @ws.onmessage = (message) => @handleMessage(message)

  handleMessage: (message) ->
    message = JSON.parse(message.data)

    switch message.event
      when "fatalError" then @ws.close(); R.player.pause(); window.Venyr.App.handleFatalError(message.data)
      when "playStateChange" then @handlePlayStateChange(message.data.state)
      when "playingTrackChange" then @handlePlayingTrackChange(message.data.track)
      else console.log("Invalid event: #{message}")

  handlePlayStateChange: (state) ->
    console.log "Here, I would change the player state to #{state}"
    @hud.updateState(state)
    # TODO
    # if state == 0 then R.player.pause() else R.player.play()

  handlePlayingTrackChange: (track) ->
    if track
      console.log "Here, I would trigger R.player.play(source: #{track.key})"
      @hud.updateTrack(track)
      # TODO
      # R.player.play(source: key) # How does play work actually?
    else
      @hud.clear()
