# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'convert/ibm390/version'

Gem::Specification.new do |spec|
  spec.name          = 'convert_ibm390'
  spec.version       = Convert::IBM390::VERSION
  spec.authors       = ['Jeremy Cronk']
  spec.email         = ['jcronk@nxtechcorp.com']
  spec.summary       = ' Module methods for converting mainframe data '
  spec.description   = ' Convert regular EBCDIC to ASCII, convert zoned and packed fields. '
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'guard-yard'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-byebug'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'shoulda-context'
  spec.add_development_dependency 'yard'
end
