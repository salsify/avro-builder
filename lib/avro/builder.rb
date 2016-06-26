require 'avro/builder/version'
require 'avro/builder/dsl'
require 'avro/builder/schema_store'

module Avro
  module Builder
    class SchemaError < StandardError; end

    def self.find(filename)
      Avro::Builder::DSL.new(filename: filename).as_schema
    end

    # Accepts a string or block to eval to define a JSON schema
    def self.build(str = nil, &block)
      Avro::Builder::DSL.new(str, &block).to_json
    end

    # Accepts a string or block to eval and returns an Avro::Schema
    def self.build_schema(str = nil, &block)
      Avro::Builder::DSL.new(str, &block).as_schema
    end

    # Add paths that will be searched for definitions
    def self.add_load_path(*paths)
      Avro::Builder::DSL.load_paths.merge(paths)
    end
  end
end
