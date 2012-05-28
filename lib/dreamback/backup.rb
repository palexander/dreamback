require 'net/sftp'

module Dreamback
  class Backup
    BACKUP_FOLDER = "./dreamback"

    # Manage the backup process
    def self.start
      # rotate the backup folders
      backup_to_link = rotate_backups
      # rsync backup of dreamhost user accounts
      rsync_backup(backup_to_link)
      # mysql backup
      # TODO: Add mysql backups
    end

    # Rotate out the backups that are past our limit
    # @returns [String] name of the most recent folder to link against
    def self.rotate_backups
      backup_to_link = ""
      Net::SFTP.start(Dreamback.settings[:backup_server], Dreamback.settings[:backup_server_user]) do |sftp|
        # Create the backup folder if it doesn't exist
        backup_folder_exists = false
        begin
          sftp.stat!(BACKUP_FOLDER) do |response|
            backup_folder_exists = response.ok?
          end
        rescue Net::SFTP::StatusException => e
          backup_folder_exists = false if e.code == 2
        end

        # Get a list of all backup directories
        backup_folders = []
        if backup_folder_exists
          sftp.dir.foreach(BACKUP_FOLDER) do |entry|
            # Names should be like "dreamback.20120520", so we can sort on the folder name
            backup_folders << [ entry.name, entry.name.split(".")[1].to_i ] if entry.name.include?("dreamback")
            backup_folders.sort! {|a,b| b <=> a}
          end
        end

        # Get the newest folder for linking
        backup_to_link = backup_folders.first[0]

        # Delete any folders older than our limit
        # Subtract one to account for the folder we're about to create
        # Normally we remove a folder so that our count is one less than the "days to keep"
        # However, if today's folder already exists then there's no need
        offset = backup_folders.include?("dreamback.#{Time.now.strftime("%Y%m%d")}") ? 0 : 1
        if backup_folders.length >= Dreamback.settings[:days_to_keep] - offset
          folders_to_delete = backup_folders.slice(Dreamback.settings[:days_to_keep] - offset, backup_folders.length)
          folders_to_delete.map! {|f| f[0]}
          rsync_delete(folders_to_delete)
        end
      end
      backup_to_link
    end

    # This uses a hack where we sync an empty directory to remove files
    # We do this because sftp has no recursive delete method
    # @params [Array[String]] list of backup directories
    def self.rsync_delete(directories)
      empty_dir_path = File.expand_path("../.dreamback_empty_dir", __FILE__)
      empty_dir = Dir.mkdir(empty_dir_path) unless File.exists?(empty_dir_path)
      begin
        directories.each do |dir|
          `rsync --delete -a #{empty_dir_path}/ #{Dreamback.settings[:backup_server_user]}@#{Dreamback.settings[:backup_server]}:#{BACKUP_FOLDER}/#{dir}`
          Net::SFTP.start(Dreamback.settings[:backup_server], Dreamback.settings[:backup_server_user]) do |sftp|
            sftp.rmdir!("#{BACKUP_FOLDER}/#{dir}")
          end
        end
      ensure
        Dir.delete(empty_dir_path)
      end
    end

    # Sync to the backup server using link-dest to save space
    # @param [String] name of the most recent backup folder prior to starting this run to link against
    def self.rsync_backup(link_dir)
      tmp_dir_path = "~/.dreamback_tmp"
      user_exclusions_path = File.expand_path("~/.dreamback_exclusions")
      default_exclusions_path = File.expand_path("../exclusions.txt", __FILE__)
      exclusions_path = File.exists?(user_exclusions_path) ? user_exclusions_path : default_exclusions_path
      begin
        backup_server_user = Dreamback.settings[:backup_server_user]
        backup_server = Dreamback.settings[:backup_server]
        today = Time.now.strftime("%Y%m%d")
        Dreamback.settings[:dreamhost_users].each do |dreamhost|
          # User that we're going to back up
          user = dreamhost[:user]
          server = dreamhost[:server]
          # rsync won't do remote<->remote syncing, so we stage everything here first
          tmp_dir = File.expand_path(tmp_dir_path)
          Dir.mkdir(tmp_dir) unless File.exists?(tmp_dir)
          `rsync -e ssh -av --keep-dirlinks --exclude-from #{exclusions_path} --copy-links #{user}@#{server}:~/ #{tmp_dir}/#{user}@#{server}`
          # Now we can sync local to remote. Only use link-dest if a previous folder to link to exists.
          link_dest = link_dir.nil? ? "" : "--link-dest=~#{BACKUP_FOLDER.gsub(".", "")}/#{link_dir}"
          `rsync -e ssh -av --delete --copy-links --keep-dirlinks #{link_dest} #{tmp_dir}/ #{backup_server_user}@#{backup_server}:#{BACKUP_FOLDER}/dreamback.#{today}`
        end
      ensure
        # Remove the staging directory
        `rm -rf #{File.expand_path(tmp_dir_path)}`
      end
    end
  end
end