# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tai64/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Craig R Webster"]
  gem.email         = ["craig@barkingiguana.com"]
  gem.description   = %q{Work with TAI64 timestamps}
  gem.summary       = %q{Work with TAI64 timestamps}
  gem.homepage      = "http://cr.yp.to/libtai/tai64.html"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tai64"
  gem.require_paths = ["lib"]
  gem.version       = Tai64::VERSION
end
