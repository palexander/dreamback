# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dreamback/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Paul R Alexander"]
  gem.email         = ["palexander@stanford.edu"]
  gem.description   = %q{The easiest, cheapest way to back up your dreamhost accounts}
  gem.summary       = %q{Dreamback is the easiest way to automate your backups on dreamhost. Dreamhost does not guarantee their backups of your users (though they've saved me with backups before), so it's best to run backups yourself.}
  gem.homepage      = "https://github.com/palexander/dreamback"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "dreamback"
  gem.require_paths = ["lib"]
  gem.version       = Dreamback::VERSION

  gem.add_dependency("json")
  gem.add_dependency("net-sftp")
  gem.add_dependency("cronedit")
  gem.add_dependency("commander")

  gem.executables = %w(dreamback)
end
