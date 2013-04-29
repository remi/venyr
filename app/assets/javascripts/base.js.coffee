class Venyr.Base
  constructor: (opts = {}) ->
    @opts = opts
    R.ready(@init)

  init: =>
    return @goHome() if @opts.type and !R.authenticated()
    @broadcaster = new Venyr.Broadcaster if @opts.type == 'broadcast'
    @listener = new Venyr.Listener if @opts.type == 'listen'
    @home = new Venyr.Home if !@opts.type

  authenticate: ->
    R.authenticate (authenticated) =>
      @home.initTemplate() if authenticated

  goHome: ->
    window.location = "/"

  handleFatalError: (data) ->
    $('#content').html('<div class="fatal-error">A fatal error occurred. The application will not work properly. Please contact <a href="mailto:remi@exomel.com">remi@exomel.com</a> if this persists.</div>')
