require "capistrano/setup"
require "capistrano/deploy"
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git
require 'capistrano/rails'
require "capistrano/bundler"
require "capistrano/rvm"
require 'capistrano/puma'
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Daemon
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require 'capistrano/delayed_job'
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
