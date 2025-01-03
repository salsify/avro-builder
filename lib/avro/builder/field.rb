# frozen_string_literal: true

require 'avro/builder/type_factory'
require 'avro/builder/aliasable'
require 'avro/builder/metadata'

module Avro
  module Builder

    # This class represents a field in a record.
    # A field must be initialized with a type.
    class Field
      include Avro::Builder::DslOptions
      include Avro::Builder::DslAttributes
      include Avro::Builder::Aliasable
      include Avro::Builder::AnonymousTypes
      include Avro::Builder::Metadata

      INTERNAL_ATTRIBUTES = [:optional_field].to_set.freeze

      # These attributes may be set as options or via a block in the DSL
      dsl_attributes :doc, :default, :order

      def initialize(name:, avro_type_or_name:, record:, cache:, internal: {}, options: {}, &block)
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

        # Find existing Type or build a new instance of a builtin Type using
        # the supplied block
        @field_type = type_lookup(avro_type_or_name, namespace) do |avro_type_name|
          create_and_configure_builtin_type(avro_type_name,
                                            field: self,
                                            cache: cache,
                                            internal: internal,
                                            validate_type: false,
                                            options: type_options)
        end

        # DSL calls must be evaluated after the type has been constructed
        instance_eval(&block) if block_given?
        @field_type.validate!
      end

      ## Delegate additional DSL calls to the type

      def respond_to_missing?(id, _include_all)
        field_type.dsl_respond_to?(id) || super
      end

      def method_missing(id, *args, &block)
        field_type.dsl_respond_to?(id) ? field_type.send(id, *args, &block) : super
      end

      def name_fragment
        record.name_fragment
      end

      # Delegate setting namespace explicitly via DSL to type
      # and return the namespace value from the enclosing record.
      def namespace(value = nil)
        if value
          field_type.namespace(value)
        else
          record.namespace
        end
      end

      # Delegate setting name explicitly via DSL to type
      def name(value = nil)
        if value
          field_type.name(value)
        else
          # Return the name of the field
          @name
        end
      end

      def serialize(reference_state)
        attrs = {
          name: name,
          type: serialized_type(reference_state),
          aliases: aliases
        }

        self.class.dsl_attribute_names.each do |attr|
          attrs[attr] = send(attr)
        end

        attrs.reject { |_, v| v.nil? }.tap do |result|
          result.merge!(default: nil) if optional_field
        end
      end

      private

      attr_accessor :field_type, :optional_field, :cache, :record

      # Optional fields must be serialized as a union -- an array of types.
      def serialized_type(reference_state)
        result = field_type.serialize(reference_state)
        optional_field ? field_type.class.union_with_null(result) : result
      end
    end
  end
end
