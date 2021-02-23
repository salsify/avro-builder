# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'avro/builder/version'

Gem::Specification.new do |spec|
  spec.name          = 'avro-builder'
  spec.version       = Avro::Builder::VERSION
  spec.authors       = ['Salsify Engineering']
  spec.email         = ['engineering@salsify.com']

  spec.summary       = 'Ruby DSL to create Avro schemas'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/salsify/avro-builder.git'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6'

  spec.add_runtime_dependency 'avro', '>= 1.9.0', '< 1.11'

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'json_spec'
  spec.add_development_dependency 'overcommit'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'salsify_rubocop', '~> 1.0.1'
  spec.add_development_dependency 'simplecov'
end
