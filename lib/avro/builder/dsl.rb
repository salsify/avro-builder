require 'avro'
require 'avro/builder/errors'
require 'avro/builder/dsl_options'
require 'avro/builder/dsl_attributes'
require 'avro/builder/namespaceable'
require 'avro/builder/definition_cache'
require 'avro/builder/type_factory'
require 'avro/builder/anonymous_types'
require 'avro/builder/types'
require 'avro/builder/field'
require 'avro/builder/record'
require 'avro/builder/enum'
require 'avro/builder/fixed'
require 'avro/builder/file_handler'
require 'avro/builder/schema_serializer_reference_state'

module Avro
  module Builder
    # This class is used to construct Avro schemas (not protocols) using a ruby
    # DSL
    class DSL
      include Avro::Builder::DslOptions
      include Avro::Builder::DslAttributes
      include Avro::Builder::FileHandler
      include Avro::Builder::TypeFactory

      dsl_attribute :namespace

      # An instance of the DSL is initialized with a string or a block to
      # evaluate to define Avro schema objects.
      def initialize(str = nil, &block)
        str ? instance_eval(str) : instance_eval(&block)
      end

      # Define an Avro schema record
      def record(name = nil, options = {}, &block)
        create_named_type(name, :record, options, &block)
      end

      # Imports from the file with specified name fragment.
      def import(name)
        previous_namespace = namespace
        result = eval_file(name)
        namespace(previous_namespace)
        result
      end

      ## DSL methods for Types

      def enum(name = nil, *symbols, **options, &block)
        create_named_type(name, :enum, { symbols: symbols }.merge(options), &block)
      end

      def fixed(name = nil, size = nil, options = {}, &block)
        size_option = size.is_a?(Hash) ? size : { size: size }
        create_named_type(name, :fixed, size_option.merge(options), &block)
      end

      # Return the last schema object processed as a Hash representing
      # the Avro schema.
      def to_h
        @last_object.to_h(SchemaSerializerReferenceState.new)
      end

      # Return the last schema object processed as an Avro JSON schema
      def to_json(validate: true, pretty: true)
        hash = to_h
        (pretty ? JSON.pretty_generate(hash) : hash.to_json).tap do |json|
          # Uncomment the next line to debug:
          # puts json
          # Parse the schema to validate before returning
          ::Avro::Schema.parse(json) if validate
        end
      end

      def as_schema
        Avro::Schema.parse(to_json(validate: false))
      end

      private

      def cache
        @cache ||= Avro::Builder::DefinitionCache.new(self)
      end

      def create_named_type(name, avro_type_name, options = {}, &block)
        @last_object = create_and_configure_builtin_type(avro_type_name,
                                                         cache: cache,
                                                         internal: { _name: name,
                                                                     namespace: namespace },
                                                         options: options,
                                                         &block)
      end

      def eval_file(name)
        instance_eval(read_file(name))
      end
    end
  end
end
