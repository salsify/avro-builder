require 'avro/builder/type_factory'

module Avro
  module Builder

    # This class represents a field in a record.
    # A field must be initialized with a type.
    class Field
      include Avro::Builder::DslAttributes
      include Avro::Builder::Namespaceable
      include Avro::Builder::TypeFactory

      INTERNAL_ATTRIBUTES = Set.new(%i(optional)).freeze

      attr_accessor :type, :optional, :builder

      # These attributes may be set as options or via a block in the DSL
      dsl_attributes :doc, :aliases, :default, :order

      def initialize(name:, type_name:, builder:, internal: {}, options: {}, &block)
        @builder = builder
        @name = name.to_s

        internal.each do |key, value|
          send("#{key}=", value) if INTERNAL_ATTRIBUTES.include?(key)
        end

        options.each do |key, value|
          send(key, value) if has_dsl_attribute?(key)
        end

        @type = builder.lookup(type_name, required: false) ||
          build_type(type_name, field: self, internal: internal, options: options)

        # DSL calls must be evaluated after the type has been constructed
        instance_eval(&block) if block_given?
      end

      ## Delegate additional DSL calls to the type

      def respond_to_missing?(id, include_all = false)
        super || type.respond_to?(id, include_all)
      end

      def method_missing(id, *args)
        type.respond_to?(id) ? type.send(id, *args) : super
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
        }.reject { |_, v| v.nil? }
      end

      private

      # Optional types must be serialized as an array.
      def serialized_type(reference_state)
        result = type.serialize(reference_state)
        optional ? [:null, result] : result
      end
    end
  end
end
