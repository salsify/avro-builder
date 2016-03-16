require 'avro/builder/types/configurable_type'

module Avro
  module Builder
    module Types

      # This is an abstract class that represents a type that can be defined
      # with a name, outside a record.
      class NamedType < Type
        include Avro::Builder::Types::SpecificType
        include Avro::Builder::Namespaceable
        include Avro::Builder::Types::ConfigurableType

        dsl_attributes :name, :namespace, :aliases

        def generated_name
          name || "__#{field.name}_#{type_name}"
        end

        # As a type for a field
        # Subclasses may call super with additional overrides to be added
        # to the serialized value.
        def serialize(reference_state, overrides: {})
          reference_state.definition_or_reference(fullname) do
            {
              name: generated_name,
              type: type_name,
              namespace: namespace
            }.merge(overrides).compact
          end
        end

        # As a top-level, named type
        # Subclasses may call super with additional overrides to be added
        # to the hash representation.
        def to_h(_reference_state, overrides: {})
          {
            name: name,
            type: type_name,
            namespace: namespace,
            aliases: aliases
          }.merge(overrides).compact
        end
      end
    end
  end
end
