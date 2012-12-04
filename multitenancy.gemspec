# -*- encoding: utf-8 -*-
require File.expand_path('../lib/multitenancy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["ganeshs"]
  gem.email         = ["ganeshs@flipkart.com"]
  gem.description   = 'Support multitennacy with active record'
  gem.summary       = 'Support multitennacy with active record at tenant and sub-tenant level'
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "multitenancy"
  gem.require_paths = ["lib"]
  gem.version       = Multitenancy::VERSION
end
