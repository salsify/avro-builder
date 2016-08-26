require 'avro/builder/version'
require 'avro/builder/dsl'
require 'avro/builder/schema_store'

module Avro
  module Builder

    # Accepts a string or block to eval to define a JSON schema
    def self.build(str = nil, filename: nil, &block)
      Avro::Builder::DSL.new(str, filename: filename, &block).to_json
    end

    # Accepts a string or block to eval and returns an Avro::Schema
    def self.build_schema(str = nil, filename: nil, &block)
      Avro::Builder::DSL.new(str, filename: filename, &block).as_schema
    end

    # Add paths that will be searched for definitions
    def self.add_load_path(*paths)
      Avro::Builder::DSL.load_paths.merge(paths)
    end
  end
end

require 'avro/builder/railtie' if defined?(Rails)
