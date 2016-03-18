module Avro
  module Builder
    # This class represents a record in an Avro schema.
    class Record
      include Avro::Builder::DslAttributes
      include Avro::Builder::Namespaceable

      attr_accessor :builder
      attr_reader :name

      dsl_attributes :doc, :aliases, :namespace

      def initialize(name, options = {})
        @name = name
        options.each do |key, value|
          send(key, value)
        end
      end

      # Add a required field to the record
      def required(name, type_name, options = {}, &block)
        new_field = Avro::Builder::Field.new(name: name,
                                             type_name: type_name,
                                             builder: builder,
                                             internal: { namespace: namespace },
                                             options: options,
                                             &block)
        add_field(new_field)
      end

      # Add an optional field to the record. In Avro this is represented
      # as a union of null and the type specified here.
      def optional(name, type_name, options = {}, &block)
        new_field = Avro::Builder::Field.new(name: name,
                                             type_name: type_name,
                                             builder: builder,
                                             internal: { namespace: namespace,
                                                         optional: true },
                                             options: options,
                                             &block)
        add_field(new_field)
      end

      # Alternate syntax to add a union field
      def union(name, *types, **options, &block)
        required(name, :union, { types: types }.merge(options), &block)
      end

      # Adds fields from the record with the specified name to the current
      # record.
      def extends(name)
        fields.merge!(builder.lookup(name).duplicated_fields)
      end

      def to_h(reference_state = SchemaSerializerReferenceState.new)
        reference_state.definition_or_reference(fullname) do
          {
            type: :record,
            name: name,
            namespace: namespace,
            doc: doc,
            aliases: aliases,
            fields: fields.values.map { |field| field.serialize(reference_state) }
          }.reject { |_, v| v.nil? }
        end
      end

      protected

      def duplicated_fields
        fields.each_with_object(Hash.new) do |(name, field), result|
          field_copy = field.dup
          result[name] = field_copy
        end
      end

      private

      # Add field, replacing any existing field with the same name.
      def add_field(field)
        fields[field.name] = field
      end

      def fields
        @fields ||= {}
      end
    end
  end
end
