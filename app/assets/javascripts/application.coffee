//= require 'base'
//= require 'home'
//= require 'broadcaster'
//= require 'listener'
//= require 'hud'

$(document).ready -> Venyr.App = new Venyr.Base(type: $('#content').data('type'))
