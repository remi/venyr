window.Venyr = {}

class Venyr.Base
  constructor: (opts = {}) ->
    @debug = false
    @opts = opts
    @fatalError = false
    R.ready(@init)

  init: =>
    return @goHome() if @opts.type != 'home' and !R.authenticated()
    switch @opts.type
      when 'broadcast' then @broadcaster = new Venyr.Broadcaster
      when 'listen' then @listener = new Venyr.Listener
      when 'home' then @home = new Venyr.Home

  authenticate: ->
    R.authenticate (authenticated) =>
      if authenticated
        returnTo = window.location.search.split("?return_to=")[1]
        if returnTo && returnTo.match(/^\//)
          window.location = returnTo
        else
          @home.initTemplate()

  goHome: ->
    window.location = "/?return_to=#{window.location.pathname}"

  handleFatalError: (data) ->
    @fatalError = true
    $('#content').html('<div class="fatal-error">
      <p><img src="http://i.imgur.com/O6JnKli.png" alt="" /></p>
      <p>A fatal error occurred. The application will not work properly. Please contact <a href="mailto:remi@exomel.com">remi@exomel.com</a> if this persists.</p>
    </div>')
