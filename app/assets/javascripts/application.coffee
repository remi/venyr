class RdioMirror
  constructor: (opts = {}) ->
    @opts = opts
    R.ready(@init)

  init: =>
    return @showAuthentication() unless R.authenticated()
    @broadcaster = new RdioBroadcaster if @opts.type == 'broadcast'
    @listener = new RdioListener if @opts.type == 'listen'

  authenticate: ->
    # TODO
    R.authenticate (authenticated) =>
      alert('You are authenticated') if authenticated

  showAuthentication: ->
    window.location = "/"

class RdioBroadcaster
  constructor: ->
    @initSocket()

  initEvents: ->
    R.player.on 'change:playState', @onPlayStateChange
    R.player.on 'change:playingTrack', @onPlayingTrackChange

  initSocket: ->
    @ws = new WebSocket('ws://' + window.location.host + window.location.pathname + '/' + R.currentUser.get('vanityName') + '/live?token=' + R.accessToken());
    @ws.onopen = => @initEvents()
    @ws.onclose = -> console.log('The WebSocket has closed')

  onPlayingTrackChange: (track) =>
    @ws.send JSON.stringify({ event: 'playingTrackChange', data: { key: track.get('key') } })

  onPlayStateChange: (isPlaying) =>
    @ws.send JSON.stringify({ event: 'playStateChange', data: { isPlaying: isPlaying  } })

class RdioListener
  constructor: ->
    @initSocket()

  initSocket: ->
    @ws = new WebSocket('ws://' + window.location.host + window.location.pathname + '/live');

    @ws.onopen = => @initEvents()
    @ws.onclose = -> console.log('The WebSocket has closed')
    @ws.onmessage = (message) => @handleMessage(message)

  handleMessage: (message) ->
    message = JSON.parse(message.data)

    switch message.event
      when "playStateChange" then @handlePlayStateChange(message.data.isPlaying)
      when "playingTrackChange" then @handlePlayingTrackChange(message.data.key)
      else console.log("Invalid event: #{message}")

  handlePlayStateChange: (state) ->
    if state == 0 then R.player.pause() else R.player.play()

  handlePlayingTrackChange: (key) ->
    console.log "Here, I would trigger R.player.play(source: #{key})"
    # TODO
    # R.player.play(source: key)

window.RdioMirror = new RdioMirror(type: window.RdioMirrorType)
