require 'avro/builder/types/configurable_type'
require 'avro/builder/namespaceable'
require 'avro/builder/aliasable'

module Avro
  module Builder
    module Types

      # This is an abstract class that represents a type that can be defined
      # with a name, outside a record.
      class NamedType < Type
        include Avro::Builder::Types::ComplexType
        include Avro::Builder::Namespaceable
        include Avro::Builder::Types::ConfigurableType
        include Avro::Builder::Aliasable

        dsl_option :namespace

        dsl_option :name do |value = nil|
          if value
            @name = value
          else
            @name || "__#{name_fragment}_#{type_name}"
          end
        end

        dsl_attribute_alias :type_aliases, :aliases

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
            {
              name: name,
              type: type_name,
              namespace: namespace
            }.merge(overrides).reject { |_, v| v.nil? }
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
          }.merge(overrides).reject { |_, v| v.nil? }
        end
      end
    end
  end
end
