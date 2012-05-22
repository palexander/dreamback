require 'json'

module Dreamback
  @settings

  def self.settings
    @settings
  end

  def self.settings=(settings)
    @settings=settings
  end

  class Initializer
    SETTINGS_LOCATION = File.expand_path("~/.dreamback")

    DEFAULT_SETTINGS = {
      :backup_server => "",
      :backup_server_user => "",
      :dreamhost_users => [ {:user => "", :server => ""} ]
    }

    @settings = {}

    # Walks a user through the initial setup process
    def self.setup
      # Check to see if settings exist
      load_settings(SETTINGS_LOCATION)

      # Ask user questions if no settings file
      if @settings.nil? || @settings.empty?
        create_new_settings
        save_settings(SETTINGS_LOCATION)
      end

      # Create ssh keys if they don't exist
      ssh_keys_exist = File.exists?(File.expand_path("~/.ssh/id_rsa"))
      create_ssh_keys unless ssh_keys_exist

      # Copy ssh keys to backup server
      unless @settings[:copied_backup_server_ssh_keys]
        say(bold("Copying the ssh key to your backup server, type in your password when prompted for #{@settings[:backup_server_user]}@#{@settings[:backup_server]}"))
        `ssh-copy-id -i #{@settings[:backup_server_user]}@#{@settings[:backup_server]}`
        @settings[:copied_backup_server_ssh_keys] = true
      end

      # Copy ssh keys to dreamhost servers
      unless @settings[:copied_dreamhost_users_ssh_keys]
        say(bold("Copying the ssh key to the dreamhost accounts you want to back up"))
        @settings[:dreamhost_users].each do |dreamhost|
          say(bold("Type in password for #{dreamhost[:user]}@#{dreamhost[:server]}"))
          `ssh-copy-id -i #{dreamhost[:user]}@#{dreamhost[:server]}`
        end
        @settings[:copied_dreamhost_users_ssh_keys] = true
      end

      save_settings(SETTINGS_LOCATION)

      # Set global settings
      Dreamback.settings = @settings
    end

    private

    # Ask the user for settings
    def self.create_new_settings
      settings = {}
      say("#{bold("Server Where We Should Store Your Backup")}\nYour dreamhost backup-specific account will work best, but any POSIX server with rsync should work\n<%= color('Note:', BOLD)%> dreamhost does not allow you to store non-webhosted data except your BACKUP-SPECIFIC account")
      settings[:backup_server] = ask("Server name: ")
      settings[:backup_server_user] = ask(bold("Username for the backup server: "))
      settings[:dreamhost_users] = []
      another_user = true
      while another_user
        dreamhost = {}
        dreamhost[:user] = ask(bold("Dreamhost user to back up: "))
        dreamhost[:server] = ask(bold("Server where the dreamhost user is located: "))
        settings[:dreamhost_users] << dreamhost
        another_user = agree(bold("Add another dreamhost account? [y/n]"))
      end
      settings[:days_to_keep] = ask(bold("How many days of backups do you want to keep [1-30]? "), Integer) {|q| q.in = 1..30}
      @settings = settings
    end

    # Create ssh keys for user when they don't exist
    def self.create_ssh_keys
      ssh_key_location = File.expand_path("~/.ssh/id_rsa")
      say(bold("You are missing an RSA ssh key for this user at #{ssh_key_location}, we will create one now"))
      say(bold("More on creating ssh keys here: http://en.wikipedia.org/wiki/ssh-keygen"))
      `ssh-keygen -t rsa`
      success = File.exists?(ssh_key_location)
      if success
        say(bold("Key created successfully"))
      else
        agree(bold("It looks like the ssh key creation failed, try again? [y/n]"))
      end
    end

    # Load settings from a JSON file
    # @param [String] path where settings are located
    def self.load_settings(settings_path)
      settings_file = File.open(settings_path, "r") if File.exists?(settings_path)
      @settings = JSON.parse(settings_file.read, :symbolize_names => true) unless settings_file.nil?
      settings_file.close unless settings_file.nil?
      @settings
    end

    # Store settings from a JSON file
    # @param [String] path where settings are located
    def self.save_settings(settings_path)
      settings = @settings ||= ""
      settings_file = File.open(settings_path, "w+")
      settings_file << JSON.pretty_generate(settings)
      settings_file.close
      true
    end

    # Setter used primarily in testing
    def self.settings=(settings)
      @settings = settings
    end

    def self.bold(text)
      "<%= color('\n#{text.gsub("'", "\\'")}', BOLD) %>"
    end

  end

end