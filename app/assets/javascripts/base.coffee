window.Venyr = {}

class Venyr.Base
  constructor: (opts = {}) ->
    @opts = opts
    R.ready(@init)

  init: =>
    return @goHome() if @opts.type != 'home' and !R.authenticated()
    switch @opts.type
      when 'broadcast' then @broadcaster = new Venyr.Broadcaster
      when 'listen' then @listener = new Venyr.Listener
      when 'home' then @home = new Venyr.Home

  authenticate: ->
    R.authenticate (authenticated) =>
      @home.initTemplate() if authenticated

  goHome: ->
    window.location = "/"

  handleFatalError: (data) ->
    $('#content').html('<div class="fatal-error">
      <p><img src="http://i.imgur.com/O6JnKli.png" alt="" /></p>
      <p>A fatal error occurred. The application will not work properly. Please contact <a href="mailto:remi@exomel.com">remi@exomel.com</a> if this persists.</p>
    </div>')
