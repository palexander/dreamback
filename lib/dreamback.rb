# Use this file with a regular ruby setup (IE not from command line or bin/dreamback)

begin
  # Try loading without rubygems
  require 'commander/import'
  require 'dreamback/version'
  require 'dreamback/initializer'
  require 'dreamback/backup'
  require 'dreamback/base'
rescue LoadError
  # If that fails, then load with it
  require 'rubygems'
  require 'commander/import'
  require File.expand_path('../dreamback/version.rb', __FILE__)
  require File.expand_path('../dreamback/initializer.rb', __FILE__)
  require File.expand_path('../dreamback/backup.rb', __FILE__)
  require File.expand_path('../dreamback/base.rb', __FILE__)
end