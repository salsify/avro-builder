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
end
