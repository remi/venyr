class Venyr.Home
  constructor: ->
    @initTemplate()
    @initEvents()

  initTemplate: ->
    if R.authenticated()
      $('.loading').hide()
      $('.unauthenticated-content').hide()
      $('.authenticated-content').show()
    else
      $('.loading').hide()
      $('.unauthenticated-content').show()

  initEvents: ->
    $('.rdio-login a').bind 'click', -> Venyr.App.authenticate()
    $('form').bind 'submit', (e) ->
      e.target.setAttribute('action', e.target.getAttribute('action').replace(/%user/, $('#listen-user').val()))
