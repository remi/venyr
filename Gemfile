source 'https://rubygems.org'
ruby '2.0.0'

# Server
gem 'thin', require: false

# Web
gem 'sinatra'
gem 'sinatra-partial', require: 'sinatra/partial'
gem 'sinatra-contrib', require: false
gem 'rack-canonical-host'

# Sockets
gem 'sinatra-websocket'
gem 'multi_json'
gem 'yajl-ruby'

# Assets
gem 'haml'
gem 'sprockets-helpers'

group :assets do
  gem 'coffee-script'
  gem 'sass'
  gem 'sprockets-sass'
end

group :development do
  gem 'shotgun', require: false
  gem 'capistrano', require: false
  gem 'capistrano_colors', require: false
end
