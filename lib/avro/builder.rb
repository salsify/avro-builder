require 'avro/builder/version'
require 'avro/builder/dsl'

# Things to do:
# - support for error? (useful outside protocol?)
# - support for union
# - support for logical types
# - nested record support
# - add more validations?

module Avro
  module Builder

    # Accepts a string or block to eval to define a JSON schema
    def self.build(str = nil, &block)
      Avro::Builder::DSL.new(str, &block).to_json
    end

    # Accepts a string or block to eval and returns an Avro::Schema
    def self.build_schema(str = nil, &block)
      Avro::Builder::DSL.new(str, &block).as_schema
    end
  end
end
