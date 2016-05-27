require 'avro/builder/type_factory'
require 'avro/builder/aliasable'

module Avro
  module Builder

    # This class represents a field in a record.
    # A field must be initialized with a type.
    class Field
      include Avro::Builder::DslOptions
      include Avro::Builder::DslAttributes
      include Avro::Builder::TypeFactory
      include Avro::Builder::Aliasable

      INTERNAL_ATTRIBUTES = %i(optional_field).to_set.freeze

      # These attributes may be set as options or via a block in the DSL
      dsl_attributes :doc, :default, :order

      def initialize(name:, avro_type_name:, record:, cache:, internal: {}, options: {}, &block)
        @cache = cache
        @record = record
        @name = name.to_s

        internal.each do |key, value|
          send("#{key}=", value) if INTERNAL_ATTRIBUTES.include?(key)
        end

        type_options = options.dup
        options.keys.each do |key|
          send(key, type_options.delete(key)) if dsl_attribute?(key)
        end

        @type = if builtin_type?(avro_type_name)
                  create_and_configure_builtin_type(avro_type_name,
                                                    field: self,
                                                    cache: cache,
                                                    internal: internal,
                                                    options: type_options)
                else
                  cache.lookup_named_type(avro_type_name, namespace)
                end

        # DSL calls must be evaluated after the type has been constructed
        instance_eval(&block) if block_given?
        @type.validate!
      end

      ## Delegate additional DSL calls to the type

      def respond_to_missing?(id, _include_all)
        type.dsl_respond_to?(id) || super
      end

      def method_missing(id, *args, &block)
        type.dsl_respond_to?(id) ? type.send(id, *args, &block) : super
      end

      def name_fragment
        record.name_fragment
      end

      # Delegate setting namespace explicitly via DSL to type
      # and return the namespace value from the enclosing record.
      def namespace(value = nil)
        if value
          type.namespace(value)
        else
          record.namespace
        end
      end

      # Delegate setting name explicitly via DSL to type
      def name(value = nil)
        if value
          type.name(value)
        else
          # Return the name of the field
          @name
        end
      end

      def serialize(reference_state)
        # TODO: order is not included here
        {
          name: name,
          type: serialized_type(reference_state),
          doc: doc,
          default: default,
          aliases: aliases
        }.reject { |_, v| v.nil? }.tap do |result|
          result.merge!(default: nil) if optional_field
        end
      end

      private

      attr_accessor :type, :optional_field, :cache, :record

      # Optional fields must be serialized as a union -- an array of types.
      def serialized_type(reference_state)
        result = type.serialize(reference_state)
        optional_field ? type.class.union_with_null(result) : result
      end
    end
  end
end
