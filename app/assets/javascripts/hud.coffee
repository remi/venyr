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
      @trackIcon.attr('src', track.icon).show()
      @trackURL.attr('href', "http://www.rdio.com#{track.url}")

  updateState: (state) ->
    @$e.toggleClass('paused', state == 0)
    @$e.toggleClass('stopped', state == 2)
    @clear() if state == 2

  clear: ->
    @$e.addClass('stopped')
    @trackName.text("")
    @trackArtist.text("")
    @trackAlbum.text("")
    @trackIcon.removeAttr('src').hide()
    @trackURL.attr('href', '')
