module Avro
  module Builder
    module Types
      # This class represents a record in an Avro schema. Records may be defined
      # at the top-level or as the type for a field in a record.
      class RecordType < Avro::Builder::Types::NamedType

        dsl_attributes :doc

        def initialize(name = nil, options: {}, cache:, field: nil, &block)
          @type_name = :record
          @name = name
          @cache = cache
          @field = field

          configure_options(options)
          instance_eval(&block) if block_given?
        end

        # Add a required field to the record
        def required(name, type_name, options = {}, &block)
          new_field = Avro::Builder::Field.new(name: name,
                                               type_name: type_name,
                                               record: self,
                                               cache: cache,
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
                                               record: self,
                                               cache: cache,
                                               internal: { namespace: namespace,
                                                           optional_field: true },
                                               options: options,
                                               &block)
          add_field(new_field)
        end

        # Adds fields from the record with the specified name to the current
        # record.
        def extends(name)
          fields.merge!(cache.lookup_named_type(name, namespace).duplicated_fields)
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
        alias_method :serialize, :to_h

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
end
