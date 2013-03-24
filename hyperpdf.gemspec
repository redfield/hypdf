# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hyperpdf/version'

Gem::Specification.new do |gem|
  gem.name          = "hyperpdf"
  gem.version       = HyperPDF::VERSION
  gem.authors       = ["redfield"]
  gem.email         = ["up.redfield@gmail.com"]
  gem.description   = %q{Ruby wrapper around the HyperPDF API}
  gem.summary       = %q{Ruby wrapper around the HyperPDF API}
  gem.homepage      = "http://www.hyper-pdf.com"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "httparty", ">=0.10.0"
end
