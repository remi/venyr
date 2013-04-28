class RdioMirror
  constructor: (opts = {}) ->
    @opts = opts
    R.ready(@init)

  init: =>
    return @showAuthentication() unless R.authenticated()
    window.RdioBroadcaster = new RdioBroadcaster if @opts.type == 'broadcast'
    window.RdioListener = new RdioListener if @opts.type == 'listen'

  authenticate: ->
   R.authenticate (authenticated) =>
     alert('You are authenticated') if authenticated

class RdioBroadcaster
  constructor: ->
    @initEvents()
    @initSocket()

  initEvents: ->
    R.player.on 'change:playState', this.onPlayStateChange
    R.player.on 'change:playingTrack', this.onPlayingTrackChange

  initSocket: ->

  onPlayingTrackChange: (track) ->
    console.log(track)

  onPlayStateChange: (isPlaying) ->
    console.log(isPlaying)

class RdioListener
  constructor: ->
    @initEvents()
    @initSocket()

  initEvents: ->

  initSocket: ->

window.RdioMirror = new RdioMirror(type: window.RdioMirrorType)
