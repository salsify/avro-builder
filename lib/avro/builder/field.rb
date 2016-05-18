require 'avro/builder/type_factory'

module Avro
  module Builder

    # This class represents a field in a record.
    # A field must be initialized with a type.
    class Field
      include Avro::Builder::DslAttributes
      include Avro::Builder::TypeFactory

      INTERNAL_ATTRIBUTES = Set.new(%i(optional_field)).freeze

      # These attributes may be set as options or via a block in the DSL
      dsl_attributes :doc, :aliases, :default, :order

      def initialize(name:, type_name:, record:, cache:, internal: {}, options: {}, &block)
        @cache = cache
        @record = record
        @name = name.to_s

        internal.each do |key, value|
          send("#{key}=", value) if INTERNAL_ATTRIBUTES.include?(key)
        end

        options.each do |key, value|
          send(key, value) if dsl_attribute?(key)
        end

        @type = if builtin_type?(type_name)
                  create_and_configure_builtin_type(type_name,
                                                    field: self,
                                                    cache: cache,
                                                    internal: internal,
                                                    options: options)
                else
                  named_type = true
                  cache.lookup_named_type(type_name, namespace)
                end

        # DSL calls must be evaluated after the type has been constructed
        instance_eval(&block) if block_given?
        @type.validate!
        @type.cache! unless named_type
      end

      ## Delegate additional DSL calls to the type

      def respond_to_missing?(id, include_all = false)
        super || type.respond_to?(id, include_all)
      end

      def method_missing(id, *args, &block)
        type.respond_to?(id) ? type.send(id, *args, &block) : super
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
