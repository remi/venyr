source "http://rubygems.org"
ruby "1.9.3"

# Server
gem "unicorn"

# Web
gem "sinatra"
gem "rack"
gem "sinatra-partial", :require => "sinatra/partial"
gem "sinatra-contrib", :require => false
gem "rack-canonical-host"

# Assets
gem "haml"
gem "sprockets-helpers"

group :assets do
  gem 'coffee-script'
  gem "sass"
  gem "sprockets"
  gem "sprockets-sass"
end

group :development do
  gem "shotgun"
  gem "thin"
end
