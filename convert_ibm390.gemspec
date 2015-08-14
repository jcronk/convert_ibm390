# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'convert/ibm390/version'

Gem::Specification.new do |spec|
  spec.name          = "convert_ibm390"
  spec.version       = Convert::IBM390::VERSION
  spec.authors       = ["Jeremy Cronk"]
  spec.email         = ["jcronk@nxtechcorp.com"]
  spec.summary       = %q{ Module methods for converting mainframe data }
  spec.description   = %q{ Convert regular EBCDIC to ASCII, convert zoned and packed fields. }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
