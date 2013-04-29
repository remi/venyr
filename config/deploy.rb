require 'capistrano_colors'
require "bundler/capistrano"
set :bundle_without, [:test]

ssh_options[:forward_agent] = true
default_run_options[:pty] = true

set :application, "venyr"
set :repository, "git@github.com:remiprev/venyr.git"
set :user, "ubuntu"

set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache
set :use_sudo, false

set :default_environment, { 'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH" }
set :deploy_to, "/home/ubuntu/apps/venyr-production"
set :ports, %w(6000)

role :app, "venyr-prod"

namespace :deploy do
  desc "Start the app"
  task :start, :roles => :app do
    ports.each do |port|
      run "cd #{current_path} && bundle exec thin start -C #{current_path}/config/thin.yml --port #{port} --environment production"
    end
  end

  desc "Stop the app"
  task :stop, :roles => :app do
    ports.each do |port|
      run "cd #{current_path} && bundle exec thin stop -C #{current_path}/config/thin.yml --port #{port} --environment production"
    end
  end

  desc "Restart the app"
  task :restart, :roles => :app do
    ports.each_with_index do |port, index|
      run "cd #{current_path} && bundle exec thin restart -C #{current_path}/config/thin.yml --port #{port} --environment production"
    end
  end

  desc "Replace paths in thin.yml"
  task :thin_config, :roles => :app do
    run "sed -i 's/DEPLOY_SHARED_PATH/#{shared_path.gsub(/\//,"\\/")}/g' #{current_path}/config/thin.yml"
    run "sed -i 's/DEPLOY_RELEASE_PATH/#{release_path.gsub(/\//,"\\/")}/g' #{current_path}/config/thin.yml"
    run "sed -i 's/DEPLOY_CURRENT_PATH/#{current_path.gsub(/\//,"\\/")}/g' #{current_path}/config/thin.yml"
  end

  desc "Remove git crumbles"
  task :git_clean, :roles => :app do
    run "rm -fr `find #{deploy_to}/releases -iname \".git*\"`"
  end

  after "deploy:create_symlink" do
    git_clean
    thin_config
  end
end
