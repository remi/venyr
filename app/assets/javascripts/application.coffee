class Venyr
  constructor: (opts = {}) ->
    @opts = opts
    R.ready(@init)

  init: =>
    return @goHome() if @opts.type and !R.authenticated()
    @broadcaster = new Broadcaster if @opts.type == 'broadcast'
    @listener = new Listener if @opts.type == 'listen'
    @listener = new Home if !@opts.type

  authenticate: ->
    # TODO
    R.authenticate (authenticated) =>
      alert('You are authenticated') if authenticated

  goHome: ->
    window.location = "/"

class Home
  constructor: ->
    @initTemplate()
    @initEvents()

  initTemplate: ->
    if R.authenticated()
      $('.loading').hide()
      $('.authenticated-content').show()
    else
      $('.loading').hide()
      $('.unauthenticated-content').show()

  initEvents: ->
    $('form').bind 'submit', (e) ->
      e.target.setAttribute('action', e.target.getAttribute('action').replace(/%user/, $('#listen-user').val()))

class Hud
  constructor: (opts = {}) ->
    @opts = opts
    @$e = $(@opts.e)
    @trackName = @$e.find('.rdio-track-title')
    @trackArtist = @$e.find('.rdio-track-artist')
    @trackAlbum = @$e.find('.rdio-track-album')
    @trackIcon = @$e.find('.rdio-track-icon')
    @trackURL = @$e.find('.rdio-track-url')

  updateTrack: (track) ->
    if track
      @trackName.text(track.name)
      @trackArtist.text(track.artist)
      @trackAlbum.text(track.album)
      @trackIcon.attr('src', track.icon)
      @trackURL.attr('href', "http://www.rdio.com#{track.url}")

  updateState: (state) ->
    @$e.toggleClass('paused', state == 0)

class Broadcaster
  constructor: ->
    @initTemplate()
    @initSocket()

  initTemplate: ->
    $('.rdio-user').text(R.currentUser.get('vanityName'))
    $('.broadcast-url').forEach (e) -> e.setAttribute('href', $(e).text())
    @hud = new Hud(e: $('.hud'))
    $('.loading').hide()
    $('.authenticated-content').show()

  initEvents: ->
    R.player.on 'change:playState', @onPlayStateChange
    R.player.on 'change:playingTrack', @onPlayingTrackChange

    @onPlayingTrackChange(R.player.playingTrack())
    @onPlayStateChange(R.player.playState())
    $(window).on 'beforeunload', -> 'This message is just there so you won’t accidentally close/reload the Venyr tab while you’re broadcasting. But leave if you must!'

  socketPath: ->
    window.location.pathname + '/' + R.currentUser.get('vanityName') + '/live?token=' + R.accessToken()

  initSocket: ->
    @ws = new WebSocket('ws://' + window.location.host + @socketPath())
    @ws.onopen = => @initEvents()
    @ws.onclose = -> console.log('The WebSocket has closed')
    @ws.onmessage = (message) => @handleMessage(message)

  handleMessage: (message) ->
    message = JSON.parse(message.data)

    switch message.event
      when "listenersCountChange" then @handleListenersCountChange(message.data.count)
      else console.log("Invalid event: #{message}")

  handleListenersCountChange: (count) ->
    $('.listeners-count').text(count)

  onPlayingTrackChange: (track) =>
    @hud.updateTrack(track.attributes)
    @ws.send JSON.stringify({ event: 'playingTrackChange', data: { track: track.attributes } })

  onPlayStateChange: (state) =>
    @hud.updateState(state)
    @ws.send JSON.stringify({ event: 'playStateChange', data: { state: state } })

class Listener
  constructor: ->
    @initTemplate()
    @initSocket()
    @initEvents()

  initEvents: ->
    $(window).on 'beforeunload', -> 'This message is just there so you won’t accidentally close/reload the Venyr tab while you’re listening. But leave if you must!'

  initTemplate: ->
    vanityName = R.currentUser.get('vanityName')
    $('.rdio-user-link').text(vanityName).wrap("<a href='http://www.rdio.com/people/#{vanityName}/'></a>")
    @hud = new Hud(e: $('.hud'))
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
      when "playStateChange" then @handlePlayStateChange(message.data.state)
      when "playingTrackChange" then @handlePlayingTrackChange(message.data.track)
      else console.log("Invalid event: #{message}")

  handlePlayStateChange: (state) ->
    console.log "Here, I would change the player state to #{state}"
    @hud.updateState(state)
    # TODO
    # if state == 0 then R.player.pause() else R.player.play()

  handlePlayingTrackChange: (track) ->
    console.log "Here, I would trigger R.player.play(source: #{track.key})"
    @hud.updateTrack(track)
    # TODO
    # R.player.play(source: key)

$(document).ready ->
  window.Venyr = new Venyr(type: window.VenyrType)
