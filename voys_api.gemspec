# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'voys_api/version'

Gem::Specification.new do |spec|
  spec.name          = "voys_api"
  spec.version       = VoysApi::VERSION
  spec.authors       = ["Joost Hietbrink"]
  spec.email         = ["joost@joopp.com"]
  spec.description   = %q{Export calls from http://www.voys.nl.}
  spec.summary       = %q{Export calls from http://www.voys.nl.}
  spec.homepage      = "https://github.com/joost/voys_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'mechanize'
end
