# frozen_string_literal: true

require 'avro/builder/namespaceable'
require 'avro/builder/aliasable'
require 'avro/builder/types/named_error_handling'

module Avro
  module Builder
    module Types

      # This is an abstract class that represents a type that can be defined
      # with a name, outside a record.
      class NamedType < ComplexType
        include Avro::Builder::Namespaceable
        include Avro::Builder::Aliasable

        dsl_option :name, dsl_name: :type_name
        dsl_option :namespace, dsl_name: :type_namespace

        dsl_attribute_alias :type_aliases, :aliases

        # This module must be included after options are defined
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
        def serialize(reference_state)
          # Return the full type definition if it hasn't been seen yet.
          # Otherwise, just return its name.
          reference_state.definition_or_reference(fullname) do
            super
          end
        end

        # As a top-level, named type
        def to_h(reference_state)
          # Always return the type definition. It's an error if the type has already been seen.
          reference_state.definition(fullname) do
            super
          end
        end

        private

        def serialized_attribute_hash(_reference_state)
          super.merge(
            name: name,
            namespace: namespace,
            aliases: aliases
          )
        end
      end
    end
  end
end
