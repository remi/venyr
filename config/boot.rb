require 'dotenv'
Dotenv.load

# Bundler setup
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
Bundler.require(:default, ENV['RACK_ENV']) if defined? Bundler

# Require sinatra-contrib modules
require "sinatra/content_for"

# Require libraries
Dir[File.expand_path('../../lib/**/*.rb', __FILE__)].each do |file|
  dirname = File.dirname(file)
  file_basename = File.basename(file, File.extname(file))
  require "#{dirname}/#{file_basename}"
end

# Require helpers
Dir[File.expand_path('../../app/helpers/**/*.rb', __FILE__)].each do |file|
  dirname = File.dirname(file)
  file_basename = File.basename(file, File.extname(file))
  require "#{dirname}/#{file_basename}"
end

# Redis
uri = URI.parse ENV["REDISTOGO_URL"] || ENV['REDIS_URL'] || 'redis://127.0.0.1:6379/1'
REDIS = Redis.new(host: uri.host, port: uri.port, password: uri.password)

# Application setup
ENV['CANONICAL_HOST'] || raise(StandardError.new "You must provide a “CANONICAL_HOST” environment variable.")
ENV['RDIO_CLIENT_ID'] || raise(StandardError.new "You must provide a “RDIO_CLIENT_ID” environment variable.")
require File.expand_path('../application',  __FILE__)
