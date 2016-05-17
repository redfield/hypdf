# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hypdf/version'

Gem::Specification.new do |gem|
  gem.name          = "hypdf"
  gem.version       = HyPDF::VERSION
  gem.authors       = ["redfield"]
  gem.email         = ["up.redfield@gmail.com"]
  gem.description   = %q{Ruby wrapper around the HyPDF API}
  gem.summary       = %q{Ruby wrapper around the HyPDF API}
  gem.homepage      = "https://bitbucket.org/quantumgears/hypdf_gem"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "httparty", "~> 0.13"
  gem.add_dependency "httmultiparty", "~> 0.3"
  gem.add_development_dependency "rspec"
end
