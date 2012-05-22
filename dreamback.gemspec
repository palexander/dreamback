# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dreamback/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Paul R Alexander"]
  gem.email         = ["palexander@stanford.edu"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "dreamback"
  gem.require_paths = ["lib"]
  gem.version       = Dreamback::VERSION

  gem.add_dependency("json")
  gem.add_dependency("net-sftp")
  gem.add_dependency("cronedit")
end
