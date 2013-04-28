# Bundler setup
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
Bundler.require(:default, ENV['RACK_ENV']) if defined? Bundler

# Require sinatra-contrib modules
require "sinatra/content_for"

# Application setup
ENV['CANONICAL_HOST'] ||= ENV['RACK_ENV'] == 'development' ? '0.0.0.0' : 'myapplication.com'
require File.expand_path('../application',  __FILE__)