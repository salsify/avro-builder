require 'avro'
require 'avro/builder/dsl_attributes'
require 'avro/builder/namespaceable'
require 'avro/builder/type_factory'
require 'avro/builder/types'
require 'avro/builder/field'
require 'avro/builder/file_handler'
require 'avro/builder/schema_serializer_reference_state'

module Avro
  module Builder
    # This class is used to construct Avro schemas (not protocols) using a ruby
    # DSL
    class DSL
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
      def record(name, options = {}, &block)
        create_named_type(name, :record, options, &block)
      end

      # Imports from the file with specified name fragment.
      def import(name)
        previous_namespace = namespace
        eval_file(name)
        namespace(previous_namespace)
      end

      ## DSL methods for Types

      def enum(name, *symbols, **options, &block)
        create_named_type(name, :enum, { symbols: symbols }.merge(options), &block)
      end

      def fixed(name, size = nil, options = {}, &block)
        size_option = size.is_a?(Hash) ? size : { size: size }
        create_named_type(name, :fixed, size_option.merge(options), &block)
      end

      # Lookup an Avro schema object by name, possibly fully qualified by namespace.
      def lookup_named_type(key)
        key_str = key.to_s
        object = schema_objects[key_str]

        unless object
          import(key)
          object = schema_objects[key_str]
        end

        raise "Schema object #{key} not found" unless object
        object
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

      def builder
        self
      end

      def schema_objects
        @schema_objects ||= {}
      end

      def add_schema_object(object)
        @last_object = object
        schema_objects[object.name.to_s] = object
        schema_objects[object.fullname] = object if object.namespace
      end

      def create_named_type(name, type_name, options = {}, &block)
        create_and_configure_builtin_type(type_name,
                                          builder: self,
                                          internal: { name: name, namespace: namespace },
                                          options: options,
                                          &block).tap do |type|
          add_schema_object(type)
        end
      end

      def eval_file(name)
        instance_eval(read_file(name))
      end
    end
  end
end
