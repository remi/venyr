# Bundler setup
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
Bundler.require(:default, ENV['RACK_ENV']) if defined? Bundler

# Require sinatra-contrib modules
require "sinatra/content_for"

# Require models
Dir[File.expand_path('../../app/models/**/*.rb', __FILE__)].each do |file|
  dirname = File.dirname(file)
  file_basename = File.basename(file, File.extname(file))
  require "#{dirname}/#{file_basename}"
end

# Application setup
ENV['CANONICAL_HOST'] || raise(StandardError.new "You must provide a “CANONICAL_HOST” environment variable.")
ENV['RDIO_CLIENT_ID'] || raise(StandardError.new "You must provide a “RDIO_CLIENT_ID” environment variable.")
ENV['FOO'] || raise(StandardError.new "You must provide a “FOO” environment variable.")
require File.expand_path('../application',  __FILE__)
