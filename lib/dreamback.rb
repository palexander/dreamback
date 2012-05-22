#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require File.expand_path('../dreamback/version.rb', __FILE__)
require File.expand_path('../dreamback/initializer.rb', __FILE__)
require File.expand_path('../dreamback/backup.rb', __FILE__)

program :version, Dreamback::VERSION
program :description, 'Automated backup for dreamhost accounts'

command :start do |c|
  c.syntax = 'dreamback start [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    Dreamback::Initializer.setup
    puts Dreamback.settings.inspect
  end
end

command :backup do |c|
  c.syntax = 'dreamback backup [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.action do |args, options|
    Dreamback::Initializer.setup
    Dreamback::Backup.start
  end
end

