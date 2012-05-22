require "rubygems"
require "test/unit"
require File.expand_path('../../lib/dreamback/initializer', __FILE__)
require "json"

# Used for testing private methods
class Class
  def publicize_methods
    saved_private_instance_methods = self.private_instance_methods
    self.class_eval { public *saved_private_instance_methods }
    yield
    self.class_eval { private *saved_private_instance_methods }
  end
end

class DreambackTest < Test::Unit::TestCase

  def test_settings_save
    settings = {:testing_settings_save => "worked"}
    settings_file = File.open("./test_settings.json", "w+")
    Dreamback::Initializer.publicize_methods do
      Dreamback::Initializer.settings = settings
      Dreamback::Initializer.save_settings(settings_file.path)
    end
    settings_new = JSON.parse(settings_file.read, :symbolize_names => true)
    assert_equal settings, settings_new
    settings_file.close
    File.delete(settings_file.path)
  end

  def test_settings_load
    file = File.open(File.expand_path('../mock/settings.json', __FILE__), "r")
    settings_file = Dreamback::Initializer.load_settings(file.path)
    settings_test =<<-EOS
      {
        "backup_server_user": "blah",
        "dreamhost_users": [
          {
            "user": "u",
            "server": "d1.dev"
          },
          {
            "user": "u2",
            "server": "d2.dev"
          },
          {
            "user": "u3",
            "server": "d3.dev"
          }
        ],
        "days_to_keep": 7,
        "backup_server": "backup.dev"
      }
    EOS
    assert_equal settings_file, JSON.parse(settings_test, :symbolize_names => true)
  end

end