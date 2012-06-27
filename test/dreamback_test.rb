require "rubygems"
require "json"
require "test/unit"
require File.expand_path('../../lib/dreamback/initializer', __FILE__)
require File.expand_path('../../lib/dreamback/backup', __FILE__)

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

  def test_time_machine_rotate
    folders = [
      "dreamback.20120514",
      "dreamback.20120513",
      "dreamback.20120512",
      "dreamback.20120511",
      "dreamback.20120510",
      "dreamback.20120509",
      "dreamback.20120508",
      "dreamback.20120501",
      "dreamback.20120424",
      "dreamback.20120413",
      "dreamback.20120417",
      "dreamback.20120411",
      "dreamback.20120410",
      "dreamback.20120403",
      "dreamback.20120327",
      "dreamback.20120325",
      "dreamback.20120320",
      "dreamback.20120321",
      "dreamback.20120313",
      "dreamback.20120312",
      "dreamback.20120309",
      "dreamback.20120308",
      "dreamback.20120301",
      "dreamback.20120227",
      "dreamback.20120215",
      "dreamback.20120207",
      "dreamback.20120208"
    ]

    folders_sorted = {
      :keep=>
        [
          "dreamback.20120207",
          "dreamback.20120215",
          "dreamback.20120227",
          "dreamback.20120308",
          "dreamback.20120312",
          "dreamback.20120320",
          "dreamback.20120327",
          "dreamback.20120403",
          "dreamback.20120410",
          "dreamback.20120417",
          "dreamback.20120424",
          "dreamback.20120501",
          "dreamback.20120508",
          "dreamback.20120509",
          "dreamback.20120510",
          "dreamback.20120511",
          "dreamback.20120512",
          "dreamback.20120513",
          "dreamback.20120514"
        ],
     :delete=>
      [
        "dreamback.20120413",
        "dreamback.20120411",
        "dreamback.20120325",
        "dreamback.20120321",
        "dreamback.20120313",
        "dreamback.20120309",
        "dreamback.20120301",
        "dreamback.20120208"
      ]
    }

    today = Date.strptime("20120514", "%Y%m%d")

    assert folders_sorted == Dreamback::Backup.rotate_time_machine(today, folders)
  end

end