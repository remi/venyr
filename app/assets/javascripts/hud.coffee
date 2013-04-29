class Venyr.Hud
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
