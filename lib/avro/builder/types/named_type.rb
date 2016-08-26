require 'avro/builder/namespaceable'
require 'avro/builder/aliasable'
require 'avro/builder/types/named_error_handling'

module Avro
  module Builder
    module Types

      # This is an abstract class that represents a type that can be defined
      # with a name, outside a record.
      class NamedType < Type
        include Avro::Builder::Types::ComplexType
        include Avro::Builder::Namespaceable
        include Avro::Builder::Aliasable

        dsl_option :name, dsl_name: :type_name
        dsl_option :namespace, dsl_name: :type_namespace

        dsl_attribute_alias :type_aliases, :aliases

        # This module most be included after options are defined
        include Avro::Builder::Types::NamedErrorHandling

        def name(value = nil)
          if value.nil?
            @name || "__#{name_fragment}_#{avro_type_name}"
          else
            type_name_instead_of_name_error!
          end
        end

        def namespace(value = nil)
          if value.nil?
            @namespace
          else
            type_namespace_instead_of_namespace_error!
          end
        end

        def validate!
          required_attribute_error!(:name) if field.nil? && @name.nil?
        end

        def cache!
          cache.add_schema_object(self)
        end

        # Named types that do not have an explicit name are assigned
        # a named based on the field and its nesting.
        def name_fragment
          [field && field.name_fragment,
           @name || (field && field.name)].compact.join('_')
        end

        # As a type for a field
        # Subclasses may call super with additional overrides to be added
        # to the serialized value.
        def serialize(reference_state, overrides: {})
          reference_state.definition_or_reference(fullname) do
            serialized_attribute_hash.merge(overrides).reject { |_, v| v.nil? }
          end
        end

        # As a top-level, named type
        # Subclasses may call super with additional overrides to be added
        # to the hash representation.
        def to_h(_reference_state, overrides: {})
          serialized_attribute_hash
            .merge(aliases: aliases)
            .merge(overrides)
            .reject { |_, v| v.nil? }
        end

        private

        def serialized_attribute_hash
          {
            name: name,
            type: avro_type_name,
            namespace: namespace,
            logicalType: logical_type
          }
        end
      end
    end
  end
end
