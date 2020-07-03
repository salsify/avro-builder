# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'json_spec'
require 'rspec/its'
require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
end

require 'avro/builder'

RSpec.configure do |config|
  config.before do
    Avro::Builder::DSL.load_paths.clear
    Avro::Builder.add_load_path('spec/avro/dsl')
  end

  enum_default_supported = Avro::Schema::EnumSchema.instance_methods.include?(:default)

  config.around(:each, :enum_default) do |example|
    # The Avro gem does not correctly set a version :(
    # So check for functionality for examples that require it.
    if enum_default_supported
      example.run
    else
      skip "enum_default not supported by this Avro version"
    end
  end
end
