$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'json_spec'
require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
end

require 'avro/builder'

RSpec.configure do |config|
  config.before do
    Avro::Builder.add_load_path('spec/avro/dsl')
  end
end
