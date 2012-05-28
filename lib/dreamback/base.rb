program :version, Dreamback::VERSION
program :description, 'Automated backup for dreamhost accounts'

default_command :setup

command :setup do |c|
  c.syntax = 'dreamback start [options]'
  c.summary = 'This will guide you through setting up Dreamback'
  c.action do |args, options|
    Dreamback::Initializer.setup(true)
  end
end

command :backup do |c|
  c.syntax = 'dreamback backup'
  c.summary = 'Run a backup process immediately. This command can also be added to a cron job.'
  c.action do |args, options|
    Dreamback::Initializer.setup
    Dreamback::Backup.start
  end
end

