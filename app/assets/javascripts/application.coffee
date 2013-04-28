class Venyr
  constructor: (opts = {}) ->
    @opts = opts
    R.ready(@init)

  init: =>
    return @showAuthentication() unless R.authenticated()
    @broadcaster = new Broadcaster if @opts.type == 'broadcast'
    @listener = new Listener if @opts.type == 'listen'

  authenticate: ->
    # TODO
    R.authenticate (authenticated) =>
      alert('You are authenticated') if authenticated

  showAuthentication: ->
    window.location = "/"

class Broadcaster
  constructor: ->
    @initSocket()

  initEvents: ->
    R.player.on 'change:playState', @onPlayStateChange
    R.player.on 'change:playingTrack', @onPlayingTrackChange

    @onPlayingTrackChange(R.player.playingTrack())
    @onPlayStateChange(R.player.playState())

  socketPath: ->
    window.location.pathname + '/' + R.currentUser.get('vanityName') + '/live?token=' + R.accessToken()

  initSocket: ->
    @ws = new WebSocket('ws://' + window.location.host + @socketPath())
    @ws.onopen = => @initEvents()
    @ws.onclose = -> console.log('The WebSocket has closed')

  onPlayingTrackChange: (track) =>
    @ws.send JSON.stringify({ event: 'playingTrackChange', data: { key: track.get('key') } })

  onPlayStateChange: (state) =>
    @ws.send JSON.stringify({ event: 'playStateChange', data: { state: state } })

class Listener
  constructor: ->
    @initSocket()

  socketPath: ->
    window.location.pathname + '/live'

  initSocket: ->
    @ws = new WebSocket('ws://' + window.location.host + @socketPath())
    @ws.onclose = -> console.log('The WebSocket has closed')
    @ws.onmessage = (message) => @handleMessage(message)

  handleMessage: (message) ->
    message = JSON.parse(message.data)

    switch message.event
      when "playStateChange" then @handlePlayStateChange(message.data.state)
      when "playingTrackChange" then @handlePlayingTrackChange(message.data.key)
      else console.log("Invalid event: #{message}")

  handlePlayStateChange: (state) ->
    console.log "Here, I would change the player state to #{state}"
    # TODO
    # if state == 0 then R.player.pause() else R.player.play()

  handlePlayingTrackChange: (key) ->
    console.log "Here, I would trigger R.player.play(source: #{key})"
    # TODO
    # R.player.play(source: key)

window.Venyr = new Venyr(type: window.VenyrType)
